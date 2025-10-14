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
// MARK: - LanguageManager 单例
final class LanguageManager {
    static let shared = LanguageManager()
    private init() {}
    /// 当前语言对应的 Bundle
    var localizedBundle: Bundle {
        // 可以根据自己的逻辑动态返回
        // 比如通过 UserDefaults 保存的语言 key
        if let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }
    /// 当前语言代码（默认系统语言）
    var currentLanguageCode: String {
        UD.string(forKey: "AppLanguage") ?? Locale.preferredLanguages.first ?? "en"
    }
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
@MainActor
 public func showToast(_ text: String) {
     JobsToast.show(
         text: text,
         config: JobsToast.Config()
             .byBgColor(.systemGreen.withAlphaComponent(0.9))
             .byCornerRadius(12)
     )
}
