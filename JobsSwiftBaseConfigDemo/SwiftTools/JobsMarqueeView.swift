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
    /// 连续滚动：按像素速率持续匀速移动（单位：pt/s）
    case continuous(speed: CGFloat)
    /// 间隔滚动：每隔 interval 跳到下一页（动画时长 duration，步长 step；若 step=nil，则按视口尺寸）
    case intervalOnce(interval: TimeInterval, duration: TimeInterval, step: CGFloat? = nil)
}

// MARK: - Item 主轴长度策略
public enum ItemMainAxisLength {
    case autoMeasure           // 按内容测量
    case fixed(CGFloat)        // 固定主轴长度
    case fillViewport          // ✅ 每个 item = JobsMarqueeView.bounds
}

// MARK: - JobsMarqueeView
public final class JobsMarqueeView: UIView, UIScrollViewDelegate {
    // =========================
    // MARK: - 链式配置
    // =========================
    @discardableResult
    public func setButtons(_ buttons: [UIButton]) -> Self {
        baseButtons = buttons
        requestRebuild()
        return self
    }
    @discardableResult
    public func byDirection(_ d: MarqueeDirection) -> Self {
        direction = d; requestRebuild(); return self
    }
    @discardableResult
    public func byMode(_ m: MarqueeMode) -> Self {
        mode = m
        switch m {
        case .continuous: timerKind = .displayLink
        case .intervalOnce: timerKind = .gcd
        }
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
    public func byItemSpacing(_ spacing: CGFloat) -> Self { itemSpacing = max(0, spacing); requestRebuild(); return self }
    @discardableResult
    public func byItemMainAxisLength(_ s: ItemMainAxisLength) -> Self { itemMainAxisLength = s; requestRebuild(); return self }
    @discardableResult
    public func bySnapOnDragEnd(_ on: Bool) -> Self { snapOnDragEnd = on; return self }
    @discardableResult
    public func bySnapSpring(damping: CGFloat, initialVelocity: CGFloat) -> Self {
        snapSpringDamping = max(0.05, min(1.0, damping)); snapSpringVelocity = max(0, initialVelocity); return self
    }
    @discardableResult
    public func byOnItemTap(_ handler: @escaping (_ index: Int, _ button: UIButton) -> Void) -> Self { onItemTap = handler; return self }
    public var onItemTap: ((_ index: Int, _ button: UIButton) -> Void)?

    /// 外部完成约束并 `superview.layoutIfNeeded()` 后调用（确保尺寸确定后重建）
    public func refreshAfterConstraints() -> Self{
        pendingRebuild = true
        needsRebuildOnLayout = true
        DispatchQueue.main.async { [weak self] in self?.setNeedsLayout() }
        return self
    }

    // =========================
    // MARK: - 生命周期
    // =========================
    public override init(frame: CGRect) { super.init(frame: frame); setup() }
    public required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else {
            needsRebuildOnLayout = true
            return
        }
        let sizeChanged = lastSize != bounds.size
        if sizeChanged {
            lastSize = bounds.size
            scrollView.frame = bounds
            container.frame = scrollView.bounds
        }
        if needsRebuildOnLayout || sizeChanged { rebuildContent() }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            setNeedsLayout()
        } else {
            stop()
        }
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
    private var container = UIView()            // ✅ 容器与视口一致
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

    // 弹簧吸附
    private var snapOnDragEnd = true
    private var snapSpringDamping: CGFloat = 0.82
    private var snapSpringVelocity: CGFloat = 0.5

    // 布局/回中
    private var baseLength: CGFloat = 0      // 一份数据（未复制）的主轴长度
    private var copies: Int = 0
    private var midpointOffset: CGFloat = 0
    private var needsRebuildOnLayout = true
    private var pendingRebuild = false
    private var lastSize: CGSize = .zero

    #if canImport(SDWebImage) || canImport(Kingfisher)
    private var firstCloneRequestedIndex = Set<Int>() // “每个原始 index 仅首个克隆允许触网”
    #endif

    private func setup() {
        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self

        scrollView.addSubview(container)
        container.frame = scrollView.bounds
        container.clipsToBounds = false

        scrollView.panGestureRecognizer.addTarget(self, action: #selector(_onPanChanged(_:)))
    }

    /// 只做标记，等下一次有效 layout 再重建（避免尺寸未定时强制 layoutIfNeeded）
    private func requestRebuild() {
        pendingRebuild = true
        needsRebuildOnLayout = true
        setNeedsLayout()
    }

    // =========================
    // MARK: - 重建内容（核心）
    // =========================
    private func rebuildContent() {
        needsRebuildOnLayout = false

        // 1) 尺寸必须已确定
        guard bounds.width > 0, bounds.height > 0 else {
            needsRebuildOnLayout = true
            return
        }
        // 若没有标记，且已有克隆，就不重复重建
        guard pendingRebuild || clones.isEmpty else { return }
        pendingRebuild = false

        // 2) 清理旧内容
        clones.forEach { $0.removeFromSuperview() }
        clones.removeAll()
        #if canImport(SDWebImage) || canImport(Kingfisher)
        firstCloneRequestedIndex.removeAll()
        #endif

        guard baseButtons.count > 0 else {
            scrollView.contentSize = .zero
            container.frame = scrollView.bounds
            return
        }

        // 3) 计算“一份数据”的主轴长度（含 itemSpacing）
        baseLength = measureBaseLengthConsideringStrategy(axisIsHorizontal: isHorizontal)

        // 4) 计算复制份数（为连贯滚动准备足量拷贝）
        let viewport = mainAxisLength(of: bounds.size)
        let epsilon: CGFloat = 1
        if contentWrapEnabled {
            let need = max(1, Int(ceil((viewport + epsilon) / max(1, baseLength))))
            copies = max(3, need + 2)   // 至少 3 份，首尾各多一份做回中
        } else {
            copies = 1
        }

        // 5) 克隆并排布；关键：首屏可见的克隆允许走网（在“回中前”的临时首屏）
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

                // ---- 远程图克隆：临时可见的 clone 允许走网（注意：这一步是“回中前”的可见性）----
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

        // 6) contentSize；容器永远等于视口（便于后面以容器坐标判断）
        let totalLen = max(0, cursor - itemSpacing)
        scrollView.contentSize = isHorizontal
            ? CGSize(width: totalLen, height: bounds.height)
            : CGSize(width: bounds.width, height: totalLen)
        container.frame = scrollView.bounds

        // 7) 回到中点，便于无缝循环
        if contentWrapEnabled && copies >= 3 {
            let oneCopyLen = baseLength
            let mid = oneCopyLen * CGFloat(copies / 2)
            midpointOffset = mid
            scrollView.contentOffset = isHorizontal ? CGPoint(x: mid, y: 0) : CGPoint(x: 0, y: mid)
        } else {
            midpointOffset = 0
            scrollView.contentOffset = .zero
        }

        // ✅ 新增：等回中完成后，把“当前真正可见”的克隆统一允许走网（首帧就能拉到网图）
        DispatchQueue.main.async { [weak self] in
            self?._allowNetForVisibleClones()
        }

        // 8) 自动启动
        if autoStartEnabled, timer == nil, !isRunning { start() }

        // ✅ 9) 统一预热并回填真正的网络图（第一次进入也能立即替换掉占位）
        _preheatBackgroundsKFIfNeeded()

    }

#if canImport(Kingfisher)
private func _preheatBackgroundsKFIfNeeded() {
    // 收集每个“源按钮”的 URL / 占位 / 选项
    struct Item {
        let url: URL
        let placeholder: UIImage?
        let options: KingfisherOptionsInfo
        let index: Int                 // 源按钮的 idx（用于匹配克隆的 tag）
    }

    var items: [Item] = []
    for (idx, src) in baseButtons.enumerated() {
        // URL 优先用我们记录的 kf_bgURL，其次 _kf_config.url（两者你已有）
        guard let url = src.kf_bgURL ?? src._kf_config.url else { continue }

        // 选项：去掉过渡，避免滚动闪；补一发后台解码
        var opts = src._kf_config.options
        opts.removeAll { if case .transition = $0 { return true } else { return false } }
        if !opts.contains(where: { if case .backgroundDecode = $0 { return true } else { return false } }) {
            opts.append(.backgroundDecode)
        }
        // 防止“占位卡死”：有占位就别 keepCurrentImageWhileLoading
        if src._kf_config.placeholder != nil {
            opts.removeAll { if case .keepCurrentImageWhileLoading = $0 { return true } else { return false } }
        }

        items.append(Item(url: url,
                          placeholder: src._kf_config.placeholder,
                          options: opts,
                          index: idx))
    }

    guard !items.isEmpty else { return }

    // 逐个预热；成功后批量回填所有 tag == index 的克隆
    for it in items {
        KingfisherManager.shared.retrieveImage(with: it.url, options: it.options) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let r):
                let img = r.image
                DispatchQueue.main.async {
                    // 回填到所有克隆（tag 在 cloneButton 里等于源 idx）
                    self.clones.filter { $0.tag == it.index }.forEach { clone in
                        // 关掉自动配置更新，确保不会被 configuration 覆盖
                        if #available(iOS 15.0, *) { clone.automaticallyUpdatesConfiguration = false }
                        clone.setBackgroundImage(img, for: .normal)   // 只走 legacy，稳定
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
#endif


    private func _allowNetForVisibleClones() {
        guard !clones.isEmpty else { return }
        // scrollView 的可见区域（内容坐标系）
        let visible = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)

        for btn in clones {
            // 仅处理当前真正“在屏”的克隆
            guard btn.frame.intersects(visible) else { continue }
            let idx = btn.tag
            guard baseButtons.indices.contains(idx) else { continue }
            let src = baseButtons[idx]

            #if canImport(Kingfisher)
            // 允许走网，把网图灌进这个克隆
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
        switch itemMainAxisLength {
        case .fillViewport:
            return bounds.size
        case .fixed(let L):
            return isHorizontal ? CGSize(width: L, height: bounds.height)
                                : CGSize(width: bounds.width, height: L)
        case .autoMeasure:
            let fitting = btn.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if fitting != .zero { return isHorizontal ? CGSize(width: fitting.width, height: bounds.height)
                                                      : CGSize(width: bounds.width, height: fitting.height) }
            let intrinsic = btn.intrinsicContentSize
            if intrinsic != .zero { return isHorizontal ? CGSize(width: intrinsic.width, height: bounds.height)
                                                        : CGSize(width: bounds.width, height: intrinsic.height) }
            btn.sizeToFit()
            let sz = btn.bounds.size
            return isHorizontal ? CGSize(width: sz.width, height: bounds.height)
                                : CGSize(width: bounds.width, height: sz.height)
        }
    }

    /// 按策略正确计算“一份数据”的主轴总长度（含间距）
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
            b.automaticallyUpdatesConfiguration = false   // ✅ 防止自动重建干扰背景图
        } else {
            // legacy 同步...
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
            animateStep(step * sign, duration: dur)
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

    private func animateStep(_ delta: CGFloat, duration: TimeInterval) {
        let target = isHorizontal
            ? CGPoint(x: scrollView.contentOffset.x + delta, y: 0)
            : CGPoint(x: 0, y: scrollView.contentOffset.y + delta)
        UIView.animate(withDuration: max(0.01, duration),
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.scrollView.setContentOffset(target, animated: false)
        } completion: { _ in
            self.recenterIfNeeded()
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
        case .began: pause()
        case .ended, .cancelled, .failed:
            if snapOnDragEnd { snapToNearestAndResume() }
            else if let d = resumeAfterDragDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + d) { [weak self] in self?.resume() }
            }
        default: break
        }
    }

    private func snapToNearestAndResume() {
        let cur = isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        var best = cur, dist = CGFloat.greatestFiniteMagnitude
        for v in clones {
            let start = isHorizontal ? v.frame.minX : v.frame.minY
            let d = abs(start - cur)
            if d < dist { dist = d; best = start }
        }
        if abs(best - cur) < 0.5 {
            if let d = resumeAfterDragDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + d) { [weak self] in self?.resume() }
            }
            return
        }
        let target = isHorizontal ? CGPoint(x: best, y: 0) : CGPoint(x: 0, y: best)
        UIView.animate(withDuration: 0.6, delay: 0,
                       usingSpringWithDamping: snapSpringDamping,
                       initialSpringVelocity: snapSpringVelocity,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.scrollView.setContentOffset(target, animated: false)
        } completion: { _ in
            self.recenterIfNeeded()
            if let d = self.resumeAfterDragDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + d) { [weak self] in self?.resume() }
            }
        }
    }

    // =========================
    // MARK: - UIScrollViewDelegate（如需硬轴锁，可在这里处理）
    // =========================
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if hardAxisLock {
            if isHorizontal {
                scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView)
            } else {
                scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView)
            }
        }
    }
}
