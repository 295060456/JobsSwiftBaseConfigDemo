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

