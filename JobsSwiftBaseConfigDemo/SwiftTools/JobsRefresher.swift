//
//  JobsRefresher.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//
//  完全替代第三方；统一支持垂直/水平刷新。
//  特性：
//  1) 水平刷新时文案自动“竖排”；垂直刷新维持横排（可强制设置）
//  2) stopRefreshing() 同步回收 contentInset 与 contentOffset（四方向都修复）
//  3) 头/尾使用 Auto Layout 锚在 contentLayoutGuide 上，动画期间不会“先回去”
//  4) iOS 10 及以下自动降级为 frame 布局（逻辑一致）
//
//  API：pullDownWithJobsAnimator / pullUpWithJobsAnimator / pullDownStart / pullDownStop
//       / pullUpStop / pullUpNoMore / pullUpReset / removeRefreshers / jobs_refreshAxis
//

import UIKit
import ObjectiveC

// MARK: - 公共枚举 / 协议
public enum JobsRefreshAxis { case vertical, horizontal }
public enum _JobsRefreshEdge { case top, bottom, leading, trailing }
public enum _JobsRefreshState { case idle, pulling, ready, refreshing, noMore }

public enum JobsTextOrientationMode { case auto, horizontal, verticalStack }
public enum _JobsResolvedOrientation { case horizontal, verticalStack }

public protocol JobsRefreshAnimatable: AnyObject {
    var executeIncremental: CGFloat { get set }      // 头=高度 / 尾=宽度
    func drive(_ state: _JobsRefreshState)
}
private protocol _JobsAnimatorAxisAware: AnyObject {
    var _jobs_isHorizontalContext: Bool { get set }
    var textOrientation: JobsTextOrientationMode { get set }
}

// MARK: - Header
public final class JobsHeaderAnimator: UIView, JobsRefreshAnimatable, _JobsAnimatorAxisAware {
    public var executeIncremental: CGFloat = 60
    public var idleDescription = "下拉刷新"
    public var releaseToRefreshDescription = "松开立即刷新"
    public var loadingDescription = "刷新中…"
    public var noMoreDataDescription = "已经是最新数据"

    public var textOrientation: JobsTextOrientationMode = .auto
    internal var _jobs_isHorizontalContext = false

    private let titleLabel = UILabel()
    private let indicator  = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = idleDescription

        indicator.hidesWhenStopped = true

        addSubview(titleLabel)
        addSubview(indicator)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let vertical = (_currentOrientation() == .verticalStack)
        let spacing: CGFloat = 6
        if vertical {
            let maxW = min(bounds.width * 0.75, 60)
            titleLabel.preferredMaxLayoutWidth = maxW
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - spacing)
            indicator.sizeToFit()
            indicator.center = CGPoint(x: bounds.midX, y: titleLabel.frame.maxY + spacing + indicator.bounds.height/2)
        } else {
            titleLabel.sizeToFit(); indicator.sizeToFit()
            let totalW = indicator.bounds.width + spacing + titleLabel.bounds.width
            let startX = bounds.midX - totalW/2
            indicator.frame.origin = CGPoint(x: startX, y: bounds.midY - indicator.bounds.height/2)
            titleLabel.frame.origin = CGPoint(x: indicator.frame.maxX + spacing,
                                              y: bounds.midY - titleLabel.bounds.height/2)
        }
    }

    public func drive(_ state: _JobsRefreshState) {
        func verticalized(_ s: String) -> String { s.contains("\n") ? s : s.map { String($0) }.joined(separator: "\n") }
        func oriented(_ s: String) -> String {
            switch _currentOrientation() {
            case .horizontal: return s
            case .verticalStack: return verticalized(s)
            }
        }
        switch state {
        case .idle, .pulling:
            titleLabel.text = oriented(idleDescription); indicator.stopAnimating()
        case .ready:
            titleLabel.text = oriented(releaseToRefreshDescription); indicator.stopAnimating()
        case .refreshing:
            titleLabel.text = oriented(loadingDescription); indicator.startAnimating()
        case .noMore:
            titleLabel.text = oriented(noMoreDataDescription); indicator.stopAnimating()
        }
        setNeedsLayout()
    }

    // DSL
    @discardableResult public func byIdleDescription(_ t: String) -> Self { idleDescription = t; return self }
    @discardableResult public func byReleaseToRefreshDescription(_ t: String) -> Self { releaseToRefreshDescription = t; return self }
    @discardableResult public func byLoadingDescription(_ t: String) -> Self { loadingDescription = t; return self }
    @discardableResult public func byNoMoreDataDescription(_ t: String) -> Self { noMoreDataDescription = t; return self }
    @discardableResult public func byTextOrientation(_ m: JobsTextOrientationMode) -> Self { textOrientation = m; return self }

    private func _currentOrientation() -> _JobsResolvedOrientation {
        switch textOrientation {
        case .horizontal: return .horizontal
        case .verticalStack: return .verticalStack
        case .auto: return _jobs_isHorizontalContext ? .verticalStack : .horizontal
        }
    }
}

// MARK: - Footer
public final class JobsFooterAnimator: UIView, JobsRefreshAnimatable, _JobsAnimatorAxisAware {
    public var executeIncremental: CGFloat = 52
    public var idleDescription = "上拉加载更多"
    public var releaseToRefreshDescription = "松开立即加载"
    public var loadingMoreDescription = "加载中…"
    public var noMoreDataDescription = "没有更多数据"

    public var textOrientation: JobsTextOrientationMode = .auto
    internal var _jobs_isHorizontalContext = false

    private let titleLabel = UILabel()
    private let indicator  = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = idleDescription

        indicator.hidesWhenStopped = true

        addSubview(titleLabel)
        addSubview(indicator)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let vertical = (_currentOrientation() == .verticalStack)
        let spacing: CGFloat = 6
        if vertical {
            let maxW = min(bounds.width * 0.75, 60)
            titleLabel.preferredMaxLayoutWidth = maxW
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - spacing)
            indicator.sizeToFit()
            indicator.center = CGPoint(x: bounds.midX, y: titleLabel.frame.maxY + spacing + indicator.bounds.height/2)
        } else {
            titleLabel.sizeToFit(); indicator.sizeToFit()
            let totalW = indicator.bounds.width + spacing + titleLabel.bounds.width
            let startX = bounds.midX - totalW/2
            indicator.frame.origin = CGPoint(x: startX, y: bounds.midY - indicator.bounds.height/2)
            titleLabel.frame.origin = CGPoint(x: indicator.frame.maxX + spacing,
                                              y: bounds.midY - titleLabel.bounds.height/2)
        }
    }

    public func drive(_ state: _JobsRefreshState) {
        func verticalized(_ s: String) -> String { s.contains("\n") ? s : s.map { String($0) }.joined(separator: "\n") }
        func oriented(_ s: String) -> String {
            switch _currentOrientation() {
            case .horizontal: return s
            case .verticalStack: return verticalized(s)
            }
        }
        switch state {
        case .idle, .pulling:
            titleLabel.text = oriented(idleDescription); indicator.stopAnimating()
        case .ready:
            titleLabel.text = oriented(releaseToRefreshDescription); indicator.stopAnimating()
        case .refreshing:
            titleLabel.text = oriented(loadingMoreDescription); indicator.startAnimating()
        case .noMore:
            titleLabel.text = oriented(noMoreDataDescription); indicator.stopAnimating()
        }
        setNeedsLayout()
    }

    // DSL
    @discardableResult public func byIdleDescription(_ t: String) -> Self { idleDescription = t; return self }
    @discardableResult public func byReleaseToRefreshDescription(_ t: String) -> Self { releaseToRefreshDescription = t; return self }
    @discardableResult public func byLoadingMoreDescription(_ t: String) -> Self { loadingMoreDescription = t; return self }
    @discardableResult public func byNoMoreDataDescription(_ t: String) -> Self { noMoreDataDescription = t; return self }
    @discardableResult public func byTextOrientation(_ m: JobsTextOrientationMode) -> Self { textOrientation = m; return self }

    private func _currentOrientation() -> _JobsResolvedOrientation {
        switch textOrientation {
        case .horizontal: return .horizontal
        case .verticalStack: return .verticalStack
        case .auto: return _jobs_isHorizontalContext ? .verticalStack : .horizontal
        }
    }
}

// MARK: - 内核
private final class _JobsSideRefresher {
    weak var scroll: UIScrollView?
    let axis: JobsRefreshAxis
    let edge: _JobsRefreshEdge
    var state: _JobsRefreshState = .idle { didSet { animator.drive(state) } }
    var noMoreData: Bool = false { didSet { state = noMoreData ? .noMore : .idle } }

    let animator: (UIView & JobsRefreshAnimatable & _JobsAnimatorAxisAware)
    let handler: () -> Void

    // 观测
    private var contentOffsetObs: NSKeyValueObservation?
    private var contentSizeObs: NSKeyValueObservation?
    private var boundsObs: NSKeyValueObservation?
    private var adjustedInsetObs: NSKeyValueObservation?
    private var contentInsetObs: NSKeyValueObservation?

    // inset 管理
    private var baseInsets: UIEdgeInsets = .zero  // 不含我们追加的量
    private var appliedInset: CGFloat = 0         // 我们追加的量

    // 约束（iOS 11+）
    private var installedConstraints: [NSLayoutConstraint] = []
    private var sizeConstraint: NSLayoutConstraint?

    init(scroll: UIScrollView,
         axis: JobsRefreshAxis,
         edge: _JobsRefreshEdge,
         animator: (UIView & JobsRefreshAnimatable & _JobsAnimatorAxisAware),
         handler: @escaping () -> Void) {
        self.scroll = scroll
        self.axis = axis
        self.edge = edge
        self.animator = animator
        self.handler = handler
        // 直接用，不需要任何 cast
        animator._jobs_isHorizontalContext = (axis == .horizontal)
        attach()
    }

    deinit { detach() }

    private func attach() {
        guard let s = scroll else { return }
        baseInsets = _adjustedInsets(s)
        s.addSubview(animator)
        _installConstraintsIfPossible()
        _layoutIfLegacy()
        animator.drive(state)

        // ★ 防御式开启弹性
        s.bounces = true
        switch axis {
        case .vertical:
            s.alwaysBounceVertical = true
        case .horizontal:
            s.alwaysBounceHorizontal = true
        }

        observe(s)
        s.panGestureRecognizer.addTarget(self, action: #selector(panChanged(_:)))
    }

    private func detach() {
        contentOffsetObs?.invalidate()
        contentSizeObs?.invalidate()
        boundsObs?.invalidate()
        adjustedInsetObs?.invalidate()
        contentInsetObs?.invalidate()
        scroll?.panGestureRecognizer.removeTarget(self, action: #selector(panChanged(_:)))
        _uninstallConstraints()
        animator.removeFromSuperview()
    }

    private func observe(_ s: UIScrollView) {
        contentOffsetObs = s.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            self?.onOffsetChanged()
            self?._layoutIfLegacy()
        }
        contentSizeObs = s.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            self?._layoutIfLegacy()
        }
        boundsObs = s.observe(\.bounds, options: [.new]) { [weak self] _, _ in
            self?._layoutIfLegacy()
        }
        if #available(iOS 11.0, *) {
            adjustedInsetObs = s.observe(\.adjustedContentInset, options: [.new]) { [weak self] s, _ in
                self?.baseInsets = s.adjustedContentInset
            }
        } else {
            contentInsetObs = s.observe(\.contentInset, options: [.new]) { [weak self] s, _ in
                self?.baseInsets = s.contentInset
            }
        }
    }

    // MARK: - Auto Layout anchoring（iOS 11+）
    private func _installConstraintsIfPossible() {
        guard let s = scroll else { return }
        guard #available(iOS 11.0, *) else { return }
        animator.translatesAutoresizingMaskIntoConstraints = false
        _uninstallConstraints()

        let cl = s.contentLayoutGuide
        let fl = s.frameLayoutGuide

        switch (axis, edge) {
        case (.vertical, .top):
            installedConstraints = [
                animator.leadingAnchor.constraint(equalTo: fl.leadingAnchor),
                animator.trailingAnchor.constraint(equalTo: fl.trailingAnchor),
                animator.bottomAnchor.constraint(equalTo: cl.topAnchor)
            ]
            sizeConstraint = animator.heightAnchor.constraint(equalToConstant: animator.executeIncremental)

        case (.vertical, .bottom):
            installedConstraints = [
                animator.leadingAnchor.constraint(equalTo: fl.leadingAnchor),
                animator.trailingAnchor.constraint(equalTo: fl.trailingAnchor)
            ]
            // 首选：顶边贴内容尾部（内容够长时生效）
            let eq = animator.topAnchor.constraint(equalTo: cl.bottomAnchor)
            eq.priority = .defaultHigh   // 999
            // 底线：绝不在可视区域底部之上（内容不满一屏时生效）
            let ge = animator.topAnchor.constraint(greaterThanOrEqualTo: fl.bottomAnchor)
            ge.priority = .required      // 1000
            installedConstraints += [eq, ge]
            sizeConstraint = animator.heightAnchor.constraint(equalToConstant: animator.executeIncremental)

        case (.horizontal, .leading):
            installedConstraints = [
                animator.topAnchor.constraint(equalTo: fl.topAnchor),
                animator.bottomAnchor.constraint(equalTo: fl.bottomAnchor),
                animator.trailingAnchor.constraint(equalTo: cl.leadingAnchor)
            ]
            sizeConstraint = animator.widthAnchor.constraint(equalToConstant: animator.executeIncremental)

        case (.horizontal, .trailing):
            installedConstraints = [
                animator.topAnchor.constraint(equalTo: fl.topAnchor),
                animator.bottomAnchor.constraint(equalTo: fl.bottomAnchor)
            ]
            // 首选：左边贴内容右侧（内容够宽时生效）
            let eq = animator.leadingAnchor.constraint(equalTo: cl.trailingAnchor)
            eq.priority = .defaultHigh   // 999
            // 底线：绝不在可视区域右侧之内（内容不满一屏时生效）
            let ge = animator.leadingAnchor.constraint(greaterThanOrEqualTo: fl.trailingAnchor)
            ge.priority = .required      // 1000
            installedConstraints += [eq, ge]
            sizeConstraint = animator.widthAnchor.constraint(equalToConstant: animator.executeIncremental)

        // 穷尽无效组合
        case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
            break
        }

        if let c = sizeConstraint { c.isActive = true }
        NSLayoutConstraint.activate(installedConstraints)
        if s.window != nil {
            s.setNeedsLayout()
            s.layoutIfNeeded()
        } else {
            // 首次常发生在 collectionView 还未 add 到父视图阶段；推迟一拍最安全
            DispatchQueue.main.async { [weak s] in
                guard let s = s else { return }
                s.setNeedsLayout()
                s.layoutIfNeeded()
            }
        }
    }


    private func _uninstallConstraints() {
        NSLayoutConstraint.deactivate(installedConstraints)
        installedConstraints.removeAll()
        sizeConstraint?.isActive = false
        sizeConstraint = nil
    }

    // iOS 10 及以下：frame 布局（与老实现等价）
    private func _layoutIfLegacy() {
        guard let s = scroll else { return }
        guard #available(iOS 11.0, *) else {
            let H = animator.executeIncremental
            switch (axis, edge) {
            case (.vertical, .top):
                animator.frame = CGRect(x: 0, y: -H - baseInsets.top, width: s.bounds.width, height: H)
            case (.vertical, .bottom):
                let contentH = max(s.contentSize.height, s.bounds.height)
                animator.frame = CGRect(x: 0, y: contentH + baseInsets.bottom, width: s.bounds.width, height: H)
            case (.horizontal, .leading):
                animator.frame = CGRect(x: -H - baseInsets.left, y: 0, width: H, height: s.bounds.height)
            case (.horizontal, .trailing):
                let contentW = max(s.contentSize.width, s.bounds.width)
                animator.frame = CGRect(x: contentW + baseInsets.right, y: 0, width: H, height: s.bounds.height)
            // 穷尽
            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
            return
        }
        // iOS 11+：只需在执行高度变化时更新 size 常量
        if let c = sizeConstraint {
            let newValue = animator.executeIncremental
            if abs(c.constant - newValue) > .ulpOfOne { c.constant = newValue }
        }
    }

    // MARK: - 状态机
    private func onOffsetChanged() {
        guard let s = scroll else { return }
        guard state != .refreshing && state != .noMore else { return }

        switch (axis, edge) {
        case (.vertical, .top):
            let pull = max(0, -(s.contentOffset.y + baseInsets.top))
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.vertical, .bottom):
            if noMoreData { state = .noMore; return }
            let contentH = max(s.contentSize.height, s.bounds.height)
            let beyond = s.contentOffset.y + s.bounds.height - contentH - baseInsets.bottom
            let pull = max(0, beyond)
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.horizontal, .leading):
            let pull = max(0, -(s.contentOffset.x + baseInsets.left))
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.horizontal, .trailing):
            if noMoreData { state = .noMore; return }
            let contentW = max(s.contentSize.width, s.bounds.width)
            let beyond = s.contentOffset.x + s.bounds.width - contentW - baseInsets.right
            let pull = max(0, beyond)
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        default: break
        }
    }


    @objc private func panChanged(_ gr: UIPanGestureRecognizer) {
        if (gr.state == .ended || gr.state == .cancelled || gr.state == .failed), state == .ready {
            beginRefreshing()
        }
    }

    // MARK: - Begin / Stop（这里仍同步 inset + offset；因为视图已锚在内容边缘，不再需要“额外 pin”）
    func beginRefreshing(auto: Bool = false) {
        guard let s = scroll, state != .refreshing else { return }
        if (edge == .trailing || edge == .bottom), noMoreData { return }

        state = .refreshing
        appliedInset = animator.executeIncremental

        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            switch (self.axis, self.edge) {
            case (.vertical, .top):
                s.contentInset.top += self.appliedInset
                let targetY = -(self.baseInsets.top + self.appliedInset)
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.vertical, .bottom):
                s.contentInset.bottom += self.appliedInset
                let contentH = max(s.contentSize.height, s.bounds.height)
                let targetY = contentH + self.baseInsets.bottom + self.appliedInset - s.bounds.height
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.horizontal, (.leading)):
                s.contentInset.left += self.appliedInset
                let targetX = -(self.baseInsets.left + self.appliedInset)
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

            case (.horizontal, (.trailing)):
                s.contentInset.right += self.appliedInset
                let contentW = max(s.contentSize.width, s.bounds.width)
                let targetX = contentW + self.baseInsets.right + self.appliedInset - s.bounds.width
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

            // 穷尽
            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
        } completion: { _ in
            self.handler()
        }
    }

    func stopRefreshing() {
        guard let s = scroll, state == .refreshing else { return }
        let delta = appliedInset
        appliedInset = 0

        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            switch (self.axis, self.edge) {
            case (.vertical, .top):
                s.contentInset.top = max(0, s.contentInset.top - delta)
                let targetY = -self.baseInsets.top
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.vertical, .bottom):
                s.contentInset.bottom = max(0, s.contentInset.bottom - delta)
                let contentH = max(s.contentSize.height, s.bounds.height)
                let targetY = contentH + self.baseInsets.bottom - s.bounds.height
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.horizontal, .leading):
                s.contentInset.left = max(0, s.contentInset.left - delta)
                let targetX = -self.baseInsets.left
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

            case (.horizontal, .trailing):
                s.contentInset.right = max(0, s.contentInset.right - delta)
                let contentW = max(s.contentSize.width, s.bounds.width)
                let targetX = contentW + self.baseInsets.right - s.bounds.width
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

            // 穷尽
            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
        } completion: { _ in
            self.state = (self.edge == .trailing || self.edge == .bottom) && self.noMoreData ? .noMore : .idle
            // iOS 11+：因为视图锚在 contentLayoutGuide，不需要额外复位；更新一下基准 inset
            self.baseInsets = _adjustedInsets(s)
        }
    }
}

// MARK: - UIScrollView API
private var _jobsRefreshAxisKey: UInt8 = 0
private var _jobsHeaderRefKey: UInt8   = 0
private var _jobsFooterRefKey: UInt8   = 0

public extension UIScrollView {
    var jobs_refreshAxis: JobsRefreshAxis {
        get {
            (objc_getAssociatedObject(self, &_jobsRefreshAxisKey) as? NSNumber)
                .map { $0.intValue == 0 ? .vertical : .horizontal } ?? .vertical
        }
        set {
            objc_setAssociatedObject(self, &_jobsRefreshAxisKey,
                                     NSNumber(value: (newValue == .vertical ? 0 : 1)),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            switch newValue { case .vertical: alwaysBounceVertical = true
            case .horizontal: alwaysBounceHorizontal = true }
        }
    }
    @discardableResult func jobs_refreshAxis(_ axis: JobsRefreshAxis) -> Self { jobs_refreshAxis = axis; return self }

    private var _jobs_headerRefresher: _JobsSideRefresher? {
        get { objc_getAssociatedObject(self, &_jobsHeaderRefKey) as? _JobsSideRefresher }
        set { objc_setAssociatedObject(self, &_jobsHeaderRefKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var _jobs_footerRefresher: _JobsSideRefresher? {
        get { objc_getAssociatedObject(self, &_jobsFooterRefKey) as? _JobsSideRefresher }
        set { objc_setAssociatedObject(self, &_jobsFooterRefKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // 安装：下拉(或左拉)
    @discardableResult
    func pullDownWithJobsAnimator(_ action: @escaping () -> Void,
                                  config: ((JobsHeaderAnimator) -> Void)? = nil) -> Self {
        if _jobs_headerRefresher == nil {
            let animator = JobsHeaderAnimator()
            (animator as _JobsAnimatorAxisAware)._jobs_isHorizontalContext = (jobs_refreshAxis == .horizontal)
            config?(animator)
            let edge: _JobsRefreshEdge = (jobs_refreshAxis == .vertical) ? .top : .leading
            _jobs_headerRefresher = _JobsSideRefresher(scroll: self,
                                                       axis: jobs_refreshAxis,
                                                       edge: edge,
                                                       animator: animator,
                                                       handler: action)
        }
        return self
    }

    // 安装：上拉(或右拉)
    @discardableResult
    func pullUpWithJobsAnimator(_ action: @escaping () -> Void,
                                config: ((JobsFooterAnimator) -> Void)? = nil) -> Self {
        if _jobs_footerRefresher == nil {
            let animator = JobsFooterAnimator()
            (animator as _JobsAnimatorAxisAware)._jobs_isHorizontalContext = (jobs_refreshAxis == .horizontal)
            config?(animator)
            let edge: _JobsRefreshEdge = (jobs_refreshAxis == .vertical) ? .bottom : .trailing
            _jobs_footerRefresher = _JobsSideRefresher(scroll: self,
                                                       axis: jobs_refreshAxis,
                                                       edge: edge,
                                                       animator: animator,
                                                       handler: action)
        }
        return self
    }

    @discardableResult func pullDownStart(auto: Bool = false) -> Self { _jobs_headerRefresher?.beginRefreshing(auto: auto); return self }
    @discardableResult func pullDownStop(ignoreDate: Bool = false, ignoreFooter: Bool = false) -> Self {
        _jobs_headerRefresher?.stopRefreshing()
        if ignoreFooter { _jobs_footerRefresher?.noMoreData = false }
        return self
    }
    @discardableResult func pullUpStop() -> Self { _jobs_footerRefresher?.stopRefreshing(); return self }
    @discardableResult func pullUpNoMore() -> Self { _jobs_footerRefresher?.noMoreData = true; return self }
    @discardableResult func pullUpReset() -> Self { _jobs_footerRefresher?.noMoreData = false; return self }
    @discardableResult func removeRefreshers() -> Self {
        _jobs_headerRefresher?.stopRefreshing()
        _jobs_footerRefresher?.stopRefreshing()
        _jobs_headerRefresher = nil
        _jobs_footerRefresher = nil
        return self
    }
}

// MARK: - Helpers
@inline(__always)
private func _adjustedInsets(_ s: UIScrollView) -> UIEdgeInsets {
    if #available(iOS 11.0, *) { return s.adjustedContentInset }
    return s.contentInset
}
