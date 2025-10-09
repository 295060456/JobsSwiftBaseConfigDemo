//
//  String.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import MessageUI

#if canImport(Kingfisher)
import Kingfisher
#endif

#if canImport(SDWebImage)
import SDWebImage
#endif
/// 字符串相关格式的（通用）转换
extension String {
    // MARK: - String 转 Int
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    // MARK: - String 转 Int64
    public func toInt64() -> Int64? {
        if let num = NumberFormatter().number(from: self) {
            return num.int64Value
        } else {
            return nil
        }
    }
    // MARK: - String 转 Double
    public func toDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")  // 固定使用 . 作为小数点
        formatter.numberStyle = .decimal

        // 设置逗号为千位分隔符，点号为小数点
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        return formatter.number(from: self.trimmingCharacters(in: .whitespacesAndNewlines))?.doubleValue
    }
    // MARK: - String 转 Double
    public func toDouble(_ max:Int,_ min:Int) -> Double? {
        let format = NumberFormatter.init()
        format.maximumFractionDigits = max
        format.minimumFractionDigits = min
        if let num = format.number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    // MARK: - String 转 Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    // MARK: - String 转 Bool
    public func toBool() -> Bool? {
        let trimmedString = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch trimmedString {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    // MARK: - String 转 NSString
    public var toNSString: NSString {
        return self as NSString
    }
    // MARK: - String 转 NSAttributedString
    /// 转富文本（默认空属性）
    var rich: NSAttributedString {
        NSAttributedString(string: self)
    }
    /// 转富文本并附加属性
    func rich(_ attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        NSAttributedString(string: self, attributes: attrs)
    }
}
// MARK: - 辅助
extension CATextLayerAlignmentMode {
    static func fromNSTextAlignment(_ a: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch a {
        case .left: return .left
        case .right: return .right
        case .center: return .center
        case .justified: return .justified
        case .natural: return .natural
        @unknown default: return .natural
        }
    }
}
// MARK: - 返回 URL（如果是网络图）或 UIImage（如果是本地）
/// 字符串解析成图
public extension String {
    /// 统一解析：字符串 → 图片来源
    var imageSource: ImageSource? {
        // 优先判断 http/https
        if let url = URL(string: self),
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return .remote(url)
        }
        // 其余视为本地资源名（包括空 scheme、非 http(s)）
        return .local(self)
    }
    /// 本地同步图（仅当来源是 .local 时有意义）
    var img: UIImage {
        guard let source = imageSource else { return UIImage() }
        switch source {
        case .remote:
            // 同步返回不支持网络加载，避免阻塞
            print("🚫 检测到网络 URL：\(self)，无法同步返回图片")
            return UIImage()
        case .local(let name):
            return UIImage(named: name) ?? UIImage()
        }
    }
#if canImport(Kingfisher)
    /// 远程：通过 KF 异步下载后返回；本地：直接返回
    func kfLoadImage() async throws -> UIImage {
        guard let source = imageSource else { throw KFError.badURL }
        switch source {
        case .remote(let url):
            let result = try await KingfisherManager.shared.retrieveImage(with: url)
            return result.image
        case .local(let name):
            if let img = UIImage(named: name) { return img }
            throw KFError.notFound
        }
    }
#endif

#if canImport(SDWebImage)
    /// 远程：通过 SDWebImage 异步下载后返回；本地：直接返回
    func sdLoadImage() async throws -> UIImage {
        guard let source = imageSource else {
            throw NSError(domain: "SDWebImage", code: -1000,
                          userInfo: [NSLocalizedDescriptionKey: "Bad URL string"])
        }
        switch source {
        case .remote(let url):
            return try await withCheckedThrowingContinuation { cont in
                SDWebImageManager.shared.loadImage(
                    with: url,
                    options: [],
                    progress: nil
                ) { image, _, error, _, _, _ in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else if let image = image {
                        cont.resume(returning: image)
                    } else {
                        cont.resume(throwing: NSError(
                            domain: "SDWebImage",
                            code: -1001,
                            userInfo: [NSLocalizedDescriptionKey: "Image not found"]
                        ))
                    }
                }
            }

        case .local(let name):
            if let img = UIImage(named: name) {
                return img
            }
            throw NSError(domain: "SDWebImage", code: -1002,
                          userInfo: [NSLocalizedDescriptionKey: "Local image not found: \(name)"])
        }
    }
#endif
}
// MARK: - 国际化
public extension String {
     var localized: String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: Bundle.main,
                                 value: "",
                                 comment: "")
    }
    func localized(comment: String? = nil,
                   defaultValue: String? = nil,
                   parameters: [String] = []) -> String {
        let localized = NSLocalizedString(self,
                                          tableName: nil,
                                          bundle: LanguageManager.shared.localizedBundle,
                                          value: defaultValue ?? self,
                                          comment: comment.safelyUnwrapped())
        return localizedFormatString(localized: localized, parameters: parameters)
    }
    private func localizedFormatString(localized: String, parameters: [String] = []) -> String {
        String(format: localized, arguments: parameters)
    }
}
@MainActor
public extension String {
    // MARK: - 一行打开：网址 / 任何支持的 URL scheme
    /// 例子：
    /// "www.baidu.com".open()
    /// "https://example.com?q=中文".open()
    /// "weixin://".open()
    /// 返回结果仅表示“是否成功调起系统打开”，并不保证目标 App 内部行为成功
    @discardableResult
    func open(options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:],
              completion: ((JobsOpenResult) -> Void)? = nil) -> JobsOpenResult {
        // 1) 预处理：去空白 + 尝试补 scheme + 百分号编码
        guard let url = Self.makeURL(from: self) else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 2) canOpenURL（系统判断是否能调起）
        guard UIApplication.shared.canOpenURL(url) else {
            completion?(.cannotOpen)
            return .cannotOpen
        }
        // 3) iOS 10+ 统一走 open(_:options:completionHandler:)
        UIApplication.shared.open(url, options: options) { ok in
            completion?(ok ? .opened : .cannotOpen)
        }
        return .opened
    }
    // MARK: - 一行拨号
    /// 例子：
    /// "13434343434".call()                 // 直接走 tel://（停留在电话 App）
    /// "13434343434".call(usePrompt: true)  // 用 telprompt://（回到 App；有被拒历史，谨慎）
    ///
    /// 审核前瞻（实话实说）：
    /// - `telprompt://` 曾有被拒案例，**能不用就不用**。默认关。
    /// - 模拟器不支持拨号；真机的家长控制/MDM 也可能拦截。
    @discardableResult
    func call(usePrompt: Bool = false,
              completion: ((JobsOpenResult) -> Void)? = nil) -> JobsOpenResult {

        #if targetEnvironment(simulator)
        // ================== 模拟器环境直接拦截 ==================
        print("📵 模拟器不支持拨号功能")
        Task { @MainActor in
            JobsToast.show(
                text: "模拟器不支持拨号功能",
                config: JobsToast.Config()
                    .byBgColor(.systemGreen.withAlphaComponent(0.9))
                    .byCornerRadius(12)
            )
        }
        completion?(.cannotOpen)
        return .cannotOpen
        #else
        // ================== 真机执行逻辑 ==================
        // 1) 规整号码：仅保留数字与前导 '+'（其余全剔除）
        let sanitized = Self.sanitizePhone(self)
        guard !sanitized.isEmpty else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 2) 生成 tel / telprompt URL
        let scheme = usePrompt ? "telprompt://" : "tel://"
        guard let url = URL(string: scheme + sanitized) else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 3) canOpenURL
        guard UIApplication.shared.canOpenURL(url) else {
            completion?(.cannotOpen)
            return .cannotOpen
        }
        UIApplication.shared.open(url, options: [:]) { ok in
            completion?(ok ? .opened : .cannotOpen)
        }
        return .opened
        #endif
    }
    /// 一行发邮件（优先原生 Mail VC；不可用时回退 mailto://）
    ///
    /// - Parameters:
    ///   - subject: 邮件主题
    ///   - body: 正文
    ///   - isHTML: 正文是否为 HTML
    ///   - cc / bcc: 抄送/密送（可多收件人）
    ///   - presentFrom: 指定展示 VC（不传则自动找顶层 VC）
    /// - Note:
    ///   - 支持 "a@b.com" 或 "a@b.com,b@c.com; d@e.com" 这样的分隔（逗号/分号/空格）
    ///   - 模拟器一般 `canSendMail == false`，会自动走 `mailto:` 回退
    @discardableResult
    func mail(subject: String? = nil,
              body: String? = nil,
              isHTML: Bool = false,
              cc: [String] = [],
              bcc: [String] = [],
              presentFrom: UIViewController? = nil,
              completion: ((JobsOpenResult) -> Void)? = nil) -> JobsOpenResult {

        let tos = Self._parseEmails(self)
        guard !tos.isEmpty else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 1) 优先走系统邮件编辑器
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.setToRecipients(tos)
            if let subject { vc.setSubject(subject) }
            if let body    { vc.setMessageBody(body, isHTML: isHTML) }
            if !cc.isEmpty { vc.setCcRecipients(Self._parseEmails(cc.joined(separator: ","))) }
            if !bcc.isEmpty { vc.setBccRecipients(Self._parseEmails(bcc.joined(separator: ","))) }
            vc.mailComposeDelegate = _JobsMailProxy.shared
            // 顶层展示 VC
            let host = presentFrom
                ?? UIApplication.jobsKeyWindow()?.rootViewController
                ?? UIViewController()

            _JobsMailProxy.shared.completion = completion
            host.present(vc, animated: true, completion: nil)
            return .opened
        }
        // 2) 回退：mailto://
        guard let url = Self._makeMailtoURL(to: tos, subject: subject, body: body, cc: cc, bcc: bcc),
              UIApplication.shared.canOpenURL(url) else {
            completion?(.cannotOpen)
            return .cannotOpen
        }
        UIApplication.shared.open(url, options: [:]) { ok in
            completion?(ok ? .opened : .cannotOpen)
        }
        return .opened
    }
}
// MARK: - 私有工具
private extension String {
    /// 尝试将任意字符串转为“可打开”的 URL：
    /// - 无 scheme 且像域名 → 自动补 `https://`
    /// - 做百分号编码，保证中文/空格安全
    static func makeURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        // 已包含 scheme：直接编码重建
        if trimmed.contains("://") {
            return percentEncodedURL(trimmed)
        }
        // 没有 scheme：如果像域名/路径，自动补 https://
        // 简单启发式：包含点号或以 "www." 开头，就按网址处理
        if trimmed.hasPrefix("www.") || trimmed.contains(".") {
            return percentEncodedURL("https://" + trimmed)
        }
        // 既没 scheme 又不像网址：当成无效
        return nil
    }
    /// 百分号编码（保留合法字符，编码空格、中文、emoji 等）
    static func percentEncodedURL(_ s: String) -> URL? {
        // 尽量宽松地保留 URL 合法字符，其余编码
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(charactersIn: "/:#?&=@!$'()*+,;[]%._~-") // 常见保留
        let encoded = s.addingPercentEncoding(withAllowedCharacters: allowed) ?? s
        return URL(string: encoded)
    }
    /// 只保留 0-9 与最前面的 '+'
    static func sanitizePhone(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return "" }

        var result = ""
        var seenPlus = false
        for ch in t {
            if ch == "+" && !seenPlus && result.isEmpty {
                result.append(ch)
                seenPlus = true
            } else if ch.isNumber {
                result.append(ch)
            }
        }
        return result
    }
    /// 解析多个邮箱：支持逗号/分号/空格
    static func _parseEmails(_ raw: String) -> [String] {
        raw
            .split { ",; ".contains($0) }
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.contains("@") }
    }

    static func _makeMailtoURL(to: [String],
                               subject: String?,
                               body: String?,
                               cc: [String],
                               bcc: [String]) -> URL? {
        var comps = URLComponents()
        comps.scheme = "mailto"
        comps.path = to.joined(separator: ",")
        var items: [URLQueryItem] = []
        if let subject, !subject.isEmpty { items.append(.init(name: "subject", value: subject)) }
        if let body, !body.isEmpty       { items.append(.init(name: "body", value: body)) }
        if !cc.isEmpty { items.append(.init(name: "cc", value: cc.joined(separator: ","))) }
        if !bcc.isEmpty { items.append(.init(name: "bcc", value: bcc.joined(separator: ","))) }
        comps.queryItems = items.isEmpty ? nil : items
        return comps.url
    }
}
// 内部委托：托管 MFMailComposeViewController 的回调与收尾
fileprivate final class _JobsMailProxy: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = _JobsMailProxy()
    var completion: ((JobsOpenResult) -> Void)?

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true) { [completion] in
            // 这层 API 只关心“是否成功调起”，这里统一回调 .opened
            completion?(.opened)
        }
        self.completion = nil
    }
}
