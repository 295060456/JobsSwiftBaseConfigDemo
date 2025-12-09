//
//  钟.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import QuartzCore
// 如果 JobsTimer.swift 是在同一个 module 里，这里不用再 import；否则按你工程结构 import
/// 带时分秒针 + 刻度数字 1～12 的模拟时钟，定时器用 JobsTimer
final class JobsClockView: UIView {
    // MARK: - 表盘 & 刻度
    /// 外圈表盘
    private lazy var dialLayer: CAShapeLayer = {
        CAShapeLayer()
            .byFillColor(.clear)
            .byStrokeColor(.label.withAlphaComponent(0.2))
            .byLineWidth(2)
            .byAddTo(layer)
    }()
    /// 12 个整点刻度
    private lazy var tickLayer: CAShapeLayer = {
        CAShapeLayer()
            .byFillColor(.clear)
            .byStrokeColor(.label)
            .byLineWidth(2)
            .byAddTo(layer)
    }()
    /// 中心小圆点
    private lazy var centerDotLayer: CAShapeLayer = {
        CAShapeLayer()
            .byFillColor(.label)
            .byStrokeColor(.clear)
            .byAddTo(layer)
    }()
    /// 1～12 的数字标签
    private lazy var numberLabels: [UILabel] = {
        (1...12).map { value in
            UILabel()
                .byText("\(value)")
                .byFont(.systemFont(ofSize: 12, weight: .medium))
                .byTextColor(.label)
                .byTextAlignment(.center)
                .byAddTo(self)
        }
    }()
    // MARK: - 指针层（懒加载）
    private lazy var hourHand: CALayer = {
        CALayer()
            .byBackgroundColor(.black)
            .byCornerRadius(3)
            .byAddTo(layer)
    }()

    private lazy var minuteHand: CALayer = {
        CALayer()
            .byBackgroundColor(.darkGray)
            .byCornerRadius(2)
            .byAddTo(layer)
    }()

    private lazy var secondHand: CALayer = {
        CALayer()
            .byBackgroundColor(.red)
            .byCornerRadius(1)
            .byAddTo(layer)
    }()

    private var timer: JobsTimerProtocol?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        stop()
    }

    private func commonInit() {
        backgroundColor = .clear
        dialLayer.byHidden(NO)
        tickLayer.byHidden(NO)
        centerDotLayer.byHidden(NO)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDialAndNumbers()
        layoutHandLayers()
        updateHands(animated: false)  // 布局完成后对齐当前时间
    }
    /// 布局表盘 + 刻度 + 数字
    private func layoutDialAndNumbers() {
        let size = min(bounds.width, bounds.height)
        guard size > 0 else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let inset: CGFloat = size * 0.05
        let radius = size / 2 - inset
        // 表盘外圈
        let circleRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        let circlePath = UIBezierPath(ovalIn: circleRect)
        dialLayer.path = circlePath.cgPath
        // 12 个整点刻度
        let tickPath = UIBezierPath()
        let tickLen: CGFloat = 8
        for i in 0..<12 {
            // 0 对应 12 点，顺时针
            let angle = CGFloat(i) / 12.0 * 2.0 * .pi - .pi / 2.0
            let outer = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            let inner = CGPoint(
                x: center.x + cos(angle) * (radius - tickLen),
                y: center.y + sin(angle) * (radius - tickLen)
            )
            tickPath.move(to: inner)
            tickPath.addLine(to: outer)
        }
        tickLayer.path = tickPath.cgPath
        // 中心小圆点
        let dotRadius: CGFloat = 4
        let dotRect = CGRect(
            x: center.x - dotRadius,
            y: center.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        )
        let dotPath = UIBezierPath(ovalIn: dotRect)
        centerDotLayer.path = dotPath.cgPath
        // 1～12 数字布局
        let numberRadius = radius - 20
        for (index, label) in numberLabels.enumerated() {
            let value = CGFloat(index + 1) // 1...12
            let angle = value / 12.0 * 2.0 * .pi - .pi / 2.0

            let labelCenter = CGPoint(
                x: center.x + cos(angle) * numberRadius,
                y: center.y + sin(angle) * numberRadius
            )

            let labelSize = label.intrinsicContentSize
            label.frame = CGRect(
                x: labelCenter.x - labelSize.width / 2,
                y: labelCenter.y - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )
        }
    }
    /// 布局三根指针
    private func layoutHandLayers() {
        let size = min(bounds.width, bounds.height)
        guard size > 0 else { return }
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // 三根针长度比例
        let hourLen:   CGFloat = size * 0.25
        let minuteLen: CGFloat = size * 0.35
        let secondLen: CGFloat = size * 0.40
        // 触发布局时，顺便触发懒加载
        hourHand.bounds   = CGRect(x: 0, y: 0, width: 6, height: hourLen)
        minuteHand.bounds = CGRect(x: 0, y: 0, width: 4, height: minuteLen)
        secondHand.bounds = CGRect(x: 0, y: 0, width: 2, height: secondLen)
        // 以底部为 anchor，position 放在表盘中心，这样旋转就是绕表心转
        [hourHand, minuteHand, secondHand].forEach { hand in
            hand.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            hand.position = center
        }
    }
    // MARK: - 对外 API：启动 / 停止
    /// 开始走表（默认用 GCD 内核）
    func start(kind: JobsTimerKind = .gcd) {
        stop()
        // 先对齐一次当前时间
        updateHands(animated: false)

        let config = JobsTimerConfig(
            interval: 1.0,          // 每秒 tick 一次
            repeats: true,
            tolerance: 0.01,
            queue: .main            // UI 更新一定要在主队列
        )

        let t = JobsTimerFactory.make(kind: kind, config: config) { [weak self] in
            self?.updateHands(animated: true)
        }
        timer = t
        t.start()
    }
    /// 停止走表
    func stop() {
        timer?.stop()
        timer = nil
    }
    // MARK: - 内部：根据当前时间更新指针角度
    private func updateHands(animated: Bool) {
        let date = Date()
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: date)

        let hour   = CGFloat(comps.hour ?? 0)   // 0...23
        let minute = CGFloat(comps.minute ?? 0) // 0...59
        let second = CGFloat(comps.second ?? 0) // 0...59
        // 角度计算（单位：弧度）
        let secAngle  = (second / 60.0) * 2.0 * .pi
        let minAngle  = ((minute + second / 60.0) / 60.0) * 2.0 * .pi
        let hourAngle = (((hour.truncatingRemainder(dividingBy: 12))
                          + minute / 60.0
                          + second / 3600.0) / 12.0) * 2.0 * .pi
        let apply = {
            self.hourHand.transform   = CATransform3DMakeRotation(hourAngle, 0, 0, 1)
            self.minuteHand.transform = CATransform3DMakeRotation(minAngle, 0, 0, 1)
            self.secondHand.transform = CATransform3DMakeRotation(secAngle, 0, 0, 1)
        }
        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            CATransaction.setAnimationTimingFunction(
                CAMediaTimingFunction(name: .easeInEaseOut)
            )
            apply()
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            apply()
            CATransaction.commit()
        }
    }
}
