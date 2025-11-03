//
//  JobsMarqueeView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/12.
//

import UIKit
import ObjectiveC

#if canImport(SDWebImage)
import SDWebImage
#endif
#if canImport(Kingfisher)
import Kingfisher
#endif

// MARK: - 滚动方向 & 模式
public enum MarqueeDirection { case left, right, up, down }

public enum MarqueeMode: Equatable {
    case continuous(speed: CGFloat)
    case intervalOnce(interval: TimeInterval, duration: TimeInterval, step: CGFloat? = nil)
}

// MARK: - Item 主轴长度策略
public enum ItemMainAxisLength {
    case autoMeasure
    case fixed(CGFloat)
    case fillViewport
}

// MARK: - PageControl 外观
public struct PageIndicatorAppearance {
    public var currentColor: UIColor?
    public var inactiveColor: UIColor?
    public var currentImage: UIImage?
    public var inactiveImage: UIImage?

    public init(currentColor: UIColor? = nil,
                inactiveColor: UIColor? = nil,
                currentImage: UIImage? = nil,
                inactiveImage: UIImage? = nil) {
        self.currentColor = currentColor
        self.inactiveColor = inactiveColor
        self.currentImage = currentImage
        self.inactiveImage = inactiveImage
    }
}

// MARK: - JobsMarqueeView
public final class JobsMarqueeView: UIView, UIScrollViewDelegate {

    // =========================
    // MARK: - 链式配置（公开）
    // =========================
    @discardableResult
    public func setButtons(_ buttons: [UIButton]) -> Self {
        baseButtons = buttons
        currentPageIndex = 0
        requestRebuild()
        return self
    }
    @discardableResult
    public func byDirection(_ d: MarqueeDirection) -> Self {
        direction = d
        updatePageControlVisibility()
        requestRebuild()
        return self
    }
    @discardableResult
    public func byMode(_ m: MarqueeMode) -> Self {
        mode = m
        switch m {
        case .continuous: timerKind = .displayLink
        case .intervalOnce: timerKind = .gcd
        }
        updatePageControlVisibility()
        restartTimerIfRunning()
        return self
    }
    @discardableResult
    public func byTimerKind(_ kind: JobsTimerKind) -> Self { timerKind = kind; restartTimerIfRunning(); return self }
    @discardableResult
    public func byAutoStartEnabled(_ on: Bool) -> Self { autoStartEnabled = on; return self }
    @discardableResult
    public func byContentWrapEnabled(_ on: Bool) -> Self { contentWrapEnabled = on; requestRebuild(); return self }
    @discardableResult
    public func byLoopEnabled(_ on: Bool) -> Self { loopEnabled = on; return self }
    @discardableResult
    public func byGestureScrollEnabled(_ on: Bool) -> Self { scrollView.isScrollEnabled = on; return self }
    @discardableResult
    public func byDirectionalLockEnabled(_ on: Bool) -> Self { scrollView.isDirectionalLockEnabled = on; return self }
    @discardableResult
    public func byHardAxisLock(_ on: Bool) -> Self { hardAxisLock = on; return self }
    @discardableResult
    public func byDecelerationRate(_ rate: UIScrollView.DecelerationRate) -> Self { scrollView.decelerationRate = rate; return self }
    @discardableResult
    public func byPauseOnUserDrag(_ on: Bool) -> Self { pauseOnUserDrag = on; return self }
    @discardableResult
    public func byResumeAfterDragDelay(_ delay: TimeInterval?) -> Self { resumeAfterDragDelay = delay; return self }
    @discardableResult
    public func byItemSpacing(_ spacing: CGFloat) -> Self { itemSpacing = max(0, spacing); requestRebuild(); updatePageControlVisibility(); return self }
    @discardableResult
    public func byItemMainAxisLength(_ s: ItemMainAxisLength) -> Self { itemMainAxisLength = s; requestRebuild(); updatePageControlVisibility(); return self }
    @discardableResult
    public func bySnapOnDragEnd(_ on: Bool) -> Self { snapOnDragEnd = on; return self }
    @discardableResult
    public func bySnapSpring(damping: CGFloat, initialVelocity: CGFloat) -> Self {
        snapSpringDamping = max(0.05, min(1.0, damping))
        snapSpringVelocity = max(0, initialVelocity)
        return self
    }
    @discardableResult
    public func byOnItemTap(_ handler: @escaping (_ index: Int, _ button: UIButton) -> Void) -> Self { onItemTap = handler; return self }
    public var onItemTap: ((_ index: Int, _ button: UIButton) -> Void)?

    /// ✅ 固有高度兜底（在外部没约束高度时避免塌到 0）
    @discardableResult
    public func byPreferredHeight(_ h: CGFloat) -> Self {
        preferredHeight = max(1, h)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        return self
    }

    /// 外部完成约束后调用（确保尺寸确定后重建）
    @discardableResult
    public func refreshAfterConstraints() -> Self {
        pendingRebuild = true
        needsRebuildOnLayout = true
        DispatchQueue.main.async { [weak self] in self?.setNeedsLayout() }
        return self
    }

    // ---------- PageControl 相关（链式） ----------
    @discardableResult
    public func byPageControlEnabled(_ on: Bool) -> Self {
        pageControlEnabled = on
        updatePageControlVisibility()
        setNeedsLayout()
        return self
    }
    @discardableResult
    public func byPageIndicatorAppearance(_ appearance: PageIndicatorAppearance) -> Self {
        pageAppearance = appearance
        applyPageAppearance()
        return self
    }
    @discardableResult
    public func byPageControlInsets(_ insets: UIEdgeInsets) -> Self {
        pageControlInsets = insets
        setNeedsLayout()
        return self
    }

    // =========================
    // MARK: - 生命周期
    // =========================
    public override init(frame: CGRect) { super.init(frame: frame); setup() }
    public required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        installBootstrapHeightIfNeeded()   // ✅ 自举高度（低优先级）
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            installBootstrapHeightIfNeeded()
            setNeedsLayout()
        } else {
            stop()
        }
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let hadSize = bounds.width > 0 && bounds.height > 0
        if !hadSize {
            needsRebuildOnLayout = true
            return
        }

        // ✅ 一旦拿到非 0 高度，卸载自举高度约束
        if bounds.height > 0, bootstrapHeight?.isActive == true {
            bootstrapHeight?.isActive = false
            bootstrapHeight = nil
        }

        let sizeChanged = lastSize != bounds.size
        if sizeChanged {
            lastSize = bounds.size
            scrollView.frame = bounds
            container.frame = scrollView.bounds
        }

        if needsRebuildOnLayout || sizeChanged { rebuildContent() }

        layoutPageControl()
    }

    deinit { stop() }

    // =========================
    // MARK: - 控制
    // =========================
    public func start() { guard baseButtons.count > 0 else { return }; startTimer() }
    public func pause() { timer?.pause(); isRunning = false }
    public func resume() { timer?.resume(); isRunning = true }
    public func fireOnce() { timer?.fireOnce() }
    public func stop() { timer?.stop(); timer = nil; isRunning = false }

    // =========================
    // MARK: - 私有成员
    // =========================
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.showsHorizontalScrollIndicator = false
        s.showsVerticalScrollIndicator = false
        s.bounces = false
        s.clipsToBounds = true
        return s
    }()
    private var container = UIView()
    private var baseButtons: [UIButton] = []
    private var clones: [UIButton] = []

    private var direction: MarqueeDirection = .left
    private var mode: MarqueeMode = .continuous(speed: 40)
    private var timerKind: JobsTimerKind = .displayLink
    private var timer: JobsTimerProtocol?
    public var isRunning = false

    private var autoStartEnabled = true
    private var contentWrapEnabled = true
    private var loopEnabled = true
    private var hardAxisLock = true
    private var pauseOnUserDrag = true
    private var resumeAfterDragDelay: TimeInterval? = 1.0
    private var itemSpacing: CGFloat = 0
    private var itemMainAxisLength: ItemMainAxisLength = .autoMeasure

    private var snapOnDragEnd = true
    private var snapSpringDamping: CGFloat = 0.82
    private var snapSpringVelocity: CGFloat = 0.5

    private var baseLength: CGFloat = 0
    private var copies: Int = 0
    private var midpointOffset: CGFloat = 0
    private var needsRebuildOnLayout = true
    private var pendingRebuild = false
    private var lastSize: CGSize = .zero

    /// ✅ 固有高度兜底；0 表示不声明固有高度（完全交给外部约束）
    private var preferredHeight: CGFloat = 0

    /// ✅ 低优先级自举高度（只在没有其它高度约束时兜底）
    private var bootstrapHeight: NSLayoutConstraint?

    #if canImport(SDWebImage) || canImport(Kingfisher)
    private var firstCloneRequestedIndex = Set<Int>()
    #endif

    // ---------- PageControl 内部状态 ----------
    private let pageControl = UIPageControl()
    private var pageControlEnabled: Bool = false
    private var pageAppearance: PageIndicatorAppearance = .init(currentColor: .white, inactiveColor: .systemGray)
    private var pageControlInsets: UIEdgeInsets = .init(top: 0, left: 8, bottom: 8, right: 8)
    private var currentPageIndex: Int = 0

    private func setup() {
        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self

        scrollView.addSubview(container)
        container.frame = scrollView.bounds
        container.clipsToBounds = false

        setContentCompressionResistancePriority(.required, for: .vertical)
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(_onPanChanged(_:)))
    }

    /// ✅ 安装低优先级“自举高度”，保证首帧也不是 0 高
    private func installBootstrapHeightIfNeeded() {
        guard bootstrapHeight == nil else { return }
        translatesAutoresizingMaskIntoConstraints = false // SnapKit 会设成 false，这里重复无害
        let h = preferredHeight > 0 ? preferredHeight : 64
        let c = heightAnchor.constraint(greaterThanOrEqualToConstant: h)
        c.priority = UILayoutPriority(250) // 低优先级，不抢外部约束
        c.isActive = true
        bootstrapHeight = c
    }

    private func requestRebuild() {
        pendingRebuild = true
        needsRebuildOnLayout = true
        setNeedsLayout()
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric,
               height: preferredHeight > 0 ? preferredHeight : UIView.noIntrinsicMetric)
    }

    // =========================
    // MARK: - 重建内容（核心）
    // =========================
    private func rebuildContent() {
        needsRebuildOnLayout = false

        guard bounds.width > 0, bounds.height > 0 else {
            needsRebuildOnLayout = true
            return
        }
        guard pendingRebuild || clones.isEmpty || lastSize != bounds.size else { return }
        pendingRebuild = false

        clones.forEach { $0.removeFromSuperview() }
        clones.removeAll()
        #if canImport(SDWebImage) || canImport(Kingfisher)
        firstCloneRequestedIndex.removeAll()
        #endif

        guard baseButtons.count > 0 else {
            scrollView.contentSize = .zero
            container.frame = scrollView.bounds
            updatePageControlVisibility()
            return
        }

        baseLength = measureBaseLengthConsideringStrategy(axisIsHorizontal: isHorizontal)

        let viewport = mainAxisLength(of: bounds.size)
        let epsilon: CGFloat = 1
        if contentWrapEnabled {
            let need = max(1, Int(ceil((viewport + epsilon) / max(1, baseLength))))
            copies = max(3, need + 2)
        } else {
            copies = 1
        }

        var cursor: CGFloat = 0
        for _ in 0..<copies {
            for (idx, src) in baseButtons.enumerated() {
                let btn = cloneButton(from: src)
                btn.tag = idx
                _ = btn.onTap { [weak self] b in self?.onItemTap?(b.tag, b) }

                let size = sizeForItem(from: btn)
                let frame = isHorizontal
                    ? CGRect(x: cursor, y: 0, width: size.width, height: size.height)
                    : CGRect(x: 0, y: cursor, width: size.width, height: size.height)

                btn.frame = frame
                container.addSubview(btn)
                clones.append(btn)

                cursor += (isHorizontal ? size.width : size.height) + itemSpacing

                let initiallyVisible = frame.intersects(self.container.bounds)
                #if canImport(SDWebImage)
                let allowNet_SD = initiallyVisible || firstCloneRequestedIndex.insert(idx).inserted
                src.sd_cloneBackground(to: btn, for: .normal, allowNetworkIfMissing: allowNet_SD)
                #elseif canImport(Kingfisher)
                let allowNet_KF = initiallyVisible || firstCloneRequestedIndex.insert(idx).inserted
                src.kf_cloneBackground(to: btn, for: .normal, allowNetworkIfMissing: allowNet_KF)
                #endif
            }
        }

        let totalLen = max(0, cursor - itemSpacing)
        scrollView.contentSize = isHorizontal
            ? CGSize(width: totalLen, height: bounds.height)
            : CGSize(width: bounds.width, height: totalLen)
        container.frame = scrollView.bounds

        if contentWrapEnabled && copies >= 3 {
            let oneCopyLen = baseLength
            let mid = oneCopyLen * CGFloat(copies / 2)
            midpointOffset = mid
            scrollView.contentOffset = isHorizontal ? CGPoint(x: mid, y: 0) : CGPoint(x: 0, y: mid)
        } else {
            midpointOffset = 0
            scrollView.contentOffset = .zero
        }

        DispatchQueue.main.async { [weak self] in self?._allowNetForVisibleClones() }

        if autoStartEnabled, timer == nil, !isRunning { start() }

        _preheatBackgroundsKFIfNeeded()

        updatePageControlVisibility()
        rebuildPageControlModel(resetToFirstPage: true)
    }

#if canImport(Kingfisher)
    private func _preheatBackgroundsKFIfNeeded() {
        struct Item { let url: URL; let placeholder: UIImage?; var options: KingfisherOptionsInfo; let index: Int }
        var items: [Item] = []
        for (idx, src) in baseButtons.enumerated() {
            guard let url = src.kf_bgURL ?? src._kf_config.url else { continue }
            var opts = src._kf_config.options
            opts.removeAll { if case .transition = $0 { return true } else { return false } }
            if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
                opts.append(.backgroundDecode)
            }
            if src._kf_config.placeholder != nil {
                opts.removeAll { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }
            }
            items.append(Item(url: url, placeholder: src._kf_config.placeholder, options: opts, index: idx))
        }
        guard !items.isEmpty else { return }
        for it in items {
            KingfisherManager.shared.retrieveImage(with: it.url, options: it.options) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let r):
                    let img = r.image
                    DispatchQueue.main.async {
                        self.clones.filter { $0.tag == it.index }.forEach { clone in
                            if #available(iOS 15.0, *) { clone.automaticallyUpdatesConfiguration = false }
                            clone.setBackgroundImage(img, for: .normal)
                            clone.setNeedsLayout()
                        }
                    }
                case .failure:
                    if let ph = it.placeholder {
                        DispatchQueue.main.async {
                            self.clones.filter { $0.tag == it.index }.forEach { clone in
                                if #available(iOS 15.0, *) { clone.automaticallyUpdatesConfiguration = false }
                                clone.setBackgroundImage(ph, for: .normal)
                                clone.setNeedsLayout()
                            }
                        }
                    }
                }
            }
        }
    }
#else
    private func _preheatBackgroundsKFIfNeeded() {}
#endif

    private func _allowNetForVisibleClones() {
        guard !clones.isEmpty else { return }
        let visible = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        for btn in clones where btn.frame.intersects(visible) {
            let idx = btn.tag
            guard baseButtons.indices.contains(idx) else { continue }
            let src = baseButtons[idx]
            #if canImport(Kingfisher)
            src.kf_cloneBackground(to: btn, for: .normal, allowNetworkIfMissing: true)
            #endif
            #if canImport(SDWebImage)
            src.sd_cloneBackground(to: btn, for: .normal, allowNetworkIfMissing: true)
            #endif
        }
    }

    // =========================
    // MARK: - 尺寸与测量
    // =========================
    private var isHorizontal: Bool { direction == .left || direction == .right }
    private func mainAxisLength(of size: CGSize) -> CGFloat { isHorizontal ? size.width : size.height }

    private func sizeForItem(from btn: UIButton) -> CGSize {
        func measured(_ b: UIButton) -> CGSize {
            let fitting = b.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if fitting != .zero { return fitting }
            let intrinsic = b.intrinsicContentSize
            if intrinsic != .zero { return intrinsic }
            b.sizeToFit()
            return b.bounds.size
        }

        let m = measured(btn)
        let vw = bounds.width
        let vh = bounds.height
        let hasViewport = (vw > 0 && vh > 0)

        switch itemMainAxisLength {
        case .fillViewport:
            return hasViewport ? bounds.size : CGSize(width: max(1, m.width), height: max(1, m.height))
        case .fixed(let L):
            if isHorizontal {
                let h = hasViewport ? max(1, vh) : max(1, m.height)
                return CGSize(width: max(1, L), height: h)
            } else {
                let w = hasViewport ? max(1, vw) : max(1, m.width)
                return CGSize(width: w, height: max(1, L))
            }
        case .autoMeasure:
            if isHorizontal {
                let h = hasViewport ? max(1, vh) : max(1, m.height)
                return CGSize(width: max(1, m.width), height: h)
            } else {
                let w = hasViewport ? max(1, vw) : max(1, m.width)
                return CGSize(width: w, height: max(1, m.height))
            }
        }
    }

    private func measureBaseLengthConsideringStrategy(axisIsHorizontal: Bool) -> CGFloat {
        let n = CGFloat(baseButtons.count)
        let spacingSum = itemSpacing * max(0, n - 1)

        switch itemMainAxisLength {
        case .fillViewport:
            return mainAxisLength(of: bounds.size) * n + spacingSum
        case .fixed(let L):
            return L * n + spacingSum
        case .autoMeasure:
            var total: CGFloat = 0
            for b in baseButtons {
                let fitting = b.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                if fitting != .zero { total += axisIsHorizontal ? fitting.width : fitting.height; continue }
                let intrinsic = b.intrinsicContentSize
                if intrinsic != .zero { total += axisIsHorizontal ? intrinsic.width : intrinsic.height; continue }
                b.sizeToFit()
                let sz = b.bounds.size
                total += axisIsHorizontal ? sz.width : sz.height
            }
            return total + spacingSum
        }
    }

    private func cloneButton(from src: UIButton) -> UIButton {
        let b = UIButton(type: src.buttonType)
        b.isEnabled = src.isEnabled
        if #available(iOS 15.0, *), let cfg = src.configuration {
            b.configuration = cfg
            b.automaticallyUpdatesConfiguration = false
        } else {
            for st in [UIControl.State.normal, .highlighted, .selected, .disabled] {
                b.setTitle(src.title(for: st), for: st)
                b.setAttributedTitle(src.attributedTitle(for: st), for: st)
                b.setImage(src.image(for: st), for: st)
                b.setBackgroundImage(src.backgroundImage(for: st), for: st)
                b.setTitleColor(src.titleColor(for: st), for: st)
            }
            b.titleLabel?.font = src.titleLabel?.font
            b.contentEdgeInsets = src.contentEdgeInsets
            b.imageEdgeInsets = src.imageEdgeInsets
            b.titleEdgeInsets = src.titleEdgeInsets
        }
        return b
    }

    // =========================
    // MARK: - 定时器
    // =========================
    private func restartTimerIfRunning() { if isRunning { stop(); start() } }

    private func startTimer() {
        stop()
        let interval: TimeInterval
        switch mode {
        case .continuous: interval = (timerKind == .displayLink) ? 1.0/60.0 : 0.016
        case .intervalOnce(let i, _, _): interval = max(0.05, i)
        }
        let cfg = JobsTimerConfig(interval: interval, repeats: true, tolerance: 0.002, queue: .main)
        timer = JobsTimerFactory.make(kind: timerKind, config: cfg) { [weak self] in self?._tick() }
        timer?.start()
        isRunning = true
    }

    private func _tick() {
        guard !clones.isEmpty, scrollView.contentSize != .zero else { return }
        switch mode {
        case .continuous(let speed):
            let dt = max(0.001, (timerKind == .displayLink) ? 1.0/60.0 : 0.016)
            applyOffset(delta: speed * CGFloat(dt) * sign)
            recenterIfNeeded()
        case .intervalOnce(_, let dur, let stepOpt):
            let step = stepOpt ?? mainAxisLength(of: bounds.size)
            animateStep(step * sign, duration: dur) { [weak self] in
                guard let self else { return }
                if self.isCarouselForPageControl {
                    let delta = (self.sign >= 0) ? 1 : -1
                    self.advanceCurrentPage(by: delta)
                }
            }
        }
    }

    private var sign: CGFloat { (direction == .left || direction == .up) ? 1 : -1 }

    private func applyOffset(delta: CGFloat) {
        if isHorizontal {
            let x = scrollView.contentOffset.x + delta
            scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        } else {
            let y = scrollView.contentOffset.y + delta
            scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
        }
    }

    private func animateStep(_ delta: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let target = isHorizontal
            ? CGPoint(x: scrollView.contentOffset.x + delta, y: 0)
            : CGPoint(x: 0, y: scrollView.contentOffset.y + delta)
        UIView.animate(withDuration: max(0.01, duration),
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.scrollView.setContentOffset(target, animated: false)
        } completion: { _ in
            self.recenterIfNeeded()
            completion?()
        }
    }

    private func recenterIfNeeded() {
        guard loopEnabled, contentWrapEnabled, copies >= 3, baseLength > 0 else { return }
        let one = baseLength
        let minOffset = midpointOffset - one
        let maxOffset = midpointOffset + one
        if isHorizontal {
            var x = scrollView.contentOffset.x
            if x < minOffset { x += one }
            else if x > maxOffset { x -= one }
            scrollView.contentOffset = CGPoint(x: x, y: 0)
        } else {
            var y = scrollView.contentOffset.y
            if y < minOffset { y += one }
            else if y > maxOffset { y -= one }
            scrollView.contentOffset = CGPoint(x: 0, y: y)
        }
    }

    // =========================
    // MARK: - 手势 & 吸附
    // =========================
    @objc private func _onPanChanged(_ gr: UIPanGestureRecognizer) {
        guard pauseOnUserDrag else { return }
        switch gr.state {
        case .began:
            pause()
        case .ended, .cancelled, .failed:
            if snapOnDragEnd { snapToNearestAndResume() }
            else if let d = resumeAfterDragDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + d) { [weak self] in self?.resume() }
            }
        default:
            break
        }
    }

    /// ✅ 吸附到最近 item 的起点，然后按策略恢复滚动，并同步 PageControl（若适用）
    private func snapToNearestAndResume() {
        let cur = isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        var best = cur, dist = CGFloat.greatestFiniteMagnitude
        var bestView: UIView?

        for v in clones {
            let start = isHorizontal ? v.frame.minX : v.frame.minY
            let d = abs(start - cur)
            if d < dist {
                dist = d
                best = start
                bestView = v
            }
        }

        let same = abs(best - cur) < 0.5
        let target = isHorizontal ? CGPoint(x: best, y: 0) : CGPoint(x: 0, y: best)

        let applyResume = { [weak self] in
            guard let self else { return }
            self.recenterIfNeeded()
            // 拖拽吸附后，同步 PageControl 当前页（仅轮播+间隔模式）
            if self.isCarouselForPageControl, let btn = bestView as? UIButton {
                self.setCurrentPage(btn.tag)
            }
            if let d = self.resumeAfterDragDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + d) { [weak self] in self?.resume() }
            }
        }

        if same {
            applyResume()
        } else {
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: snapSpringDamping,
                           initialSpringVelocity: snapSpringVelocity,
                           options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.scrollView.setContentOffset(target, animated: false)
            } completion: { _ in
                applyResume()
            }
        }
    }

    // =========================
    // MARK: - UIScrollViewDelegate
    // =========================
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if hardAxisLock {
            // 预留扩展
        }
    }

    // =========================
    // MARK: - PageControl 逻辑
    // =========================
    private var isCarouselForPageControl: Bool {
        guard isHorizontal else { return false }
        guard baseButtons.count > 1 else { return false }
        guard itemSpacing == 0 else { return false }
        guard case .fillViewport = itemMainAxisLength else { return false }
        guard case .intervalOnce(_, _, let stepOpt) = mode else { return false }
        let viewport = mainAxisLength(of: bounds.size)
        if let s = stepOpt, abs(s - viewport) > 0.5 { return false }
        return true
    }

    private func updatePageControlVisibility() {
        let shouldShow = pageControlEnabled && isCarouselForPageControl
        if shouldShow {
            if pageControl.superview == nil { addSubview(pageControl) }
            pageControl.isHidden = false
        } else {
            pageControl.isHidden = true
        }
    }

    private func rebuildPageControlModel(resetToFirstPage: Bool) {
        guard pageControl.superview != nil else { return }
        pageControl.numberOfPages = max(0, baseButtons.count)
        pageControl.hidesForSinglePage = true
        if resetToFirstPage { currentPageIndex = 0 }
        pageControl.currentPage = min(currentPageIndex, max(0, pageControl.numberOfPages - 1))
        applyPageAppearance(forceResetPerPageImages: true)
        setNeedsLayout()
    }

    private func setCurrentPage(_ idx: Int) {
        guard pageControl.superview != nil else { return }
        let total = max(0, pageControl.numberOfPages)
        guard total > 0 else { return }
        let normalized = (idx % total + total) % total
        currentPageIndex = normalized
        pageControl.currentPage = normalized
        applyPageAppearance(forceResetPerPageImages: true)
    }

    private func advanceCurrentPage(by delta: Int) { setCurrentPage(currentPageIndex + delta) }

    private func applyPageAppearance(forceResetPerPageImages: Bool = false) {
        guard pageControl.superview != nil else { return }
        let ap = pageAppearance

        if #available(iOS 14.0, *), let inactiveImg = ap.inactiveImage, let currentImg = ap.currentImage {
            pageControl.preferredIndicatorImage = inactiveImg
            if forceResetPerPageImages {
                for i in 0..<pageControl.numberOfPages { pageControl.setIndicatorImage(inactiveImg, forPage: i) }
            }
            if pageControl.numberOfPages > 0 { pageControl.setIndicatorImage(currentImg, forPage: pageControl.currentPage) }
            pageControl.pageIndicatorTintColor = .clear
            pageControl.currentPageIndicatorTintColor = .clear
        } else {
            pageControl.pageIndicatorTintColor = ap.inactiveColor ?? .systemGray
            pageControl.currentPageIndicatorTintColor = ap.currentColor ?? .white
            if #available(iOS 14.0, *) {
                pageControl.preferredIndicatorImage = nil
                if forceResetPerPageImages {
                    for i in 0..<pageControl.numberOfPages { pageControl.setIndicatorImage(nil, forPage: i) }
                }
            }
        }
    }

    private func layoutPageControl() {
        guard pageControl.superview != nil, !pageControl.isHidden else { return }
        let total = pageControl.numberOfPages
        guard total > 1 else { pageControl.isHidden = true; return }

        let intrinsic = pageControl.size(forNumberOfPages: total)
        let maxWidth = bounds.width - pageControlInsets.left - pageControlInsets.right
        let w = min(intrinsic.width, maxWidth)
        let h = intrinsic.height
        let x = (bounds.width - w) * 0.5
        let y = bounds.height - h - pageControlInsets.bottom
        pageControl.frame = CGRect(x: max(0, x), y: max(0, y), width: max(0, w), height: max(0, h))
    }
}

// MARK: - 协议：支持“约束生效后重建”
public protocol JobsRefreshableAfterConstraints {
    @discardableResult
    func refreshAfterConstraints() -> Self
}
extension JobsMarqueeView: JobsRefreshableAfterConstraints {}

// MARK: - UIView 层“启动开关”
public extension UIView {
    @discardableResult
    func byActivateAfterAdd() -> Self {
        func perform(_ v: UIView) {
            v.superview?.setNeedsLayout()
            v.superview?.layoutIfNeeded()
            (v as? JobsRefreshableAfterConstraints)?.refreshAfterConstraints()
            v.setNeedsLayout()
            v.layoutIfNeeded()
        }
        if self.window != nil {
            DispatchQueue.main.async { [weak self] in self.map(perform) }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let s = self else { return }
                DispatchQueue.main.async { perform(s) }
            }
        }
        return self
    }
}
