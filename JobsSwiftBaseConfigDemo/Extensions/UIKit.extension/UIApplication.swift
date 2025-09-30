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
    /// 统一的 KeyWindow 获取（支持 iOS 13 多场景；老系统兜底）
    static func jobsKeyWindow(in scene: UIScene? = nil) -> UIWindow? {
        if #available(iOS 13.0, *) {
            // 1) 场景优先：先用传入的 scene；否则用所有 connectedScenes
            let scenes: [UIWindowScene] = (scene != nil
                                           ? [scene].compactMap { $0 as? UIWindowScene }
                                           : UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene })

            // 2) 先找前台激活 → 前台非激活 → 其余
            let orderedScenes = scenes.sorted { lhs, rhs in
                // foregroundActive 优先
                func rank(_ s: UIScene.ActivationState) -> Int {
                    switch s {
                    case .foregroundActive:   return 0
                    case .foregroundInactive: return 1
                    case .background:         return 2
                    default:                  return 3
                    }
                }
                return rank(lhs.activationState) < rank(rhs.activationState)
            }

            // 3) 在每个 scene 的 windows 里先找 isKeyWindow；没有就取第一个可见 window
            for ws in orderedScenes {
                let windows = ws.windows
                if let key = windows.first(where: { $0.isKeyWindow }) { return key }
                if let first = windows.first { return first }
            }
            // 4) 兜底：若仍然拿不到，返回 nil
            return nil
        } else {
            // < iOS 13 旧式 API 兜底
            // keyWindow 在无场景时代可用；若为 nil，则从 windows 里取第一个
            return UIApplication.shared.keyWindow
                ?? UIApplication.shared.windows.first { $0.isKeyWindow }
                ?? UIApplication.shared.windows.first
        }
    }
    // MARK: - 顶层可见 VC（配合 jobsKeyWindow）
    /// 获取当前“最顶层可见”的 UIViewController（递归解析：Nav/Tab/Split/Presented）
    static func jobsTopMostVC(from root: UIViewController? = {
        jobsKeyWindow()?.rootViewController
    }()) -> UIViewController? {
        guard let root = root else { return nil }

        // UINavigationController
        if let nav = root as? UINavigationController {
            return jobsTopMostVC(from: nav.visibleViewController ?? nav.topViewController)
        }
        // UITabBarController
        if let tab = root as? UITabBarController {
            return jobsTopMostVC(from: tab.selectedViewController)
        }
        // UISplitViewController（取最右侧详情栈）
        if let split = root as? UISplitViewController, let last = split.viewControllers.last {
            return jobsTopMostVC(from: last)
        }
        // 被 present 出来的控制器
        if let presented = root.presentedViewController {
            // 若是 UIAlertController，按需返回其 presenting（看你业务，这里不特殊处理）
            return jobsTopMostVC(from: presented)
        }
        // 其他情况：就是它本身
        return root
    }
}
