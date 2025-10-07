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
import Kingfisher
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
/// 图片解析错误类型
public enum KFError: Error {
    case badURL          // 非法 URL 或无法解析
    case notFound        // 本地图片不存在
}
/// 统一来源：远程 or 本地
public enum ImageSource {
    case remote(URL)
    case local(String)
}
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
