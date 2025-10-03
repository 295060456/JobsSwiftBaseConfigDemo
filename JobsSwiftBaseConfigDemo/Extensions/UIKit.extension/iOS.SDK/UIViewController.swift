//
//  Untitled.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import GKNavigationBarSwift

@MainActor
public extension UIViewController {
    @discardableResult
    func byTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        // ⚠️ 确保 view 已加载，否则强制加载
        if viewIfLoaded == nil { loadViewIfNeeded() }
        self.view.backgroundColor = color
        return self
    }

    @discardableResult
    func addChildVC(_ child: UIViewController) -> Self {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        return self
    }
    /// 标准三步逆过程：willMove(nil) -> removeFromSuperview -> removeFromParent
    @discardableResult
    func removeFromParentVC() -> Self {
        guard parent != nil else { return self }
        self.willMove(toParent: nil)
        // 只移除自身 root view，不动外部 UI
        self.view.removeFromSuperview()
        self.removeFromParent()
        return self
    }

    @discardableResult
    func byPresentModallyAnimated(_ viewController: UIViewController,
                                  completion: (() -> Void)? = nil) -> Self {
        self.present(viewController,
                     animated: true,
                     completion: completion)
        return self
    }
    /// preferredContentSize 常用于 sheet / popover / containment
    @discardableResult
    func byPreferredContentSize(_ size: CGSize) -> Self {
        self.preferredContentSize = size
        return self
    }
    // ------------------------------ 状态栏外观 ------------------------------
    /// iOS 13+ 建议与 overrideUserInterfaceStyle / preferredStatusBarStyle 配合
    @discardableResult
    func byOverrideUserInterfaceStyle(_ style: UIUserInterfaceStyle) -> Self {
        self.overrideUserInterfaceStyle = style
        return self
    }
    /// 触发状态栏刷新动画
    @discardableResult
    func byNeedsStatusBarUpdate() -> Self {
        self.setNeedsStatusBarAppearanceUpdate()
        return self
    }
    // ------------------------------ 布局区域控制 ------------------------------
    @discardableResult
    func byEdgesForExtendedLayout(_ edges: UIRectEdge) -> Self {
        self.edgesForExtendedLayout = edges
        return self
    }

    @discardableResult
    func byExtendedLayoutIncludesOpaqueBars(_ flag: Bool) -> Self {
        self.extendedLayoutIncludesOpaqueBars = flag
        return self
    }
    // ------------------------------ 展示/解散（modal） ------------------------------
    @discardableResult
    func byModalPresentationStyle(_ style: UIModalPresentationStyle) -> Self {
        self.modalPresentationStyle = style
        return self
    }

    @discardableResult
    func byModalTransitionStyle(_ style: UIModalTransitionStyle) -> Self {
        self.modalTransitionStyle = style
        return self
    }
    /// iOS 18 新增首选过渡（系统可能忽略），保持语义
    @available(iOS 18.0, *)
    @discardableResult
    func byPreferredTransition(_ transition: UIViewController.Transition?) -> Self {
        self.preferredTransition = transition
        return self
    }
    /// 统一语义化 dismiss
    @discardableResult
    func byDismiss(animated: Bool = true,
                   completion: (() -> Void)? = nil) -> Self {
        self.dismiss(animated: animated, completion: completion)
        return self
    }
    // ------------------------------ show / showDetail（分栏/分屏友好） ------------------------------
    @discardableResult
    func byShow(_ vc: UIViewController, sender: Any? = nil) -> Self {
        self.show(vc, sender: sender)
        return self
    }

    @discardableResult
    func byShowDetail(_ vc: UIViewController, sender: Any? = nil) -> Self {
        self.showDetailViewController(vc, sender: sender)
        return self
    }
    // ------------------------------ 容器：安全 add/remove child ------------------------------
    /// 标准三步：addChild -> addSubview -> didMove(toParent:)
    @discardableResult
    func addChildVC(_ child: UIViewController,
                    into container: UIView? = nil,
                    layout: ((UIView) -> Void)? = nil) -> Self {
        // 1) 建立父子
        self.addChild(child)

        // 2) 准备容器 & 子视图
        if viewIfLoaded == nil { loadViewIfNeeded() }
        let host = container ?? self.view!
        host.addSubview(child.view)

        // 3) 可选布局闭包（Auto Layout/SnapKit 由你决定）
        layout?(child.view)

        // 4) 完成回调
        child.didMove(toParent: self)
        return self
    }
    // ------------------------------ 滚动联动（iOS15+） ------------------------------
    /// 将某个方向的滚动视图与本 VC 绑定，支持大标题折叠等行为
    @available(iOS 15.0, *)
    @discardableResult
    func byContentScrollView(_ scrollView: UIScrollView?, for edge: NSDirectionalRectEdge) -> Self {
        self.setContentScrollView(scrollView, for: edge)
        return self
    }
    // ------------------------------ 焦点 / 交互跟踪（TV / iOS 15+） ------------------------------
    @available(iOS 15.0, *)
    @discardableResult
    func byFocusGroupIdentifier(_ id: String?) -> Self {
        self.focusGroupIdentifier = id
        return self
    }

    @available(iOS 16.0, *)
    @discardableResult
    func byInteractionActivityBaseName(_ name: String?) -> Self {
        self.interactionActivityTrackingBaseName = name
        return self
    }
    // ------------------------------ iOS 26+ 属性更新批（前瞻，占位） ------------------------------
    /// 未来 API：属性批更新调度（不要直接调用 updateProperties）
    @available(iOS 26.0, *)
    @discardableResult
    func bySetNeedsUpdateProperties() -> Self {
        self.setNeedsUpdateProperties()
        return self
    }
    /// 设置自定义转场动画代理
    /// - Parameter delegate: 任何符合 UIViewControllerTransitioningDelegate 的对象
    /// - Returns: Self（链式可继续调用）
    @available(iOS 7.0, *)
    @discardableResult
    func byTransitioningDelegate(_ delegate: UIViewControllerTransitioningDelegate?) -> Self {
        self.transitioningDelegate = delegate
        return self
    }
}
// MARK: - GKNavigationBarSwift
public extension UIViewController {
    /// 通用 GKNavigationBar 封装
    func jobsSetupGKNav(
        title: String,
        leftSymbol: String? = nil,
        rightButtons: [(String, UIColor, (() -> Void)?)] = []
    ) {
        gk_navTitle = title
        // ✅ 左侧按钮逻辑
        if let symbol = leftSymbol {
            // 用户传入了自定义图标 → 自定义行为
            gk_navLeftBarButtonItem = UIBarButtonItem(
                customView: makeNavButton(symbol: symbol, tint: .systemBlue) {
                    print("👈 自定义左按钮 tapped")
                }
            )
        } else {
            // 🚀 未传 symbol → 自动生成“返回”按钮
            gk_navLeftBarButtonItem = UIBarButtonItem(
                customView: makeNavButton(symbol: "chevron.left", tint: .systemBlue) { [weak self] in
                    guard let self else { return }
                    self.jobsSmartBack()
                }
            )
        }
        // ✅ 右上角按钮数组（可选）
        if !rightButtons.isEmpty {
            gk_navRightBarButtonItems = rightButtons.map { symbol, color, action in
                UIBarButtonItem(customView: makeNavButton(symbol: symbol, tint: color, action: action))
            }
        }
    }
    /// 智能返回操作：自动判断是 Push 还是 Present
    private func jobsSmartBack() {
        if let nav = navigationController {
            if nav.viewControllers.first != self {
                nav.popViewController(animated: true)
                print("⬅️ Pop 返回上一层")
                return
            }
        }
        if presentingViewController != nil {
            dismiss(animated: true)
            print("⬇️ Dismiss 关闭当前模态页")
            return
        }
        print("⚠️ [JobsNav] 当前 VC 无法返回（既非 push 也非 present）")
    }

    private func makeNavButton(
        symbol: String,
        tint: UIColor,
        action: (() -> Void)? = nil
    ) -> UIButton {
        return UIButton(type: .system)
            .byFrame(CGRect(x: 0, y: 0, width: 32.w, height: 32.h))
//            .byTitle("显示", for: .normal)// 普通文字：未选中状态标题
//            .byTitle("隐藏", for: .selected)// 选中状态标题
            .byTintColor(tint)
            .byTitleColor(.systemBlue, for: .normal)// 文字颜色：区分状态（普通）
            .byTitleColor(.systemRed, for: .selected)// 文字颜色：区分状态（选中）
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))// 字体统一
            .byImage(UIImage(systemName: symbol), for: .normal)   // 未选中图标
            .byImage(UIImage(systemName: symbol), for: .selected) // 选中图标
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))// 图文内边距
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))// 图标与文字间距
            .onTap { sender in
                sender.isSelected.toggle()
                // ✅ guard 安全调用外部闭包
                guard let action else {
                    print("⚠️ [JobsNav] 未设置 action（symbol: \(symbol)）")
                    return
                }
                action()

            }// 点按事件（统一入口）
    }
}
// MARK: - 数据传递（byData / inputData / onResult / sendResult）
private enum JobsAssocKey {
    static var inputData: UInt8 = 0
    static var onResult: UInt8 = 1   // ⬅️ 只保留 Any 回调
}

extension UIViewController: JobsRouteComparable {
    @inline(__always)
    func jobs_isSameDestination(as other: UIViewController) -> Bool {
        type(of: self) == type(of: other)
    }
}
// MARK: - 兜底：任何 VC 都能先把数据塞进关联对象，VC 内再 `inputData()` 取
public extension UIViewController {
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
public enum JobsPresentPolicy {
    /// 有东西正在展示就忽略（最稳，默认）
    case ignoreIfBusy
    /// 沿着 presented 链找到最顶层再 present（适合强行顶层弹窗）
    case presentOnTopMost
}
public extension UIViewController {
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
    // MARK: - 统一语义化 present：合法性校验 + 同目的地已展示则忽略
    @discardableResult
    func byPresent(_ from: UIResponder,
                   animated: Bool = true,
                   policy: JobsPresentPolicy = .ignoreIfBusy,
                   completion: (() -> Void)? = nil) -> Self {
        assert(Thread.isMainThread, "byPresent must be called on main thread")
        // 1) 目标不能已挂载或已被展示
        guard self.parent == nil,
              self.presentingViewController == nil else {
            assertionFailure("❌ Trying to present a VC that already has a parent/presenter: \(self)")
            return self
        }
        // 2) 找宿主（你的 jobsNearestVC 已封装了 keyWindow 兜底）
        guard var host = from.jobsNearestVC() else {
            assertionFailure("❌ byPresent: 未找到宿主 VC")
            return self
        }
        // 3) 策略：忽略 or 顶层
        switch policy {
        case .ignoreIfBusy:
            if let presented = host.presentedViewController {
                // 同目的地 → 忽略；否则也忽略（保持简单、稳定）
                if self.jobs_isSameDestination(as: presented) { return self }
                return self
            }
        case .presentOnTopMost:
            // 沿链条爬到最顶（正在 dismiss 的不算稳定锚点）
            while let p = host.presentedViewController, !p.isBeingDismissed {
                host = p
            }
        }
        // 4) 防止“自己 present 自己”
        guard host !== self else {
            assertionFailure("❌ Don't present self on self. host === presented: \(host)")
            return self
        }
        // 5) 宿主正在转场：等转场完成再 present（避免系统警告/掉帧）
        if let tc = host.transitionCoordinator {
            tc.animate(alongsideTransition: nil) { _ in
                host.present(self, animated: animated, completion: completion)
            }
            return self
        }
        host.present(self, animated: animated, completion: completion)
        return self
    }
}
