//
//  JobsSafeRouting.swift
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
// MARK: - 路由目的地等价（避免重名-前缀化）
/// 默认“同类型 = 同目的地”。需要区分同类不同参数时，在目标 VC 里 override `jobs_isSameDestination(as:)`
protocol JobsRouteComparable {
    func jobs_isSameDestination(as other: UIViewController) -> Bool
}

extension UIViewController: JobsRouteComparable {
    @inline(__always)
    func jobs_isSameDestination(as other: UIViewController) -> Bool {
        type(of: self) == type(of: other)
    }
}
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
// MARK: - 数据传递（byData / inputData / onResult / sendResult）
private enum JobsAssocKey {
    static var inputData: UInt8 = 0
    static var onResult: UInt8 = 1   // ⬅️ 只保留 Any 回调
}
// MARK: - 强类型输入协议（可选实现）
protocol JobsDataReceivable {
    associatedtype InputData
    func receive(_ data: InputData)
}
// MARK: - 给“实现了 JobsDataReceivable 的 VC”提供强类型重载：编译期直达 receive(_:)
extension JobsDataReceivable where Self: UIViewController {
    @discardableResult
    func byData(_ data: InputData) -> Self {
        receive(data)
        return self
    }
}
// MARK: - 兜底：任何 VC 都能先把数据塞进关联对象，VC 内再 `inputData()` 取
extension UIViewController {
    // MARK: - 任意类型数据注入
    /// 可注入任何类型（Int、Double、String、Array、Dictionary、自定义结构体...）
    @discardableResult
    func byData(_ data: Any?) -> Self {
        objc_setAssociatedObject(self, &JobsAssocKey.inputData, data, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    // MARK: - 数据读取:按指定类型取出注入的数据（类型安全）
    func inputData<T>() -> T? {
        objc_getAssociatedObject(self, &JobsAssocKey.inputData) as? T
    }
    // MARK: - 结果回调:订阅任意回传类型
    @discardableResult
    func onResult(_ callback: @escaping (Any) -> Void) -> Self {
        objc_setAssociatedObject(self, &JobsAssocKey.onResult, callback, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
    // MARK: - 触发回传（传任何类型都行）
    func sendResult(_ result: Any) {
        if let cb = objc_getAssociatedObject(self, &JobsAssocKey.onResult) as? (Any) -> Void {
            cb(result)
        }
    }
    // MARK: - 便捷：回传后关闭当前页（push→pop / present→dismiss）
    @discardableResult
    func closeByResult(_ result: Any?, animated: Bool = true) -> Self {
        if let r = result { sendResult(r) }
        if let nav = navigationController { nav.popViewController(animated: animated) }
        else { dismiss(animated: animated) }
        return self
    }
}
// MARK: - 链式导航（基于“栈内容去重”，无时间节流）
extension UIViewController {
    // MARK: - Push：基于“目的地等价”逻辑
    /// 1) 栈顶同目的地 → 忽略
    /// 2) 栈内存在同目的地 → popTo
    /// 3) 否则 → push
    @discardableResult
    func byPush(_ from: UIResponder, animated: Bool = true) -> Self {
        guard let host = from.jobsNearestVC() else {
            assertionFailure("byPush: 未找到宿主 VC"); return self
        }

        if let nav = (host as? UINavigationController) ?? host.navigationController {
            nav.jobs_pushOrPopTo(self, animated: animated)
            return self
        } else {
            // 没有导航栈 → 包一层再 present（首次进入）
            guard self.parent == nil else { return self } // 目标不能已挂载
            if host.transitionCoordinator != nil || host.presentedViewController != nil { return self }

            let wrapper = UINavigationController(rootViewController: self)
            wrapper.isNavigationBarHidden = true
            wrapper.modalPresentationStyle = .fullScreen
            host.present(wrapper, animated: animated)
            return self
        }
    }
    // MARK: - Present：合法性校验 + 同目的地已展示则忽略
    @discardableResult
    func byPresent(_ from: UIResponder, animated: Bool = true) -> Self {
        guard let host = from.jobsNearestVC() else {
            assertionFailure("byPresent: 未找到宿主 VC"); return self
        }

        // 目标不能已挂载（否则就是“把已有父控制器再 present”→ 系统崩）
        if self.parent != nil { return self }
        // 宿主在做转场 → 不叠加
        if host.transitionCoordinator != nil { return self }
        // 已有一个 presentedVC：同目的地则忽略，否则不叠加（保持简单、稳定）
        if let presented = host.presentedViewController {
            if self.jobs_isSameDestination(as: presented) { return self }
            return self
        }

        host.present(self, animated: animated)
        return self
    }
}
