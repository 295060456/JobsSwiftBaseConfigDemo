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
    // ================================== 标题 / 背景 ==================================
    @discardableResult
    func byTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        if viewIfLoaded == nil { loadViewIfNeeded() }
        self.view.backgroundColor = color
        return self
    }

    // ================================== Segue ==================================
    @discardableResult
    func byPerformSegue(_ identifier: String, sender: Any? = nil) -> Self {
        self.performSegue(withIdentifier: identifier, sender: sender)
        return self
    }

    // ================================== Modal 展示 / 解散 ==================================
    /// 无动画 Present
    @discardableResult
    func byPresent(_ viewController: UIViewController,
                   animated: Bool = false,
                   completion: (() -> Void)? = nil) -> Self {
        self.present(viewController, animated: animated, completion: completion)
        return self
    }

    /// 有动画 Present
    @discardableResult
    func byPresentModallyAnimated(_ viewController: UIViewController,
                                  completion: (() -> Void)? = nil) -> Self {
        self.present(viewController, animated: true, completion: completion)
        return self
    }

    /// 统一语义化 dismiss
    @discardableResult
    func byDismiss(animated: Bool = true,
                   completion: (() -> Void)? = nil) -> Self {
        self.dismiss(animated: animated, completion: completion)
        return self
    }

    // ================================== Modal 属性 ==================================
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

    @available(iOS 18.0, *)
    @discardableResult
    func byPreferredTransition(_ transition: UIViewController.Transition?) -> Self {
        self.preferredTransition = transition
        return self
    }

    @available(iOS 7.0, *)
    @discardableResult
    func byTransitioningDelegate(_ delegate: UIViewControllerTransitioningDelegate?) -> Self {
        self.transitioningDelegate = delegate
        return self
    }

    // ================================== Content Size / Layout ==================================
    @discardableResult
    func byPreferredContentSize(_ size: CGSize) -> Self {
        self.preferredContentSize = size
        return self
    }

    var jobs_preferredContentSize: CGSize {
        self.preferredContentSize
    }

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

    @discardableResult
    func byAutomaticallyAdjustsScrollInsets(_ flag: Bool) -> Self {
        if #available(iOS 11.0, *) {
            assertionFailure("iOS 11+ 请使用 UIScrollView.contentInsetAdjustmentBehavior")
        } else {
            self.automaticallyAdjustsScrollViewInsets = flag
        }
        return self
    }

    // ================================== show / showDetail（安全命名） ==================================
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

    // ================================== 状态栏 / 外观 ==================================
    @discardableResult
    func byOverrideUserInterfaceStyle(_ style: UIUserInterfaceStyle) -> Self {
        self.overrideUserInterfaceStyle = style
        return self
    }

    @discardableResult
    func byNeedsStatusBarUpdate() -> Self {
        self.setNeedsStatusBarAppearanceUpdate()
        return self
    }

    @discardableResult
    func byPreferredStatusBarStyle(_ style: UIStatusBarStyle) -> Self {
        assertionFailure("请在子类中 override preferredStatusBarStyle 实现此功能")
        return self
    }

    // ================================== 子控制器管理 ==================================
    /// 标准三步：addChild -> addSubview -> didMove(toParent:)
    @discardableResult
    func addChildVC(_ child: UIViewController,
                    into container: UIView? = nil,
                    layout: ((UIView) -> Void)? = nil) -> Self {
        self.addChild(child)
        if viewIfLoaded == nil { loadViewIfNeeded() }
        let host = container ?? self.view!
        host.addSubview(child.view)
        layout?(child.view)
        child.didMove(toParent: self)
        return self
    }

    /// 快速添加（不指定容器）
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
        self.view.removeFromSuperview()
        self.removeFromParent()
        return self
    }

    /// 判断是否已有父控制器
    var jobs_hasParent: Bool {
        self.parent != nil
    }

    // ================================== 滚动联动（iOS15+） ==================================
    @available(iOS 15.0, *)
    @discardableResult
    func byContentScrollView(_ scrollView: UIScrollView?, for edge: NSDirectionalRectEdge) -> Self {
        self.setContentScrollView(scrollView, for: edge)
        return self
    }

    @available(iOS 15.0, *)
    var jobs_contentScrollViewTop: UIScrollView? {
        self.contentScrollView(for: .top)
    }

    // ================================== 焦点 / 交互追踪（TV / iOS 15+） ==================================
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

    // ================================== iOS 26+ 属性更新批 ==================================
    @available(iOS 26.0, *)
    @discardableResult
    func bySetNeedsUpdateProperties() -> Self {
        self.setNeedsUpdateProperties()
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byUpdatePropertiesIfNeeded() -> Self {
        self.updatePropertiesIfNeeded()
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
    func byPush(_ from: UIResponder?, animated: Bool = true) -> Self {
        guard let host = from?.jobsNearestVC() else {
            assertionFailure("❌ byPush: 未找到宿主 VC（传入 nil 或 responder 链断裂）")
            return self
        }

        if let nav = (host as? UINavigationController) ?? host.navigationController {
            nav.jobs_pushOrPopTo(self, animated: animated)
            return self
        }

        // 没有导航栈 → 包一层 present
        guard self.parent == nil else { return self }
        if host.transitionCoordinator != nil || host.presentedViewController != nil { return self }

        host.present(UINavigationController(rootViewController: self)
            .byNavigationBarHidden(true)
            .byModalPresentationStyle(.fullScreen), animated: animated)
        return self
    }
    // MARK: - 统一语义化 present：合法性校验 + 同目的地已展示则忽略
    @discardableResult
    func byPresent(_ from: UIResponder?,
                   animated: Bool = true,
                   policy: JobsPresentPolicy = .ignoreIfBusy,
                   completion: (() -> Void)? = nil) -> Self {
        assert(Thread.isMainThread, "byPresent must be called on main thread")

        // 1) 目标不能已挂载或已被展示
        guard self.parent == nil, self.presentingViewController == nil else {
            assertionFailure("❌ Trying to present a VC already mounted/presented: \(self)")
            return self
        }

        // 2) 选择宿主
        guard var host = from?.jobsNearestVC() ?? UIWindow.wd.rootViewController else {
            assertionFailure("❌ byPresent: no host VC (from is nil and no keyWindow rootVC)")
            return self
        }

        // 2.1 取最上层可见 VC（考虑导航/标签/已present链）
        if let top = UIApplication.jobsTopMostVC(from: host, ignoreAlert: true) {
            host = top
        }

        // 2.2 宿主必须在窗口且未在 dismiss
        guard host.viewIfLoaded?.window != nil, host.isBeingDismissed == false else {
            assertionFailure("❌ byPresent: host not in window or being dismissed: \(host)")
            return self
        }

        // 3) 策略
        switch policy {
        case .ignoreIfBusy:
            if let presented = host.presentedViewController, presented.isBeingDismissed == false {
                // 展示中的目的地等价 → 忽略
                if jobs_isSameDestination(as: presented) { return self }
                // 不等价也忽略，保持简单稳定
                return self
            }

        case .presentOnTopMost:
            // 从 host 出发，递归取最上层可见 VC
            while let top = UIApplication.jobsTopMostVC(from: host, ignoreAlert: true),
                  top.isBeingDismissed == false,
                  top !== host
            {
                host = top
            }
        }

        // 4) 防“自己 present 自己”
        guard host !== self else {
            assertionFailure("❌ Don't present self on self")
            return self
        }

        // 5) 若宿主在转场，等转场完成再 present
        if let tc = host.transitionCoordinator {
            tc.animate(alongsideTransition: nil) { [weak host, weak self] _ in
                guard let host, let s = self else { return }
                host.present(s, animated: animated, completion: completion)
            }
            return self
        }

        host.present(self, animated: animated, completion: completion)
        return self
    }
}
