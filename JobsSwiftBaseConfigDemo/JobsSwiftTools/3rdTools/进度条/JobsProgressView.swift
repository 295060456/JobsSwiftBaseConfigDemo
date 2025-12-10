//
//  JobsProgressView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
/// 自定义进度条@进度值和前进方向
final class JobsProgressView: UIView {
    enum Direction {
        case leftToRight
        case rightToLeft
        case bottomToTop
        case topToBottom
    }
    // MARK: - Public API
    /// 进度方向
    var direction: Direction = .leftToRight {
        didSet { setNeedsLayout() }
    }
    /// 当前进度 [0, 1]
    var progress: CGFloat {
        get { _progress }
        set { setProgress(newValue, animated: false) }
    }
    /// 轨道（背景）
    private lazy var trackView: UIView = {
        UIView()
            .byBgColor(.systemGray5)
            .byMasksToBounds(YES)
            .byAddTo(self)
    }()
    /// 填充（前景）
    private lazy var fillView: UIView = {
        UIView()
            .byBgColor(.systemBlue)
            .byMasksToBounds(YES)
            .byAddTo(trackView)
    }()
    /// 显示百分比的标签（跟随移动）
    private lazy var progressLabel: UILabel = {
        UILabel()
            .byFont(.monospacedDigitSystemFont(ofSize: 12, weight: .medium))
            .byTextColor(.label)
            .byTextAlignment(.center)
            .byText("0%")
            .byBgCor(.secondarySystemBackground)
            .byCornerRadius(10)
            .byAddTo(self)
    }()
    // MARK: - Private
    private var _progress: CGFloat = 0
    // MARK: - Init
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
        // 使用时触发懒加载
        trackView.byVisible(YES)
        fillView.byVisible(YES)
        progressLabel.byVisible(YES)
    }

    override var intrinsicContentSize: CGSize {
        // 默认高度给个 40，方便直接用 Auto Layout
        return CGSize(width: UIView.noIntrinsicMetric, height: 40)
    }
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutForCurrentState()
    }

    private func layoutForCurrentState() {
        let p = max(0, min(_progress, 1)) // clamp 到 [0, 1]

        let horizontalInset: CGFloat = 8
        let verticalInset: CGFloat = 8
        let trackThickness: CGFloat = 6
        let labelOffset: CGFloat = 4

        switch direction {
        case .leftToRight, .rightToLeft:
            // 水平进度条：放在底部
            let trackWidth = max(0, bounds.width - 2 * horizontalInset)
            let trackHeight = trackThickness
            let trackY = bounds.height - trackHeight - verticalInset
            let trackFrame = CGRect(x: horizontalInset,
                                    y: trackY,
                                    width: trackWidth,
                                    height: trackHeight)
            trackView.frame = trackFrame
            trackView.layer.cornerRadius = trackHeight / 2
            fillView.layer.cornerRadius = trackHeight / 2

            let fillWidth = trackWidth * p

            if direction == .leftToRight {
                fillView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: fillWidth,
                                        height: trackHeight)
            } else {
                fillView.frame = CGRect(x: trackWidth - fillWidth,
                                        y: 0,
                                        width: fillWidth,
                                        height: trackHeight)
            }

            // 更新 Label 尺寸
            progressLabel.sizeToFit()
            let labelSize = CGSize(width: progressLabel.bounds.width + 8,
                                   height: progressLabel.bounds.height + 4)
            progressLabel.bounds.size = labelSize

            // 端点 x（在 self 坐标系里）
            let endpointX: CGFloat
            if direction == .leftToRight {
                endpointX = trackFrame.minX + fillWidth
            } else {
                endpointX = trackFrame.maxX - fillWidth
            }

            // clamp，防止越界
            var centerX = endpointX
            let minX = trackFrame.minX + labelSize.width / 2
            let maxX = trackFrame.maxX - labelSize.width / 2
            centerX = min(max(centerX, minX), maxX)

            let centerY = trackFrame.minY - labelOffset - labelSize.height / 2
            let finalCenterY = max(labelSize.height / 2, centerY)

            progressLabel.center = CGPoint(x: centerX, y: finalCenterY)

        case .bottomToTop, .topToBottom:
            // 垂直进度条：放在左侧
            let trackWidth = trackThickness
            let trackHeight = max(0, bounds.height - 2 * verticalInset)
            let trackX = horizontalInset
            let trackFrame = CGRect(x: trackX,
                                    y: verticalInset,
                                    width: trackWidth,
                                    height: trackHeight)
            trackView.frame = trackFrame
            trackView.layer.cornerRadius = trackWidth / 2
            fillView.layer.cornerRadius = trackWidth / 2

            let fillHeight = trackHeight * p

            if direction == .bottomToTop {
                let y = trackHeight - fillHeight
                fillView.frame = CGRect(x: 0,
                                        y: y,
                                        width: trackWidth,
                                        height: fillHeight)
            } else {
                fillView.frame = CGRect(x: 0,
                                        y: 0,
                                        width: trackWidth,
                                        height: fillHeight)
            }

            // 更新 Label 尺寸
            progressLabel.sizeToFit()
            let labelSize = CGSize(width: progressLabel.bounds.width + 8,
                                   height: progressLabel.bounds.height + 4)
            progressLabel.bounds.size = labelSize

            // 端点 y（在 self 坐标系里）
            let endpointY: CGFloat
            if direction == .bottomToTop {
                endpointY = trackFrame.minY + (trackHeight - fillHeight)
            } else {
                endpointY = trackFrame.minY + fillHeight
            }

            var centerY = endpointY
            let minY = trackFrame.minY + labelSize.height / 2
            let maxY = trackFrame.maxY - labelSize.height / 2
            centerY = min(max(centerY, minY), maxY)

            let centerX = trackFrame.maxX + labelOffset + labelSize.width / 2
            let minCenterX = labelSize.width / 2
            let maxCenterX = bounds.width - labelSize.width / 2

            progressLabel.center = CGPoint(
                x: min(max(centerX, minCenterX), maxCenterX),
                y: centerY
            )
        }
        // 更新文案
        progressLabel.text = "\(Int(round(p * 100)))%"
    }
    // MARK: - Progress API
    func setProgress(_ progress: CGFloat,
                     animated: Bool = true,
                     duration: TimeInterval = 0.25) {
        let clamped = max(0, min(progress, 1))
        _progress = clamped
        if animated {
            setNeedsLayout()
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        } else {
            setNeedsLayout()
        }
    }
}
// MARK: - DSL
extension JobsProgressView {
    // MARK: - Direction
    /// 配置进度方向
    @discardableResult
    func byDirection(_ direction: Direction) -> Self {
        self.direction = direction
        return self
    }
    // MARK: - Progress
    /// 配置当前进度 [0, 1]
    @discardableResult
    func byProgress(_ value: CGFloat,
                    animated: Bool = false,
                    duration: TimeInterval = 0.25) -> Self {
        self.setProgress(value, animated: animated, duration: duration)
        return self
    }
    // MARK: - Track
    /// 配置轨道背景色
    @discardableResult
    func byTrackColor(_ color: UIColor) -> Self {
        self.trackView.backgroundColor = color
        return self
    }
    /// 配置轨道圆角（不配的话默认按高度一半）
    @discardableResult
    func byTrackCornerRadius(_ radius: CGFloat) -> Self {
        self.trackView.layer.cornerRadius = radius
        return self
    }
    // MARK: - Label
    /// 配置标签字体
    @discardableResult
    func byLabelFont(_ font: UIFont) -> Self {
        self.progressLabel.font = font
        return self
    }
    /// 配置标签文字颜色
    @discardableResult
    func byLabelTextColor(_ color: UIColor) -> Self {
        self.progressLabel.textColor = color
        return self
    }
    /// 配置标签背景色
    @discardableResult
    func byLabelBackgroundColor(_ color: UIColor) -> Self {
        self.progressLabel.backgroundColor = color
        return self
    }
    /// 配置标签圆角
    @discardableResult
    func byLabelCornerRadius(_ radius: CGFloat) -> Self {
        self.progressLabel.layer.cornerRadius = radius
        self.progressLabel.layer.masksToBounds = true
        return self
    }
}
