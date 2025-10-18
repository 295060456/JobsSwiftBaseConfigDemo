import UIKit
import WebKit
import UniformTypeIdentifiers
import SnapKit

public typealias NativeHandler = (_ payload: Any?, _ reply: @escaping (Any?) -> Void) -> Void

// 任意 JSON 解码容器（备用）
public struct AnyDecodable: Decodable {
    public let value: Any
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { value = NSNull() }
        else if let v = try? c.decode(Bool.self)   { value = v }
        else if let v = try? c.decode(Int.self)    { value = v }
        else if let v = try? c.decode(Double.self) { value = v }
        else if let v = try? c.decode(String.self) { value = v }
        else if let v = try? c.decode([AnyDecodable].self) { value = v.map { $0.value } }
        else if let v = try? c.decode([String: AnyDecodable].self) { value = v.mapValues { $0.value } }
        else { throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unsupported JSON") }
    }
}

// iOS < 14 的弱代理封装
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}

// 用 keyPath 显式取系统的 name，规避你工程里的全局 name 扩展
private typealias WKSM = WebKit.WKScriptMessage
private extension WKSM { var jobsChannel: String { self[keyPath: \WKSM.name] } }

/// 主线程隔离，所有 WebKit/UIKit 访问都自然安全
@MainActor
public final class BaseWebView: UIView {

    // ===== 配置项 =====
    public var allowedHosts: Set<String> = []                         // 空 = 不限制
    public var externalSchemes: Set<String> = ["tel","mailto","sms","facetime","itms-apps","maps"]
    public var openBlankInPlace: Bool = true
    public var disableSelectionAndCallout: Bool = false
    public var injectDarkStylePatch: Bool = false
    public var customUserAgentSuffix: String?
    public var isInspectableEnabled: Bool = true

    public var presenter: () -> UIViewController? = {
        var base = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        while let p = base?.presentedViewController { base = p }
        if let nav = base as? UINavigationController { return nav.visibleViewController }
        if let tab = base as? UITabBarController { return tab.selectedViewController }
        return base
    }

    // ===== UI / 状态 =====
    public let webView: WKWebView
    public private(set) var progressView = UIProgressView(progressViewStyle: .default)

    private var handlers: [String: NativeHandler] = [:]
    private let bridgeName = "bridge"
    private let consoleName = "console"

    private var kvoEstimatedProgress: NSKeyValueObservation?
    private var kvoTitle: NSKeyValueObservation?
    private lazy var refresher: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(reload), for: .valueChanged)
        return r
    }()

    // 强引用 DocumentPicker 代理，避免立刻释放
    private var docPickerDelegate: DocumentPickerDelegateProxy?

    // ===== 初始化 =====
    public override init(frame: CGRect) {
        // 先配置，不要在 super.init 前用 self
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()

        let ucc = WKUserContentController()
        ucc.addUserScript(Self.makeBridgeUserScript())
        config.userContentController = ucc

        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init(frame: frame)

        // super.init 之后再用 self
        registerMessageHandlers()
        setupUI()
        setupKVO()
        applyRuntimeToggles()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        // ✅ 显式回到主演员做清理，干掉所有 MainActor 警告
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.webView.navigationDelegate = nil
            self.webView.uiDelegate = nil
            let ucc = self.webView.configuration.userContentController
            ucc.removeAllUserScripts()
            ucc.removeScriptMessageHandler(forName: self.bridgeName)
            ucc.removeScriptMessageHandler(forName: self.consoleName)
            self.kvoEstimatedProgress?.invalidate()
            self.kvoTitle?.invalidate()
        }
    }

    private func registerMessageHandlers() {
        let ucc = webView.configuration.userContentController
        if #available(iOS 14.0, *) {
            ucc.addScriptMessageHandler(self, contentWorld: .page, name: bridgeName)
            ucc.addScriptMessageHandler(self, contentWorld: .page, name: consoleName)
        } else {
            ucc.add(WeakScriptMessageHandler(target: self), name: bridgeName)
            ucc.add(WeakScriptMessageHandler(target: self), name: consoleName)
        }
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(progressView)
        addSubview(webView)

        // SnapKit 约束
        progressView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        webView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        webView.navigationDelegate = self
        webView.uiDelegate = self

        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.refreshControl = refresher

        if #available(iOS 16.4, *), isInspectableEnabled { webView.isInspectable = true }
        if let suffix = customUserAgentSuffix, !suffix.isEmpty {
            let current = (webView.customUserAgent ?? "").trimmingCharacters(in: .whitespaces)
            webView.customUserAgent = current.isEmpty ? suffix : (current + " " + suffix)
        }
    }

    private func setupKVO() {
        kvoEstimatedProgress = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let p = change.newValue else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.progressView.isHidden = p >= 1.0
                self.progressView.setProgress(Float(p), animated: true)
                if p >= 1.0 {
                    try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s
                    self.progressView.progress = 0
                }
            }
        }
        kvoTitle = webView.observe(\.title, options: [.new]) { _, _ in }
    }

    private func applyRuntimeToggles() {
        if injectDarkStylePatch { injectDarkCSS() }
        setSelectionDisabled(disableSelectionAndCallout)
    }

    // ===== Public API =====
    @discardableResult
    public func loadBy(_ url: URL) -> Self {
        if url.isFileURL {
            // file:// 用专用 API，确保子资源能读
            let readAccess = url.deletingLastPathComponent()
            webView.loadFileURL(url, allowingReadAccessTo: readAccess)
        } else {
            webView.load(URLRequest(url: url))
        }
        return self
    }

    @discardableResult
    public func loadBy(_ urlString: String) -> Self {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return self
    }

    @discardableResult
    public func loadBy(_ url: URL,
                       cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                       timeout: TimeInterval = 60) -> Self {
        let req = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        webView.load(req)
        return self
    }

    @discardableResult
    public func loadBy(_ request: URLRequest) -> Self {
        webView.load(request)
        return self
    }

    @discardableResult
    public func loadHTMLBy(_ html: String, baseURL: URL? = nil) -> Self {
        webView.loadHTMLString(html, baseURL: baseURL)
        return self
    }
    /// 加载 **App Bundle** 内的本地 HTML 文件（链式）
    ///
    /// 本方法先按你提供的 `subdirectory` 精确检索；
    /// 若未找到，则**遍历整个 Bundle** 查找同名 `*.html`，以兼容 Xcode 中
    /// 「黄色分组（Group）」不会保留目录层级的情况。
    ///
    /// - Important:
    ///   - 这是运行时从 **Bundle** 读取资源；**不要**传入磁盘绝对路径（如 `/Users/...`）。
    ///   - 如果工程里存在**重名 HTML**，建议传 `subdirectory` 以避免匹配到错误文件。
    ///   - 资源文件需勾选 *Target Membership* 且包含在 *Copy Bundle Resources* 中，
    ///     否则打包后也找不到。
    ///   - `subdirectory` 仅对 **蓝色 Folder Reference**（Create folder references）保留层级；
    ///     黄色 Group 会被“扁平化”，通常应传 `nil`。
    ///
    /// - Parameters:
    ///   - name: 不含扩展名的 HTML 文件名（`"xxx"` 对应 `xxx.html`）。
    ///   - subdirectory: 包内子目录路径（如 `"HTML"` / `"Web/demo"`），
    ///     若为黄色 Group，请传 `nil`（默认值）。
    ///   - bundle: 资源所在的 `Bundle`，默认 `.main`。
    ///
    /// - Returns: `Self`，可继续链式调用。
    ///
    /// - Complexity:
    ///   - 成功走分目录检索为 **O(1)**；
    ///   - 走兜底“全 Bundle 扫描”时为 **O(N)**（N 为包内 html 文件数），
    ///     若频繁调用建议提供 `subdirectory` 以避免全量扫描。
    ///
    /// - SeeAlso: `load(_:)`, `loadHTML(_:baseURL:)`
    ///
    /// - Example:
    /// ```swift
    /// // 常见情况（黄色 Group “HTML”）：不要传 subdirectory
    /// web.loadBundleHTMLBy(named: "BaseWebViewDemo")
    ///
    /// // 若是蓝色 Folder Reference：可以指定子目录
    /// web.loadBundleHTMLBy(named: "BaseWebViewDemo", in: "HTML")
    /// ```
    @discardableResult
    public func loadBundleHTMLBy(named name: String,
                                 in subdirectory: String? = nil,
                                 bundle: Bundle = .main) -> Self {
        // 1) 先按参数去找（最快）
        if let url = bundle.url(forResource: name, withExtension: "html", subdirectory: subdirectory) {
            return loadBy(url)
        }
        // 2) 若未找到，遍历整个 bundle（兼容黄色 Group 被“扁平化”的情况）
        if let urls = bundle.urls(forResourcesWithExtension: "html", subdirectory: nil),
           let url = urls.first(where: { $0.lastPathComponent == "\(name).html" }) {
            return loadBy(url)
        }
        assertionFailure("HTML '\(name).html' not found in bundle")
        return self
    }

    public func on(_ name: String, handler: @escaping NativeHandler) { handlers[name] = handler }
    public func off(_ name: String) { handlers.removeValue(forKey: name) }

    public func emitEvent(_ name: String, payload: Any?) {
        let js = "window.Native && window.Native.emit(\(Self.quote(name)), \(Self.toJSONLiteral(payload)));"
        webView.jobsEval(js)
    }

    public func callJS(function: String,
                       args: [Any] = [],
                       completion: (@MainActor @Sendable (Any?, Error?) -> Void)? = nil) {
        let jsArgs = args.map(Self.toJSONLiteral).joined(separator: ",")
        webView.jobsEval("\(function)(\(jsArgs));", completion: completion)
    }

    // MARK: - JS eval（Raw + Decodable）
    @available(iOS 13.0, *)
    public func evalAsyncRaw(_ js: String, timeout: TimeInterval = 8) async throws -> Any? {
        try await withThrowingTaskGroup(of: Any?.self) { group in
            group.addTask { [weak webView] in
                guard let webView else {
                    throw NSError(domain: "BaseWebView", code: -10,
                                  userInfo: [NSLocalizedDescriptionKey: "deallocated"])
                }

                if #available(iOS 15.0, *) {
                    // 15+ 直接用 async 版
                    return try await webView.evaluateJavaScript(js)
                } else {
                    // <15 用 jobsEval，但要跳到主演员执行
                    return try await withCheckedThrowingContinuation { cont in
                        Task { @MainActor [weak webView] in
                            guard let webView else {
                                cont.resume(throwing: NSError(domain: "BaseWebView", code: -10,
                                                              userInfo: [NSLocalizedDescriptionKey: "deallocated"]))
                                return
                            }
                            webView.jobsEval(js) { res, err in
                                if let err { cont.resume(throwing: err) }
                                else { cont.resume(returning: res) }
                            }
                        }
                    }
                }
            }

            // 超时保护
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1e9))
                throw NSError(domain: "BaseWebView", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "JS eval timeout"])
            }

            let v = try await group.next()!!
            group.cancelAll()
            return v
        }
    }

    @available(iOS 13.0, *)
    public func evalAsync<T: Decodable>(_ js: String,
                                        as type: T.Type = T.self,
                                        timeout: TimeInterval = 8,
                                        decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        let raw = try await evalAsyncRaw(js, timeout: timeout)
        return try Self.decodeJSResult(raw, as: T.self, decoder: decoder)
    }

    public func setCookies(_ cookies: [HTTPCookie], completion: (() -> Void)? = nil) {
        let store = webView.configuration.websiteDataStore.httpCookieStore
        let group = DispatchGroup()
        cookies.forEach { c in group.enter(); store.setCookie(c) { group.leave() } }
        group.notify(queue: .main) { completion?() }
    }

    public func setSelectionDisabled(_ disabled: Bool) {
        disableSelectionAndCallout = disabled
        let js = """
        (function(){
          var el = document.documentElement;
          el.style.webkitUserSelect=\(disabled ? "'none'" : "''");
          el.style.webkitTouchCallout=\(disabled ? "'none'" : "''");
        })();
        """
        webView.jobsEval(js)
    }

    private static func makeBridgeUserScript() -> WKUserScript {
        let js = """
        (function() {
          if (window.Native) return;
          const _callbacks = {};
          let _seq = 0;

          window.__nativeReturn = function(id, value) {
            const cb = _callbacks[id];
            if (cb) { delete _callbacks[id]; try { cb(value); } catch(e) { console.error(e); } }
          };

          function _post(name, payload) {
            try { window.webkit.messageHandlers.bridge.postMessage({ name:name, payload:payload ?? null }); }
            catch(e){ console.error('bridge.post failed', e); }
          }
          function _call(name, payload) {
            const id = ++_seq;
            try {
              return new Promise(function(resolve){
                _callbacks[id] = resolve;
                window.webkit.messageHandlers.bridge.postMessage({ name:name, payload:payload ?? null, id:id });
              });
            } catch(e){ console.error('bridge.call failed', e); return Promise.reject(e); }
          }
          function _emit(name, detail) {
            try { document.dispatchEvent(new CustomEvent(name, { detail: detail })); }
            catch(e){ console.error('emit failed', e); }
          }
          function _on(name, fn) {
            document.addEventListener(name, function(e){ try { fn && fn(e.detail); } catch(e){ console.error(e); } });
          }

          ['log','warn','error'].forEach(function(level){
            const old = console[level];
            console[level] = function(){
              try { window.webkit.messageHandlers.console.postMessage({ level:level, args:[].slice.call(arguments) }); } catch(_){}
              old && old.apply(console, arguments);
            };
          });
          window.onerror = function(msg, src, line, col, err){
            try { window.webkit.messageHandlers.console.postMessage({ level:'error', args:[String(msg||''), String(src||''), line||0, col||0, String((err&&err.stack)||'')] }); } catch(_){}
          };
          window.onunhandledrejection = function(e){
            try { window.webkit.messageHandlers.console.postMessage({ level:'error', args:['unhandledrejection', String((e&&e.reason)||'')] }); } catch(_){}
          };

          window.Native = { post:_post, call:_call, emit:_emit, on:_on };
        })();
        """
        if #available(iOS 14.0, *) {
            return WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false, in: .page)
        } else {
            return WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        }
    }

    private func injectDarkCSS() {
        let css = """
        @media (prefers-color-scheme: dark) {
          html, body { background:#000 !important; color:#eee !important; }
        }
        """
        let js = "var s=document.createElement('style');s.innerHTML=\(Self.quote(css));document.head&&document.head.appendChild(s);"
        let script: WKUserScript
        if #available(iOS 14.0, *) {
            script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false, in: .page)
        } else {
            script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        }
        webView.configuration.userContentController.addUserScript(script)
    }

    @objc private func reload() {
        webView.reload()
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            refresher.endRefreshing()
        }
    }

    // ===== 工具 =====
    static func quote(_ s: String) -> String {
        let escaped = s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "\"\(escaped)\""
    }

    static func toJSONLiteral(_ value: Any?) -> String {
        guard let value else { return "null" }
        switch value {
        case is NSNull: return "null"
        case let s as String: return quote(s)
        case let b as Bool:   return b ? "true" : "false"
        case let i as Int:    return "\(i)"
        case let i64 as Int64: return "\(i64)"
        case let u64 as UInt64: return "\(u64)"
        case let d as Double: return d.isFinite ? "\(d)" : "null"
        case let f as Float:  return f.isFinite ? "\(f)" : "null"
        case let dec as Decimal: return NSDecimalNumber(decimal: dec).stringValue
        case let date as Date:
            let iso = ISO8601DateFormatter()
            return quote(iso.string(from: date))
        case let arr as [Any]:
            return "[\(arr.map { toJSONLiteral($0) }.joined(separator: ","))]"
        case let dict as [String: Any]:
            let body = dict.map { key, val in "\(quote(key)):\(toJSONLiteral(val))" }.joined(separator: ",")
            return "{\(body)}"
        default:
            if JSONSerialization.isValidJSONObject(value),
               let data = try? JSONSerialization.data(withJSONObject: value, options: []),
               let s = String(data: data, encoding: .utf8) { return s }
            return quote("\(value)")
        }
    }

    // 将 evaluateJavaScript 的返回值（Any?）解码为 Decodable
    static func decodeJSResult<T: Decodable>(_ value: Any?, as type: T.Type, decoder: JSONDecoder) throws -> T {
        if T.self == String.self, let v = value as? String { return v as! T }
        if T.self == Bool.self,   let v = value as? Bool   { return v as! T }
        if T.self == Int.self,    let v = value as? Int    { return v as! T }
        if T.self == Double.self, let v = value as? Double { return v as! T }
        if T.self == Float.self,  let v = value as? Float  { return v as! T }
        if value == nil || value is NSNull {
            throw NSError(domain: "BaseWebView", code: -2, userInfo: [NSLocalizedDescriptionKey: "JS returned null"])
        }
        if JSONSerialization.isValidJSONObject(value ?? NSNull()) {
            let data = try JSONSerialization.data(withJSONObject: value!, options: [])
            return try decoder.decode(T.self, from: data)
        }
        if let s = value as? String, let data = s.data(using: .utf8) {
            let first = s.trimmingCharacters(in: .whitespacesAndNewlines).first
            if let f = first, ["{","["].contains(f) {
                return try decoder.decode(T.self, from: data)
            }
        }
        let fallback = "\(value!)"
        if let data = fallback.data(using: .utf8) {
            let first = fallback.trimmingCharacters(in: .whitespacesAndNewlines).first
            if let f = first, ["{","[","\"","0","1","2","3","4","5","6","7","8","9","t","f","n"].contains(f),
               let decoded = try? decoder.decode(T.self, from: data) {
                return decoded
            }
        }
        throw NSError(domain: "BaseWebView", code: -3,
                      userInfo: [NSLocalizedDescriptionKey: "Cannot decode JS result to \(T.self) – raw: \(String(describing: value))"])
    }
}

// ===== ScriptMessageHandler（iOS < 14） =====
extension BaseWebView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let channel = message.jobsChannel
        handleScriptMessage(channel: channel, body: message.body, reply: { _, _ in })
    }
}

// ===== WithReply（iOS 14+） =====
@available(iOS 14.0, *)
extension BaseWebView: WKScriptMessageHandlerWithReply {
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage,
                                      replyHandler: @escaping (Any?, String?) -> Void) {
        let channel = message.jobsChannel
        handleScriptMessage(channel: channel, body: message.body, reply: { value, err in
            replyHandler(value, err)
        })
    }
}

// ===== 统一消息处理 =====
private extension BaseWebView {
    func handleScriptMessage(channel: String, body: Any, reply: @escaping (Any?, String?) -> Void) {
        if channel == consoleName {
            if let dict = body as? [String: Any],
               let level = dict["level"] as? String,
               let args  = dict["args"] {
                print("[JS:\(level)] \(args)")
            }
            return
        }
        guard channel == bridgeName else { return }

        let dictBody: [String: Any]
        if let d = body as? [String: Any] { dictBody = d }
        else if let s = body as? String,
                let data = s.data(using: .utf8),
                let d = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] { dictBody = d }
        else { print("Invalid bridge message:", body); return }

        let api = dictBody["name"] as? String ?? ""
        let payload = dictBody["payload"]
        let reqId = dictBody["id"] as? Int

        guard let handler = handlers[api] else {
            if #available(iOS 14.0, *), reqId == nil {
                reply(["error":"unhandled:\(api)"], nil)
            } else if let reqId {
                jsReturn(id: reqId, value: ["error":"unhandled:\(api)"])
            }
            return
        }

        handler(payload) { [weak self] value in
            guard let self else { return }
            if #available(iOS 14.0, *), reqId == nil {
                reply(value, nil)
            } else if let reqId {
                self.jsReturn(id: reqId, value: value)
            }
        }
    }

    func jsReturn(id: Int, value: Any?) {
        let js = "window.__nativeReturn && window.__nativeReturn(\(id), \(Self.toJSONLiteral(value)));"
        webView.jobsEval(js)
    }
}

// ===== Navigation =====
extension BaseWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        emitEvent("nativeReady", payload: [
            "ua": webView.customUserAgent ?? "",
            "title": webView.title ?? ""
        ])
    }
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { webView.reload() }

    public func webView(_ webView: WKWebView,
                        decidePolicyFor action: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url else { decisionHandler(.cancel); return }
        let scheme = (url.scheme ?? "").lowercased()

        if externalSchemes.contains(scheme) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel); return
        }

        if !allowedHosts.isEmpty {
            let host = (url.host ?? "").lowercased()
            if !allowedHosts.contains(host) { decisionHandler(.cancel); return }
        }

        if action.targetFrame == nil {
            if openBlankInPlace { webView.load(action.request) }
            else { UIApplication.shared.open(url, options: [:], completionHandler: nil) }
            decisionHandler(.cancel); return
        }

        decisionHandler(.allow)
    }

    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView,
                        decidePolicyFor response: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(response.canShowMIMEType ? .allow : .download)
    }

    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView,
                        navigationResponse: WKNavigationResponse,
                        didBecome download: WKDownload) {
        download.delegate = self
    }
}

// ===== WKUIDelegate（使用你的 Alert DSL） =====
extension BaseWebView: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void) {
        let ac = UIAlertController.makeAlert("提示", message).byAddOK { _ in completionHandler() }
        presenter()?.present(ac, animated: true)
    }

    public func webView(_ webView: WKWebView,
                        runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (Bool) -> Void) {
        let ac = UIAlertController
            .makeAlert("确认", message)
            .byAddCancel { _ in completionHandler(false) }
            .byAddOK     { _ in completionHandler(true)  }
        presenter()?.present(ac, animated: true)
    }

    public func webView(_ webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {
        let ac = UIAlertController.makeAlert("输入", prompt)
        ac.addTextField { $0.text = defaultText }
        _ = ac
            .byAddCancel { _ in completionHandler(nil) }
            .byAddOK     { _ in completionHandler(ac.textFields?.first?.text) }
        presenter()?.present(ac, animated: true)
    }

    /// iOS 18.4+ 自定义文件选择
    @available(iOS 18.4, *)
    public func webView(_ webView: WKWebView,
                        runOpenPanelWith parameters: WKOpenPanelParameters,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping ([URL]?) -> Void) {
        var types: [UTType] = [.item]
        if parameters.allowsDirectories { types = [.folder] }

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.allowsMultipleSelection = parameters.allowsMultipleSelection

        let proxy = DocumentPickerDelegateProxy { [weak self] urls in
            completionHandler(urls)
            self?.docPickerDelegate = nil
        }
        self.docPickerDelegate = proxy
        picker.delegate = proxy
        picker.modalPresentationStyle = .formSheet
        presenter()?.present(picker, animated: true)
    }
}

// ===== 下载（iOS 14.5+） =====
@available(iOS 14.5, *)
extension BaseWebView: WKDownloadDelegate {
    public func download(_ download: WKDownload,
                         decideDestinationUsing response: URLResponse,
                         suggestedFilename: String,
                         completionHandler: @escaping (URL?) -> Void) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
        completionHandler(url)
    }
    public func downloadDidFinish(_ download: WKDownload) {
        emitEvent("downloadFinish", payload: ["ok": true])
    }
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        emitEvent("downloadError", payload: ["message": error.localizedDescription])
    }
}

// ===== 文档选择器代理（强引用由外层保持） =====
private final class DocumentPickerDelegateProxy: NSObject, UIDocumentPickerDelegate {
    private let onFinish: ([URL]?) -> Void
    init(_ onFinish: @escaping ([URL]?) -> Void) { self.onFinish = onFinish }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) { onFinish(urls) }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { onFinish(nil) }
}

// ===== DSL（链式配置） =====
@MainActor
public extension BaseWebView {

    @discardableResult
    func byAllowedHosts(_ hosts: [String]) -> Self {
        self.allowedHosts = Set(hosts.map { $0.lowercased() }); return self
    }

    @discardableResult
    func byOpenBlankInPlace(_ inPlace: Bool = true) -> Self {
        self.openBlankInPlace = inPlace; return self
    }

    @discardableResult
    func byDisableSelectionAndCallout(_ disabled: Bool) -> Self {
        self.setSelectionDisabled(disabled); return self
    }

    @discardableResult
    func byInjectDarkStylePatch(_ enable: Bool) -> Self {
        self.injectDarkStylePatch = enable
        guard enable else { return self }
        let css = """
        @media (prefers-color-scheme: dark) {
          html, body { background:#000 !important; color:#eee !important; }
        }
        """
        let js = "var s=document.createElement('style');s.innerHTML=\(BaseWebView.quote(css));document.head&&document.head.appendChild(s);"
        self.webView.jobsEval(js)
        return self
    }

    /// 统一 UA 后缀（推荐）
    @discardableResult
    func byCustomUserAgentSuffix(_ suffix: String?) -> Self {
        self.customUserAgentSuffix = suffix
        if let s = suffix, !s.isEmpty {
            let current = self.webView.customUserAgent?.trimmingCharacters(in: .whitespaces) ?? ""
            self.webView.customUserAgent = current.isEmpty ? s : (current + " " + s)
        }
        return self
    }

    /// 兼容别名
    @discardableResult
    func byUA(_ suffix: String?) -> Self { byCustomUserAgentSuffix(suffix) }

    /// 旧名保留为别名（避免工程里已使用的编译错误）
    @available(*, deprecated, renamed: "byCustomUserAgentSuffix(_:)")
    @discardableResult
    func byUserAgentSuffix(_ suffix: String?) -> Self { byCustomUserAgentSuffix(suffix) }

    @discardableResult
    func byApply(_ block: (BaseWebView) -> Void) -> Self { block(self); return self }
}
