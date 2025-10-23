//
//  UIViewController.swift
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

import ObjectiveC
// ================================== UIViewController 链式扩展 ==================================
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
    // ⚠️ 已删除：byPresent(_ viewController: UIViewController, ...) 这个容易误用的重载
    // 如果确实想保留，请放开下面注释，并保留所有护栏（强烈建议不要改）：
    /*
    @discardableResult
    func byPresent(_ viewController: UIViewController,
                   animated: Bool = false,
                   completion: (() -> Void)? = nil) -> Self {
        // 强力护栏：禁止 present 已挂载 / 正在展示 / 自己
        guard viewController !== self else {
            assertionFailure("❌ Don't present self on self")
            return self
        }
        guard viewController.parent == nil, viewController.presentingViewController == nil else {
            assertionFailure("❌ Trying to present a VC that already has a parent/presentingVC: \(viewController)")
            return self
        }
        // 宿主自己必须在 window 上，且不在 dismiss
        guard self.viewIfLoaded?.window != nil, self.isBeingDismissed == false else {
            assertionFailure("❌ Host not in window or being dismissed: \(self)")
            return self
        }
        self.present(viewController, animated: animated, completion: completion)
        return self
    }
    */
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

    @discardableResult
    func addChildVC(_ child: UIViewController) -> Self {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        return self
    }

    @discardableResult
    func removeFromParentVC() -> Self {
        guard parent != nil else { return self }
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        return self
    }

    var jobs_hasParent: Bool { self.parent != nil }
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
// ================================== GKNavigationBarSwift 包装 ==================================
#if canImport(GKNavigationBarSwift)
import GKNavigationBarSwift
public extension UIViewController {
    /// 统一配置 GKNav
    /// - Parameters:
    ///   - title: JobsText（支持纯文本/富文本，这里取 rawString 写到 gk_navTitle）
    ///   - leftButton: 左侧按钮（UIButton）。nil → 使用默认“< 返回”
    ///   - rightButtons: 右侧按钮组（[UIButton]）。nil 或空 → 不创建
    func jobsSetupGKNav(
        title: JobsText,
        leftButton: UIButton? = nil,
        rightButtons: [UIButton]? = nil
    ) {
        // 标题（GK 只吃 String）
        gk_navTitle = title.rawString

        // 左侧按钮：nil → 默认返回；否则用传入的 UIButton
        if let btn = leftButton {
            gk_navLeftBarButtonItem = UIBarButtonItem(customView: btn)
        } else {
            gk_navLeftBarButtonItem = UIBarButtonItem(
                customView: makeDefaultBackButton()
            )
        }
        // 右侧按钮：只有在非空时才创建
        if let items = rightButtons, !items.isEmpty {
            gk_navRightBarButtonItems = items.map { UIBarButtonItem(customView: $0) }
        } else {
            gk_navRightBarButtonItems = nil
        }
    }
    // MARK: - 内置：默认“< 返回”按钮（SF Symbol: chevron.left）
    private func makeDefaultBackButton() -> UIButton {
        UIButton(type: .system)
            .byFrame(CGRect(x: 0, y: 0, width: 32.w, height: 32.h))
            .byTintColor(.white)
            .byImage("chevron.left".sysImg, for: .normal)
            .byContentEdgeInsets(.zero)
            .byTitleEdgeInsets(.zero)
            .onTap { [weak self] _ in
                guard let self else { return }
                closeByResult("") // 系统通用返回
            }
    }
}

#endif
// ================================== 数据传递 + 出现完成回调 ==================================
private enum JobsAssocKey {
    static var inputData: UInt8 = 0
    static var onResult: UInt8 = 1
    static var onAppearCompletions: UInt8 = 2
    static var appearCompletionFired: UInt8 = 3
}

extension UIViewController: JobsRouteComparable {
    @inline(__always)
    func jobs_isSameDestination(as other: UIViewController) -> Bool {
        type(of: self) == type(of: other)
    }
}

public extension UIViewController {
    @discardableResult
    func byData(_ data: Any?) -> Self {
        objc_setAssociatedObject(self, &JobsAssocKey.inputData, data, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    func inputData<T>() -> T? {
        objc_getAssociatedObject(self, &JobsAssocKey.inputData) as? T
    }

    @discardableResult
    func onResult(_ callback: @escaping (Any) -> Void) -> Self {
        objc_setAssociatedObject(self, &JobsAssocKey.onResult, callback, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    func sendResult(_ result: Any) {
        if let cb = objc_getAssociatedObject(self, &JobsAssocKey.onResult) as? (Any) -> Void { cb(result) }
    }

    @discardableResult
    func closeByResult(_ result: Any?, animated: Bool = true) -> Self {
        if let r = result { sendResult(r) }
        if let nav = navigationController { nav.popViewController(animated: animated) }
        else { dismiss(animated: animated) }
        return self
    }
    // ✅ 出现完成（push/present 结束）的一次性回调
    @discardableResult
    func byCompletion(_ block: @escaping () -> Void) -> Self {
        UIViewController._JobsAppearSwizzler.installIfNeeded()
        var arr = (objc_getAssociatedObject(self, &JobsAssocKey.onAppearCompletions) as? [() -> Void]) ?? []
        arr.append(block)
        objc_setAssociatedObject(self, &JobsAssocKey.onAppearCompletions, arr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 若已在窗口（先跳转后注册），下一轮主线程立即触发
        if self.viewIfLoaded?.window != nil {
            DispatchQueue.main.async { [weak self] in self?.jobs_fireAppearCompletionIfNeeded(reason: "alreadyVisible") }
        }
        return self
    }

    fileprivate func jobs_fireAppearCompletionIfNeeded(reason: String) {
        let fired = (objc_getAssociatedObject(self, &JobsAssocKey.appearCompletionFired) as? Bool) ?? false
        guard !fired else { return }
        guard let blocks = objc_getAssociatedObject(self, &JobsAssocKey.onAppearCompletions) as? [() -> Void],
              !blocks.isEmpty else { return }
        objc_setAssociatedObject(self, &JobsAssocKey.appearCompletionFired, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &JobsAssocKey.onAppearCompletions, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        blocks.forEach { $0() }
        // print("✅ [JobsAppearCompletion] fired by \(reason) for \(self)")
    }
}
// `viewDidAppear` swizzle：出现完成时机
private enum _JobsAppearSwizzleOnceToken { static var done = false }
private extension UIViewController {
    final class _JobsAppearSwizzler {
        static func installIfNeeded() {
            guard !_JobsAppearSwizzleOnceToken.done else { return }
            _JobsAppearSwizzleOnceToken.done = true
            let cls: AnyClass = UIViewController.self
            guard
                let m1 = class_getInstanceMethod(cls, #selector(UIViewController.viewDidAppear(_:))),
                let m2 = class_getInstanceMethod(cls, #selector(UIViewController.jobs_viewDidAppear_swizzled(_:)))
            else { return }
            method_exchangeImplementations(m1, m2)
        }
    }

    @objc func jobs_viewDidAppear_swizzled(_ animated: Bool) {
        self.jobs_viewDidAppear_swizzled(animated) // 原实现
        self.jobs_fireAppearCompletionIfNeeded(reason: "viewDidAppear")
    }
}
// ================================== 链式导航（去重） ==================================
public enum JobsPresentPolicy {
    case ignoreIfBusy
    case presentOnTopMost
}

public extension UIViewController {
    @discardableResult
    func byPush(_ from: UIResponder?, animated: Bool = true) -> Self {
        guard let host = from?.jobsNearestVC() else {
            assertionFailure("❌ byPush: 未找到宿主 VC"); return self
        }

        if let nav = (host as? UINavigationController) ?? host.navigationController {
            nav.jobs_pushOrPopTo(self, animated: animated)
            if let tc = nav.transitionCoordinator {
                tc.animate(alongsideTransition: nil) { [weak self] _ in
                    self?.jobs_fireAppearCompletionIfNeeded(reason: "pushTransitionCoordinator")
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.jobs_fireAppearCompletionIfNeeded(reason: "pushAsyncFallback")
                }
            }
            return self
        }
        // 没导航 → 包一层 present
        guard self.parent == nil else { return self }
        if host.transitionCoordinator != nil || host.presentedViewController != nil { return self }

        host.present(
            UINavigationController(rootViewController: self)
                .byNavigationBarHidden(true)
                .byModalPresentationStyle(.fullScreen),
            animated: animated
        ) { [weak self] in
            self?.jobs_fireAppearCompletionIfNeeded(reason: "presentWrappedForPush")
        }
        return self
    }

    @discardableResult
    func byPresent(_ from: UIResponder?,
                   animated: Bool = true,
                   policy: JobsPresentPolicy = .ignoreIfBusy,
                   completion: (() -> Void)? = nil) -> Self {
        assert(Thread.isMainThread, "byPresent must be called on main thread")
        // 目标不能已挂载 / 正在展示
        guard self.parent == nil, self.presentingViewController == nil else {
            assertionFailure("❌ Trying to present a VC already mounted/presented: \(self)")
            return self
        }
        // 宿主选择
        guard var host = from?.jobsNearestVC() ?? UIWindow.wd.rootViewController else {
            assertionFailure("❌ byPresent: no host VC"); return self
        }
        if let top = UIApplication.jobsTopMostVC(from: host, ignoreAlert: true) { host = top }
        guard host.viewIfLoaded?.window != nil, host.isBeingDismissed == false else { return self }
        // 策略
        switch policy {
        case .ignoreIfBusy:
            if let presented = host.presentedViewController, presented.isBeingDismissed == false {
                if jobs_isSameDestination(as: presented) { return self }
                return self
            }
        case .presentOnTopMost:
            while let top = UIApplication.jobsTopMostVC(from: host, ignoreAlert: true),
                  top.isBeingDismissed == false, top !== host { host = top }
        }
        // 防自己 present 自己
        guard host !== self else {
            assertionFailure("❌ Don't present self on self"); return self
        }
        // 系统 present；完成时触发一次（与 viewDidAppear 幂等）
        host.present(self, animated: animated) { [weak self] in
            completion?()
            self?.jobs_fireAppearCompletionIfNeeded(reason: "presentCompletion")
        }
        return self
    }
}
#if canImport(SnapKit)
import SnapKit
/// 利用SnapKit 给 UIViewController 加背景图（UIImageView）
public extension UIViewController {
    // MARK: - AO Key（UInt8 哨兵）
    private struct _JobsAssocKeys {
        static var imageView: UInt8 = 0
    }
    // MARK: - 懒载 imageView（挂在 VC 上）
    var jobsImageView: UIImageView {
        if let iv = objc_getAssociatedObject(self, &_JobsAssocKeys.imageView) as? UIImageView {
            return iv
        }
        let iv = UIImageView().byUserInteractionEnabled(false).byClipsToBounds(true).byContentMode(.scaleAspectFill)
        objc_setAssociatedObject(self, &_JobsAssocKeys.imageView, iv, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return iv
    }
    // MARK: - 安装并约束（默认铺满 Safe Area）
    @discardableResult
    func bgImageView(
        to container: UIView? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        backgroundColor: UIColor? = nil,
        remakeConstraints: Bool = true,
        layout: ((ConstraintMaker) -> Void)? = nil
    ) -> UIImageView {
        let holder = container ?? view
        let iv = jobsImageView
        if iv.superview !== holder {
            iv.removeFromSuperview()
            holder?.addSubview(iv)
        }

        iv.contentMode = contentMode
        if let bg = backgroundColor { iv.backgroundColor = bg }

        if let layout = layout {
            if remakeConstraints { iv.snp.remakeConstraints(layout) }
            else { iv.snp.makeConstraints(layout) }
        } else {
            if remakeConstraints {
                iv.snp.remakeConstraints { make in
                    if let holder = holder {
                        make.edges.equalTo(holder.safeAreaLayoutGuide)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            } else {
                iv.snp.makeConstraints { make in
                    if let holder = holder {
                        make.edges.equalTo(holder.safeAreaLayoutGuide)
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            }
        }
        view.sendSubviewToBack(iv)
        return iv
    }
    // MARK: - 卸载
    func removeJobsImageView() {
        jobsImageView.removeFromSuperview()
    }
}
#endif

@MainActor
public extension UIViewController {
    private struct _JobsNavKey {
        // 用地址作为唯一 key
        static var wrapper: UInt8 = 0
    }

    var jobsNavContainer: UINavigationController {
        if let nav = self as? UINavigationController { return nav }
        if let nav = self.navigationController { return nav }
        if let cached = objc_getAssociatedObject(self, &_JobsNavKey.wrapper) as? UINavigationController {
            return cached
        }
        let nav = UINavigationController(rootViewController: self)
        objc_setAssociatedObject(self, &_JobsNavKey.wrapper, nav, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return nav
    }

    var jobsNav: Self {
        _ = jobsNavContainer
        return self
    }

    @discardableResult
    func jobsNav(_ onWrap: (UINavigationController) -> Void) -> Self {
        let alreadyHad = (self is UINavigationController)
            || (self.navigationController != nil)
            || (objc_getAssociatedObject(self, &_JobsNavKey.wrapper) != nil)

        let nav = jobsNavContainer
        if !alreadyHad { onWrap(nav) }
        return self
    }
}
