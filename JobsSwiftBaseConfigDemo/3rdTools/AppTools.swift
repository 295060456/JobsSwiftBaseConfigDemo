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
    let alert = UIAlertController(
        title: "点击链接",
        message: "已点击：\(urlString)",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "确定", style: .default))
    // 💡 iOS17+ 的 delegate 可能不在当前 VC，需要兜底 rootViewController
    let host = textView.window?.rootViewController
            ?? UIApplication.jobsTopMostVC(ignoreAlert: true)   // ✅ 统一找最顶 VC
    host?.present(alert, animated: true)
}
// MARK: - 启动分类处理（Block DSL）
///
/// - Parameters:
///   - firstInstall: 安装后第一次启动
///   - firstToday: 当天第一次启动
///   - normal: 普通启动
public struct AppLaunchManager {
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
        }

        return kind
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

public func fmt(_ date: Date, _ f: String) -> String {
    DateFormatter().byLocale(.current).byDateFormat(f).string(from: date)
}
/// 分割线
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
