//
//  苹果滑动开锁.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/29/25.
//

import UIKit
import SnapKit

final class SlideToUnlockView: UIView {
    // MARK: - 方向
    enum Direction {
        case leftToRight   // 默认：从左往右
            // 解锁进度 0 -> 1 ：从左到右
        case rightToLeft   // 可选：从右往左
            // 解锁进度 0 -> 1 ：从右到左
    }
    /// 滑到终点时回调（只在成功解锁时调用）
    var onUnlock: (() -> Void)?
    /// 解锁方向（默认从左往右）
    var direction: Direction = .leftToRight {
        didSet {
            updateDirectionUI()
            setNeedsLayout()
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
    /// 背景轨道
    private lazy var trackView: UIView = {
        UIView()
            .byBgColor(.systemGray5)
            .byCornerRadius(28)
            .byMasksToBounds(YES)
            .byAddTo(self) { [unowned self] make in
                make.edges.equalToSuperview()
            }
    }()
    /// 中间文字：“滑动以解锁”
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("滑动以解锁".tr)
            .byTextColor(.darkGray)
            .byFont(.systemFont(ofSize: 16, weight: .medium))
            .byTextAlignment(.center)
            .byAddTo(self) { [unowned self] make in
                make.edges.equalToSuperview().inset(16)
            }
    }()

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
                            // 记录开始时的进度
                            self.panStartProgress = self.progress

                        case .changed:
                            // 根据拖动距离更新进度
                            // 左->右：translation.x 正；右->左：translation.x 负
                            // 对于 rightToLeft，我们反向取值，让“向左拖”依然让 progress 增加
                            let rawDelta = translation.x / dragWidth
                            let delta: CGFloat
                            switch self.direction {
                            case .leftToRight:
                                delta = rawDelta
                            case .rightToLeft:
                                delta = -rawDelta
                            }

                            self.progress = self.panStartProgress + delta
                            // 让 UI 立即跟手
                            self.layoutIfNeeded()

                        case .ended, .cancelled, .failed:
                            // 超过 85% 认为解锁成功（与方向无关，只看完成度）
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
                /// 记录 leading 约束，后面根据 progress + 方向 动态更新
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
    // MARK: - Init
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
        titleLabel.byVisible(YES)
        thumbView.byVisible(YES)
        arrow.byVisible(YES)
        updateDirectionUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 尺寸变化时，让滑块位置跟 progress + 方向 对齐
        updateLayoutForProgress(animated: false)
    }
    // MARK: - UI & 布局
    /// 根据方向更新箭头等视觉
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
    /// 进度 -> 布局
    private func updateLayoutForProgress(animated: Bool) {
        guard bounds.width > 0 else { return }
        /// 滑块可移动的最大距离（leading）
        let maxOffset = bounds.width - thumbInset - thumbSize.width
        // leftToRight:
        //   progress = 0 -> 左侧；1 -> 右侧
        // rightToLeft:
        //   progress = 0 -> 右侧；1 -> 左侧
        let positionFactor: CGFloat
        switch direction {
        case .leftToRight:
            positionFactor = _progress
        case .rightToLeft:
            positionFactor = 1 - _progress
        }

        let offset = thumbInset + maxOffset * positionFactor
        thumbLeadingConstraint?.update(offset: offset)
        // 文本透明度只和完成度有关，方向无关
        titleLabel.alpha = 1 - _progress * 0.8
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }
    // MARK: - 状态切换
    private func completeUnlock() {
        /// 动画滑到终点（不同方向下终点不一样，但 progress 统一为 1）
        progress = 1
        updateLayoutForProgress(animated: true)
        /// 只在真正“滑到头”时触发回调
        onUnlock?()
        /// 如果你希望控件可以重复使用，稍等一下再自动复位
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.reset(animated: true)
        }
    }
    /// 复位到起点一侧
    func reset(animated: Bool) {
        progress = 0
        updateLayoutForProgress(animated: animated)
    }
}
// MARK: - DSL
extension SlideToUnlockView {
    /// DSL：配置解锁回调
    @discardableResult
    func byOnUnlock(_ handler: @escaping () -> Void) -> Self {
        self.onUnlock = handler
        return self
    }

    /// DSL：配置方向（默认 .leftToRight）
    @discardableResult
    func byDirection(_ direction: Direction) -> Self {
        self.direction = direction
        return self
    }
}
