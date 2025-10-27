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

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC
import SnapKit
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
public final class JobsHeaderAnimator: UIView,
                                        JobsRefreshAnimatable,
                                       _JobsAnimatorAxisAware {
    public var executeIncremental: CGFloat = 60
    public var idleDescription = "下拉刷新"
    public var releaseToRefreshDescription = "松开立即刷新"
    public var loadingDescription = "刷新中…"
    public var noMoreDataDescription = "已经是最新数据"

    public var textOrientation: JobsTextOrientationMode = .auto
    internal var _jobs_isHorizontalContext = false

    // ✅ 改成懒加载配置块
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
            .byNumberOfLines(0)
            .byText(idleDescription)
    }()

    private let indicator  = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false

        // titleLabel 的样式已放入 lazy 闭包，这里只做添加
        addSubview(titleLabel)
        indicator.byHidesWhenStopped(true)
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
            titleLabel.byText(oriented(idleDescription))
            indicator.stopAnimating()
        case .ready:
            titleLabel.byText(oriented(releaseToRefreshDescription))
            indicator.stopAnimating()
        case .refreshing:
            titleLabel.byText(oriented(loadingDescription))
            indicator.startAnimating()
        case .noMore:
            titleLabel.byText(oriented(noMoreDataDescription))
            indicator.stopAnimating()
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

    // ✅ 懒加载配置块
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
            .byNumberOfLines(0)
            .byText(idleDescription)
    }()

    private let indicator  = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false

        // titleLabel 样式已移入 lazy 闭包
        addSubview(titleLabel)

        indicator.byHidesWhenStopped(true)
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
            titleLabel.byText(oriented(idleDescription))
            indicator.stopAnimating()
        case .ready:
            titleLabel.byText(oriented(releaseToRefreshDescription))
            indicator.stopAnimating()
        case .refreshing:
            titleLabel.byText(oriented(loadingMoreDescription))
            indicator.startAnimating()
        case .noMore:
            titleLabel.byText(oriented(noMoreDataDescription))
            indicator.stopAnimating()
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
    private var sizeConstraint: Constraint?

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

        switch (axis, edge) {
        case (.vertical, .top):
            animator.snp.remakeConstraints { make in
                make.leading.equalTo(s.frameLayoutGuide.snp.leading)
                make.trailing.equalTo(s.frameLayoutGuide.snp.trailing)
                make.bottom.equalTo(s.contentLayoutGuide.snp.top)
                sizeConstraint = make.height.equalTo(animator.executeIncremental).constraint
            }

        case (.vertical, .bottom):
            animator.snp.remakeConstraints { make in
                make.leading.equalTo(s.frameLayoutGuide.snp.leading)
                make.trailing.equalTo(s.frameLayoutGuide.snp.trailing)
                // 首选：顶边贴内容尾部（内容够长时生效）
                make.top.equalTo(s.contentLayoutGuide.snp.bottom).priority(.high)
                // 底线：绝不在可视区域底部之上（内容不满一屏时生效）
                make.top.greaterThanOrEqualTo(s.frameLayoutGuide.snp.bottom).priority(.required)
                sizeConstraint = make.height.equalTo(animator.executeIncremental).constraint
            }

        case (.horizontal, .leading):
            animator.snp.remakeConstraints { make in
                make.top.equalTo(s.frameLayoutGuide.snp.top)
                make.bottom.equalTo(s.frameLayoutGuide.snp.bottom)
                make.trailing.equalTo(s.contentLayoutGuide.snp.leading)
                sizeConstraint = make.width.equalTo(animator.executeIncremental).constraint
            }

        case (.horizontal, .trailing):
            animator.snp.remakeConstraints { make in
                make.top.equalTo(s.frameLayoutGuide.snp.top)
                make.bottom.equalTo(s.frameLayoutGuide.snp.bottom)

                // 首选：左边贴内容右侧（内容够宽时生效）
                make.leading.equalTo(s.contentLayoutGuide.snp.trailing).priority(.high)
                // 底线：绝不在可视区域右侧之内（内容不满一屏时生效）
                make.leading.greaterThanOrEqualTo(s.frameLayoutGuide.snp.trailing).priority(.required)

                sizeConstraint = make.width.equalTo(animator.executeIncremental).constraint
            }

        case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
            break
        }

        if s.window != nil {
            s.setNeedsLayout()
            s.layoutIfNeeded()
        } else {
            DispatchQueue.main.async { [weak s] in
                guard let s else { return }
                s.setNeedsLayout()
                s.layoutIfNeeded()
            }
        }
    }

    private func _uninstallConstraints() {
        // 移除 animator 上由 SnapKit 安装的全部约束
        animator.snp.removeConstraints()
        // 清掉旧的手动记录（如果你还保留了这套字段）
        installedConstraints.removeAll()
        // 尺寸约束是单独存的 SnapKit.Constraint，记得关闭并置空
        sizeConstraint?.deactivate()
        sizeConstraint = nil
    }
    // iOS 10 及以下：frame 布局（与老实现等价）
    private func _layoutIfLegacy() {
        guard let s = scroll else { return }
        // iOS 10 及以下：仍用 frame 手工布局
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
            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
            return
        }
        // iOS 11+：用 SnapKit 的尺寸约束更新（height 或 width 都是同一个 sizeConstraint）
        if let c = sizeConstraint {
            let newValue = animator.executeIncremental
            c.update(offset: newValue) // 等价原来 c.constant = newValue
            // 如需避免频繁无效刷新，可自行加判断，但通常没必要
        }
    }
    // MARK: - 状态机（改良：动态 inset + translation 兜底）
    private func onOffsetChanged() {
        guard let s = scroll else { return }
        guard state != .refreshing && state != .noMore else { return }
        // 每次动态读取（不要依赖缓存的 baseInsets）
        @inline(__always)
        func liveInsets(_ s: UIScrollView) -> UIEdgeInsets {
            if #available(iOS 11.0, *) { return s.adjustedContentInset }
            return s.contentInset
        }
        // 当 contentOffset 被系统“卡死在 -topInset”时，用手势 translation 兜底
        @inline(__always)
        func fallbackPullY(_ s: UIScrollView, topInset: CGFloat) -> CGFloat {
            // 正常情况下，offset 会 < -topInset；被卡死时，offset ≈ -topInset
            let pull = -(s.contentOffset.y + topInset)
            if pull > 0 { return pull }
            // 只在拖拽中启用兜底：把“向下的手势位移”视作拉动量
            if s.isDragging {
                let t = -s.panGestureRecognizer.translation(in: s).y
                return max(0, t)
            }
            return 0
        }

        switch (axis, edge) {
        case (.vertical, .top):
            let topInset = liveInsets(s).top
            let pull = fallbackPullY(s, topInset: topInset)
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.vertical, .bottom):
            if noMoreData { state = .noMore; return }
            let bottomInset = liveInsets(s).bottom
            let contentH = max(s.contentSize.height, s.bounds.height)
            let beyond = s.contentOffset.y + s.bounds.height - contentH - bottomInset
            let pull = max(0, beyond)
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.horizontal, .leading):
            let leftInset = liveInsets(s).left
            let pull = max(0, -(s.contentOffset.x + leftInset))
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.horizontal, .trailing):
            if noMoreData { state = .noMore; return }
            let rightInset = liveInsets(s).right
            let contentW = max(s.contentSize.width, s.bounds.width)
            let beyond = s.contentOffset.x + s.bounds.width - contentW - rightInset
            let pull = max(0, beyond)
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        default:
            break
        }
    }

    @objc private func panChanged(_ gr: UIPanGestureRecognizer) {
        if state == .ready && (gr.state == .changed || gr.state == .ended || gr.state == .cancelled || gr.state == .failed) {
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
