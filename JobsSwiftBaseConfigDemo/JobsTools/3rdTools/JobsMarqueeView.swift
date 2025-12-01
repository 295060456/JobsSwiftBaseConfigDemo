//
//  JobsMarqueeView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/12.
//

import UIKit
/// 统一「跑马灯」&「轮播图」的视图组件
/// 数据源：`[UIButton]`
/// 滚动载体：内部 `UIScrollView` + 若干个按钮副本
public final class JobsMarqueeView: UIView {
    /// 滚动模式
    public enum ScrollMode {
        /// 按频率滚动（间隔滚动）：interval = 每次触发时间（秒）
        case frequency(interval: TimeInterval)
        /// 一直滚动（连续滚动）：speed = 每秒滚动的点数（pt/s）
        case continuous(speed: CGFloat)
    }
    /// 滚动方向
    public enum Direction {
        case left
        case right
        case up
        case down

        var isHorizontal: Bool {
            switch self {
            case .left, .right: return true
            case .up, .down:    return false
            }
        }
    }
    /// item 尺寸模式
    /// - fitContent: 使用按钮本身内容尺寸（跑马灯）
    /// - fillBounds: 每个按钮尺寸 = JobsMarqueeView 的宽/高（轮播图）
    public enum ItemSizeMode {
        case fitContent
        case fillBounds
    }

    private struct Metrics {
        static let defaultFrequency: TimeInterval = 1.0
        static let defaultContinuousSpeed: CGFloat = 40.0  // pt/s
        static let continuousInterval: TimeInterval = 1.0 / 60.0 // 60fps
    }
    /// 滚动模式（默认：连续向左滚动）
    public var scrollMode: ScrollMode = .continuous(speed: Metrics.defaultContinuousSpeed) {
        didSet { handleScrollModeChanged() }
    }
    /// 滚动方向（默认水平向左）
    public var direction: Direction = .left {
        didSet {
            needsRebuildContent = true
            setNeedsLayout()
        }
    }
    /// item 尺寸模式（默认：fitContent 跑马灯）
    public var itemSizeMode: ItemSizeMode = .fitContent {
        didSet {
            needsRebuildContent = true
            setNeedsLayout()
        }
    }
    /// 数据源：按钮数组
    public var dataSourceButtons: [UIButton] = [] {
        didSet {
            needsRebuildContent = true
            setNeedsLayout()
        }
    }
    /// 按频率滚动时使用的定时器内核（默认 GCD）
    public var timerKindForFrequency: JobsTimerKind = .gcd {
        didSet { timer = nil }
    }
    /// 连续滚动时使用的定时器内核（默认 CADisplayLink）
    public var timerKindForContinuous: JobsTimerKind = .displayLink {
        didSet { timer = nil }
    }
    public var isRunning: Bool { timer?.isRunning ?? false }

    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.bounces = false
        v.isPagingEnabled = false
        v.isScrollEnabled = false   // 全程由 JobsTimer 驱动
        v.scrollsToTop = false
        return v
    }()

    private var internalButtons: [UIButton] = []
    private var needsRebuildContent = false
    private var lastBoundsSize: CGSize = .zero
    /// 一个英文字符在系统按钮字体下的最小尺寸 S1/S2
    private var minButtonSize: CGSize = JobsMarqueeView.computeMinButtonSize()
    /// 离散滚动时每一步的位移（横向=宽度, 纵向=高度）
    private var stepLength: CGFloat = 0
    /// 连续滚动的速度（pt/s）
    private var continuousSpeed: CGFloat = Metrics.defaultContinuousSpeed
    /// 连续滚动定时器 tick 间隔
    private var continuousInterval: TimeInterval = Metrics.continuousInterval
    /// 按频率滚动的触发间隔
    private var frequencyInterval: TimeInterval = Metrics.defaultFrequency
    /// JobsTimer
    private var timer: JobsTimerProtocol?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
        addSubview(scrollView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds

        guard bounds.width > 0, bounds.height > 0 else { return }

        if bounds.size != lastBoundsSize || needsRebuildContent {
            lastBoundsSize = bounds.size
            rebuildContent()
        }
    }
    /// 重建内部按钮 & contentSize
    private func rebuildContent() {
        needsRebuildContent = false
        // 清空旧内容
        scrollView.layer.removeAllAnimations()
        scrollView.contentOffset = .zero
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        internalButtons.removeAll()

        guard !dataSourceButtons.isEmpty else {
            scrollView.contentSize = bounds.size
            return
        }

        let isHorizontal = direction.isHorizontal
        minButtonSize = JobsMarqueeView.computeMinButtonSize()

        // 计算需要的按钮个数
        let source = dataSourceButtons
        let sourceCount = source.count
        let targetCount: Int

        switch (isHorizontal, itemSizeMode) {
        case (true, .fillBounds):
            // 水平 & 轮播图：多复制 1 个，形成 1,2,3,1 这种结构，方便无感循环
            targetCount = max(3, sourceCount + 1)
        case (false, .fillBounds):
            // 垂直 & 轮播图：同理，多复制 1 个
            targetCount = max(3, sourceCount + 1)
        case (true, .fitContent):
            // 水平 & 按内容：个数 = 视图宽 / S1
            let s1 = max(minButtonSize.width, 1.0)
            let base = Int(ceil(bounds.width / s1))
            targetCount = max(base, sourceCount)
        case (false, .fitContent):
            // 垂直 & 按内容：个数 = 视图高 / S2
            let s2 = max(minButtonSize.height, 1.0)
            let base = Int(ceil(bounds.height / s2))
            targetCount = max(base, sourceCount)
        }

        internalButtons = buildButtons(from: source, targetCount: targetCount)

        // 布局
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0

        if isHorizontal {
            var x: CGFloat = 0
            for button in internalButtons {
                button.sizeToFit()

                var size = button.bounds.size
                size.width  = max(size.width, minButtonSize.width)
                size.height = bounds.height

                if itemSizeMode == .fillBounds {
                    size.width = bounds.width
                }

                button.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
                scrollView.addSubview(button)

                x += size.width
            }
            contentWidth = max(bounds.width, x)
            contentHeight = bounds.height
        } else {
            var y: CGFloat = 0
            for button in internalButtons {
                button.sizeToFit()

                var size = button.bounds.size
                size.height = max(size.height, minButtonSize.height)
                size.width  = bounds.width

                if itemSizeMode == .fillBounds {
                    size.height = bounds.height
                }

                button.frame = CGRect(x: 0, y: y, width: size.width, height: size.height)
                scrollView.addSubview(button)

                y += size.height
            }
            contentHeight = max(bounds.height, y)
            contentWidth = bounds.width
        }

        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)

        // 更新 stepLength
        if itemSizeMode == .fillBounds {
            stepLength = isHorizontal ? bounds.width : bounds.height
        } else {
            stepLength = isHorizontal ? minButtonSize.width : minButtonSize.height
        }

        scrollView.contentOffset = .zero
    }
    /// 开始滚动
    public func start() {
        guard !dataSourceButtons.isEmpty else { return }
        if timer == nil {
            createTimer()
        }
        timer?.start()
    }
    /// 暂停滚动
    public func pause() {
        timer?.pause()
    }
    /// 恢复计时器
    public func resume() {
        timer?.resume()
    }
    /// 停止并销毁定时器
    public func stop() {
        timer?.stop()
        timer = nil
    }
    // MARK: - Timer 内部实现
    private func handleScrollModeChanged() {
        switch scrollMode {
        case .frequency(let interval):
            frequencyInterval = max(0.01, interval)
        case .continuous(let speed):
            continuousSpeed = max(0, speed)
        }
        timer?.stop()
        timer = nil
    }

    private func createTimer() {
        switch scrollMode {
        case .frequency:
            let config = JobsTimerConfig(
                interval: frequencyInterval,
                repeats: true,
                tolerance: 0.0,
                queue: .main
            )
            timer = JobsTimerFactory.make(
                kind: timerKindForFrequency,
                config: config
            ) { [weak self] in
                self?.tickFrequency()
            }

        case .continuous:
            let config = JobsTimerConfig(
                interval: continuousInterval,
                repeats: true,
                tolerance: 0.0,
                queue: .main
            )
            timer = JobsTimerFactory.make(
                kind: timerKindForContinuous,
                config: config
            ) { [weak self] in
                self?.tickContinuous()
            }
        }
    }
    /// 按频率滚动（间隔滚动）
    private func tickFrequency() {
        guard !internalButtons.isEmpty, stepLength > 0 else { return }
        let current = scrollView.contentOffset
        let maxOffsetX = max(0, scrollView.contentSize.width  - scrollView.bounds.width)
        let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
        var target = current                  // 动画要滚到哪里
        var needResetAfterAnimation = false   // 动画结束后是否需要“无感复位”
        var resetOffset = current             // 复位到哪里（填充好再用）
        switch direction {
        case .left:
            guard maxOffsetX > 0 else { return }
            let next = current.x + stepLength

            if itemSizeMode == .fillBounds {
                // 轮播图模式：最后一页是“首个的副本”
                if next >= maxOffsetX {
                    // 动画到副本那一页
                    target.x = maxOffsetX
                    // 动画结束后瞬移到真实第一页
                    resetOffset.x = 0
                    needResetAfterAnimation = true
                } else {
                    target.x = next
                }
            } else {
                // 跑马灯模式：用原来的逻辑
                if next > maxOffsetX {
                    target.x = 0
                } else {
                    target.x = next
                }
            }
        case .right:
            guard maxOffsetX > 0 else { return }
            let next = current.x - stepLength

            if itemSizeMode == .fillBounds {
                if next <= 0 {
                    // 动画到真实第一页
                    target.x = 0
                    // 动画结束后瞬移到“最后一页的副本”
                    resetOffset.x = maxOffsetX
                    needResetAfterAnimation = true
                } else {
                    target.x = next
                }
            } else {
                if next < 0 {
                    target.x = maxOffsetX
                } else {
                    target.x = next
                }
            }
        case .up:
            guard maxOffsetY > 0 else { return }
            let next = current.y + stepLength

            if itemSizeMode == .fillBounds {
                if next >= maxOffsetY {
                    target.y = maxOffsetY
                    resetOffset.y = 0
                    needResetAfterAnimation = true
                } else {
                    target.y = next
                }
            } else {
                if next > maxOffsetY {
                    target.y = 0
                } else {
                    target.y = next
                }
            }
        case .down:
            guard maxOffsetY > 0 else { return }
            let next = current.y - stepLength

            if itemSizeMode == .fillBounds {
                if next <= 0 {
                    target.y = 0
                    resetOffset.y = maxOffsetY
                    needResetAfterAnimation = true
                } else {
                    target.y = next
                }
            } else {
                if next < 0 {
                    target.y = maxOffsetY
                } else {
                    target.y = next
                }
            }
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView.contentOffset = target
        }, completion: { finished in
            guard finished, needResetAfterAnimation else { return }
            // ⚠️ 这里的瞬移是“无感”的：
            // 1,2,3,1 里 maxOffsetX 对应的那页 和 offset=0 的第一页内容一样
            self.scrollView.contentOffset = resetOffset
        })
    }
    /// 连续滚动
    private func tickContinuous() {
        guard !internalButtons.isEmpty else { return }

        let distance = CGFloat(continuousInterval) * continuousSpeed
        guard distance > 0 else { return }

        var offset = scrollView.contentOffset
        let maxOffsetX = max(0, scrollView.contentSize.width  - scrollView.bounds.width)
        let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)

        switch direction {
        case .left:
            guard maxOffsetX > 0 else { return }
            offset.x += distance
            if offset.x > maxOffsetX { offset.x -= maxOffsetX }
        case .right:
            guard maxOffsetX > 0 else { return }
            offset.x -= distance
            if offset.x < 0 { offset.x += maxOffsetX }
        case .up:
            guard maxOffsetY > 0 else { return }
            offset.y += distance
            if offset.y > maxOffsetY { offset.y -= maxOffsetY }
        case .down:
            guard maxOffsetY > 0 else { return }
            offset.y -= distance
            if offset.y < 0 { offset.y += maxOffsetY }
        }

        scrollView.contentOffset = offset
    }
    /// 计算 S1/S2：系统默认按钮字体下，一个英文字符的宽高
    private static func computeMinButtonSize() -> CGSize {
        let font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        let text = "A" as NSString
        let size = text.size(withAttributes: [.font: font])
        return size
    }
    /// 按需求数量构造按钮数组（不足则复制）
    private func buildButtons(from source: [UIButton], targetCount: Int) -> [UIButton] {
        guard !source.isEmpty else { return [] }

        var result: [UIButton] = []
        var index = 0

        while result.count < targetCount {
            let template = source[index % source.count]
            let clone = cloneButton(from: template)
            result.append(clone)
            index += 1
        };return result
    }
    /// 复制 UIButton 的外观 & 行为（尽量复制标题、图片、颜色、事件）
    private func cloneButton(from source: UIButton) -> UIButton {

        // 1. 用你的工厂方法创建按钮
        let button = UIButton.sys()
        button.jobs_isClone = true    // 给 SD / KF 背景图克隆那一套用

        // 2. 标题 & 图片（链式）
        let states: [UIControl.State] = [.normal, .highlighted, .selected, .disabled]
        for state in states {

            if let title = source.title(for: state) {
                button.byTitle(title, for: state)
            }

            if let attrTitle = source.attributedTitle(for: state) {
                button.byAttributedTitle(attrTitle, for: state)
            }

            if let color = source.titleColor(for: state) {
                button.byTitleColor(color, for: state)
            }

            if let image = source.image(for: state) {
                button.byImage(image, for: state)
            }

            if let bgImage = source.backgroundImage(for: state) {
                button.byBackgroundImage(bgImage, for: state)
            }
        }

        // 3. 字体
        if let font = source.titleLabel?.font {
            button.byTitleFont(font)
        }

        // 4. 内边距 / configuration（避免 iOS 15 之后的 deprecated 警告）
        if #available(iOS 15.0, *), let cfg = source.configuration {
            // 按钮已经在用 UIButton.Configuration：直接克隆配置
            button.configuration = cfg
        } else {
            // 老模式：用 edgeInsets（只在 < iOS 15 的分支里调用，不会再黄）
            button
                .byContentEdgeInsets(source.contentEdgeInsets)
                .byTitleEdgeInsets(source.titleEdgeInsets)
                .byImageEdgeInsets(source.imageEdgeInsets)
        }

        // 5. 背景色
        if let bgColor = source.backgroundColor {
            button.byBackgroundColor(bgColor, for: .normal)
        }

        // 6. 对齐方式
        button.contentHorizontalAlignment = source.contentHorizontalAlignment
        button.contentVerticalAlignment   = source.contentVerticalAlignment

        // 7. layer 样式
        button.layer.cornerRadius  = source.layer.cornerRadius
        button.layer.masksToBounds = source.layer.masksToBounds
        button.layer.borderWidth   = source.layer.borderWidth
        button.layer.borderColor   = source.layer.borderColor

        // 8. 远程图片：SDWebImage / Kingfisher 配置克隆
        //    - 如果该按钮没用 SD / KF，则对应 url 为 nil，下面这些调用都直接 return，不会有副作用
        //    - 如果已经加载过，会优先命中缓存；没缓存才按需触网

        #if canImport(SDWebImage)
        // SDWebImage@前景图
//        source.sd_cloneImage(to: button, for: .normal)
        // SDWebImage@背景图
        source.sd_cloneBackground(to: button,
                                  for: .normal,
                                  allowNetworkIfMissing: true)
        #endif

        #if canImport(Kingfisher)
        // Kingfisher@前景图
//        source.kf_cloneImage(to: button, for: .normal)
        // Kingfishe@背景图
        source.kf_cloneBackground(to: button,
                                  for: .normal,
                                  allowNetworkIfMissing: true)
        #endif

        // 9. 复制 target-action（兼容老式 addTarget，包括 jobs_addTapClosure 那一套）
        var hasTapTarget = false

        for target in source.allTargets {
            for event in [
                UIControl.Event.touchUpInside,
                .touchDown,
                .touchUpOutside,
                .touchCancel,
                .valueChanged,
                .primaryActionTriggered
            ] {
                guard let actions = source.actions(forTarget: target,
                                                   forControlEvent: event) else { continue }
                for action in actions {
                    button.addTarget(target, action: Selector(action), for: event)
                    if event == .touchUpInside {
                        hasTapTarget = true
                    }
                }
            }
        }

        // 10. 兼容 onTap / byTapSound：它们在 iOS 14+ 用的是 UIAction，看不到 target-action
        //     如果没有任何 .touchUpInside 的 target，就加一个“转发器”：
        if #available(iOS 14.0, *), !hasTapTarget {
            button.addAction(
                UIAction { [weak source] _ in
                    // 让原按钮自己触发所有点击逻辑（onTap + byTapSound 全跑）
                    source?.sendActions(for: .touchUpInside)
                },
                for: .touchUpInside
            )
        }

        // 11. 复制长按手势（onLongPress）
        if let recognizers = source.gestureRecognizers {
            for recognizer in recognizers {
                guard let lp = recognizer as? UILongPressGestureRecognizer else { continue }

                let cloneGR = UILongPressGestureRecognizer()

                cloneGR.minimumPressDuration    = lp.minimumPressDuration
                cloneGR.numberOfTapsRequired    = lp.numberOfTapsRequired
                cloneGR.numberOfTouchesRequired = lp.numberOfTouchesRequired
                cloneGR.allowableMovement       = lp.allowableMovement
                cloneGR.cancelsTouchesInView    = lp.cancelsTouchesInView
                cloneGR.delaysTouchesBegan      = lp.delaysTouchesBegan
                cloneGR.delaysTouchesEnded      = lp.delaysTouchesEnded
                cloneGR.isEnabled               = lp.isEnabled

                // ✅ 从原手势上把 sleeve 拿出来，挂到 cloneGR 上
                if let sleeve = objc_getAssociatedObject(lp, &kJobsUIButtonLongPressSleeveKey) {
                    // _GRSleeve.invoke(_:) 暴露到 ObjC 后就是 "invoke:"
                    cloneGR.addTarget(sleeve, action: NSSelectorFromString("invoke:"))
                    objc_setAssociatedObject(
                        cloneGR,
                        &kJobsUIButtonLongPressSleeveKey,
                        sleeve,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }

                button.addGestureRecognizer(cloneGR)
            }
        }

        return button
    }

}

extension JobsMarqueeView {
    @discardableResult
    func byDirection(_ direction: Direction) -> Self {
        self.direction = direction
        return self
    }

    @discardableResult
    func byScrollMode(_ mode: ScrollMode) -> Self {
        self.scrollMode = mode
        return self
    }

    @discardableResult
    func byItemSizeMode(_ mode: ItemSizeMode) -> Self {
        self.itemSizeMode = mode
        return self
    }

    @discardableResult
    func byDataSourceButtons(_ buttons: [UIButton]) -> Self {
        self.dataSourceButtons = buttons
        return self
    }
}
