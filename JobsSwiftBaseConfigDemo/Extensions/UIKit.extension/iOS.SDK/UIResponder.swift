//
//  UIResponder.swift
//  Drop-in file
//
//  Created by Jobs on 2025/09/30.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import ObjectiveC
// MARK: - UIResponder → 最近的 VC（统一用 UIApplication 工具兜底）
extension UIResponder {
    /// 从任意 UIResponder（View / VC）向上找到最近的宿主 VC；若全程找不到则兜底到 keyWindow 的 root
    func jobsNearestVC() -> UIViewController? {
        var r: UIResponder? = self
        while let cur = r {
            if let vc = cur as? UIViewController { return vc }
            r = cur.next
        }
        // ✅ 优化：直接使用我们统一封装的 keyWindow 工具
        return UIApplication.jobsKeyWindow()?.rootViewController
    }
}
// MARK: - UINavigationController 辅助（前缀化）
extension UINavigationController {
    /// 若栈内已有“同目的地”，则 popTo；否则 push（无时间节流）
    func jobs_pushOrPopTo(_ vc: UIViewController, animated: Bool) {
        // 1) 动画进行中不叠加
        if transitionCoordinator != nil { return }
        // 2) 目标 VC 不能已挂载（避免“把已有父控制器的 VC 再 push”）
        if vc.parent != nil { return }
        // 3) 栈顶就是同目的地 → 忽略
        if let top = viewControllers.last, vc.jobs_isSameDestination(as: top) { return }
        // 4) 栈内存在同目的地 → popTo
        if let existed = viewControllers.first(where: { vc.jobs_isSameDestination(as: $0) }) {
            popToViewController(existed, animated: animated)
            return
        }
        // 5) 否则 push
        pushViewController(vc, animated: animated)
    }
}
// MARK: - 给“实现了 JobsDataReceivable 的 VC”提供强类型重载：编译期直达 receive(_:)
extension JobsDataReceivable where Self: UIViewController {
    @discardableResult
    func byData(_ data: InputData) -> Self {
        receive(data)
        return self
    }
}
