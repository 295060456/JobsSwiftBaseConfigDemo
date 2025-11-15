//
//  BaseStructDefines.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/2/25.
//

import Foundation
// MARK: - ShadowDirection
struct ShadowDirection: OptionSet {
    let rawValue: UInt
    static let top        = ShadowDirection([])
    static let down       = ShadowDirection(rawValue: 1 << 0)
    static let left       = ShadowDirection(rawValue: 1 << 1)
    static let right      = ShadowDirection(rawValue: 1 << 2)
    static let leftTop    = ShadowDirection(rawValue: 1 << 3)
    static let leftDown   = ShadowDirection(rawValue: 1 << 4)
    static let rightTop   = ShadowDirection(rawValue: 1 << 5)
    static let rightDown  = ShadowDirection(rawValue: 1 << 6)
    static let all: ShadowDirection = [.top, .down, .left, .right, .leftTop, .leftDown, .rightTop, .rightDown]
}
// MARK: - UIBorderSideType
struct UIBorderSideType: OptionSet {
    let rawValue: UInt
    static let all    = UIBorderSideType([])
    static let top    = UIBorderSideType(rawValue: 1 << 0)
    static let bottom = UIBorderSideType(rawValue: 1 << 1)
    static let left   = UIBorderSideType(rawValue: 1 << 2)
    static let right  = UIBorderSideType(rawValue: 1 << 3)
}
// MARK: - 这样写的话，外面可以JobsIndexPath.section 进行调用
struct JobsIndexPath {
    var section: Int
    var rowOrItem: Int
}
// MARK: - 无数据占位图的类型
struct JobsEmptyViewType: OptionSet {
    let rawValue: UInt
    static let none       = JobsEmptyViewType([])
    static let label      = JobsEmptyViewType(rawValue: 1 << 0)
    static let button     = JobsEmptyViewType(rawValue: 1 << 1)
    static let customView = JobsEmptyViewType(rawValue: 1 << 2)
}
/// 一些小工具
public struct JobsValidators {
    // MARK: - 非空验证
    static func nonEmpty(_ s: String) -> Bool {
        !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    // MARK: - 数值范围验证器
    static func decimal(min: Double? = nil, max: Double? = nil) -> (String) -> Bool {
        return { s in
            guard let v = Double(s) else { return false }
            if let min = min, v < min { return false }
            if let max = max, v > max { return false }
            return true
        }
    }
    // MARK: - 手机号验证（中国大陆）
    static func phoneCN() -> (String) -> Bool {
        return { s in
            // 去空格后的纯数字长度 11
            let digits = s.filter(\.isNumber)
            return digits.count == 11
        }
    }
}
/**
     let id18 = "510105199307315321"                 // 18位示例（应有效）
     let id15 = "130503670401001"                     // 15位经典示例
     do {
      let normalizedFrom18 = try CNID.validate(id18)      // 返回18位本身
      let normalizedFrom15 = try CNID.validate(id15)      // 自动转18位
      print("18 -> \(normalizedFrom18)")
      print("15 -> \(normalizedFrom15)")                  // 预期：13050319670401001X
     } catch { print("无效：\(error)") }

     print("isValid(18):", CNID.isValid(id18))
     print("isValid(15):", CNID.isValid(id15))
 */
// MARK: - 中国大陆居民身份证号码校验
public struct CNID {
    private static let re18 = try! NSRegularExpression(pattern: #"^\d{17}[\dX]$"#)
    private static let re15 = try! NSRegularExpression(pattern: #"^\d{15}$"#)
    private static let weights = [7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2]
    private static let map: [Int: Character] = [0:"1",1:"0",2:"X",3:"9",4:"8",5:"7",6:"6",7:"5",8:"4",9:"3",10:"2"]
    /// 快速校验：自动兼容 15/18 位
    static func isValid(_ raw: String) -> Bool { (try? validate(raw)) != nil }
    /// 严格校验：非法抛错。总是返回“归一化后的18位证号”
    @discardableResult
    static func validate(_ raw: String, centuryHintFor15: Int = 19) throws -> String {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if match(re18, s) { try validate18(s); return s }
        if match(re15, s) {
            let v18 = try convert15to18(s, centuryHint: centuryHintFor15)
            try validate18(v18)
            return v18
        }
        throw CNIDError.format
    }
    /// 将 15 位转换为 18 位（默认世纪 “19”）
    static func convert15to18(_ id15: String, centuryHint: Int = 19) throws -> String {
        guard match(re15, id15) else { throw CNIDError.format }
        let area = String(id15.prefix(6))
        let yymmdd = String(id15[id15.index(id15.startIndex, offsetBy:6)..<id15.index(id15.startIndex, offsetBy:12)])
        let seq = String(id15.suffix(3))
        // 15位默认表示 1900-1999 年出生（个别极边缘例外可通过 centuryHint 覆写为 20）
        let yearPrefix = String(centuryHint)
        let yyyyMMdd = yearPrefix + yymmdd
        let body17 = area + yyyyMMdd + seq
        let check = checksumFor(body17)
        return body17 + String(check)
    }

    private static func match(_ re: NSRegularExpression, _ s: String) -> Bool {
        re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
    }

    private static func validate18(_ id: String) throws {
        guard match(re18, id) else { throw CNIDError.format }
        // 出生日期
        let y = Int(id[Range(NSRange(location: 6, length: 4), in: id)!])!
        let m = Int(id[Range(NSRange(location:10, length:2), in: id)!])!
        let d = Int(id[Range(NSRange(location:12, length:2), in: id)!])!
        var comps = DateComponents(); comps.year = y; comps.month = m; comps.day = d
        let cal = Calendar(identifier: .gregorian)
        guard let birth = cal.date(from: comps) else { throw CNIDError.birthDate }
        let minDate = cal.date(from: DateComponents(year: 1900, month: 1, day: 1))!
        let maxDate = Date()
        guard (minDate ... maxDate).contains(birth) else { throw CNIDError.birthDate }
        // 顺序码≠"000"
        let seq = id[Range(NSRange(location:14, length:3), in: id)!]
        guard seq != "000" else { throw CNIDError.sequence }
        // 校验位
        let body17 = String(id.prefix(17))
        let expected = checksumFor(body17)
        guard id.last! == expected else { throw CNIDError.checksum }
    }

    private static func checksumFor(_ body17: String) -> Character {
        var sum = 0
        for (i, ch) in body17.enumerated() {
            sum += Int(ch.asciiValue! - Character("0").asciiValue!) * weights[i]
        }
        let r = sum % 11
        return map[r]!
    }
}
// MARK: - App 启动检查
public struct LaunchChecker {
    // 存储键（全部用 UInt8）
    private static let kFirstLaunchFlag = "com.jobs.launch.first"   // 0/1
    private static let kY = "com.jobs.launch.y"     // 年(偏移量)
    private static let kM = "com.jobs.launch.m"     // 月(1...12)
    private static let kD = "com.jobs.launch.d"     // 日(1...31)
    // 年份用 UInt8 不够装绝对年，这里做“偏移年”方案：year - 2000
    // 2000...2255 对应 0...255（足够未来几十年）
    private static let yearBase: Int = 2000
    /// 核心：执行一次检查并返回这次启动的类型
    @discardableResult
    public static func markAndClassifyThisLaunch(now: Date = Date()) -> LaunchKind {
        // 1) 是否首次安装启动
        let firstFlag = UD.uint8(forKey: kFirstLaunchFlag) ?? 0
        if firstFlag == 0 {
            UD.setUInt8(1, forKey: kFirstLaunchFlag)
            // 同时写入“今天”的 Y/M/D
            let (y,m,d) = ymd(from: now)
            writeYMD(y, m, d, UD: UD)
            UD.synchronize()
            logLaunch(kind: .firstInstallLaunch, now: now, lastYMD: nil)
            return .firstInstallLaunch
        }
        // 2) 当日首次：对比存储的 Y/M/D（全是 UInt8）
        let storedY = UD.uint8(forKey: kY)
        let storedM = UD.uint8(forKey: kM)
        let storedD = UD.uint8(forKey: kD)
        let (curY, curM, curD) = ymd(from: now)

        if storedY != curY || storedM != curM || storedD != curD {
            // 新的一天 → 更新 Y/M/D
            writeYMD(curY, curM, curD, UD: UD)
            UD.synchronize()
            logLaunch(kind: .firstLaunchToday,
                      now: now,
                      lastYMD: (storedY, storedM, storedD))
            return .firstLaunchToday
        }
        // 3) 普通启动
        logLaunch(kind: .normal, now: now, lastYMD: (storedY, storedM, storedD))
        return .normal
    }
    /// 是否为安装后的第一次启动（不产生副作用，纯读）
    public static var isFirstInstallLaunch: Bool {
        (UD.uint8(forKey: kFirstLaunchFlag) ?? 0) == 0
    }
    /// 是否为今天的第一次启动（不产生副作用，纯读）
    public static func isFirstLaunchToday(now: Date = Date()) -> Bool {
        guard
            let y = UD.uint8(forKey: kY),
            let m = UD.uint8(forKey: kM),
            let dd = UD.uint8(forKey: kD)
        else { return true } // 没存过，当作今天第一次
        let (cy, cm, cd) = ymd(from: now)
        return y != cy || m != cm || dd != cd
    }
    /// 调试/测试用：清空标记
    public static func reset() {
        UD.removeBy(kFirstLaunchFlag)
            .removeBy(kY)
            .removeBy(kM)
    }
}
// MARK: - 私有工具
private extension LaunchChecker {
    /// 以 UInt8 表示的 Y/M/D（年为 2000 基准偏移）
    static func ymd(from date: Date) -> (UInt8, UInt8, UInt8) {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "zh_CN")
        cal.timeZone = .current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let y = UInt8(clamping: (c.year ?? 2000) - yearBase)
        let m = UInt8(clamping: c.month ?? 1)
        let d = UInt8(clamping: c.day ?? 1)
        return (y, m, d)
    }

    static func writeYMD(_ y: UInt8,
                         _ m: UInt8,
                         _ d: UInt8,
                         UD: UserDefaults) {
        UD.setUInt8(y, forKey: kY)
        UD.setUInt8(m, forKey: kM)
        UD.setUInt8(d, forKey: kD)
    }
    /// “尽可能最全”的时间格式化（用于打印，而不是存储）
    static func fullFormatter() -> DateFormatter {
        let f = DateFormatter() 
        // 年月日 时分秒.毫秒 时区 星期 以及具体时区名和公历
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS ZZZZZ (VV) EEEE G"
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "zh_CN")
        f.timeZone = .current
        return f
    }
    static func logLaunch(
        kind: LaunchKind,
        now: Date,
        lastYMD: (UInt8?, UInt8?, UInt8?)? = nil
    ) {
        let stamp = fullFormatter().string(from: now)
        let last = lastYMD ?? (nil, nil, nil)

        func desc(_ tuple: (UInt8?, UInt8?, UInt8?)) -> String {
            if let y = tuple.0, let m = tuple.1, let d = tuple.2 {
                let absYear = Int(y) + yearBase
                return "\(absYear)-\(m)-\(d)"
            } else {
                return "缺失"
            }
        }
        switch kind {
        case .firstInstallLaunch:
            log("🎉 [Launch] 首次安装启动 @ \(stamp)")
        case .firstLaunchToday:
            log("🌅 [Launch] 当日首次启动 @ \(stamp)（上次记录：\(desc(last))）")
        case .normal:
            log("➡️ [Launch] 普通启动 @ \(stamp)（最近启动日：\(desc(last))）")
        }
    }
}
// MARK: - 通用于 UITableViewCell 和 UICollectionViewCell 的模型组件
public struct JobsCellConfig {
    public let title: JobsText?
    public let detail: JobsText?
    public let image: UIImage?
    public let data: Any?

    public init(title: JobsText? = nil,
                detail: JobsText? = nil,
                image: UIImage? = nil,
                data: Any? = nil) {
        self.title = title
        self.detail = detail
        self.image = image
        self.data = data
    }
}
