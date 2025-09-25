//
//  NSString.swift
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
        let trimmedString = self.lowercased()
        if trimmedString == "true" || trimmedString == "false" {
            return (trimmedString as NSString).boolValue
        }
        return nil
    }
    // MARK: - String 转 NSString
    public var toNSString: NSString {
        return self as NSString
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
