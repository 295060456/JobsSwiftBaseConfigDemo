//
//  JobsMarqueeView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/08.
//

import UIKit
import SnapKit

// MARK: - 公共数据模型（可选：外部也可直接传 UIButton）
public struct MarqueeItem {
    public var title: String?
    public var image: UIImage?
    /// 点按时展示的 tips 文本（如不传，则用 title 兜底）
    public var tip: String?
    public init(title: String? = nil, image: UIImage? = nil, tip: String? = nil) {
        self.title = title
        self.image = image
        self.tip = tip
    }
}

// MARK: - 滚动方向 & 模式
public enum MarqueeDirection { case left, right, up, down }

public enum MarqueeMode: Equatable {
    /// 连续滚动：按像素速率持续匀速移动
    case continuous(speed: CGFloat) // pt/s
    /// 间隔滚动：每隔 interval 跳到下一页（动画时长 duration）
    case intervalOnce(interval: TimeInterval, duration: TimeInterval = 0.28)

    public static func == (lhs: MarqueeMode, rhs: MarqueeMode) -> Bool {
        switch (lhs, rhs) {
        case let (.continuous(a), .continuous(b)): return a == b
        case let (.intervalOnce(i1, d1), .intervalOnce(i2, d2)): return i1 == i2 && d1 == d2
        default: return false
        }
    }
}

// MARK: - 核心视图
public final class JobsMarqueeView: UIView {

    // ================================== 公共可配 ==================================
    public var direction: MarqueeDirection = .left { didSet { reconfigureAxisIfNeeded() } }
    public var mode: MarqueeMode = .continuous(speed: 30) { didSet { restartIfNeededForModeChange(oldValue: oldValue) } }
    /// 是否无限循环
    public var isLoopEnabled: Bool = true
    /// 点击回调（外部未设置时，会在内部兜底弹 Toast）
    public var onTap: ((_ index: Int, _ button: UIButton) -> Void)?
    /// 🔧 定时器内核选择（默认 .gcd），外部可覆盖
    public var timerKind: JobsTimerKind = .gcd { didSet { if oldValue != timerKind { restartTimerForKernelChange() } } }
    /// 🔧 连续滚动时用于调度的“tick 间隔”（非必须，displayLink 会按帧率；GCD/NSTimer/RunLoop 用此值），默认 1/60
    public var continuousTickInterval: TimeInterval = 1.0 / 60.0 { didSet { if isRunning { buildTimerIfNeededAndStart() } } }
    /// 🔧 手势滑动开关（true 允许用户手势滑动，false 仅程序驱动）
    public var isGestureScrollEnabled: Bool = false { didSet { scrollView.isScrollEnabled = isGestureScrollEnabled } }
    /// 🔧 内容自适应开关：仅在 .continuous 模式下生效。true=按内容宽/高流式滚动；false=按页等分
    public var isContentWrapEnabled: Bool = false { didSet { rebuildStack(); resetContentOffsetToFirst() } }

    // ================================== 只读状态 ==================================
    public private(set) var currentIndex: Int = 0
    public private(set) var isRunning: Bool = false

    // ================================== UI ==================================
    private lazy var scrollView: UIScrollView = {
        UIScrollView()
            .byShowsHorizontalScrollIndicator(false)
            .byShowsVerticalScrollIndicator(false)
            .byBounces(false)
            .byPagingEnabled(false)
            .byClipsToBounds(true)
    }()

    private lazy var stack: UIStackView = {
        UIStackView()
            .byAxis(isHorizontal ? .horizontal : .vertical)
            .byAlignment(.fill)
            .byDistribution(.fillEqually)   // contentWrap 时在 rebuildStack 内动态改为 .fill
            .bySpacing(0)
    }()

    // ================================== 数据 ==================================
    private var buttons: [UIButton] = []

    // ================================== 计时器 ==================================
    private var timer: JobsTimerProtocol?
    private var lastTickTime: CFTimeInterval = 0 // 连续模式下用于计算 dt

    // ================================== 便利属性 ==================================
    private var isHorizontal: Bool {
        switch direction { case .left, .right: return true; case .up, .down: return false }
    }
    private var isContinuousMode: Bool { if case .continuous = mode { return true } else { return false } }

    /// contentWrap 下使用：原始一轮内容的总长度（横向=宽，纵向=高）
    private var loopUnitLength: CGFloat {
        if stack.arrangedSubviews.isEmpty { return 0 }
        let count = buttons.count
        guard count > 0 else { return 0 }
        if isHorizontal {
            return stack.arrangedSubviews.prefix(count).reduce(0) { $0 + $1.bounds.width }
        } else {
            return stack.arrangedSubviews.prefix(count).reduce(0) { $0 + $1.bounds.height }
        }
    }

    // ================================== 生命周期 ==================================
    public override init(frame: CGRect) {
        super.init(frame: frame); setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder); setupUI()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateItemSizeConstraints() // 仅分页时需要；contentWrap 时不强制子视图尺寸
    }

    // ================================== 公共 API ==================================
    /// 外部直接传按钮（不写外部约束！）
    public func setButtons(_ items: [UIButton]) {
        stop()
        buttons = items
        rebuildStack()
        resetContentOffsetToFirst()
    }

    /// 外部传图片/文字，内部生成标准按钮（全屏内容按钮）
    public func setItems(_ items: [MarqueeItem],
                         config: ((UIButton, MarqueeItem, Int) -> Void)? = nil) {
        stop()
        let btns = items.enumerated().map { (idx, item) -> UIButton in
            let b = makeFillButton(title: item.title, image: item.image)
            b.accessibilityLabel = item.tip ?? item.title
            config?(b, item, idx) // 二次定制
            return b
        }
        setButtons(btns)
    }

    public func start() {
        guard !buttons.isEmpty else { return }
        isRunning = true
        buildTimerIfNeededAndStart()
    }

    public func pause() { timer?.pause(); isRunning = false }
    public func resume() { timer?.resume(); isRunning = true }
    public func stop() { timer?.stop(); timer = nil; isRunning = false }

    deinit { stop() }

    // ================================== 内部：UI & 约束 ==================================
    private func setupUI() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            if isHorizontal { make.height.equalToSuperview() } else { make.width.equalToSuperview() }
        }
        // 初始化手势滑动开关
        scrollView.isScrollEnabled = isGestureScrollEnabled

        // 默认点击行为：外部没设置时兜底弹 Toast
        onTap = nil

        reconfigureAxisIfNeeded()
    }

    private func rebuildStack() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // contentWrap：流式/变长；否则分页
        let useContentWrap = isContentWrapEnabled && isContinuousMode
        stack.distribution = useContentWrap ? .fill : .fillEqually

        // 构造视图集合
        let views: [UIButton] = {
            switch (mode, useContentWrap) {
            case (.continuous, true):   return makeDoubledButtons(buttons) // 流式：src + src
            case (.continuous, false):  return makeLoopedButtons(buttons)  // 分页：哨兵 [last] + src + [first]
            case (.intervalOnce, _):    return buttons
            }
        }()

        if useContentWrap {
            // ✅ 流式：直接把“按钮”加到 stack（不再包 holder）
            for (idx, btn) in views.enumerated() {
                // 先加入层级，再加约束（避免未在同一层级时报约束错误）
                stack.addArrangedSubview(btn)

                // 让按钮自身以 intrinsic size 决定宽/高；交叉轴撑满可见区
                if isHorizontal {
                    btn.setContentHuggingPriority(.required, for: .horizontal)
                    btn.setContentCompressionResistancePriority(.required, for: .horizontal)
                    btn.snp.makeConstraints { make in
                        make.height.equalTo(self.scrollView.snp.height)
                    }
                } else {
                    btn.setContentHuggingPriority(.required, for: .vertical)
                    btn.setContentCompressionResistancePriority(.required, for: .vertical)
                    btn.snp.makeConstraints { make in
                        make.width.equalTo(self.scrollView.snp.width)
                    }
                }

                // 统一方角
                enforceSquareCorners(btn)

                // 点击
                btn.tag = idx % max(1, buttons.count)
                btn.onTap { [weak self] sender in
                    guard let self else { return }
                    let realIndex = sender.tag
                    if let onTap = self.onTap {
                        onTap(realIndex, sender)
                    } else {
                        self.toastFallback(index: realIndex) // 兜底
                    }
                }
            }
        } else {
            // ✅ 分页：保持原 holder 包裹并等分
            for (idx, btn) in views.enumerated() {
                let holder = UIView()
                holder.clipsToBounds = true
                holder.addSubview(btn)
                btn.snp.makeConstraints { $0.edges.equalToSuperview() }
                stack.addArrangedSubview(holder)

                // 统一方角
                enforceSquareCorners(btn)

                // 点击
                btn.tag = idx % max(1, buttons.count)
                btn.onTap { [weak self] sender in
                    guard let self else { return }
                    let realIndex = sender.tag
                    if let onTap = self.onTap {
                        onTap(realIndex, sender)
                    } else {
                        self.toastFallback(index: realIndex) // 兜底
                    }
                }
            }
        }

        updateItemSizeConstraints()
        layoutIfNeeded()
        resetContentOffsetToFirst()
    }

    private func updateItemSizeConstraints() {
        // 仅在“分页”场景下强制每页等宽/等高；contentWrap 时不要改写子视图尺寸
        let useContentWrap = isContentWrapEnabled && isContinuousMode
        guard !useContentWrap else { return }

        for v in stack.arrangedSubviews {
            v.snp.remakeConstraints { make in
                if isHorizontal { make.width.equalTo(self.scrollView.snp.width) }
                else            { make.height.equalTo(self.scrollView.snp.height) }
            }
        }
    }

    private func resetContentOffsetToFirst() {
        guard !buttons.isEmpty else { return }
        currentIndex = 0

        let useContentWrap = isContentWrapEnabled && isContinuousMode
        switch mode {
        case .continuous:
            if useContentWrap {
                scrollView.contentOffset = .zero
            } else {
                if isHorizontal { scrollView.contentOffset.x = pageWidth() }
                else            { scrollView.contentOffset.y = pageHeight() }
            }
        case .intervalOnce:
            scrollView.contentOffset = .zero
        }
    }

    private func reconfigureAxisIfNeeded() {
        stack.axis = isHorizontal ? .horizontal : .vertical
        stack.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            if isHorizontal { make.height.equalToSuperview() } else { make.width.equalToSuperview() }
        }
        updateItemSizeConstraints()
        layoutIfNeeded()
    }

    private func pageWidth()  -> CGFloat { bounds.width }
    private func pageHeight() -> CGFloat { bounds.height }

    // ================================== Timer ==================================
    private func buildTimerIfNeededAndStart() {
        stop() // 清理旧的
        lastTickTime = CACurrentMediaTime()

        switch mode {
        case let .continuous(speed):
            let cfg = JobsTimerConfig(
                interval: max(0.0001, continuousTickInterval),
                repeats: true,
                tolerance: timerKind == .displayLink ? 0 : 0.005,
                queue: .main
            )
            timer = JobsTimerFactory.make(kind: timerKind, config: cfg) { [weak self] in
                self?.stepContinuous(speed: speed)
            }

        case let .intervalOnce(interval, _):
            let cfg = JobsTimerConfig(
                interval: max(0.2, interval),
                repeats: true,
                tolerance: 0.02,
                queue: .main
            )
            timer = JobsTimerFactory.make(kind: timerKind, config: cfg) { [weak self] in
                self?.stepIntervalOnce()
            }
        }

        timer?.start()
        isRunning = true
    }

    private func restartIfNeededForModeChange(oldValue: MarqueeMode) {
        guard mode != oldValue else { return }
        rebuildStack()
        if isRunning { buildTimerIfNeededAndStart() }
    }

    private func restartTimerForKernelChange() {
        if isRunning { buildTimerIfNeededAndStart() }
    }

    // ================================== 连续滚动逻辑 ==================================
    private func stepContinuous(speed: CGFloat) {
        guard scrollView.bounds.size != .zero, stack.arrangedSubviews.count > 0 else { return }

        let now = CACurrentMediaTime()
        let dt  = CGFloat(max(0.0, now - lastTickTime))
        lastTickTime = now

        let delta = max(0, speed) * dt
        var offset = scrollView.contentOffset

        let useContentWrap = isContentWrapEnabled

        if useContentWrap {
            // 流式：双份内容，按“半程长度”回绕
            if isHorizontal {
                offset.x += (direction == .right ? -delta : +delta)
                let half = max(1, loopUnitLength) // 单轮内容宽
                if offset.x >= half { offset.x -= half }
                if offset.x < 0    { offset.x += half }
            } else {
                offset.y += (direction == .down ? -delta : +delta)
                let half = max(1, loopUnitLength) // 单轮内容高
                if offset.y >= half { offset.y -= half }
                if offset.y < 0    { offset.y += half }
            }
            scrollView.setContentOffset(offset, animated: false)
            updateCurrentIndexForContentWrap()
            return
        }

        // 分页：保持原逻辑
        switch direction {
        case .left:
            offset.x += delta
            if offset.x >= pageWidth() * CGFloat(stack.arrangedSubviews.count - 1) {
                offset.x = pageWidth() // 回到第1真实页
            }
        case .right:
            offset.x -= delta
            if offset.x <= 0 {
                offset.x = pageWidth() * CGFloat(stack.arrangedSubviews.count - 2)
            }
        case .up:
            offset.y += delta
            if offset.y >= pageHeight() * CGFloat(stack.arrangedSubviews.count - 1) {
                offset.y = pageHeight()
            }
        case .down:
            offset.y -= delta
            if offset.y <= 0 {
                offset.y = pageHeight() * CGFloat(stack.arrangedSubviews.count - 2)
            }
        }
        scrollView.setContentOffset(offset, animated: false)
        updateCurrentIndexByNearestPage()
    }

    // ================================== 间隔滚动逻辑 ==================================
    private func stepIntervalOnce() {
        guard buttons.count > 0 else { return }
        let next = (currentIndex + 1) % buttons.count
        animateScrollTo(index: next)
    }

    private func animateScrollTo(index: Int) {
        guard buttons.indices.contains(index) else { return }
        currentIndex = index

        let targetOffset: CGPoint = isHorizontal
            ? CGPoint(x: CGFloat(index) * pageWidth(),  y: 0)
            : CGPoint(x: 0, y: CGFloat(index) * pageHeight())

        let duration: TimeInterval = {
            switch mode {
            case let .intervalOnce(_, d): return d
            case .continuous:             return 0.25
            }
        }()

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
            self.scrollView.contentOffset = targetOffset
        }
    }

    private func updateCurrentIndexByNearestPage() {
        guard buttons.count > 0 else { return }
        let offset = scrollView.contentOffset
        let idx: Int
        if isHorizontal {
            let unit = pageWidth()
            idx = Int(round((offset.x.truncatingRemainder(dividingBy: unit * CGFloat(buttons.count))) / unit)) % buttons.count
        } else {
            let unit = pageHeight()
            idx = Int(round((offset.y.truncatingRemainder(dividingBy: unit * CGFloat(buttons.count))) / unit)) % buttons.count
        }
        currentIndex = (idx + buttons.count) % buttons.count
    }

    /// contentWrap 连续滚动下的 index 估算（按累计宽/高与可见起点对齐）
    private func updateCurrentIndexForContentWrap() {
        guard buttons.count > 0 else { return }
        let count = buttons.count
        let halfLen = max(1, loopUnitLength)
        if halfLen <= 1 { currentIndex = 0; return }

        if isHorizontal {
            var pos = scrollView.contentOffset.x
            if pos < 0 { pos += halfLen }
            pos = pos.truncatingRemainder(dividingBy: halfLen)

            var acc: CGFloat = 0
            var found = 0
            let firstCycle = stack.arrangedSubviews.prefix(count)
            for (i, v) in firstCycle.enumerated() {
                let w = v.bounds.width
                if pos < acc + w { found = i; break }
                acc += w
            }
            currentIndex = found
        } else {
            var pos = scrollView.contentOffset.y
            if pos < 0 { pos += halfLen }
            pos = pos.truncatingRemainder(dividingBy: halfLen)

            var acc: CGFloat = 0
            var found = 0
            let firstCycle = stack.arrangedSubviews.prefix(count)
            for (i, v) in firstCycle.enumerated() {
                let h = v.bounds.height
                if pos < acc + h { found = i; break }
                acc += h
            }
            currentIndex = found
        }
    }

    // ================================== 无缝循环视图 ==================================
    /// 分页用（等分）：[last] + src + [first]
    private func makeLoopedButtons(_ src: [UIButton]) -> [UIButton] {
        guard isLoopEnabled, src.count >= 1 else { return src }
        var arr: [UIButton] = []
        if let last = src.last  { arr.append(last) }
        arr.append(contentsOf: src)
        if let first = src.first { arr.append(first) }
        return arr
    }

    /// 流式用（变长）：[src + src]
    private func makeDoubledButtons(_ src: [UIButton]) -> [UIButton] {
        guard isLoopEnabled, src.count >= 1 else { return src }
        var arr: [UIButton] = []
        arr.append(contentsOf: src)
        arr.append(contentsOf: src.map { cloneButton($0) }) // 克隆一份，避免共享状态副作用
        return arr
    }

    /// 简单克隆按钮
    private func cloneButton(_ b: UIButton) -> UIButton {
        let nb = UIButton(type: b.buttonType)
        nb.isEnabled = b.isEnabled
        nb.isSelected = b.isSelected
        nb.isHighlighted = b.isHighlighted
        nb.contentEdgeInsets = b.contentEdgeInsets
        nb.titleEdgeInsets = b.titleEdgeInsets
        nb.imageEdgeInsets = b.imageEdgeInsets
        nb.contentHorizontalAlignment = b.contentHorizontalAlignment
        nb.contentVerticalAlignment = b.contentVerticalAlignment
        if #available(iOS 15.0, *), let cfg = b.configuration {
            nb.configuration = cfg
        } else {
            nb.setTitle(b.title(for: .normal), for: .normal)
            nb.setTitleColor(b.titleColor(for: .normal), for: .normal)
            nb.setImage(b.image(for: .normal), for: .normal)
            nb.backgroundColor = b.backgroundColor
        }
        return nb
    }

    // ================================== 工具：创建标准填充按钮（方角） ==================================
    private func makeFillButton(title: String?, image: UIImage?) -> UIButton {
        let b = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var c = UIButton.Configuration.filled()
            c.title = title
            c.image = image
            c.imagePadding = 8
            c.baseForegroundColor = .white
            c.baseBackgroundColor = .systemBlue
            c.titleAlignment = .center
            c.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
            c.cornerStyle = .fixed
            var bg = c.background; bg.cornerRadius = 0; c.background = bg
            b.configuration = c
        } else {
            b.setTitle(title, for: .normal)
            b.setTitleColor(.white, for: .normal)
            b.setImage(image, for: .normal)
            b.backgroundColor = .systemBlue
            b.layer.cornerRadius = 0
            b.clipsToBounds = true
        }
        return b
    }

    // 统一方角
    private func enforceSquareCorners(_ b: UIButton) {
        if #available(iOS 15.0, *), var c = b.configuration {
            c.cornerStyle = .fixed
            var bg = c.background; bg.cornerRadius = 0; c.background = bg
            b.configuration = c
        } else {
            b.layer.cornerRadius = 0
            b.clipsToBounds = true
        }
    }

    // 兜底提示
    private func toastFallback(index: Int) {
        Task { @MainActor in
            JobsToast.show(
                text: "Tapped \(index)",
                config: JobsToast.Config()
                    .byBgColor(.systemGreen.withAlphaComponent(0.9))
                    .byCornerRadius(12)
            )
        }
    }
}

// MARK: - 链式语法糖扩展
public extension JobsMarqueeView {
    @discardableResult
    func byDirection(_ dir: MarqueeDirection) -> Self { self.direction = dir; return self }

    @discardableResult
    func byMode(_ mode: MarqueeMode) -> Self { self.mode = mode; return self }

    @discardableResult
    func byLoopEnabled(_ enabled: Bool = true) -> Self { self.isLoopEnabled = enabled; return self }

    @discardableResult
    func byOnTap(_ handler: @escaping (Int, UIButton) -> Void) -> Self { self.onTap = handler; return self }

    /// 选择计时器内核（默认 .gcd）
    @discardableResult
    func byTimerKind(_ kind: JobsTimerKind) -> Self { self.timerKind = kind; return self }

    /// 连续滚动的 tick 间隔（对 .gcd/.foundation/.runLoop 生效；.displayLink 按帧率）
    @discardableResult
    func byContinuousTickInterval(_ interval: TimeInterval) -> Self { self.continuousTickInterval = interval; return self }

    /// 手势滑动开关（true 允许手势滚动，false 只能程序驱动）
    @discardableResult
    func byGestureScrollEnabled(_ enabled: Bool) -> Self { self.isGestureScrollEnabled = enabled; return self }

    /// 内容自适应开关（仅 .continuous）
    @discardableResult
    func byContentWrapEnabled(_ enabled: Bool = true) -> Self { self.isContentWrapEnabled = enabled; return self }
}

// MARK: - 设置数据项（可选自定义按钮配置）
public extension JobsMarqueeView {
    @discardableResult
    func byItems(_ items: [MarqueeItem],
                 config: ((UIButton, MarqueeItem, Int) -> Void)? = nil) -> Self {
        self.setItems(items, config: config)
        return self
    }
}
