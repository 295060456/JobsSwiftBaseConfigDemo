//
//  ColorWheelView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

import UIKit
import SnapKit

/// 扇形圆盘 + 中央按钮（按钮用 Jobs 封装 API）
/// 旋转动画用 JobsTimer（displayLink 内核） + ScrollDecelerator 实现 UIScrollView 式减速
/// 支持:
/// 1. 中央按钮点击减速旋转
/// 2. 扇形短按 / 长按
/// 3. 手势拖动旋转 + 松手后减速
final class ColorWheelView: UIView {

    // MARK: - 配置 ==============================

    /// 扇形颜色数组
    var colors: [UIColor] = [] {
        didSet { setNeedsLayout() }
    }

    /// 旋转持续时间（秒，近似控制）
    /// 例如：2 / 3 / 4 秒，内部根据 decelerationRate + stopThreshold 反推初始角速度
    var spinDuration: TimeInterval = 3.0

    /// 自定义初始角速度（单位：rad/s）
    /// - 如果不为 nil，则优先使用这个值，而不是通过 spinDuration 反推
    /// - 数值越大，甩得越猛，转得越久
    var customInitialVelocity: CGFloat?

    /// 是否允许手势拖动旋转（默认 true）
    var isPanRotationEnabled: Bool = true {
        didSet {
            panGesture.isEnabled = isPanRotationEnabled
        }
    }

    /// 减速率（默认 UIScrollView.normal）
    /// 值越接近 1，减速越慢、转得越久
    private var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    /// 认为“停下”的角速度阈值（rad/s）
    /// 越小，最后拖尾越久
    private var stopThreshold: CGFloat = 0.05

    // MARK: - 子视图 ==============================

    /// 真正画轮盘的盘面 view（我们只旋转它）
    private let plateView = UIView()

    /// 中央按钮（用你的 UIButton DSL）
    private lazy var centerButton: UIButton = {
        UIButton.sys()
            /// 背景色
            .byBackgroundColor(.systemGreen, for: .normal)
            /// 普通标题
            .byTitle("点击\n抽奖", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCornerRadius(30)
            .byMasksToBounds(true)
            /// 点击声音
            .byTapSound("Sound.wav")
            /// 点按事件：走统一的旋转逻辑
            .onTap { [weak self] _ in
                self?.startSpinWithScrollLikeDeceleration()
            }
            /// 长按反馈（按钮自身的视觉反馈）
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                }
            }
            .byAddTo(self) { make in
                make.center.equalToSuperview()
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
    }()

    // MARK: - 绘制相关 ==============================

    private var sliceLayers: [CAShapeLayer] = []

    // MARK: - 旋转状态 / JobsTimer ====================

    private var currentAngle: CGFloat = 0              // 当前盘面角度（rad）
    private var decelerator: ScrollDecelerator?
    private var timer: JobsTimerProtocol?
    private let timerInterval: CGFloat = 1.0 / 60.0

    // MARK: - 手势状态 ================================

    /// 使用你的封装创建 Pan 手势
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer
            .byConfig { [weak self] gr in
                guard let self,
                      let pan = gr as? UIPanGestureRecognizer else { return }
                self.handlePan(pan)
            }
            .byMinTouches(1)
            .byMaxTouches(2)
            .byCancelsTouchesInView(true)

        self.jobs_addGesture(gr)
        return gr
    }()

    /// 扇形点击（Tap）
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer
            .byConfig { [weak self] gr in
                guard let self,
                      let tap = gr as? UITapGestureRecognizer else { return }
                self.handleSegmentTap(tap)
            }
            .byTaps(1)
            .byTouches(1)
            .byCancelsTouchesInView(false)  // 不拦截中心按钮触摸

        self.jobs_addGesture(gr)
        return gr
    }()

    /// 扇形长按（LongPress）
    private lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let gr = UILongPressGestureRecognizer
            .byConfig { [weak self] gr in
                guard let self,
                      let lp = gr as? UILongPressGestureRecognizer else { return }
                self.handleSegmentLongPress(lp)
            }
            .byMinDuration(0.5)
            .byMovement(12)
            .byTouches(1)

        self.jobs_addGesture(gr)
        return gr
    }()

    /// Pan 拖动计算用
    private var lastTouchAngle: CGFloat = 0
    private var lastTouchTimestamp: CFTimeInterval = 0
    private var angularVelocityFromPan: CGFloat = 0

    // MARK: - Segment 交互（点击 / 长按） ===============

    /// 短按回调：index = 扇形下标
    private var segmentTapHandler: ((Int) -> Void)?

    /// 长按回调：index + 手势（方便你根据 state 做不同处理）
    private var segmentLongPressHandler: ((Int, UILongPressGestureRecognizer) -> Void)?

    // MARK: - Init ==============================

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        clipsToBounds = false

        // 盘面铺满整个 ColorWheelView
        addSubview(plateView)
        plateView.backgroundColor = .clear
        plateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 触发 lazy，完成 jobs_addGesture 绑定
        _ = panGesture
        _ = tapRecognizer
        _ = longPressRecognizer

        // Tap / LongPress 与 Pan 冲突时，让 Pan 优先（拖动优先）
        tapRecognizer.require(toFail: panGesture)
        longPressRecognizer.require(toFail: panGesture)

        // 确保按钮创建并在最上
        _ = centerButton
        bringSubviewToFront(centerButton)
    }

    // MARK: - Layout / Draw ==============================

    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildSlices()
        bringSubviewToFront(centerButton)   // 再保险一次
    }

    private func rebuildSlices() {
        sliceLayers.forEach { $0.removeFromSuperlayer() }
        sliceLayers.removeAll()

        guard !colors.isEmpty,
              plateView.bounds.width > 0,
              plateView.bounds.height > 0
        else { return }

        let bounds = plateView.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2

        let count = colors.count
        let anglePerSlice = 2 * CGFloat.pi / CGFloat(count)

        for (index, color) in colors.enumerated() {
            let startAngle = -CGFloat.pi / 2 + CGFloat(index) * anglePerSlice
            let endAngle = startAngle + anglePerSlice

            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            path.close()

            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = color.cgColor

            plateView.layer.addSublayer(layer)
            sliceLayers.append(layer)
        }

        // 中心点方便观察
        let dotRadius: CGFloat = 3
        let dotPath = UIBezierPath(ovalIn: CGRect(
            x: center.x - dotRadius,
            y: center.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))
        let dotLayer = CAShapeLayer()
        dotLayer.path = dotPath.cgPath
        dotLayer.fillColor = UIColor.white.cgColor
        plateView.layer.addSublayer(dotLayer)
        sliceLayers.append(dotLayer)
    }

    // MARK: - Segment 命中计算 ===========================

    /// 根据点击点（在 ColorWheelView 自身坐标系）计算命中的扇形 index
    private func segmentIndex(at point: CGPoint) -> Int? {
        guard !colors.isEmpty,
              plateView.bounds.width > 0,
              plateView.bounds.height > 0
        else { return nil }

        // 圆心，以 ColorWheelView 自身坐标系
        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2

        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = hypot(dx, dy)

        // 超出圆半径：不算点击扇形
        if distance > radius { return nil }

        // 触点相对圆心的绝对角度（世界坐标），[-π, π]
        let touchAngle = atan2(dy, dx)

        // 盘面已经被 currentAngle 旋转了；把触点角度“反旋转”回静止态
        var angle0 = touchAngle - currentAngle

        let twoPi = 2 * CGFloat.pi
        // 归一化到 [0, 2π)
        while angle0 < 0 { angle0 += twoPi }
        while angle0 >= twoPi { angle0 -= twoPi }

        // 静止态下，0 对应 -π/2（正上方）
        let startFromTop: CGFloat = -CGFloat.pi / 2
        var relative = angle0 - startFromTop
        while relative < 0 { relative += twoPi }
        while relative >= twoPi { relative -= twoPi }

        let count = colors.count
        let anglePerSlice = twoPi / CGFloat(count)
        let idx = Int(relative / anglePerSlice)

        if idx >= 0 && idx < count {
            return idx
        } else {
            return nil
        }
    }

    // MARK: - Segment 手势回调 ===========================

    private func handleSegmentTap(_ gr: UITapGestureRecognizer) {
        guard gr.state == .ended else { return }
        // 旋转中不响应点击
        guard timer == nil else { return }

        let point = gr.location(in: self)

        // 点到中心按钮区域 -> 交给按钮自己处理
        if centerButton.frame.contains(point) { return }

        guard let index = segmentIndex(at: point) else { return }

        segmentTapHandler?(index)
    }

    private func handleSegmentLongPress(_ gr: UILongPressGestureRecognizer) {
        // 旋转中不响应长按
        guard timer == nil else { return }

        let point = gr.location(in: self)

        // 点到中心按钮区域 -> 不算扇形长按
        if centerButton.frame.contains(point) { return }

        guard let index = segmentIndex(at: point) else { return }

        segmentLongPressHandler?(index, gr)
    }

    // MARK: - 手势拖动旋转 ===============================

    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 不允许拖动 / 自动减速旋转中都不处理
        if !isPanRotationEnabled { return }
        if timer != nil { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let location = gesture.location(in: self)

        // 在中心按钮区域开始的拖动，忽略
        if gesture.state == .began,
           centerButton.frame.contains(location) {
            return
        }

        let dx = location.x - center.x
        let dy = location.y - center.y
        let angle = atan2(dy, dx)
        let now = CACurrentMediaTime()

        switch gesture.state {
        case .began:
            lastTouchAngle = angle
            lastTouchTimestamp = now
            angularVelocityFromPan = 0

        case .changed:
            var step = angle - lastTouchAngle
            let pi = CGFloat.pi
            if step > pi { step -= 2 * pi }
            if step < -pi { step += 2 * pi }

            currentAngle += step
            plateView.transform = CGAffineTransform(rotationAngle: currentAngle)

            let dt = now - lastTouchTimestamp
            if dt > 0 {
                angularVelocityFromPan = step / CGFloat(dt)
            }
            lastTouchAngle = angle
            lastTouchTimestamp = now

        case .ended, .cancelled, .failed:
            let v = angularVelocityFromPan
            angularVelocityFromPan = 0
            // 有明显速度 => 按 UIScrollView 曲线做减速旋转
            if abs(v) > 0.1 {
                startSpinWithScrollLikeDeceleration(initialVelocity: v)
            }

        default:
            break
        }
    }

    // MARK: - 旋转逻辑（JobsTimer + UIScrollView 减速） ========

    /// 外部也可以直接调用这个方法来启动
    ///
    /// - 参数优先级：
    ///   1. `initialVelocity`（方法参数）如果不为 nil，优先使用；
    ///   2. 否则如果 `customInitialVelocity` 不为 nil，使用属性；
    ///   3. 否则根据 `spinDuration` 反推一个初始角速度。
    func startSpinWithScrollLikeDeceleration(initialVelocity: CGFloat? = nil) {
        // 已经在自动旋转中，直接丢掉本次请求
        guard timer == nil else { return }

        let v0: CGFloat
        if let v = initialVelocity {
            v0 = v
        } else if let v = customInitialVelocity {
            v0 = v
        } else {
            v0 = velocityForTargetDuration(spinDuration)
        }

        // 开始旋转时统一锁死按钮
        centerButton.isSelected = true
        centerButton.isUserInteractionEnabled = false

        decelerator = ScrollDecelerator(
            velocity: v0,
            decelerationRate: decelerationRate
        )

        let config = JobsTimerConfig(
            interval: TimeInterval(timerInterval),
            repeats: true,
            tolerance: 0,
            queue: .main
        )

        let t = JobsTimerFactory.make(
            kind: .displayLink,
            config: config
        ) { [weak self] in
            self?.tickTimer()
        }

        timer = t
        t.start()
    }

    /// 根据目标时间粗略反推需要的初始角速度
    ///
    /// v(t) = v0 * d^(1000 t)
    /// 令 |v(T)| ≈ stopThreshold，得到 v0 ≈ stopThreshold / d^(1000 T)
    private func velocityForTargetDuration(_ duration: TimeInterval) -> CGFloat {
        // 防御：限制时间范围，避免数值爆炸
        let T = max(0.1, min(duration, 6.0))
        let d = decelerationRate
        let eps = stopThreshold

        let denom = pow(d, 1000 * T)
        if denom < 1e-4 {
            // 避免 v0 过大，做一个下限
            return eps / 1e-4
        } else {
            return eps / denom
        }
    }

    private func tickTimer() {
        guard var dec = decelerator else {
            stopSpin()
            return
        }

        let dt = timerInterval
        let deltaAngle = dec.step(dt: dt)
        decelerator = dec

        currentAngle += deltaAngle
        // 只旋转盘面，不旋转整个 ColorWheelView，这样按钮不会跟着转
        plateView.transform = CGAffineTransform(rotationAngle: currentAngle)

        if dec.isStopped(threshold: stopThreshold) {
            stopSpin()
            print("✅ 减速结束，最终角度 = \(currentAngle)")
            // TODO: 在这里根据 currentAngle 算命中的扇形 index
        }
    }

    private func stopSpin() {
        timer?.stop()
        timer = nil
        decelerator = nil

        // 旋转结束：按钮恢复可点击 & 状态复位
        centerButton.isSelected = false
        centerButton.isUserInteractionEnabled = true
    }
}

// MARK: - ColorWheelView 点语法 DSL ===================

extension ColorWheelView {

    /// 配置扇形颜色数组
    @discardableResult
    func byColors(_ colors: [UIColor]) -> Self {
        self.colors = colors
        return self
    }

    /// 配置旋转持续时间（秒）
    @discardableResult
    func bySpinDuration(_ duration: TimeInterval) -> Self {
        self.spinDuration = duration
        return self
    }

    /// 配置自定义初始角速度（rad/s）
    /// 数值越大，开始越猛，转得越久
    @discardableResult
    func byInitialVelocity(_ velocity: CGFloat) -> Self {
        self.customInitialVelocity = velocity
        return self
    }

    /// 配置减速率（使用 UIScrollView.DecelerationRate）
    @discardableResult
    func byDecelerationRate(_ rate: UIScrollView.DecelerationRate) -> Self {
        self.decelerationRate = rate.rawValue
        return self
    }

    /// 配置减速率（直接传 rawValue，0 ~ 1，越接近 1 转得越久）
    @discardableResult
    func byDecelerationRateRaw(_ raw: CGFloat) -> Self {
        self.decelerationRate = raw
        return self
    }

    /// 配置认为“停下”的角速度阈值（rad/s）
    @discardableResult
    func byStopThreshold(_ threshold: CGFloat) -> Self {
        self.stopThreshold = threshold
        return self
    }

    /// 配置是否允许手势拖动旋转
    @discardableResult
    func byPanRotationEnabled(_ enabled: Bool) -> Self {
        self.isPanRotationEnabled = enabled
        return self
    }

    /// 配置扇形短按回调
    @discardableResult
    func onSegmentTap(_ handler: @escaping (Int) -> Void) -> Self {
        self.segmentTapHandler = handler
        return self
    }

    /// 配置扇形长按回调
    @discardableResult
    func onSegmentLongPress(_ handler: @escaping (Int, UILongPressGestureRecognizer) -> Void) -> Self {
        self.segmentLongPressHandler = handler
        return self
    }
}
