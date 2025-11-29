//
//  苹果滑动开锁.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/29/25.
//

import UIKit
import SnapKit

final class SlideToUnlockView: UIView {
    /// 滑到最右侧时回调（只在成功滑到头时调用）
    var onUnlock: (() -> Void)?
    // MARK: - 配置
    private let thumbInset: CGFloat = 4          // 滑块距离左右的内边距
    private let thumbSize = CGSize(width: 52, height: 52)
    private var panStartProgress: CGFloat = 0    // 手势开始时的进度备份
    /// 0 ~ 1 的进度，映射到滑块位置
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
            .byText("滑动以解锁")
            .byTextColor(.darkGray)
            .byFont(.systemFont(ofSize: 16, weight: .medium))
            .byTextAlignment(.center)
            .byAddTo(self) { [unowned self] make in
                make.edges.equalToSuperview().inset(16)
            }
    }()

    private lazy var arrow: UIImageView = { [unowned self] in
        UIImageView()
            .byTintColor(.systemBlue)
            .byImage("chevron.right".sysImg(UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)))
            .byAddTo(thumbView) { [unowned self] make in
                make.center.equalToSuperview()
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
                            // 记录开始时的进度
                            self.panStartProgress = self.progress

                        case .changed:
                            // 根据拖动距离更新进度
                            let delta = translation.x / dragWidth
                            self.progress = self.panStartProgress + delta
                            // 让 UI 立即跟手
                            self.layoutIfNeeded()

                        case .ended, .cancelled, .failed:
                            // 超过 85% 认为解锁成功
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
                /// 记录 leading 约束，后面根据 progress 动态更新
                self.thumbLeadingConstraint = make.leading.equalToSuperview()
                    .offset(self.thumbInset)
                    .constraint
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
        titleLabel.byVisible(YES)
        thumbView.byVisible(YES)
        arrow.byVisible(YES)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 尺寸变化时，让滑块位置跟 progress 对齐
        updateLayoutForProgress(animated: false)
    }
    /// 进度 -> 布局
    private func updateLayoutForProgress(animated: Bool) {
        guard bounds.width > 0 else { return }
        /// 滑块可移动的最大距离（leading）
        let maxOffset = bounds.width - thumbInset - thumbSize.width
        let offset = thumbInset + maxOffset * _progress
        thumbLeadingConstraint?.update(offset: offset)
        titleLabel.alpha = 1 - _progress * 0.8
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }
    /// 状态切换
    private func completeUnlock() {
        /// 动画滑到最右边
        progress = 1
        updateLayoutForProgress(animated: true)
        /// 只在真正“滑到头”时触发回调
        onUnlock?()
        /// 如果你希望控件可以重复使用，稍等一下再自动复位
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.reset(animated: true)
        }
    }
    /// 复位到最左侧
    func reset(animated: Bool) {
        progress = 0
        updateLayoutForProgress(animated: animated)
    }
}

extension SlideToUnlockView {
    /// DSL：配置解锁回调
    @discardableResult
    func byOnUnlock(_ handler: @escaping () -> Void) -> Self {
        self.onUnlock = handler
        return self
    }
}
