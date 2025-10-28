//
//  JobsRefresher.swift
//  JobsSwiftBaseConfigDemo
//
//  完全替代第三方；统一支持垂直/水平刷新。
//  关键：新增 .insetFollow —— 交互期用 contentInset 跟手（不再用 transform）
//
//  API：pullDownWithJobsAnimator / pullUpWithJobsAnimator / pullDownStart / pullDownStop
//       / pullUpStop / pullUpNoMore / pullUpReset / removeRefreshers
//       / jobs_refreshAxis / jobs_refreshSense
//

#if os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC
import SnapKit
import QuartzCore

// MARK: - 公共枚举 / 协议
public enum JobsRefreshAxis { case vertical, horizontal }
public enum _JobsRefreshEdge { case top, bottom, leading, trailing }
public enum _JobsRefreshState { case idle, pulling, ready, refreshing, noMore }
public enum JobsTextOrientationMode { case auto, horizontal, verticalStack }
public enum _JobsResolvedOrientation { case horizontal, verticalStack }

// 手势/位移取样策略：
// 1) .pureOffset   —— 仅依赖 contentOffset（短内容橡皮筋时没有进度）
// 2) .panFallback  —— offset 被“夹住”时，读 pan.translation 兜底（会用 transform 露出）
// 3) .insetFollow  —— 交互期实时把 contentInset 顶/底/左/右加上 liveExtent（ScrollView 本体被拉动）
public enum JobsPullSenseMode { case pureOffset, panFallback, insetFollow }

public protocol JobsRefreshAnimatable: AnyObject {
    var executeIncremental: CGFloat { get set }      // Header=高度；Footer=高度/宽度
    func drive(_ state: _JobsRefreshState)
}

private protocol _JobsAnimatorAxisAware: AnyObject {
    var _jobs_isHorizontalContext: Bool { get set }
    var textOrientation: JobsTextOrientationMode { get set }
}

// MARK: - 方向解析 + 文案排版
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

// MARK: - Header（DEBUG：红）
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

    // DSL
    @discardableResult public func byIdleDescription(_ t: String) -> Self { idleDescription = t; return self }
    @discardableResult public func byReleaseToRefreshDescription(_ t: String) -> Self { releaseToRefreshDescription = t; return self }
    @discardableResult public func byLoadingDescription(_ t: String) -> Self { loadingDescription = t; return self }
    @discardableResult public func byNoMoreDataDescription(_ t: String) -> Self { noMoreDataDescription = t; return self }
    @discardableResult public func byTextOrientation(_ m: JobsTextOrientationMode) -> Self { textOrientation = m; return self }
}

// MARK: - Footer（DEBUG：绿）
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

    // DSL
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

    // KVO
    private var contentOffsetObs: NSKeyValueObservation?
    private var contentSizeObs: NSKeyValueObservation?
    private var boundsObs: NSKeyValueObservation?
    private var adjustedInsetObs: NSKeyValueObservation?
    private var contentInsetObs: NSKeyValueObservation?

    // inset 管理
    private var baseInsets: UIEdgeInsets = .zero     // “外界”的 inset，不含交互 & 刷新
    private var appliedInset: CGFloat = 0            // 进入刷新后我们追加的量（不含 liveExtent）

    // 约束（iOS 11+）
    private var sizeConstraint: Constraint?

    // 松手侦测
    private var releaseWatchLink: CADisplayLink?

    // —— 跟手所需 —— //
    private var panBaseline: CGPoint = .zero         // 手势开始时 translation 基线
    private let PAN_EPS: CGFloat = 4                 // 4pt 死区
    private let HYSTERESIS: CGFloat = 2              // 2pt 回差
    private var liveExtent: CGFloat = 0              // 交互期：可见尺寸 = min(阈值, 拉动量)
    private var interactiveAdjusting = false         // 交互期正在改 inset：禁止更新 baseInsets

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

        // DEBUG 颜色：Header=红 / Footer=绿
        #if DEBUG
        let isHeader = (edge == .top || edge == .leading)
        let color = isHeader ? UIColor.systemRed : UIColor.systemGreen
        animator.layer.borderWidth = 1
        animator.layer.borderColor = color.cgColor
        animator.backgroundColor = color.withAlphaComponent(0.08)
        #endif

        _installConstraintsIfPossible()
        _layoutIfLegacy()
        animator.drive(state)

        ensureBounceIfNeeded(s)
        observe(s)
        onOffsetChanged() // 首帧：短内容隐藏 footer/右侧
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
                guard let self else { return }
                // 仅在“非交互+非刷新”时刷新基线，避免把 liveExtent/刷新量写进基线
                if !self.interactiveAdjusting && self.state == .idle {
                    self.baseInsets = s.adjustedContentInset
                }
            }
        } else {
            contentInsetObs = s.observe(\.contentInset, options: [.new]) { [weak self] s, _ in
                guard let self else { return }
                if !self.interactiveAdjusting && self.state == .idle {
                    self.baseInsets = s.contentInset
                }
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
                make.top.equalTo(s.contentLayoutGuide.snp.bottom).priority(.high)
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
                make.leading.equalTo(s.contentLayoutGuide.snp.trailing).priority(.high)
                make.leading.greaterThanOrEqualTo(s.frameLayoutGuide.snp.trailing).priority(.required)
                sizeConstraint = make.width.equalTo(animator.executeIncremental).constraint
            }
        default: break
        }

        if s.window != nil {
            s.setNeedsLayout(); s.layoutIfNeeded()
        } else {
            DispatchQueue.main.async { [weak s] in
                s?.setNeedsLayout(); s?.layoutIfNeeded()
            }
        }
    }

    // iOS 10−：frame；iOS 11+：更新尺寸约束
    private func _layoutIfLegacy() {
        guard let s = scroll else { return }
        if #available(iOS 11.0, *) {
            let desired = (state == .refreshing) ? animator.executeIncremental : liveExtent
            sizeConstraint?.update(offset: max(0, desired))
            return
        }
        let H = (state == .refreshing) ? animator.executeIncremental : liveExtent
        switch (axis, edge) {
        case (.vertical, .top):
            animator.frame = CGRect(x: 0, y: -(H + baseInsets.top), width: s.bounds.width, height: H)
        case (.vertical, .bottom):
            let contentH = max(s.contentSize.height, s.bounds.height)
            animator.frame = CGRect(x: 0, y: contentH + baseInsets.bottom, width: s.bounds.width, height: H)
        case (.horizontal, .leading):
            animator.frame = CGRect(x: -(H + baseInsets.left), y: 0, width: H, height: s.bounds.height)
        case (.horizontal, .trailing):
            let contentW = max(s.contentSize.width, s.bounds.width)
            animator.frame = CGRect(x: contentW + baseInsets.right, y: 0, width: H, height: s.bounds.height)
        default: break
        }
    }

    // MARK: - 状态机（offset 为主；pan 兜底；.insetFollow 改 inset）
    private func onOffsetChanged() {
        guard let s = scroll else { return }
        guard state != .refreshing && state != .noMore else { return }

        ensureBounceIfNeeded(s)

        // 记录/清理手势基线
        let pan = s.panGestureRecognizer
        if pan.state == .began { panBaseline = pan.translation(in: s) }
        if pan.state == .ended || pan.state == .cancelled || pan.state == .failed { panBaseline = .zero }

        @inline(__always) func dY() -> CGFloat { pan.translation(in: s).y - panBaseline.y }
        @inline(__always) func dX() -> CGFloat { pan.translation(in: s).x - panBaseline.x }
        @inline(__always) func extraYIfDragging() -> CGFloat { s.isDragging ? max(0, dY() - PAN_EPS) : 0 }
        @inline(__always) func extraXIfDragging() -> CGFloat { s.isDragging ? max(0, dX() - PAN_EPS) : 0 }

        let th = animator.executeIncremental
        let sense = s.jobs_refreshSense

        func applyInteractiveInset(_ extent: CGFloat) {
            interactiveAdjusting = extent > 0
            guard sense == .insetFollow else { return }
            switch (axis, edge) {
            case (.vertical, .top):
                s.contentInset.top = baseInsets.top + extent
            case (.vertical, .bottom):
                s.contentInset.bottom = baseInsets.bottom + extent
            case (.horizontal, .leading):
                s.contentInset.left = baseInsets.left + extent
            case (.horizontal, .trailing):
                s.contentInset.right = baseInsets.right + extent
            default: break
            }
        }

        switch (axis, edge) {
        // 顶部：下拉
        case (.vertical, .top):
            do {
                let raw = max(0, -(s.contentOffset.y + baseInsets.top))
                let extra = (sense == .panFallback || sense == .insetFollow) ? extraYIfDragging() : 0
                let pull = max(raw, extra)

                liveExtent = min(th, pull)
                animator.isHidden = (pull <= 0)

                if sense == .insetFollow {
                    applyInteractiveInset(liveExtent)
                    animator.transform = .identity
                } else {
                    animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: 0, y: extra)
                }

                state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
                _layoutIfLegacy()
            }

        // 底部：上推
        case (.vertical, .bottom):
            do {
                if noMoreData { state = .noMore; return }
                let contentH = max(s.contentSize.height, 0)
                let visibleH = s.bounds.height
                let bottomEdge = max(-baseInsets.top, contentH + baseInsets.bottom - visibleH)
                let raw = max(0, s.contentOffset.y - bottomEdge)
                let extra = (sense == .panFallback || sense == .insetFollow) ? (s.isDragging ? max(0, -extraYIfDragging()) : 0) : 0
                let pull = max(raw, extra)

                liveExtent = min(th, pull)
                animator.isHidden = (pull <= 0)

                if sense == .insetFollow {
                    applyInteractiveInset(liveExtent)
                    animator.transform = .identity
                } else {
                    let ex = (raw > 0) ? 0 : (s.isDragging ? max(0, -dY() - PAN_EPS) : 0)
                    animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: 0, y: -ex)
                }

                state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
                _layoutIfLegacy()
            }

        // 左侧：右拉
        case (.horizontal, .leading):
            do {
                let raw = max(0, -(s.contentOffset.x + baseInsets.left))
                let extra = (sense == .panFallback || sense == .insetFollow) ? extraXIfDragging() : 0
                let pull = max(raw, extra)

                liveExtent = min(th, pull)
                animator.isHidden = (pull <= 0)

                if sense == .insetFollow {
                    applyInteractiveInset(liveExtent)
                    animator.transform = .identity
                } else {
                    animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: extra, y: 0)
                }

                state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
                _layoutIfLegacy()
            }

        // 右侧：左拉
        case (.horizontal, .trailing):
            do {
                if noMoreData { state = .noMore; return }
                let contentW = max(s.contentSize.width, 0)
                let visibleW = s.bounds.width
                let rightEdge = max(-baseInsets.left, contentW + baseInsets.right - visibleW)
                let raw = max(0, s.contentOffset.x - rightEdge)
                let extra = (sense == .panFallback || sense == .insetFollow) ? (s.isDragging ? max(0, -extraXIfDragging()) : 0) : 0
                let pull = max(raw, extra)

                liveExtent = min(th, pull)
                animator.isHidden = (pull <= 0)

                if sense == .insetFollow {
                    applyInteractiveInset(liveExtent)
                    animator.transform = .identity
                } else {
                    let ex = (raw > 0) ? 0 : (s.isDragging ? max(0, -dX() - PAN_EPS) : 0)
                    animator.transform = (raw > 0) ? .identity : CGAffineTransform(translationX: -ex, y: 0)
                }

                state = (pull >= th) ? .ready : (pull > HYSTERESIS ? .pulling : .idle)
                _layoutIfLegacy()
            }

        default: break
        }

        // 拖拽中开侦测；其它状态关
        updateReleaseWatch(for: s)

        // 有些设备最后一帧不再触发 offset：兜底
        if state == .ready, !s.isDragging { beginRefreshing() }
    }

    // MARK: - Begin / Stop
    func beginRefreshing(auto: Bool = false) {
        guard let s = scroll, state != .refreshing else { return }
        if (edge == .trailing || edge == .bottom), noMoreData { return }

        animator.isHidden = false
        state = .refreshing

        // 若使用 .insetFollow，交互期已经加了 liveExtent，这里只补“阈值 - liveExtent”
        let pre = (s.jobs_refreshSense == .insetFollow) ? liveExtent : 0
        let need = max(0, animator.executeIncremental - pre)
        appliedInset = need

        // 进入刷新：尺寸设为阈值、复位 transform
        animator.transform = .identity
        liveExtent = animator.executeIncremental
        sizeConstraint?.update(offset: liveExtent)
        interactiveAdjusting = false

        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            switch (self.axis, self.edge) {
            case (.vertical, .top):
                s.contentInset.top = self.baseInsets.top + pre + need
                let targetY = -(self.baseInsets.top + pre + need)
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.vertical, .bottom):
                s.contentInset.bottom = self.baseInsets.bottom + pre + need
                let contentH = max(s.contentSize.height, s.bounds.height)
                let targetY = contentH + self.baseInsets.bottom + pre + need - s.bounds.height
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.horizontal, .leading):
                s.contentInset.left = self.baseInsets.left + pre + need
                let targetX = -(self.baseInsets.left + pre + need)
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

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
                let targetY = -self.baseInsets.top
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.vertical, .bottom):
                s.contentInset.bottom = self.baseInsets.bottom
                let contentH = max(s.contentSize.height, s.bounds.height)
                let targetY = contentH + self.baseInsets.bottom - s.bounds.height
                s.setContentOffset(CGPoint(x: s.contentOffset.x, y: targetY), animated: false)

            case (.horizontal, .leading):
                s.contentInset.left = self.baseInsets.left
                let targetX = -self.baseInsets.left
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

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
                // 刷新完成后再更新基线
                self.baseInsets = _adjustedInsets(s)
                self.onOffsetChanged()
            }
        }
    }

    // 松手但未达阈值：把临时 inset 复原，避免“自己往下拉”
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

    // MARK: - 弹性保障（不触碰手势）
    @inline(__always)
    private func ensureBounceIfNeeded(_ s: UIScrollView) {
        if axis == .vertical {
            if !s.alwaysBounceVertical { s.alwaysBounceVertical = true }
        } else {
            if !s.alwaysBounceHorizontal { s.alwaysBounceHorizontal = true }
        }
        if !s.bounces { s.bounces = true }
    }

    // MARK: - 松手侦测（DisplayLink）
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

// MARK: - DEBUG 工具
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
