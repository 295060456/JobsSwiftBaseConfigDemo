//
//  JobsToast.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

import UIKit
import SnapKit

// ================================== Toast ==================================
@MainActor
public final class JobsToast: UIView {

    public typealias Completion = () -> Void

    // ✅ 用 UInt8 做关联 key，避免字符串
    private static var currentToastKey: UInt8 = 0

    // 供懒加载按钮的点按回调占位（由 show(...) 注入）
    private var tapHandler: ((UIButton) -> Void)?

    // ✅ 懒加载按钮，使用给的链式 API
    private lazy var contentButton: UIButton = {
        UIButton(type: .system)
            // 默认占位标题；真正文案在 show(...) 里设置
            .byTitle(" ", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            // 内边距先给个默认；show(...) 会按 config 重新设置
            .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
            // 点按：走统一入口 → 转给 tapHandler
            .onTap { [weak self] sender in
                guard let self else { return }
                self.tapHandler?(sender)
            }
            // 直接加到 Toast 自身上，并用 SnapKit 充满容器
            .byAddTo(self) { make in
                make.edges.equalToSuperview()
            }
    }()

    private var completion: Completion?

    // MARK: - 配置：支持时长、边距、偏移、圆角、背景色等链式
    public struct Config {
        public var duration: TimeInterval = 1.0
        public var bottomOffset: CGFloat = 120
        public var horizontalPadding: CGFloat = 16
        public var verticalPadding: CGFloat = 10
        public var cornerRadius: CGFloat = 10
        public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.85)

        public init() {}

        // MARK: - 链式配置
        @discardableResult
        public func byDuration(_ value: TimeInterval) -> Self {
            var cfg = self
            cfg.duration = value
            return cfg
        }

        @discardableResult
        public func byBottomOffset(_ value: CGFloat) -> Self {
            var cfg = self
            cfg.bottomOffset = value
            return cfg
        }

        @discardableResult
        public func byHorizontalPadding(_ value: CGFloat) -> Self {
            var cfg = self
            cfg.horizontalPadding = value
            return cfg
        }

        @discardableResult
        public func byVerticalPadding(_ value: CGFloat) -> Self {
            var cfg = self
            cfg.verticalPadding = value
            return cfg
        }

        @discardableResult
        public func byCornerRadius(_ value: CGFloat) -> Self {
            var cfg = self
            cfg.cornerRadius = value
            return cfg
        }

        @discardableResult
        public func byBgColor(_ color: UIColor) -> Self {
            var cfg = self
            cfg.backgroundColor = color
            return cfg
        }
    }

    // ================================== API ==================================
    @discardableResult
    public static func show(
        text: String,
        in window: UIWindow? = nil,      // ⚠️ 不用默认参数取 .wd，避免 actor 警告
        config: Config = .init(),
        tap: ((UIButton) -> Void)? = nil,
        completion: Completion? = nil
    ) -> JobsToast {
        let targetWindow = window ?? UIWindow.wd   // 在主线程里安全获取
        removeExistingToast(from: targetWindow)

        let toast = JobsToast()
        toast.completion = completion
        toast.tapHandler = tap

        // 容器外观
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toast.layer.cornerRadius = 10
        toast.layer.masksToBounds = true

        // 触发懒加载并更新内容与内边距
        _ = toast.contentButton
        toast.contentButton
            .byTitle(text, for: .normal)
        toast.contentButton.byContentEdgeInsets(UIEdgeInsets(
            top: config.verticalPadding,
            left: config.horizontalPadding,
            bottom: config.verticalPadding,
            right: config.horizontalPadding
        ))

        // 添加到 window
        targetWindow.addSubview(toast)

        // 位置：底部安全区上方、居中；限制最大宽
        toast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(targetWindow.safeAreaLayoutGuide.snp.bottom).offset(-config.bottomOffset)
            make.width.lessThanOrEqualTo(targetWindow.bounds.width - 40)
        }

        // 动画显示
        toast.alpha = 0
        toast.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            toast.alpha = 1
            toast.transform = .identity
        }

        // 记录（每窗只保留一个）
        objc_setAssociatedObject(targetWindow, &currentToastKey, toast, .OBJC_ASSOCIATION_ASSIGN)

        // 定时消失
        DispatchQueue.main.asyncAfter(deadline: .now() + max(0.15, config.duration)) { [weak toast, weak targetWindow] in
            guard let toast, let targetWindow else { return }
            toast.dismiss(from: targetWindow)
        }

        return toast
    }

    // 主动消失 —— 无参便捷版（MainActor 内部安全取 wd）
    public func dismiss() {
        let targetWindow = UIWindow.wd
        dismiss(from: targetWindow)
    }

    // 主动消失 —— 需要明确传入 window（不提供默认值）
    public func dismiss(from window: UIWindow) {
        guard superview != nil else { return }

        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97).translatedBy(x: 0, y: 6)
        } completion: { [weak self, weak window] _ in
            self?.removeFromSuperview()
            if let window { Self.clearAssociatedToast(from: window) }
            self?.completion?()
        }
    }

    // MARK: - 辅助
    private static func removeExistingToast(from window: UIWindow) {
        if let existing = objc_getAssociatedObject(window, &currentToastKey) as? JobsToast {
            existing.removeFromSuperview()
            clearAssociatedToast(from: window)
        }
    }

    private static func clearAssociatedToast(from window: UIWindow) {
        objc_setAssociatedObject(window, &currentToastKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
}
