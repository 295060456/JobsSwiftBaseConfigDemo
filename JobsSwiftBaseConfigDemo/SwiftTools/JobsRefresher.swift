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

// MARK: - 统一的“方向解析 + 文案按方向排版”
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
        case .horizontal:
            return s                           // 横排：一行显示
        case .verticalStack:
            return s.contains("\n") ? s        // 竖排：逐字加换行
                                     : s.map { String($0) }.joined(separator: "\n")
        }
    }
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

    // 懒加载 label（链式 DSL 由你工程内扩展提供）
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
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let vertical = (_jobs_resolvedOrientation() == .verticalStack)
        let spacing: CGFloat = 6

        if vertical {
            // 竖排：多行
            let maxW = min(bounds.width * 0.75, 60)
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.preferredMaxLayoutWidth = maxW

            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - spacing)

            indicator.sizeToFit()
            indicator.center = CGPoint(x: bounds.midX,
                                       y: titleLabel.frame.maxY + spacing + indicator.bounds.height / 2)
        } else {
            // 横排：单行
            titleLabel.numberOfLines = 1
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.preferredMaxLayoutWidth = 0

            titleLabel.sizeToFit()
            indicator.sizeToFit()

            let totalW = indicator.bounds.width + spacing + titleLabel.bounds.width
            let startX = bounds.midX - totalW / 2
            indicator.frame.origin = CGPoint(x: startX, y: bounds.midY - indicator.bounds.height / 2)
            titleLabel.frame.origin = CGPoint(x: indicator.frame.maxX + spacing,
                                              y: bounds.midY - titleLabel.bounds.height / 2)
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

// MARK: - Footer
public final class JobsFooterAnimator: UIView, JobsRefreshAnimatable, _JobsAnimatorAxisAware {
    public var executeIncremental: CGFloat = 52
    public var idleDescription = "上拉加载更多"
    public var releaseToRefreshDescription = "松开立即加载"
    public var loadingMoreDescription = "加载中…"
    public var noMoreDataDescription = "没有更多数据"

    public var textOrientation: JobsTextOrientationMode = .auto
    internal var _jobs_isHorizontalContext = false

    // 懒加载 label
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
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let vertical = (_jobs_resolvedOrientation() == .verticalStack)
        let spacing: CGFloat = 6

        if vertical {
            // 竖排：多行
            let maxW = min(bounds.width * 0.75, 60)
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.preferredMaxLayoutWidth = maxW

            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - spacing)

            indicator.sizeToFit()
            indicator.center = CGPoint(x: bounds.midX,
                                       y: titleLabel.frame.maxY + spacing + indicator.bounds.height / 2)
        } else {
            // 横排：单行
            titleLabel.numberOfLines = 1
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.preferredMaxLayoutWidth = 0

            titleLabel.sizeToFit()
            indicator.sizeToFit()

            let totalW = indicator.bounds.width + spacing + titleLabel.bounds.width
            let startX = bounds.midX - totalW / 2
            indicator.frame.origin = CGPoint(x: startX, y: bounds.midY - indicator.bounds.height / 2)
            titleLabel.frame.origin = CGPoint(x: indicator.frame.maxX + spacing,
                                              y: bounds.midY - titleLabel.bounds.height / 2)
        }

        // DEBUG：打印子视图布局
        JDBG("Footer.layoutSubviews \(vertical ? "vertical" : "horizontal")", [
            "self.bounds=\(JSize(bounds.size))",
            "title=\(JRect(titleLabel.frame)) indicator=\(JRect(indicator.frame))"
        ])
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

        animator._jobs_isHorizontalContext = (axis == .horizontal)
        attach()
    }

    deinit { detach() }

    private func attach() {
        guard let s = scroll else { return }
        baseInsets = _adjustedInsets(s)

        s.addSubview(animator)
        #if DEBUG
        animator.layer.borderWidth = 1
        animator.layer.borderColor = UIColor.systemPink.cgColor
        animator.backgroundColor = UIColor.systemPink.withAlphaComponent(0.08)
        #endif

        _installConstraintsIfPossible()
        _layoutIfLegacy()
        animator.drive(state)

        // 防御式弹性
        s.bounces = true
        switch axis { case .vertical: s.alwaysBounceVertical = true
        case .horizontal: s.alwaysBounceHorizontal = true }

        JDBG("attach begin \(axis)-\(edge)", [
            "after addSubview -> animator \(JFrame(animator)) hidden=\(animator.isHidden)",
            "scroll bounds=\(JSize(s.bounds.size)) contentSize=\(JSize(s.contentSize)) inset=\(JInsets(_adjustedInsets(s)))"
        ])

        observe(s)

        // 进页面立即算一次，短内容首屏隐藏 footer
        onOffsetChanged()
        JDBG("attach after first onOffsetChanged \(axis)-\(edge)", [
            "animator \(JFrame(animator)) hidden=\(animator.isHidden)"
        ])

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
                // 贴内容尾部（高优先）
                make.top.equalTo(s.contentLayoutGuide.snp.bottom).priority(.high)
                // FIX: ≥  —— 至少在可视区下边缘之外，短内容时顶到 frame 底
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
                // 贴内容尾部（高优先）
                make.leading.equalTo(s.contentLayoutGuide.snp.trailing).priority(.high)
                // FIX: ≥  —— 至少在可视区右边缘之外，短内容时靠到 frame 右
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

        JDBG("installConstraints \(axis)-\(edge)", [
            "scroll bounds=\(JSize(s.bounds.size)) contentSize=\(JSize(s.contentSize)) inset=\(JInsets(_adjustedInsets(s)))",
            "animator \(JFrame(animator)) hidden=\(animator.isHidden)"
        ])

        DispatchQueue.main.async { [weak self, weak s] in
            guard let self, let s else { return }
            JDBG("post-layout (next runloop) \(self.axis)-\(self.edge)", [
                "animator \(JFrame(self.animator)) hidden=\(self.animator.isHidden)",
                "scroll bounds=\(JSize(s.bounds.size)) contentSize=\(JSize(s.contentSize))"
            ])
        }
    }


    private func _uninstallConstraints() {
        animator.snp.removeConstraints()
        installedConstraints.removeAll()
        sizeConstraint?.deactivate()
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
            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
            return
        }
        // iOS 11+：更新尺寸约束（height 或 width）
        if let c = sizeConstraint {
            let newValue = animator.executeIncremental
            c.update(offset: newValue)
        }
    }

    // MARK: - 状态机（动态 inset + translation 兜底）
    private func onOffsetChanged() {
        guard let s = scroll else { return }
        guard state != .refreshing && state != .noMore else { return }

        @inline(__always)
        func liveInsets(_ s: UIScrollView) -> UIEdgeInsets {
            if #available(iOS 11.0, *) { return s.adjustedContentInset }
            return s.contentInset
        }

        // 顶部兜底（下拉）
        @inline(__always)
        func fallbackPullY(_ s: UIScrollView, topInset: CGFloat) -> CGFloat {
            let pull = -(s.contentOffset.y + topInset)
            if pull > 0 { return pull }
            if s.isDragging {
                let t = -s.panGestureRecognizer.translation(in: s).y
                return max(0, t)
            }
            return 0
        }

        // 底部兜底（短内容：offset 卡在 -topInset，靠 translation 取值）
        @inline(__always)
        func fallbackPullBottom(_ s: UIScrollView, bottomEdge: CGFloat) -> CGFloat {
            let beyond = s.contentOffset.y - bottomEdge
            if beyond > 0 { return beyond }
            if s.isDragging {
                let t = -s.panGestureRecognizer.translation(in: s).y  // 上拖为正
                return max(0, t)
            }
            return 0
        }

        // 右侧兜底（短内容：offset 卡在 -leftInset）
        @inline(__always)
        func fallbackPullRight(_ s: UIScrollView, rightEdge: CGFloat) -> CGFloat {
            let beyond = s.contentOffset.x - rightEdge
            if beyond > 0 { return beyond }
            if s.isDragging {
                let t = -s.panGestureRecognizer.translation(in: s).x  // 向左为正
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
            let insets = liveInsets(s)
            let topInset = insets.top
            let bottomInset = insets.bottom
            let contentH = max(s.contentSize.height, 0)
            let bottomEdgeOffset = max(-topInset, contentH + bottomInset - s.bounds.height)

            // 兜底：短内容/系统“夹 offset”时仍能得到 pull
            let pull = fallbackPullBottom(s, bottomEdge: bottomEdgeOffset)

            JDBG("onOffsetChanged .vertical/.bottom", [
                "offset.y=\(JF(s.contentOffset.y)) bottomEdge=\(JF(bottomEdgeOffset)) pull=\(JF(pull))",
                "contentH=\(JF(contentH)) boundsH=\(JF(s.bounds.height)) insets=\(JInsets(insets))",
                "animator \(JFrame(animator)) hidden(before)=\(animator.isHidden)"
            ])

            animator.isHidden = (pull <= 0)

            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

            JDBG("onOffsetChanged .vertical/.bottom(after)", [
                "state=\(state) hidden(after)=\(animator.isHidden) execute=\(JF(animator.executeIncremental))"
            ])

        case (.horizontal, .leading):
            let leftInset = liveInsets(s).left
            let pull = max(0, -(s.contentOffset.x + leftInset))
            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

        case (.horizontal, .trailing):
            if noMoreData { state = .noMore; return }
            let insets = liveInsets(s)
            let leftInset = insets.left
            let rightInset = insets.right
            let contentW = max(s.contentSize.width, 0)
            let rightEdgeOffset = max(-leftInset, contentW + rightInset - s.bounds.width)

            let pull = fallbackPullRight(s, rightEdge: rightEdgeOffset)

            JDBG("onOffsetChanged .horizontal/.trailing", [
                "offset.x=\(JF(s.contentOffset.x)) rightEdge=\(JF(rightEdgeOffset)) pull=\(JF(pull))",
                "contentW=\(JF(contentW)) boundsW=\(JF(s.bounds.width)) insets=\(JInsets(insets))",
                "animator \(JFrame(animator)) hidden(before)=\(animator.isHidden)"
            ])

            animator.isHidden = (pull <= 0)

            if pull >= animator.executeIncremental { state = .ready }
            else if pull > 0 { state = .pulling }
            else { state = .idle }

            JDBG("onOffsetChanged .horizontal/.trailing(after)", [
                "state=\(state) hidden(after)=\(animator.isHidden) execute=\(JF(animator.executeIncremental))"
            ])

        default:
            break
        }
    }

    @objc private func panChanged(_ gr: UIPanGestureRecognizer) {
        if state == .ready && (gr.state == .changed || gr.state == .ended || gr.state == .cancelled || gr.state == .failed) {
            beginRefreshing()
        }
    }

    // MARK: - Begin / Stop（视图锚在内容边缘，不需要额外 pin）
    func beginRefreshing(auto: Bool = false) {
        guard let s = scroll, state != .refreshing else { return }
        if (edge == .trailing || edge == .bottom), noMoreData { return }

        animator.isHidden = false // 开始刷新一定可见
        state = .refreshing
        appliedInset = animator.executeIncremental

        JDBG("beginRefreshing \(axis)-\(edge) (before anim)", [
            "contentOffset=\(JPoint(s.contentOffset)) inset=\(JInsets(s.contentInset))",
            "animator \(JFrame(animator)) hidden=\(animator.isHidden)"
        ])

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

            case (.horizontal, .leading):
                s.contentInset.left += self.appliedInset
                let targetX = -(self.baseInsets.left + self.appliedInset)
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

            case (.horizontal, .trailing):
                s.contentInset.right += self.appliedInset
                let contentW = max(s.contentSize.width, s.bounds.width)
                let targetX = contentW + self.baseInsets.right + self.appliedInset - s.bounds.width
                s.setContentOffset(CGPoint(x: targetX, y: s.contentOffset.y), animated: false)

            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
        } completion: { _ in
            self.handler()
            if let s = self.scroll {
                JDBG("beginRefreshing \(self.axis)-\(self.edge) (after anim)", [
                    "contentOffset=\(JPoint(s.contentOffset)) inset=\(JInsets(s.contentInset))",
                    "animator \(JFrame(self.animator)) hidden=\(self.animator.isHidden)"
                ])
            }
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

            case (.horizontal, .top), (.horizontal, .bottom), (.vertical, .leading), (.vertical, .trailing):
                break
            }
        } completion: { _ in
            self.state = (self.edge == .trailing || self.edge == .bottom) && self.noMoreData ? .noMore : .idle
            if let s = self.scroll {
                self.baseInsets = _adjustedInsets(s)
                self.onOffsetChanged() // 结束后根据当前位置/拉动量决定显隐
                JDBG("stopRefreshing \(self.axis)-\(self.edge) completion", [
                    "state=\(self.state) contentOffset=\(JPoint(s.contentOffset)) inset=\(JInsets(s.contentInset))",
                    "animator \(JFrame(self.animator)) hidden=\(self.animator.isHidden)"
                ])
            }
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
            switch newValue {
            case .vertical:   alwaysBounceVertical = true
            case .horizontal: alwaysBounceHorizontal = true
            }
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

// MARK: - DEBUG 工具（本文件局部，非 UIView 扩展）
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
