//
//  BaseWebView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/20/25.
//

import UIKit
import WebKit
import UniformTypeIdentifiers
import SafariServices
import SnapKit

/**
 在 Info.plist 添加👇（更通用的 ATS 配置，避免为某域名单独开洞）
     <key>NSAppTransportSecurity</key>
     <dict>
       <!-- 仅放开 Web 内容，其他网络请求仍受 ATS 约束 -->
       <key>NSAllowsArbitraryLoadsInWebContent</key><true/>
     </dict>
 */
public typealias NativeHandler = (_ payload: Any?, _ reply: @escaping (Any?) -> Void) -> Void
/// 任意 JSON 解码容器（备用）
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
/// iOS < 14 的弱代理封装
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}
/// 用 keyPath 显式取系统的 name，规避工程里可能的同名扩展
private typealias WKSM = WebKit.WKScriptMessage
private extension WKSM { var jobsChannel: String { self[keyPath: \WKSM.name] } }
/// 主线程隔离，所有 WebKit/UIKit 访问都自然安全
@MainActor
public final class BaseWebView: UIView {
    /// 基础配置项
    public var allowedHosts: Set<String> = []                         // 空 = 不限制
    public var externalSchemes: Set<String> = [
        "tel","mailto","sms","facetime","itms-apps","maps",
        "weixin","alipays","alipay","mqqapi","line"
    ]
    public var openBlankInPlace: Bool = true
    public var disableSelectionAndCallout: Bool = false
    public var injectDarkStylePatch: Bool = false
    @available(*, deprecated, message: "请使用 byUserAgentSuffixProvider(_:) 回调按页面配置 UA 后缀")
    public var customUserAgentSuffix: String?
    public var isInspectableEnabled: Bool = true
    /// 单页 UA 后缀提供器（返回 nil 表示使用系统默认 UA；非空则作为 applicationNameForUserAgent 追加）
    public typealias UASuffixProvider = (URLRequest) -> String?
    private var uaSuffixProvider: UASuffixProvider?
    private var lastAppliedUASuffix: String?   // 当前实例上一次已生效的后缀（nil 代表系统默认）

    private func normalizeSuffix(_ s: String?) -> String? {
        guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }
    /// 导航规范化与兜底（可按需改）
    public var normalizeMToWWW: Bool = true           // m.bwsit.cc → www.bwsit.cc（强制 HTTPS）
    public var forceHTTPSUpgrade: Bool = true         // http:// → https://
    public var injectRedirectSanitizerJS: Bool = false// 注入前端重定向修补脚本
    public var safariFallbackOnHTTP: Bool = true      // 命中 http://m.bwsit.cc 或重写风暴 → Safari 兜底
    public var safariFallbackHosts: Set<String> = ["m.bwsit.cc"]
    /// 循环重写保护（短时间重写过多直接兜底）
    public var rewriteBurstWindow: TimeInterval = 3
    public var rewriteBurstLimit: Int = 3
    private var rewriteCount = 0
    private var lastRewriteAt = Date.distantPast
    private var didFallbackToSafari = false
    /// 宿主 VC 获取（用于弹窗/Safari 兜底）
    public var presenter: () -> UIViewController? = {
        var base = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        while let p = base?.presentedViewController { base = p }
        if let nav = base as? UINavigationController { return nav.visibleViewController }
        if let tab = base as? UITabBarController { return tab.selectedViewController }
        return base
    }
    /// UI / 状态
    private lazy var webView: WKWebView = {
        WKWebView(frame: .zero, configuration: WKWebViewConfiguration()
            .byWebsiteDataStore(.default())
            .byAllowsInlineMediaPlayback(true)
            .byUserContentController(WKUserContentController().byAddUserScript(Self.makeBridgeUserScript()))
            .byDefaultWebpagePreferences { wp in
                wp.allowsContentJavaScript = true
            }
        )
    }()
    public private(set) var progressView = UIProgressView(progressViewStyle: .default)
    private var handlers: [String: NativeHandler] = [:]
    private let bridgeName = "bridge"
    private let consoleName = "console"
    private var kvoEstimatedProgress: NSKeyValueObservation?
    private var kvoTitle: NSKeyValueObservation?
    private var progressTopConstraint: Constraint?

    private lazy var refresher: UIRefreshControl = {
        let r = UIRefreshControl()
        // ✅ 使用你的 UIControl API（而非 addTarget/selector）
        r.onJobsChange { [weak self] (_: UIRefreshControl) in
            self?.reload()
        }
        return r
    }()
    /// 强引用 DocumentPicker 代理，避免立刻释放
    private var docPickerDelegate: DocumentPickerDelegateProxy?
    /// 初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        webView.byVisible(true)
        registerMessageHandlers()
        setupUI()
        setupKVO()
        applyRuntimeToggles()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        // ✅ 显式回到主演员做清理
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

        // 进度条默认贴宿主顶部；若外部装了 JobsNavBar，会通过回调把它改到 NavBar 下方
        progressView.snp.makeConstraints { make in
            progressTopConstraint = make.top.equalToSuperview().constraint
            make.leading.trailing.equalToSuperview()
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
        // UA 初始为系统默认；实际按页面在导航阶段动态切换
        webView.customUserAgent = nil
        webView.configuration.applicationNameForUserAgent = nil
        lastAppliedUASuffix = nil
        // （可选）注入重定向修补 JS
        if injectRedirectSanitizerJS {
            webView.configuration.userContentController.addUserScript(Self.makeSanitizeUserScript())
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

    private func nearestViewController() -> UIViewController? {
        var r: UIResponder? = self
        while let n = r?.next {
            if let vc = n as? UIViewController { return vc }
            r = n
        }
        return nil
    }
    // ===== Public API =====
    @discardableResult
    public func loadBy(_ url: URL) -> Self {
        if url.isFileURL {
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
    /// 加载 App Bundle 内的本地 HTML 文件（链式）
    @discardableResult
    public func loadBundleHTMLBy(named name: String,
                                 in subdirectory: String? = nil,
                                 bundle: Bundle = .main) -> Self {
        if let url = bundle.url(forResource: name, withExtension: "html", subdirectory: subdirectory) {
            return loadBy(url)
        }
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
                    return try await webView.evaluateJavaScript(js)
                } else {
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
    // MARK: - Dark CSS 注入
    private func injectDarkCSS() {
        let css = """
        @media (prefers-color-scheme: dark) {
          html, body { background:#000 !important; color:#eee !important; }
        }
        """
        let js = "var s=document.createElement('style');s.innerHTML=\(BaseWebView.quote(css));document.head&&document.head.appendChild(s);"
        let script: WKUserScript
        if #available(iOS 14.0, *) {
            script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false, in: .page)
        } else {
            script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        }
        webView.configuration.userContentController.addUserScript(script)
    }
    // MARK: - Pull to refresh
    @objc private func reload() {
        webView.reload()
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
            refresher.endRefreshing()
        }
    }
}
// ===== WK Script Bridge =====
extension BaseWebView {
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

    private static func makeSanitizeUserScript() -> WKUserScript {
        let js = """
        (function(){
          function sanitize(u){
            try{
              var x = new URL(u, location.href);
              if (x.protocol === 'http:') x.protocol = 'https:';
              if (x.host === 'm.bwsit.cc') x.host = 'www.bwsit.cc';
              return x.href;
            }catch(e){ return u; }
          }
          var _assign = Location.prototype.assign;
          var _replace = Location.prototype.replace;
          Object.defineProperty(Location.prototype, 'assign', { value: function(u){ return _assign.call(this, sanitize(u)); }});
          Object.defineProperty(Location.prototype, 'replace', { value: function(u){ return _replace.call(this, sanitize(u)); }});
          var hrefDesc = Object.getOwnPropertyDescriptor(Location.prototype, 'href');
          Object.defineProperty(Location.prototype, 'href', {
            get: function(){ return hrefDesc.get.call(this); },
            set: function(u){ return _replace.call(this, sanitize(u)); }
          });
          var _open = window.open;
          Object.defineProperty(window, 'open', { value: function(u, t, f){
            if (typeof u === 'string') u = sanitize(u);
            return _open.call(window, u, t, f);
          }});
          try { console.log('[SanitizeJS] installed'); } catch(_){}
        })();
        """
        if #available(iOS 14.0, *) {
            return WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false, in: .page)
        } else {
            return WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        }
    }
}
// ===== 工具 =====
extension BaseWebView {
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
        // 真实 UA 回传给前端
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] v, _ in
            let ua = v as? String ?? ""
            self?.emitEvent("nativeReady", payload: [
                "ua": ua,
                "title": webView.title ?? ""
            ])
        }

        // 如果外部在当前视图上装了 NavBar 且未自定义标题，则默认绑定 webView.title
        if let nb = self.jobsNavBar, nb.titleProvider == nil {
            nb.bind(webView: webView)
            nb.refresh()
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { webView.reload() }
    public func webView(_ webView: WKWebView,
                        decidePolicyFor action: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = action.request.url else { decisionHandler(.cancel); return }
        let scheme = (url.scheme ?? "").lowercased()
        let host = (url.host ?? "").lowercased()
        let isMain = (action.targetFrame?.isMainFrame == true)

        // ===== 0) 外部 scheme（weixin:// 等）=====
        let standardSchemes: Set<String> = ["http","https","file","about","data","javascript"]
        if !standardSchemes.contains(scheme) || externalSchemes.contains(scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            return
        }
        // ===== 1) Safari 兜底：命中 http:// + 指定 host 或发生重写风暴 =====
        if safariFallbackOnHTTP, isMain, scheme == "http", safariFallbackHosts.contains(host) {
            decisionHandler(.cancel)
            presentSafari(with: url)
            return
        }
        // ===== 2) 主文档：域名/协议规范化（避免 ATS/白板）=====
        if isMain {
            var rewritten: URL? = nil

            if normalizeMToWWW, host == "m.bwsit.cc" {
                if var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    comps.scheme = "https"
                    comps.host   = "www.bwsit.cc"
                    rewritten = comps.url
                }
            } else if forceHTTPSUpgrade, scheme == "http" {
                if var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    comps.scheme = "https"
                    rewritten = comps.url
                }
            }

            if let newURL = rewritten, newURL != url {
                let now = Date()
                if now.timeIntervalSince(lastRewriteAt) > rewriteBurstWindow { rewriteCount = 0 }
                rewriteCount += 1
                lastRewriteAt = now

                if safariFallbackOnHTTP, rewriteCount > rewriteBurstLimit, !didFallbackToSafari {
                    didFallbackToSafari = true
                    decisionHandler(.cancel)
                    presentSafari(with: url) // 直接把原始 URL 丢给 Safari
                    return
                }

                decisionHandler(.cancel)
                webView.load(URLRequest(url: newURL))
                return
            }
        }
        // ===== 3) UA 动态切换（仅主文档）=====
        if isMain {
            let desired = normalizeSuffix(uaSuffixProvider?(action.request))
            if desired != lastAppliedUASuffix {
                lastAppliedUASuffix = desired
                webView.configuration.applicationNameForUserAgent = desired
                webView.customUserAgent = nil
                decisionHandler(.cancel)
                webView.load(action.request)
                return
            }
        }
        // ===== 4) target=_blank 的 in-place 处理 =====
        if action.targetFrame == nil {
            if openBlankInPlace { webView.load(action.request) }
            else { UIApplication.shared.open(url, options: [:], completionHandler: nil) }
            decisionHandler(.cancel); return
        }
        // ===== 5) Host 白名单 =====
        if !allowedHosts.isEmpty {
            if let h = url.host?.lowercased(), !allowedHosts.contains(h) {
                decisionHandler(.cancel); return
            }
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

    public func webView(_ webView: WKWebView,
                        didFailProvisionalNavigation navigation: WKNavigation!,
                        withError error: Error) {
        let ns = error as NSError
        print("⛔️ Provisional fail: \(ns.domain) [\(ns.code)] \(ns.localizedDescription)")
    }
    // Safari 兜底
    private func presentSafari(with url: URL) {
        guard let vc = presenter() else { return }
        SFSafariViewController(url: url)
            .byModalPresentationStyle(.pageSheet)
            .byData(3.14)// 基本数据类型
            .onResult { name in
                print("回来了 \(name)")
            }
            .byPresent(vc)
            .byCompletion{
                print("结束")
            }
    }
}
// ===== WKUIDelegate =====
extension BaseWebView: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        runJavaScriptAlertPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping () -> Void) {
        UIAlertController
            .makeAlert("提示", message)
            .byAddOK { _ in
                completionHandler()
            }
            .byData("Jobs")// 字符串
            .onResult { name in
                print("回来了 \(name)")
            }
            .byPresent(presenter())
    }

    public func webView(_ webView: WKWebView,
                        runJavaScriptConfirmPanelWithMessage message: String,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (Bool) -> Void) {
        UIAlertController
            .makeAlert("确认", message)
            .byAddCancel { _ in
                completionHandler(false)
            }
            .byAddOK { _ in
                completionHandler(true)
            }
            .byData("Jobs")// 字符串
            .onResult { name in
                print("回来了 \(name)")
            }
            .byPresent(presenter())
    }

    public func webView(_ webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {
        UIAlertController
            .makeAlert("确认", prompt).byAddTextField { tf in
                tf.text = defaultText
            }
            .byAddCancel { _ in
                completionHandler(nil)
            }
            .byAddOK { _ in
                completionHandler(nil)
            }
            .byData("Jobs")// 字符串
            .onResult { name in
                print("回来了 \(name)")
            }
            .byPresent(presenter())
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
// ===== BaseWebView 专属：Web 配置 DSL（NavBar 相关已移到 UIView 扩展） =====
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
    /// ✅ 按请求动态提供 UA 后缀；返回 nil = 系统默认 UA；非空 = 通过 applicationNameForUserAgent 追加
    @discardableResult
    func byUserAgentSuffixProvider(_ provider: @escaping UASuffixProvider) -> Self {
        self.uaSuffixProvider = provider
        return self
    }

    @discardableResult
    func byNormalizeMToWWW(_ on: Bool = true) -> Self { self.normalizeMToWWW = on; return self }

    @discardableResult
    func byForceHTTPSUpgrade(_ on: Bool = true) -> Self { self.forceHTTPSUpgrade = on; return self }

    @discardableResult
    func bySafariFallbackOnHTTP(_ on: Bool = true, hosts: [String]? = nil) -> Self {
        self.safariFallbackOnHTTP = on
        if let hs = hosts { self.safariFallbackHosts = Set(hs.map { $0.lowercased() }) }
        return self
    }

    @discardableResult
    func byInjectRedirectSanitizerJS(_ on: Bool = true) -> Self {
        self.injectRedirectSanitizerJS = on
        if on { self.webView.configuration.userContentController.addUserScript(BaseWebView.makeSanitizeUserScript()) }
        return self
    }

    @discardableResult
    func byBgColor(_ color: UIColor) -> Self { self.backgroundColor = color; return self }

    @discardableResult
    func byAddTo(_ parent: UIView, _ layout: (ConstraintMaker) -> Void) -> Self {
        parent.addSubview(self)
        self.snp.makeConstraints(layout)
        return self
    }

    @discardableResult
    func byApply(_ block: (BaseWebView) -> Void) -> Self { block(self); return self }
}
// ===== BaseWebView 作为 NavBar 宿主：根据显隐重排内部约束 =====
extension BaseWebView: JobsNavBarHost {
    public func jobsNavBarDidToggle(enabled: Bool, navBar: JobsNavBar) {
        // 进度条：顶到 NavBar 底部（或无 NavBar 时顶到宿主顶部）
        progressView.snp.remakeConstraints { make in
            if enabled {
                make.top.equalTo(navBar.snp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview()
        }
        // webView 仍旧跟随 progressView 底部
        webView.snp.remakeConstraints { make in
            make.top.equalTo(progressView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        layoutIfNeeded()
    }
}
