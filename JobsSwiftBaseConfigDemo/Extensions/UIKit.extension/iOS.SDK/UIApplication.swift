//
//  UIApplication.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/30/25.
//

import UIKit
/**
     // 取 keyWindow
     let win = UIApplication.jobsKeyWindow()

     // 取最顶层可见 VC（做 push/present 的宿主）
     if let topVC = UIApplication.jobsTopMostVC() {
         // ... 用 topVC 做 present 或你的 pushSafely 入口
     }
 */
// MARK: - Key Window（跨版本最大兼容）
public extension UIApplication {
    /// 顶层可见 VC（支持多 Scene；覆盖 Nav/Tab/Split/PageVC/Presented；可忽略 Alert）
    static func jobsTopMostVC(
        from root: UIViewController? = nil,
        in scene: UIScene? = nil,
        ignoreAlert: Bool = false
    ) -> UIViewController? {
        // 1) 选择 root：入参优先 → 指定 scene → 自动挑选最合适的 scene
        let rootVC: UIViewController? = {
            if let root = root { return root }
            if let ws = (scene as? UIWindowScene) ?? bestWindowScene() {
                return bestRootViewController(in: ws)
            }
            return nil
        }()
        // 2) 递归解析
        func dig(_ vc: UIViewController?) -> UIViewController? {
            guard let vc else { return nil }

            // UINavigationController
            if let nav = vc as? UINavigationController {
                return dig(nav.visibleViewController ?? nav.topViewController ?? nav)
            }
            // UITabBarController
            if let tab = vc as? UITabBarController {
                return dig(tab.selectedViewController ?? tab)
            }
            // UISplitViewController（取最右侧详情）
            if let split = vc as? UISplitViewController {
                return dig(split.viewControllers.last ?? split)
            }
            // UIPageViewController（当前页）
            if let page = vc as? UIPageViewController,
               let current = page.viewControllers?.first {
                return dig(current)
            }
            // 被 present 出来的控制器
            if let presented = vc.presentedViewController {
                if ignoreAlert, presented is UIAlertController {
                    // 忽略 Alert：保留当前 vc
                } else {
                    return dig(presented)
                }
            }
            return vc
        }
        return dig(rootVC)
    }
    // MARK: - Scene / Window 选择策略
    private static func bestWindowScene() -> UIWindowScene? {
        // 前台激活 > 前台非激活 > 其余
        func rank(_ s: UIScene.ActivationState) -> Int {
            switch s {
            case .foregroundActive:   return 0
            case .foregroundInactive: return 1
            case .background:         return 2
            default:                  return 3
            }
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .sorted { rank($0.activationState) < rank($1.activationState) }
            .first
    }

    private static func bestRootViewController(in ws: UIWindowScene) -> UIViewController? {
        // 优先 keyWindow；没有就找可见的 normal window
        let windows = ws.windows
        let window = windows.first(where: \.isKeyWindow)
            ?? windows.first(where: { !$0.isHidden && $0.alpha > 0 && $0.windowLevel == .normal })
            ?? windows.first
        return window?.rootViewController
    }
}

public extension UIApplication {
    // MARK: - 获取当前“最合理”的 Key Window（多 Scene / 外接屏 / 可见性 / windowLevel 兼容，支持 iOS 13 多场景；老系统兜底）
    /// - Parameters:
    ///   - scene: 指定 UIScene；nil 则自动从所有 connectedScenes 中择优
    ///   - preferMainScreen: 优先主屏幕（避免取到外接屏/CarPlay 的 window）
    static func jobsKeyWindow(in scene: UIScene? = nil,
                              preferMainScreen: Bool = true) -> UIWindow? {
        // 建议在主线程调用
        assert(Thread.isMainThread, "jobsKeyWindow should be called on main thread")

        if #available(iOS 13.0, *) {
            // 1) 场景优先级：前台激活 > 前台非激活 > 其余
            let allScenes: [UIWindowScene] = {
                if let s = scene as? UIWindowScene { return [s] }
                return UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            }()

            func sceneRank(_ s: UIScene.ActivationState) -> Int {
                switch s {
                case .foregroundActive:   return 0
                case .foregroundInactive: return 1
                case .background:         return 2
                default:                  return 3
                }
            }

            let orderedScenes = allScenes.sorted {
                sceneRank($0.activationState) < sceneRank($1.activationState)
            }

            // 2) 在每个 scene 内挑“最佳窗口”
            for ws in orderedScenes {
                if let w = bestWindow(in: ws, preferMainScreen: preferMainScreen) {
                    return w
                }
            }
            return nil
        } else {
            // < iOS 13：没有 Scene 的年代
            // 先用 keyWindow；再挑可见 normal-level 的；最后兜底任何一个
            let app = UIApplication.shared
            if let w = app.keyWindow { return w }
            let visibleNormal = app.windows.first {
                !$0.isHidden && $0.alpha > 0.01 && $0.windowLevel == .normal
            }
            return visibleNormal ?? app.windows.first
        }
    }
    // MARK: - 全局安全区 Insets（无视当前 VC）
    static var jobsSafeAreaInsets: UIEdgeInsets {
        jobsKeyWindow()?.safeAreaInsets ?? .zero
    }
    // MARK: - 顶部安全区（状态栏 + 自定义导航栏）
    static var jobsSafeTopInset: CGFloat {
        let statusBarHeight = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .statusBarManager?.statusBarFrame.height ?? 0
        let navHeight: CGFloat = 44
        return statusBarHeight + navHeight
    }
    // MARK: - 底部安全区（Home Indicator / TabBar）
    static var jobsSafeBottomInset: CGFloat {
        jobsKeyWindow()?.safeAreaInsets.bottom ?? 0
    }
    // MARK: - 左安全区（横屏时）
    static var jobsSafeLeftInset: CGFloat {
        jobsKeyWindow()?.safeAreaInsets.left ?? 0
    }
    // MARK: - 右安全区（横屏时）
    static var jobsSafeRightInset: CGFloat {
        jobsKeyWindow()?.safeAreaInsets.right ?? 0
    }
}
// MARK: - Helpers (iOS 13+)
@available(iOS 13.0, *)
private func bestWindow(in ws: UIWindowScene, preferMainScreen: Bool) -> UIWindow? {
    let windows = ws.windows
    if windows.isEmpty { return nil }

    // keyWindow 优先
    if let key = windows.first(where: \.isKeyWindow) {
        if !preferMainScreen || key.screen == UIScreen.main { return key }
    }

    // 按可见性/level/主屏偏好排序
    func windowRank(_ w: UIWindow) -> (Int, Int, Int) {
        // 0: 可见(normal) > 1: 可见(非normal) > 2: 其他
        let visibilityGroup: Int = {
            guard !w.isHidden, w.alpha > 0.01 else { return 2 }
            return (w.windowLevel == .normal) ? 0 : 1
        }()
        // 主屏优先
        let screenGroup = (preferMainScreen && w.screen != UIScreen.main) ? 1 : 0
        // windowLevel 越接近 normal 越好
        let levelDistance = Int(abs(w.windowLevel.rawValue - UIWindow.Level.normal.rawValue))
        return (visibilityGroup, screenGroup, levelDistance)
    }

    let sorted = windows.sorted { a, b in windowRank(a) < windowRank(b) }
    return sorted.first
}
