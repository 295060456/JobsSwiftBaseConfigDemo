//
//  JobsRefresher.swift
//  JobsSwiftBaseConfigDemo
//

#if os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC
import SnapKit
import QuartzCore

public enum JobsRefreshAxis { case vertical, horizontal }
public enum _JobsRefreshEdge { case top, bottom, leading, trailing }
public enum _JobsRefreshState { case idle, pulling, ready, refreshing, noMore }
public enum JobsTextOrientationMode { case auto, horizontal, verticalStack }
public enum _JobsResolvedOrientation { case horizontal, verticalStack }

// 手势/位移取样策略
public enum JobsPullSenseMode { case pureOffset, panFallback, insetFollow }

public protocol JobsRefreshAnimatable: AnyObject {
    var executeIncremental: CGFloat { get set }
    func drive(_ state: _JobsRefreshState)
}

private protocol _JobsAnimatorAxisAware: AnyObject {
    var _jobs_isHorizontalContext: Bool { get set }
    var textOrientation: JobsTextOrientationMode { get set }
}

extension _JobsAnimatorAxisAware {
    @inline(__always)
    fileprivate func _jobs_resolvedOrientation() -> _JobsResolvedOrientation {
        switch textOrientation {
        case .horizontal:    return .horizontal
        case .verticalStack: return .verticalStack
        case .auto:          return _jobs_isHorizontalContext ? .verticalStack : .horizontal
        }
    }
    @inline(__always)
    fileprivate func _jobs_orientedText(_ s: String) -> String {
        switch _jobs_resolvedOrientation() {
        case .horizontal:    return s
        case .verticalStack: return s.contains("\n") ? s : s.map { String($0) }.joined(separator: "\n")
        }
    }
}

// MARK: - Header（红）
public final class JobsHeaderAnimator: UIView, JobsRefreshAnimatable, _JobsAnimatorAxisAware {
    public var executeIncremental: CGFloat = 60
    public var idleDescription = "下拉刷新"
    public var releaseToRefreshDescription = "松开立即刷新"
    public var loadingDescription = "刷新中…"
    public var noMoreDataDescription = "已经是最新数据"

    public var textOrientation: JobsTextOrientationMode = .auto
    internal var _jobs_isHorizontalContext = false

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
            .byText(idleDescription)
    }()
    private let indicator = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        addSubview(titleLabel)
        indicator.byHidesWhenStopped(true)
        addSubview(indicator)
        #if DEBUG
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemRed.cgColor
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.08)
        if #available(iOS 13.0, *) { indicator.color = .systemRed }
        #endif
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let vertical = (_jobs_resolvedOrientation() == .verticalStack)
        let spacing: CGFloat = 6
        if vertical {
            let maxW = min(bounds.width * 0.75, 60)
            titleLabel.byNumberOfLines(0).byLineBreakMode(.byWordWrapping).byPreferredMaxLayoutWidth(maxW)
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - spacing)
            indicator.sizeToFit()
            indicator.center = CGPoint(x: bounds.midX, y: titleLabel.frame.maxY + spacing + indicator.bounds.height/2)
        } else {
            titleLabel.byNumberOfLines(1).byLineBreakMode(.byTruncatingTail).byPreferredMaxLayoutWidth(0)
            titleLabel.sizeToFit()
            indicator.sizeToFit()
            let totalW = indicator.bounds.width + spacing + titleLabel.bounds.width
            let startX = bounds.midX - totalW / 2
            indicator.frame.origin = CGPoint(x: startX, y: bounds.midY - indicator.bounds.height/2)
            titleLabel.frame.origin = CGPoint(x: indicator.frame.maxX + spacing,
                                              y: bounds.midY - titleLabel.bounds.height/2)
        }
    }

    public func drive(_ state: _JobsRefreshState) {
        switch state {
        case .idle, .pulling:
            titleLabel.byText(_jobs_orientedText(idleDescription)); indicator.stopAnimating()
        case .ready:
            titleLabel.byText(_jobs_orientedText(releaseToRefreshDescription)); indicator.stopAnimating()
        case .refreshing:
            titleLabel.byText(_jobs_orientedText(loadingDescription)); indicator.startAnimating()
        case .noMore:
            titleLabel.byText(_jobs_orientedText(noMoreDataDescription)); indicator.stopAnimating()
        }
        setNeedsLayout()
    }

    @discardableResult public func byIdleDescription(_ t: String) -> Self { idleDescription = t; return self }
    @discardableResult public func byReleaseToRefreshDescription(_ t: String) -> Self { releaseToRefreshDescription = t; return self }
    @discardableResult public func byLoadingDescription(_ t: String) -> Self { loadingDescription = t; return self }
    @discardableResult public func byNoMoreDataDescription(_ t: String) -> Self { noMoreDataDescription = t; return self }
    @discardableResult public func byTextOrientation(_ m: JobsTextOrientationMode) -> Self { textOrientation = m; return self }
}

// MARK: - Footer（绿）
public final class JobsFooterAnimator: UIView, JobsRefreshAnimatable, _JobsAnimatorAxisAware {
    public var executeIncremental: CGFloat = 52
    public var idleDescription = "上拉加载更多"
    public var releaseToRefreshDescription = "松开立即加载"
    public var loadingMoreDescription = "加载中…"
    public var noMoreDataDescription = "没有更多数据"

    public var textOrientation: JobsTextOrientationMode = .auto
    internal var _jobs_isHorizontalContext = false

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
            .byText(idleDescription)
    }()
    private let indicator = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        addSubview(titleLabel)
        indicator.byHidesWhenStopped(true)
        addSubview(indicator)
        #if DEBUG
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGreen.cgColor
        backgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
        if #available(iOS 13.0, *) { indicator.color = .systemGreen }
        #endif
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let vertical = (_jobs_resolvedOrientation() == .verticalStack)
        let spacing: CGFloat = 6
        if vertical {
            let maxW = min(bounds.width * 0.75, 60)
            titleLabel.byNumberOfLines(0).byLineBreakMode(.byWordWrapping).byPreferredMaxLayoutWidth(maxW)
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - spacing)
            indicator.sizeToFit()
            indicator.center = CGPoint(x: bounds.midX, y: titleLabel.frame.maxY + spacing + indicator.bounds.height/2)
        } else {
            titleLabel.byNumberOfLines(1).byLineBreakMode(.byTruncatingTail).byPreferredMaxLayoutWidth(0)
            titleLabel.sizeToFit()
            indicator.sizeToFit()
            let totalW = indicator.bounds.width + spacing + titleLabel.bounds.width
            let startX = bounds.midX - totalW / 2
            indicator.frame.origin = CGPoint(x: startX, y: bounds.midY - indicator.bounds.height/2)
            titleLabel.frame.origin = CGPoint(x: indicator.frame.maxX + spacing,
                                              y: bounds.midY - titleLabel.bounds.height/2)
        }
    }

    public func drive(_ state: _JobsRefreshState) {
        switch state {
        case .idle, .pulling:
            titleLabel.byText(_jobs_orientedText(idleDescription)); indicator.stopAnimating()
        case .ready:
            titleLabel.byText(_jobs_orientedText(releaseToRefreshDescription)); indicator.stopAnimating()
        case .refreshing:
            titleLabel.byText(_jobs_orientedText(loadingMoreDescription)); indicator.startAnimating()
        case .noMore:
            titleLabel.byText(_jobs_orientedText(noMoreDataDescription)); indicator.stopAnimating()
        }
        setNeedsLayout()
    }

    @discardableResult public func byIdleDescription(_ t: String) -> Self { idleDescription = t; return self }
    @discardableResult public func byReleaseToRefreshDescription(_ t: String) -> Self { releaseToRefreshDescription = t; return self }
    @discardableResult public func byLoadingMoreDescription(_ t: String) -> Self { loadingMoreDescription = t; return self }
    @discardableResult public func byNoMoreDataDescription(_ t: String) -> Self { noMoreDataDescription = t; return self }
    @discardableResult public func byTextOrientation(_ m: JobsTextOrientationMode) -> Self { textOrientation = m; return self }
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

    private var contentOffsetObs: NSKeyValueObservation?
    private var contentSizeObs: NSKeyValueObservation?
    private var boundsObs: NSKeyValueObservation?
    private var adjustedInsetObs: NSKeyValueObservation?
    private var contentInsetObs: NSKeyValueObservation?

    private var baseInsets: UIEdgeInsets = .zero
    private var appliedInset: CGFloat = 0

    private var sizeConstraint: Constraint?

    private var releaseWatchLink: CADisplayLink?

    private var panBaseline: CGPoint = .zero
    private let PAN_EPS: CGFloat = 4
    private let HYSTERESIS: CGFloat = 2
    private var liveExtent: CGFloat = 0
    private var interactiveAdjusting = false

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
        ensureBounceIfNeeded(s)
        observe(s)
        onOffsetChanged()
    }

    private func detach() {
        stopReleaseWatch()
        contentOffsetObs?.invalidate()
        contentSizeObs?.invalidate()
        boundsObs?.invalidate()
        adjustedInsetObs?.invalidate()
        contentInsetObs?.invalidate()
        animator.removeFromSuperview()
    }

    private func observe(_ s: UIScrollView) {
        contentOffsetObs = s.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            self?.onOffsetChanged(); self?._layoutIfLegacy()
        }
        contentSizeObs = s.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            self?._layoutIfLegacy()
        }
        boundsObs = s.observe(\.bounds, options: [.new]) { [weak self] _, _ in
            self?._layoutIfLegacy()
        }
        if #available(iOS 11.0, *) {
            adjustedInsetObs = s.observe(\.adjustedContentInset, options: [.new]) { [weak self] s, _ in
                guard let self else { return }
                if !self.interactiveAdjusting && self.state == .idle { self.baseInsets = s.adjustedContentInset }
            }
        } else {
            contentInsetObs = s.observe(\.contentInset, options: [.new]) { [weak self] s, _ in
                guard let self else { return }
                if !self.interactiveAdjusting && self.state == .idle { self.baseInsets = s.contentInset }
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
                make.top.equalTo(s.frameLayoutGuide.snp.top)              // 头部也贴可视区顶
                sizeConstraint = make.height.equalTo(0).constraint        // 高度由 liveExtent 驱动
            }

        case (.vertical, .bottom):
            animator.snp.remakeConstraints { make in
                make.leading.equalTo(s.frameLayoutGuide.snp.leading)
                make.trailing.equalTo(s.frameLayoutGuide.snp.trailing)
                make.bottom.equalTo(s.frameLayoutGuide.snp.bottom)        // ✅ 关键：贴可视区底
                sizeConstraint = make.height.equalTo(0).constraint        //   从 0 向上长
            }

        case (.horizontal, .leading):
            animator.snp.remakeConstraints { make in
                make.top.equalTo(s.frameLayoutGuide.snp.top)
                make.bottom.equalTo(s.frameLayoutGuide.snp.bottom)
                make.leading.equalTo(s.frameLayoutGuide.snp.leading)      // 左侧贴可视区左
                sizeConstraint = make.width.equalTo(0).constraint         // 宽度由 liveExtent 驱动
            }

        case (.horizontal, .trailing):
            animator.snp.remakeConstraints { make in
                make.top.equalTo(s.frameLayoutGuide.snp.top)
                make.bottom.equalTo(s.frameLayoutGuide.snp.bottom)
                make.trailing.equalTo(s.frameLayoutGuide.snp.trailing)    // ✅ 关键：贴可视区右
                sizeConstraint = make.width.equalTo(0).constraint         //   从 0 向左长
            }

        default:
            break
        }

        if s.window != nil { s.setNeedsLayout(); s.layoutIfNeeded() }
        else { DispatchQueue.main.async { [weak s] in s?.setNeedsLayout(); s?.layoutIfNeeded() } }
    }

    // iOS 11+：用约束更新高度/宽度；iOS 10-：用 frame 贴可视区
    private func _layoutIfLegacy() {
        guard let s = scroll else { return }

        if #available(iOS 11.0, *) {
            // iOS 11+ 用约束：高度/宽度 = (refreshing ? executeIncremental : liveExtent)
            let desired = (state == .refreshing) ? animator.executeIncremental : liveExtent
            sizeConstraint?.update(offset: max(0, desired))
            return
        }

        // iOS 10 及以下：frame 布局（把 Header/Footer 贴在“当前视口”的边缘，尺寸=liveExtent/execute）
        let H = (state == .refreshing) ? animator.executeIncremental : liveExtent
        switch (axis, edge) {
        case (.vertical, .top):
            // 贴可视区顶，向下长
            animator.frame = CGRect(x: s.contentOffset.x,
                                    y: s.contentOffset.y,
                                    width: s.bounds.width,
                                    height: H)

        case (.vertical, .bottom):
            // 贴可视区底，向上长
            animator.frame = CGRect(x: s.contentOffset.x,
                                    y: s.contentOffset.y + s.bounds.height - H,
                                    width: s.bounds.width,
                                    height: H)

        case (.horizontal, .leading):
            // 贴可视区左，向右长
            animator.frame = CGRect(x: s.contentOffset.x,
                                    y: s.contentOffset.y,
                                    width: H,
                                    height: s.bounds.height)

        case (.horizontal, .trailing):
            // 贴可视区右，向左长
            animator.frame = CGRect(x: s.contentOffset.x + s.bounds.width - H,
                                    y: s.contentOffset.y,
                                    width: H,
                                    height: s.bounds.height)

        default:
            break
        }
    }

    // MARK: - 状态机（带 .insetFollow 跟手）
    private func onOffsetChanged() {
        guard let s = scroll else { return }
        guard state != .refreshing && state != .noMore else { return }

        ensureBounceIfNeeded(s)

        // 采样基准：每次拖拽开始记录一次
        let pan = s.panGestureRecognizer
        if pan.state == .began { panBaseline = pan.translation(in: s) }
        if pan.state == .ended || pan.state == .cancelled || pan.state == .failed { panBaseline = .zero }

        @inline(__always) func dY() -> CGFloat { pan.translation(in: s).y - panBaseline.y } // 下拉为正，上推为负
        @inline(__always) func dX() -> CGFloat { pan.translation(in: s).x - panBaseline.x } // 右拉为正，左推为负

        // 针对四个方向的“额外位移兜底”
        @inline(__always) func extraDown() -> CGFloat { s.isDragging ? max(0,  dY() - PAN_EPS) : 0 }   // 头部：下拉
        @inline(__always) func extraUp()   -> CGFloat { s.isDragging ? max(0, -dY() - PAN_EPS) : 0 }   // 尾部：上推
        @inline(__always) func extraRight() -> CGFloat { s.isDragging ? max(0,  dX() - PAN_EPS) : 0 }  // leading：向右
        @inline(__always) func extraLeft()  -> CGFloat { s.isDragging ? max(0, -dX() - PAN_EPS) : 0 }  // trailing：向左

        let sense = s.jobs_refreshSense
        let th = animator.executeIncremental

        // 跟手：把 liveExtent 同步到 contentInset
        func applyInteractiveInset(_ extent: CGFloat) {
            guard sense == .insetFollow else { return }
            interactiveAdjusting = extent > 0
            switch (axis, edge) {
            case (.vertical, .top):        s.contentInset.top    = baseInsets.top + extent
            case (.vertical, .bottom):     s.contentInset.bottom = baseInsets.bottom + extent
            case (.horizontal, .leading):  s.contentInset.left   = baseInsets.left + extent
            case (.horizontal, .trailing): s.contentInset.right  = baseInsets.right + extent
            default: break
            }
        }

        switch (axis, edge) {

        // 顶部：下拉
        case (.vertical, .top):
            let raw   = max(0, -(s.contentOffset.y + baseInsets.top))
            let extra = (sense == .panFallback || sense == .insetFollow) ? extraDown() : 0
            let pull  = max(raw, extra)

            liveExtent = min(th, pull)
            animator.isHidden = (pull <= 0)

            if sense == .insetFollow { applyInteractiveInset(liveExtent); animator.transform = .identity }
            else { animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: 0, y: extra) }

            state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
            _layoutIfLegacy()

        // 底部：上推（关键修复：extraUp）
        case (.vertical, .bottom):
            if noMoreData { state = .noMore; return }
            let contentH  = max(s.contentSize.height, 0)
            let visibleH  = s.bounds.height
            let bottomEdge = max(-baseInsets.top, contentH + baseInsets.bottom - visibleH)

            let raw   = max(0, s.contentOffset.y - bottomEdge)
            let extra = (sense == .panFallback || sense == .insetFollow) ? extraUp() : 0    // ✅ 方向修正
            let pull  = max(raw, extra)

            liveExtent = min(th, pull)
            animator.isHidden = (pull <= 0)

            if sense == .insetFollow { applyInteractiveInset(liveExtent); animator.transform = .identity }
            else { animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: 0, y: -extra) }

            state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
            _layoutIfLegacy()

        // 左侧（等价“下拉”）：向右拉
        case (.horizontal, .leading):
            let raw   = max(0, -(s.contentOffset.x + baseInsets.left))
            let extra = (sense == .panFallback || sense == .insetFollow) ? extraRight() : 0
            let pull  = max(raw, extra)

            liveExtent = min(th, pull)
            animator.isHidden = (pull <= 0)

            if sense == .insetFollow { applyInteractiveInset(liveExtent); animator.transform = .identity }
            else { animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: extra, y: 0) }

            state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
            _layoutIfLegacy()

        // 右侧（等价“上拉”）：向左推（关键修复：extraLeft）
        case (.horizontal, .trailing):
            if noMoreData { state = .noMore; return }
            let contentW = max(s.contentSize.width, 0)
            let visibleW = s.bounds.width
            let rightEdge = max(-baseInsets.left, contentW + baseInsets.right - visibleW)

            let raw   = max(0, s.contentOffset.x - rightEdge)
            let extra = (sense == .panFallback || sense == .insetFollow) ? extraLeft() : 0   // ✅ 方向修正
            let pull  = max(raw, extra)

            liveExtent = min(th, pull)
            animator.isHidden = (pull <= 0)

            if sense == .insetFollow { applyInteractiveInset(liveExtent); animator.transform = .identity }
            else { animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: -extra, y: 0) }

            state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
            _layoutIfLegacy()

        default:
            break
        }

        // 自动触发 & 回弹收拢
        updateReleaseWatch(for: s)
        if state == .ready, !s.isDragging { beginRefreshing() }
    }

    // MARK: - Begin / Stop
    func beginRefreshing(auto: Bool = false) {
        guard let s = scroll, state != .refreshing else { return }
        if (edge == .trailing || edge == .bottom), noMoreData { return }

        animator.isHidden = false
        state = .refreshing

        let pre = (s.jobs_refreshSense == .insetFollow) ? liveExtent : 0
        let need = max(0, animator.executeIncremental - pre)
        appliedInset = need

        animator.transform = .identity
        liveExtent = animator.executeIncremental
        sizeConstraint?.update(offset: liveExtent)
        interactiveAdjusting = false

        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            switch (self.axis, self.edge) {
            case (.vertical, .top):
                s.contentInset.top = self.baseInsets.top + pre + need
                s.setContentOffset(CGPoint(x: s.contentOffset.x,
                                           y: -(self.baseInsets.top + pre + need)), animated: false)
            case (.vertical, .bottom):
                s.contentInset.bottom = self.baseInsets.bottom + pre + need
                let contentH = max(s.contentSize.height, s.bounds.height)
                let targetY = contentH + self.baseInsets.bottom + pre + need - s.bounds.height
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)
            case (.horizontal, .leading):
                s.contentInset.left = self.baseInsets.left + pre + need
                s.setContentOffset(CGPoint(x: -(self.baseInsets.left + pre + need),
                                           y: s.contentOffset.y), animated: false)
            case (.horizontal, .trailing):
                s.contentInset.right = self.baseInsets.right + pre + need
                let contentW = max(s.contentSize.width, s.bounds.width)
                let targetX = contentW + self.baseInsets.right + pre + need - s.bounds.width
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)
            default: break
            }
        } completion: { _ in
            self.stopReleaseWatch()
            self.handler()
        }
    }

    func stopRefreshing() {
        guard let s = scroll, state == .refreshing else { return }
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            switch (self.axis, self.edge) {
            case (.vertical, .top):
                s.contentInset.top = self.baseInsets.top
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: -self.baseInsets.top), animated: false)
            case (.vertical, .bottom):
                s.contentInset.bottom = self.baseInsets.bottom
                let contentH = max(s.contentSize.height, s.bounds.height)
                let targetY = contentH + self.baseInsets.bottom - s.bounds.height
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)
            case (.horizontal, .leading):
                s.contentInset.left = self.baseInsets.left
                s.setContentOffset(CGPoint(x: -self.baseInsets.left, y: s.contentOffset.y), animated: false)
            case (.horizontal, .trailing):
                s.contentInset.right = self.baseInsets.right
                let contentW = max(s.contentSize.width, s.bounds.width)
                let targetX = contentW + self.baseInsets.right - s.bounds.width
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)
            default: break
            }
        } completion: { _ in
            self.state = (self.edge == .trailing || self.edge == .bottom) && self.noMoreData ? .noMore : .idle
            if let s = self.scroll {
                self.liveExtent = 0
                self.animator.transform = .identity
                self.baseInsets = _adjustedInsets(s)
                self.onOffsetChanged()
            }
        }
    }

    private func collapseIfNeedWhenReleased() {
        guard let s = scroll else { return }
        guard state != .refreshing, !s.isDragging, liveExtent > 0 else { return }
        UIView.animate(withDuration: 0.20, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            switch (self.axis, self.edge) {
            case (.vertical, .top):        s.contentInset.top    = self.baseInsets.top
            case (.vertical, .bottom):     s.contentInset.bottom = self.baseInsets.bottom
            case (.horizontal, .leading):  s.contentInset.left   = self.baseInsets.left
            case (.horizontal, .trailing): s.contentInset.right  = self.baseInsets.right
            default: break
            }
        } completion: { _ in
            self.liveExtent = 0
            self.interactiveAdjusting = false
            self.state = .idle
            self.animator.transform = .identity
            self._layoutIfLegacy()
        }
    }

    @inline(__always)
    private func ensureBounceIfNeeded(_ s: UIScrollView) {
        if axis == .vertical {
            if !s.alwaysBounceVertical { s.alwaysBounceVertical = true }
        } else {
            if !s.alwaysBounceHorizontal { s.alwaysBounceHorizontal = true }
        }
        if !s.bounces { s.bounces = true }
    }

    private func updateReleaseWatch(for s: UIScrollView) {
        if state == .pulling || state == .ready {
            if releaseWatchLink == nil {
                let link = CADisplayLink(target: self, selector: #selector(_releaseTick))
                link.add(to: .main, forMode: .common)
                releaseWatchLink = link
            }
        } else {
            stopReleaseWatch()
        }
    }

    @objc private func _releaseTick() {
        guard let s = scroll else { stopReleaseWatch(); return }
        ensureBounceIfNeeded(s)
        if state == .ready && !s.isDragging { beginRefreshing() }
        if state != .refreshing && !s.isDragging { collapseIfNeedWhenReleased() }
        if state != .pulling && state != .ready { stopReleaseWatch() }
    }

    private func stopReleaseWatch() {
        releaseWatchLink?.invalidate()
        releaseWatchLink = nil
    }
}

// MARK: - UIScrollView API
private var _jobsRefreshAxisKey: UInt8 = 0
private var _jobsHeaderRefKey: UInt8   = 0
private var _jobsFooterRefKey: UInt8   = 0
private var _jobsSenseModeKey: UInt8   = 0

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
            switch newValue {
            case .vertical:   alwaysBounceVertical = true
            case .horizontal: alwaysBounceHorizontal = true
            }
        }
    }
    @discardableResult func jobs_refreshAxis(_ axis: JobsRefreshAxis) -> Self { jobs_refreshAxis = axis; return self }

    var jobs_refreshSense: JobsPullSenseMode {
        get {
            (objc_getAssociatedObject(self, &_jobsSenseModeKey) as? NSNumber)
                .map { $0.intValue == 0 ? .pureOffset : ($0.intValue == 1 ? .panFallback : .insetFollow) } ?? .pureOffset
        }
        set {
            let v: Int = (newValue == .pureOffset ? 0 : (newValue == .panFallback ? 1 : 2))
            objc_setAssociatedObject(self, &_jobsSenseModeKey, NSNumber(value: v), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    @discardableResult func jobs_refreshSense(_ mode: JobsPullSenseMode) -> Self { self.jobs_refreshSense = mode; return self }

    private var _jobs_headerRefresher: _JobsSideRefresher? {
        get { objc_getAssociatedObject(self, &_jobsHeaderRefKey) as? _JobsSideRefresher }
        set { objc_setAssociatedObject(self, &_jobsHeaderRefKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var _jobs_footerRefresher: _JobsSideRefresher? {
        get { objc_getAssociatedObject(self, &_jobsFooterRefKey) as? _JobsSideRefresher }
        set { objc_setAssociatedObject(self, &_jobsFooterRefKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

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
    @discardableResult func pullUpStart(auto: Bool = false) -> Self { _jobs_footerRefresher?.beginRefreshing(auto: auto); return self }
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

#if DEBUG
@inline(__always) private func JF(_ v: CGFloat) -> String { String(format: "%.1f", v) }
@inline(__always) private func JSize(_ s: CGSize) -> String { "(w:\(JF(s.width)), h:\(JF(s.height)))" }
@inline(__always) private func JPoint(_ p: CGPoint) -> String { "(x:\(JF(p.x)), y:\(JF(p.y)))" }
@inline(__always) private func JInsets(_ i: UIEdgeInsets) -> String { "(t:\(JF(i.top)), l:\(JF(i.left)), b:\(JF(i.bottom)), r:\(JF(i.right)))" }
@inline(__always) private func JRect(_ r: CGRect) -> String { "(x:\(JF(r.origin.x)), y:\(JF(r.origin.y)), w:\(JF(r.size.width)), h:\(JF(r.size.height)))" }
@inline(__always) private func JFrame(_ v: UIView) -> String { JRect(v.frame) }
@inline(__always) private func JDBG(_ tag: String, _ lines: [String]) {
    print("🧩 [JobsRefresher] \(tag)")
    for l in lines { print("   • \(l)") }
}
#else
@inline(__always) private func JF(_ v: CGFloat) -> String { "" }
@inline(__always) private func JSize(_ s: CGSize) -> String { "" }
@inline(__always) private func JPoint(_ p: CGPoint) -> String { "" }
@inline(__always) private func JInsets(_ i: UIEdgeInsets) -> String { "" }
@inline(__always) private func JRect(_ r: CGRect) -> String { "" }
@inline(__always) private func JFrame(_ v: UIView) -> String { "" }
@inline(__always) private func JDBG(_ tag: String, _ lines: [String]) {}
#endif
