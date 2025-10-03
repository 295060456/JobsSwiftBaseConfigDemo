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
// MARK: 🔎 获取当前最顶层控制器
private func topViewController(
    base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
        .first
) -> UIViewController? {
    if let nav = base as? UINavigationController {
        return topViewController(base: nav.visibleViewController)
    } else if let tab = base as? UITabBarController {
        return topViewController(base: tab.selectedViewController)
    } else if let presented = base?.presentedViewController {
        return topViewController(base: presented)
    }
    return base
}
// MARK: 🔔 通用弹窗提示
public func presentAlert(for urlString: String, on textView: UITextView) {
    let alert = UIAlertController(
        title: "点击链接",
        message: "已点击：\(urlString)",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "确定", style: .default))
    // 💡 iOS17+ 的 delegate 可能不在当前 VC，需要兜底 rootViewController
    if let vc = textView.window?.rootViewController {
        vc.present(alert, animated: true)
    } else if let vc = topViewController() {
        vc.present(alert, animated: true)
    }
}

extension NSObject: Then {}
// MARK: - LanguageManager 单例
final class LanguageManager {
    static let shared = LanguageManager()
    private init() {}

    /// 当前语言对应的 Bundle
    var localizedBundle: Bundle {
        // 你可以根据自己的逻辑动态返回
        // 比如通过 UserDefaults 保存的语言 key
        if let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    /// 当前语言代码（默认系统语言）
    var currentLanguageCode: String {
        UserDefaults.standard.string(forKey: "AppLanguage") ?? Locale.preferredLanguages.first ?? "en"
    }
}
