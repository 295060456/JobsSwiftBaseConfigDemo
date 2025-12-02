//
//  AppTools.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/29/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import SwiftEntryKit
import SnapKit
// MARK: 🔔 通用弹窗提示
public func presentAlert(for urlString: String, on textView: UITextView) {
    // 💡 iOS17+：delegate 不一定是当前 VC，用原来的兜底逻辑
    guard let host = textView.window?.rootViewController
        ?? UIApplication.jobsTopMostVC(ignoreAlert: true) else {
        return
    }

    UIAlertController
        .makeAlert("点击链接", "已点击：\(urlString)")
        .byAddOK()                  // 默认“确定”按钮
        .byPresent(host)            // 用你封装过的 present 逻辑
}
// MARK: - 启动分类处理（Block DSL）
///
/// - Parameters:
///   - firstInstall: 安装后第一次启动
///   - firstToday: 当天第一次启动
///   - normal: 普通启动
public enum AppLaunchManager {
    @discardableResult
    public static func handleLaunch(
        firstInstall: (() -> Void)? = nil,
        firstToday: (() -> Void)? = nil,
        normal: (() -> Void)? = nil
    ) -> LaunchKind {
        let kind = LaunchChecker.markAndClassifyThisLaunch()
        switch kind {
        case .firstInstallLaunch:
            print("🎉 首次安装启动")
            firstInstall?()
        case .firstLaunchToday:
            print("🌅 当日首次启动")
            firstToday?()
        case .normal:
            print("📦 普通启动")
            normal?()
        };return kind
    }
}
// MARK: - App 启动检查
public enum LaunchChecker {
    // 存储键（全部用 UInt8）
    static let kFirstLaunchFlag = "com.jobs.launch.first"   // 0/1
    static let kY = "com.jobs.launch.y"     // 年(偏移量)
    static let kM = "com.jobs.launch.m"     // 月(1...12)
    static let kD = "com.jobs.launch.d"     // 日(1...31)
    // 年份用 UInt8 不够装绝对年，这里做“偏移年”方案：year - 2000
    // 2000...2255 对应 0...255（足够未来几十年）
    static let yearBase: Int = 2000
    /// 核心：执行一次检查并返回这次启动的类型
    @discardableResult
    public static func markAndClassifyThisLaunch(now: Date = Date()) -> LaunchKind {
        // 1) 是否首次安装启动
        let firstFlag = UD.uint8(forKey: kFirstLaunchFlag) ?? 0
        if firstFlag == 0 {
            UD.setUInt8(1, forKey: kFirstLaunchFlag)
            // 同时写入“今天”的 Y/M/D
            let (y, m, d) = ymd(from: now)
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
            let y  = UD.uint8(forKey: kY),
            let m  = UD.uint8(forKey: kM),
            let dd = UD.uint8(forKey: kD)
        else {
            // 没存过，当作今天第一次
            return true
        }
        let (cy, cm, cd) = ymd(from: now)
        return y != cy || m != cm || dd != cd
    }
    /// 调试/测试用：清空标记
    public static func reset() {
        UD.removeBy(kFirstLaunchFlag)
            .removeBy(kY)
            .removeBy(kM)
            .removeBy(kD)
    }
}
// MARK: - 私有工具
extension LaunchChecker {
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
// MARK: - 关于时间格式化
public func nowClock() -> String {
    DateFormatter()
        .byLocale(.autoupdatingCurrent)
        .byTimeZone(.autoupdatingCurrent)
        .byDateFormat("HH:mm:ss")
        .string(from: Date())
}

public func fmt(_ d: Date) -> String {
    DateFormatter().byDateFormat("HH:mm:ss.SSS").string(from: d)
}
// MARK: - 判断目标字符串是否是URL
@inline(__always)
public func isHttpURL(_ raw: String?) -> Bool {
    guard let s = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
          !s.isEmpty
    else { return false }
    let p = s.lowercased()
    return p.hasPrefix("http://") || p.hasPrefix("https://")
}
// MARK: - Tips
func toastBy(_ string: String) {
    /// 允许任意线程调用这个方法
    Task { @MainActor in
        JobsToast.show(
            text: string,
            config: JobsToast.Config()
                .byBgColor(.systemGreen.withAlphaComponent(0.9))
                .byCornerRadius(12)
        )
    }
}
/// 全局通用注册@UITableViewCell及其子类
extension UITableView {
    @discardableResult
    func register() -> Self{
        self.registerCell(AvatarCell.self)
        self.registerCell(UITableViewCell.self)

        self.registerCell(BaseTableViewCellByDefault.self)
        self.registerCell(BaseTableViewCellByValue1.self)
        self.registerCell(BaseTableViewCellByValue2.self)
        self.registerCell(BaseTableViewCellBySubtitle.self)

        return self;
    }
}
/// 全局通用注册@UICollectionViewCell及其子类
extension UICollectionView {
    @discardableResult
    func register() -> Self{
        self.registerCell(UICollectionViewCell.self)
        return self;
    }
}
// MARK: - 弹窗策略
public func makeEKAttributes() -> EKAttributes{
    let anim = EKAttributes.animScaleInFadeOut
    return EKAttributes()
        .byPosition(.center)
        .byDuration(.infinity)  // 交互型：不自动消失
        // 统一交给 EK 控制外观
        .byBackground(.color(color: EKColor(.secondarySystemBackground)))
        .byCorner(radius: 14)
        .byShadow()
        // 外部点击无效，必须点按钮
        .byEntryInteraction(.absorbTouches)
        .byScreenInteraction(.forward)
        // 给一点儿半透明遮罩增强聚焦，但不响应关闭
        .byScreen(.color(color: EKColor(UIColor(white: 0, alpha: 0.15))))
        .byDisplayMode(.inferred)
        .byStatusBar(.inferred)
        .byEntrance(anim.entrance)
        .byExit(anim.exit)
}
// MARK: - 时间格式化策略
public func fmt(_ date: Date, _ f: String) -> String {
    DateFormatter().byLocale(.current).byDateFormat(f).string(from: date)
}
// MARK: - 分割线
extension UIView {
    /// 在指定 view 下方添加一条分割线，添加到当前 view（self）上
    @discardableResult
    func makeBelowSeparatorBy(below anchor:UIView ,offset t:CGFloat = 0.0) -> UIView {
        UIView()
            .byBgColor("#3C3C431F".cor)
            .byAddTo(self) { make in
                make.height.equalTo(0.6)
                make.top.equalTo(anchor.snp.bottom).offset(t)
                make.left.right.equalToSuperview()
            }
    }
    /// 在当前 UILayoutGuide 下方添加一条分割线，添加到它的 owningView 上
    @discardableResult
    func makeBelowSeparatorBy(below anchor:UILayoutGuide ,offset t: CGFloat = 0.0) -> UIView? {
        // 1️⃣ owningView 是可选，要先解包，而且函数要返回 UIView
        guard let hostView = anchor.owningView else {
            assertionFailure("UILayoutGuide 没有 owningView，无法添加分割线")
            return nil
        }
        // 2️⃣ 分割线加到 hostView 上，约束基于“当前 guide(self)” 的 bottom
        return UIView()
            .byBgColor("#3C3C431F".cor)
            .byAddTo(hostView) { make in
                make.height.equalTo(0.6)
                make.top.equalTo(anchor.snp.top).offset(t)
                make.left.right.equalToSuperview()
            }
    }
}
// MARK: - 网络监听
private enum JobsNetworkListenerKeys {
    static var labelKey: UInt8 = 0
}

public extension UIView {
    /// 为当前 view 创建 / 复用一个悬浮网络监听 Label
    @discardableResult
    func makeNetworkListener(in containerView: UIView? = nil) -> UILabel {
        // 1️⃣ 如果已经有了，直接复用
        if let cached = objc_getAssociatedObject(self, &JobsNetworkListenerKeys.labelKey) as? UILabel {
            return cached
        }
        // 2️⃣ 第一次创建
        let container = containerView ?? self
        let label = UILabel()
            .byText("网络初始化中...")
            .byFont(.systemFont(ofSize: 11, weight: .medium))
            .byTextColor(.white)
            .byNumberOfLines(2)
            .byTextAlignment(.center)
            .byBgColor(UIColor.black.withAlphaComponent(0.7))
            .byCornerRadius(8)
            .byMasksToBounds(true)
            .byUserInteractionEnabled(YES)
            .bySuspend { cfg in
                cfg
                    .byContainer(container)
                    .byStart(.point(CGPoint(x: Screen.width - 160,
                                            y: Screen.height - 200))) // 起始点（可用区域坐标）
                    .byFallbackSize(CGSize(width: 140, height: 48))
                    .byDocking(.nearestEdge)
                    .byHapticOnDock(true)
            }
        // 3️⃣ 关联到当前 view，保证之后都是这一个
        objc_setAssociatedObject(self,
                                 &JobsNetworkListenerKeys.labelKey,
                                 label,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return label
    }
}

func networkNormalListenerBy(_ view:UIView){
    JobsNetworkTrafficMonitor.shared
        .byOnUpdate {source, up, down in

            let upStr   = jobs_formatSpeed(up)
            let downStr = jobs_formatSpeed(down)

            let text = """
            源: \(source.displayName)
            ⬆︎ \(upStr)  ⬇︎ \(downStr)
            """

            view.makeNetworkListener().byText(text)
        }
        .byStart(interval: 1.0)
}

func networkRichListenerBy(_ view:UIView){
    JobsNetworkTrafficMonitor.shared
        .byOnUpdate {source, up, down in
            let upStr   = jobs_formatSpeed(up)
            let downStr = jobs_formatSpeed(down)
            // 段落样式：居中 + 行距
            let paragraph = jobsMakeParagraphStyle { ps in
                ps.alignment = .center
                ps.lineSpacing = 2
            }
            // 用 JobsRichText 拼富文本
            let attr = JobsRichText.make([
                // 第 1 行：源
                JobsRichRun(.text("源: "))
                    .font(.systemFont(ofSize: 10, weight: .medium))
                    .color(.secondaryLabel),

                JobsRichRun(.text(source.displayName))
                    .font(.systemFont(ofSize: 11, weight: .semibold))
                    .color(.white),

                JobsRichRun(.text("\n")),
                // 第 2 行：上行
                JobsRichRun(.text("⬆︎ "))
                    .font(.systemFont(ofSize: 11))
                    .color(.systemGreen),

                JobsRichRun(.text(upStr + "  "))
                    .font(.monospacedDigitSystemFont(ofSize: 11, weight: .medium))
                    .color(.white),
                // 下行
                JobsRichRun(.text("⬇︎ "))
                    .font(.systemFont(ofSize: 11))
                    .color(.systemRed),

                JobsRichRun(.text(downStr))
                    .font(.monospacedDigitSystemFont(ofSize: 11, weight: .medium))
                    .color(.white)
            ], paragraphStyle: paragraph)
            // 单例悬浮 Label + 富文本
            view.makeNetworkListener().byAttributedString(attr)
        }
        .byStart(interval: 1.0)
}
/// UIScrollView 的投射距离：减速到 0 速度时走了多少路
/// v0: 手指离开瞬间的速度（pt/s）
/// d: UIScrollView.DecelerationRate.normal.rawValue 之类
func projectDistance(v0: CGFloat,
                     decelerationRate d: CGFloat) -> CGFloat {
    return (v0 / 1000.0) * d / (1.0 - d)
}
