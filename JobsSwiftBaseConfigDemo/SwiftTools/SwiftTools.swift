//
//  SwiftTools.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

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

enum JobsValidators {
    /// 非空验证
    static func nonEmpty(_ s: String) -> Bool { !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    /// 数值范围验证器
    static func decimal(min: Double? = nil, max: Double? = nil) -> (String) -> Bool {
        return { s in
            guard let v = Double(s) else { return false }
            if let min = min, v < min { return false }
            if let max = max, v > max { return false }
            return true
        }
    }
    ///手机号验证（中国大陆）
    static func phoneCN() -> (String) -> Bool {
        return { s in
            // 去空格后的纯数字长度 11
            let digits = s.filter(\.isNumber)
            return digits.count == 11
        }
    }
}
