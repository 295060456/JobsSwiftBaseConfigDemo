//
//  苹果滑动开锁.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/29/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import SnapKit

final class SlideToUnlockView: UIView {
    // MARK: - 方向
    enum Direction {
        case leftToRight   // 默认：从左往右
        case rightToLeft   // 可选：从右往左
    }
    /// 滑到终点时回调（只在成功解锁时调用）
    var onUnlock: (jobsByVoidBlock)?
    /// 解锁方向（默认从左往右）
    var direction: Direction = .leftToRight {
        didSet {
            updateDirectionUI()
            setNeedsLayout()
            updateShimmerMask()
        }
    }
    /// 是否开启“轨道骨架屏闪动效果”（用 JobsShimmerBarView 模拟）
    var isSkeletonEnabled: Bool = false {
        didSet {
            updateSkeletonState()
        }
    }
    // MARK: - 配置
    private let thumbInset: CGFloat = 4          // 滑块距离左右的内边距
    private let thumbSize = CGSize(width: 52, height: 52)
    private var panStartProgress: CGFloat = 0    // 手势开始时的进度备份

    /// 0 ~ 1 的进度，表示从“起点侧”到“终点侧”的完成度
    private var _progress: CGFloat = 0
    private var progress: CGFloat {
        get { _progress }
        set {
            let v = min(max(newValue, 0), 1)
            guard v != _progress else { return }
            _progress = v
            updateLayoutForProgress(animated: false)
        }
    }
    private var thumbLeadingConstraint: Constraint?
    /// 背景轨道（灰色圆角条）
    private lazy var trackView: UIView = {
        UIView()
            .byBgColor(.systemGray5)
            .byCornerRadius(28)
            .byMasksToBounds(YES)
            .byAddTo(self) { [unowned self] make in
                make.edges.equalToSuperview()
            }
    }()
    /// 轨道内部的“骨架屏效果”闪动条（覆盖整个父视图）
    private lazy var shimmerView: UIView = { [unowned self] in
        UIView()
            .byShimmerColors(
                base: UIColor.systemGray5,                 // 与轨道底色一致
                highlight: UIColor.white.withAlphaComponent(0.9)
            )
            .byAddTo(trackView) { make in
                make.edges.equalToSuperview()   // 全覆盖，无缝隙
            }
    }()
    /// 中间文字：“滑动以解锁”
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("滑动以解锁")
            .byTextColor(.darkGray)
            .byFont(.systemFont(ofSize: 16, weight: .medium))
            .byTextAlignment(.center)
            .byAddTo(self) { [unowned self] make in
                make.edges.equalToSuperview().inset(16)
            }
    }()
    /// 滑块视图
    private lazy var thumbView: UIView = { [unowned self] in
        UIView()
            .byBgColor(.white)
            .byCornerRadius(thumbSize.height / 2)
            .byMasksToBounds(YES)
            .byShadowOpacity(0.15)
            .byShadowColor(.black)
            .byShadowRadius(4)
            .byShadowOffset(CGSize(width: 0, height: 2))
            .jobs_addGestureRetView(
                UIPanGestureRecognizer
                    .byConfig { [weak self] gr in
                        guard let self = self,
                              let pan = gr as? UIPanGestureRecognizer,
                              let container = gr.view?.superview
                        else { return }

                        let translation = pan.translation(in: container)
                        let dragWidth = max(
                            container.bounds.width - self.thumbInset * 2 - self.thumbSize.width,
                            1
                        )

                        switch pan.state {
                        case .began:
                            self.panStartProgress = self.progress
                        case .changed:
                            let rawDelta = translation.x / dragWidth
                            let delta: CGFloat
                            switch self.direction {
                            case .leftToRight:
                                delta = rawDelta
                            case .rightToLeft:
                                delta = -rawDelta
                            }

                            self.progress = self.panStartProgress + delta
                            self.layoutIfNeeded()
                            self.updateShimmerMask()

                        case .ended, .cancelled, .failed:
                            if self.progress > 0.85 {
                                self.completeUnlock()
                            } else {
                                self.reset(animated: true)
                            }

                        default:
                            break
                        }
                    }
                    .byMinTouches(1)
                    .byMaxTouches(2)
                    .byCancelsTouchesInView(true)
            )
            .byAddTo(self) { [unowned self] make in
                make.centerY.equalToSuperview()
                make.size.equalTo(thumbSize)
                self.thumbLeadingConstraint = make.leading.equalToSuperview()
                    .offset(self.thumbInset)
                    .constraint
            }
    }()

    private lazy var arrow: UIImageView = { [unowned self] in
        UIImageView()
            .byTintColor(.systemBlue)
            .byAddTo(thumbView) { [unowned self] make in
                make.center.equalToSuperview()
            }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        trackView.byVisible(YES)
        shimmerView.byVisible(YES)
        titleLabel.byVisible(YES)
        thumbView.byVisible(YES)
        arrow.byVisible(YES)

        updateDirectionUI()
        updateSkeletonState()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayoutForProgress(animated: false)
        updateShimmerMask()
    }

    private func updateDirectionUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let symbolName: String
        switch direction {
        case .leftToRight:
            symbolName = "chevron.right"
        case .rightToLeft:
            symbolName = "chevron.left"
        }
        arrow.byImage(symbolName.sysImg(config))
    }

    private func updateLayoutForProgress(animated: Bool) {
        guard bounds.width > 0 else { return }

        let maxOffset = bounds.width - thumbInset - thumbSize.width

        let positionFactor: CGFloat
        switch direction {
        case .leftToRight:
            positionFactor = _progress
        case .rightToLeft:
            positionFactor = 1 - _progress
        }

        let offset = thumbInset + maxOffset * positionFactor
        thumbLeadingConstraint?.update(offset: offset)

        titleLabel.alpha = 1 - _progress * 0.8

        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
                self.updateShimmerMask()
            })
        }
    }

    private func updateSkeletonState() {
        shimmerView.jobs_isShimmering = isSkeletonEnabled
        shimmerView.isHidden = !isSkeletonEnabled
        updateShimmerMask()
    }

    /// 用遮罩让“滑块经过的区域”不再有呼吸屏效果
    /// 左->右：从“圆心”开始右侧有呼吸屏
    /// 右->左：到“圆心”为止左侧有呼吸屏
    private func updateShimmerMask() {
        guard isSkeletonEnabled else {
            shimmerView.layer.mask = nil
            return
        }

        layoutIfNeeded()

        let trackBounds = trackView.bounds
        guard trackBounds.width > 0, trackBounds.height > 0 else {
            shimmerView.layer.mask = nil
            return
        }

        let thumbFrameInTrack = trackView.convert(thumbView.frame, from: self)
        let maskRect: CGRect

        switch direction {
        case .leftToRight:
            // 左->右：分界线在圆心位置，右侧保留呼吸屏
            var startX = thumbFrameInTrack.midX        // 圆心
            startX = min(max(startX, 0), trackBounds.width)
            let width = max(trackBounds.width - startX, 0)
            guard width > 0 else {
                shimmerView.layer.mask = nil
                return
            };maskRect = CGRect(x: startX, y: 0, width: width, height: trackBounds.height)

        case .rightToLeft:
            // 右->左：分界线在圆心位置，左侧保留呼吸屏
            var endX = thumbFrameInTrack.midX          // 圆心
            endX = min(max(endX, 0), trackBounds.width)
            let width = max(endX, 0)
            guard width > 0 else {
                shimmerView.layer.mask = nil
                return
            };maskRect = CGRect(x: 0, y: 0, width: width, height: trackBounds.height)
        }
        // 纯矩形遮罩，靠近滑块是笔直的直角边
        let path = UIBezierPath(rect: maskRect)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = shimmerView.bounds
        maskLayer.path  = path.cgPath
        shimmerView.layer.mask = maskLayer
    }

    private func completeUnlock() {
        progress = 1
        updateLayoutForProgress(animated: true)
        onUnlock?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.reset(animated: true)
        }
    }

    func reset(animated: Bool) {
        progress = 0
        updateLayoutForProgress(animated: animated)
    }
}

extension SlideToUnlockView {

    @discardableResult
    func byOnUnlock(_ handler: @escaping jobsByVoidBlock) -> Self {
        self.onUnlock = handler
        return self
    }

    @discardableResult
    func byDirection(_ direction: Direction) -> Self {
        self.direction = direction
        return self
    }

    @discardableResult
    func bySkeletonEnabled(_ enabled: Bool) -> Self {
        self.isSkeletonEnabled = enabled
        return self
    }
}
