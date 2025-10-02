//
//  SwiftTools.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

import Foundation

// MARK: - 扩展 Int 与 JXAuthCode 的比较
public func ==(lhs: Int?, rhs: JXAuthCode) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs == Int(rhs.rawValue)
}

public func ==(lhs: Int, rhs: JXAuthCode) -> Bool {
    return lhs == Int(rhs.rawValue)
}

public func ==(lhs: JXAuthCode, rhs: Int?) -> Bool {
    guard let rhs = rhs else { return false }
    return Int(lhs.rawValue) == rhs
}

public func ==(lhs: JXAuthCode, rhs: Int) -> Bool {
    return Int(lhs.rawValue) == rhs
}
// MARK: - 扩展 Int 与 JXAuthCode 的不等于
public func !=(lhs: Int?, rhs: JXAuthCode) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: Int, rhs: JXAuthCode) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: JXAuthCode, rhs: Int?) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: JXAuthCode, rhs: Int) -> Bool {
    !(lhs == rhs)
}
// MARK: - 🧠 Unicode 解码：把 \uXXXX / \UXXXXXXXX 转成真实字符
private func decodeUnicodeEscapes(in string: String) -> String {
    let temp = string
        .replacingOccurrences(of: "\\u", with: "\\U")
        .replacingOccurrences(of: "\"", with: "\\\"")
    let data = "\"\(temp)\"".data(using: .utf8)!
    if let decoded = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? String {
        return decoded
    }
    return string
}
// MARK: - 🚀 统一日志打印
func log(_ items: Any..., separator: String = " ", terminator: String = "\n",
         file: String = #file,
         line: Int = #line,
         function: String = #function) {
    // 1️⃣ 拼接参数
    let message = items.map { "\($0)" }.joined(separator: separator)
    let decoded = decodeUnicodeEscapes(in: message)
    // 2️⃣ 文件名提取
    let fileName = (file as NSString).lastPathComponent
    // 3️⃣ 时间戳
    let time = currentTimeString()
    // 4️⃣ 输出格式（最简洁但信息量最大）
    Swift.print("🕒 \(time) | \(fileName):\(line) | \(function) → \(decoded)", terminator: terminator)
}
/// 🕒 时间格式（时:分:秒）
private func currentTimeString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    formatter.locale = Locale(identifier: "zh_CN")
    return formatter.string(from: Date())
}
// MARK: - 工具：常用格式化 & 校验
enum JobsFormatters {
    /// 仅保留数字与一个小数点，并限制到 scale 位小数（默认 2 位）
    static func decimal(scale: Int = 2) -> (String) -> String {
        return { s in
            let chars = Array(s)
            var out: [Character] = []
            var dotSeen = false
            var fracCount = 0
            for ch in chars {
                if ch.isNumber { // 0~9
                    if dotSeen {
                        if fracCount < scale {
                            out.append(ch)
                            fracCount += 1
                        }
                    } else {
                        out.append(ch)
                    }
                } else if ch == "." && !dotSeen {
                    // 第一颗小数点
                    dotSeen = true
                    if out.isEmpty { out.append("0") } // 形如 ".1" -> "0.1"
                    out.append(".")
                }
            }
            // 去掉首部多余 0：保留 "0" 或 "0.xxx"
            // （注意：不做进位，仅做清洗）
            let str = String(out)
            if str.hasPrefix("00") {
                // 粗暴去多零
                let trimmed = str.drop(while: { $0 == "0" })
                if trimmed.first == "." { return "0" + trimmed }
                return trimmed.isEmpty ? "0" : String(trimmed)
            }
            return str.isEmpty ? "" : str
        }
    }
    /// 中国大陆手机号 3-4-4 分组（仅清洗与分组，不做合法号段校验）
    static func phoneCN() -> (String) -> String {
        return { s in
            let digits = s.filter(\.isNumber)
            var parts: [String] = []
            let c = digits.count
            if c <= 3 {
                parts = [digits]
            } else if c <= 7 {
                let p1 = String(digits.prefix(3))
                let p2 = String(digits.dropFirst(3))
                parts = [p1, p2]
            } else {
                let p1 = String(digits.prefix(3))
                let p2 = String(digits.dropFirst(3).prefix(4))
                let p3 = String(digits.dropFirst(7).prefix(4))
                parts = [p1, p2, p3].filter { !$0.isEmpty }
            }
            return parts.joined(separator: " ")
        }
    }
}

