//
//  UIButton.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS)
import UIKit
#endif

import ObjectiveC
// MARK: - 基础链式
extension UIButton {
    @discardableResult
    func byTitle(_ title: String?, for state: UIControl.State = .normal) -> Self {
        self.setTitle(title, for: state)
        if #available(iOS 15.0, *), var cfg = self.configuration {   // ✅ 同步到 configuration
            if state == .normal { cfg.title = title }
            self.configuration = cfg
        }
        return self
    }

    @discardableResult
    func byAttributedTitle(_ text: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        self.setAttributedTitle(text, for: state)
        return self
    }

    @discardableResult
    func byTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        if #available(iOS 15.0, *), var cfg = self.configuration {   // ✅ 同步到 configuration
            if state == .normal && cfg.baseForegroundColor == nil {
                cfg.baseForegroundColor = color
            }
            self.configuration = cfg
        }
        return self
    }

    @discardableResult
    func byTitleShadowColor(_ color: UIColor?, for state: UIControl.State = .normal) -> Self {
        self.setTitleShadowColor(color, for: state)
        return self
    }

    @discardableResult
    func byImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setImage(image, for: state)
        return self
    }
    /// SF Symbol 的 per-state 首选配置
    @available(iOS 13.0, *)
    @discardableResult
    func byPreferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?,
                                       forImageIn state: UIControl.State = .normal) -> Self {
        self.setPreferredSymbolConfiguration(configuration, forImageIn: state)
        return self
    }

    @discardableResult
    func byBackgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setBackgroundImage(image, for: state)
        return self
    }

    @discardableResult
    func byTitleFont(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }

    /// ⚠️ iOS 并没有公开的 subtitleLabel，这里转调兼容方法
    @discardableResult
    func bySubtitleFont(_ font: UIFont) -> Self {
        return bySubtitleFontCompat(font)
    }

    @discardableResult
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
}
// MARK: - 进阶：按 state 的链式代理
extension UIButton {
    /// 按 state 的链式代理（class + 强引用，安全不易崩）
    final class StateProxy {
        private let button: UIButton
        let state: UIControl.State

        init(button: UIButton, state: UIControl.State) {
            self.button = button
            self.state = state
        }

        @discardableResult
        func title(_ text: String?) -> UIButton {
            button.setTitle(text, for: state); return button
        }

        @discardableResult
        func attributedTitle(_ text: NSAttributedString?) -> UIButton {
            button.setAttributedTitle(text, for: state); return button
        }

        @discardableResult
        func titleColor(_ color: UIColor?) -> UIButton {
            button.setTitleColor(color, for: state); return button
        }

        @discardableResult
        func titleShadowColor(_ color: UIColor?) -> UIButton {
            button.setTitleShadowColor(color, for: state); return button
        }

        @discardableResult
        func image(_ image: UIImage?) -> UIButton {
            button.setImage(image, for: state); return button
        }

        @available(iOS 13.0, *)
        @discardableResult
        func preferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?) -> UIButton {
            button.setPreferredSymbolConfiguration(configuration, forImageIn: state); return button
        }
        /// 背景色（state 级）：iOS15+ 仅 normal 用 configuration，其它/低版本用 1×1 背景图兜底
        @discardableResult
        func backgroundColor(_ color: UIColor) -> UIButton {
            if #available(iOS 15.0, *), state == .normal {
                var cfg = button.configuration ?? .plain()
                var bg = cfg.background
                bg.backgroundColor = color
                cfg.background = bg
                button.configuration = cfg
            } else {
                button.setBackgroundColor(color, forState: state)
            }
            return button
        }

        @discardableResult
        func backgroundImage(_ image: UIImage?) -> UIButton {
            button.setBackgroundImage(image, for: state); return button
        }
    }
    /// 进入某个 state 的链式代理
    func `for`(_ state: UIControl.State) -> StateProxy {
        StateProxy(button: self, state: state)
    }
}
// MARK: - 布局 / 外观（iOS15+ 走 configuration，旧版兜底）
extension UIButton {
    // MARK: 背景色（按 state）
    @discardableResult
    func byBackgroundColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *), state == .normal {
            var cfg = self.configuration ?? .plain()
            var bg = cfg.background
            bg.backgroundColor = color
            cfg.background = bg
            // 同步 title / 颜色，避免只见底色不见字
            if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty {
                cfg.title = t
            }
            if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) {
                cfg.baseForegroundColor = tc
            }
            self.configuration = cfg
        } else {
            self.setBgCor(color, forState: state) // 你原来的兜底实现
        }
        return self
    }
    /// 便捷别名：大多数情况下只需要 normal
    @discardableResult
    func byNormalBgColor(_ color: UIColor) -> Self {
        return byBackgroundColor(color, for: .normal)
    }

    @discardableResult
    func byNumberOfLines(_ lines: Int) -> Self {
        titleLabel?.numberOfLines = lines; return self
    }

    @discardableResult
    func byLineBreakMode(_ mode: NSLineBreakMode) -> Self {
        titleLabel?.lineBreakMode = mode; return self
    }

    @discardableResult
    func byTitleAlignment(_ alignment: NSTextAlignment) -> Self {
        titleLabel?.textAlignment = alignment; return self
    }
    // MARK: iOS15+ 优先 contentInsets，否则回落到 UIEdgeInsets
    @discardableResult
    func byContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            cfg.contentInsets = insets
            configuration = cfg
        } else {
            contentEdgeInsets = UIEdgeInsets(top: insets.top,
                                             left: insets.leading,
                                             bottom: insets.bottom,
                                             right: insets.trailing)
        }
        return self
    }
    /// 兼容旧签名：UIEdgeInsets -> NSDirectionalEdgeInsets（iOS15+）
    @discardableResult
    func byContentEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top,
                                                        leading: insets.left,
                                                        bottom: insets.bottom,
                                                        trailing: insets.right)
            configuration = cfg
        } else {
            self.contentEdgeInsets = insets
        }
        return self
    }
    // MARK: iOS15+ 推荐用 imagePadding；旧版保留 imageEdgeInsets
    @discardableResult
    func byImageEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            cfg.imagePadding = (insets.left + insets.right) / 2
            configuration = cfg
        } else {
            self.imageEdgeInsets = insets
        }
        return self
    }
    // MARK: iOS15+ 建议用 contentInsets/配置副标题；旧版保留 titleEdgeInsets
    @discardableResult
    func byTitleEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top,
                                                        leading: insets.left,
                                                        bottom: insets.bottom,
                                                        trailing: insets.right)
            configuration = cfg
        } else {
            self.titleEdgeInsets = insets
        }
        return self
    }

    @discardableResult
    func byContentAlignment(horizontal: UIControl.ContentHorizontalAlignment? = nil,
                            vertical: UIControl.ContentVerticalAlignment? = nil) -> Self {
        if let h = horizontal { contentHorizontalAlignment = h }
        if let v = vertical { contentVerticalAlignment = v }
        return self
    }

    @discardableResult
    func byCornerRadius(_ radius: CGFloat, masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = radius
        layer.masksToBounds = masksToBounds
        return self
    }

    @discardableResult
    func byBorder(color: UIColor, width: CGFloat) -> Self {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self
    }

    @discardableResult
    func byShadow(color: UIColor = .black,
                  opacity: Float = 0.15,
                  radius: CGFloat = 6,
                  offset: CGSize = .init(width: 0, height: 2)) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
        return self
    }
    // MARK: 图片与标题的相对位置（iOS15+ 原生；低版本尽力而为）
    @discardableResult
    func byImagePlacement(_ placement: NSDirectionalRectEdge, padding: CGFloat = 8) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            cfg.imagePlacement = placement
            cfg.imagePadding = padding
            configuration = cfg
        } else {
            switch placement {
            case .leading:
                semanticContentAttribute = .forceLeftToRight
            case .trailing:
                semanticContentAttribute = .forceRightToLeft
            case .top, .bottom:
                let inset = padding / 2
                contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            default:
                break
            }
        }
        return self
    }
    // MARK: iOS15+ Configuration mutate 钩子
    @available(iOS 15.0, *)
    @discardableResult
    func byConfiguration(_ mutate: (inout UIButton.Configuration) -> Void) -> Self {
        var cfg = configuration ?? .plain()
        mutate(&cfg)
        configuration = cfg
        return self
    }
}
// MARK: - Subtitle 独立控制（iOS 15+ 用 attributedSubtitle；iOS14- 用两行富文本）
private struct _JobsSubtitleStore {
    var text: String = ""
    var font: UIFont = .systemFont(ofSize: 11, weight: .regular)
    var color: UIColor = UIColor.white.withAlphaComponent(0.85)
}
private var _subtitleStoreKey: UInt8 = 0

private extension UIButton {
    var _subtitleStore: _JobsSubtitleStore {
        get { (objc_getAssociatedObject(self, &_subtitleStoreKey) as? _JobsSubtitleStore) ?? _JobsSubtitleStore() }
        set { objc_setAssociatedObject(self, &_subtitleStoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _rebuildLegacyTwoLine(title: String, titleFont: UIFont, titleColor: UIColor) {
        let sub = _subtitleStore
        let full = NSMutableAttributedString(
            string: title,
            attributes: [.font: titleFont, .foregroundColor: titleColor]
        )
        if !sub.text.isEmpty {
            full.append(NSAttributedString(string: "\n"))
            full.append(NSAttributedString(
                string: sub.text,
                attributes: [.font: sub.font, .foregroundColor: sub.color]
            ))
        }
        setAttributedTitle(full, for: .normal)
        titleLabel?.byNumberOfLines(2).byTextAlignment(.center)
        self.byContentEdgeInsets(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
}

public extension UIButton {
    /// 设置副标题（独立字体&颜色）。不会影响主标题颜色。
    @discardableResult
    func bySubtitle(_ text: String?,
                    color: UIColor? = nil,
                    font: UIFont? = nil) -> Self {
        let subText = text ?? ""
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()

            // ✅ 关键：如果还没启用 configuration.title，就把现有的主标题同步进去
            if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty {
                cfg.title = t
            }

            if subText.isEmpty {
                cfg.attributedSubtitle = nil
                cfg.subtitle = nil
            } else {
                var sub = AttributedString(subText)
                if let font  { sub.font  = font  }
                if let color { sub.foregroundColor = color }   // 只给“副标题”上色
                cfg.attributedSubtitle = sub
                cfg.subtitle = nil
            }
            configuration = cfg
        } else {
            // iOS 14-：两行富文本降级（略，同你现有实现即可）
            // ……保持你原来的 legacy 拼接，两行 NSAttributedString
        }
        return self
    }
    /// 仅修改副标题颜色（不改文字、不改字体）
    @discardableResult
    func bySubtitleColor(_ color: UIColor) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            let current = cfg.attributedSubtitle ?? AttributedString(cfg.subtitle ?? "")
            var mutated = current
            mutated.foregroundColor = color
            cfg.attributedSubtitle = mutated
            cfg.subtitle = nil
            configuration = cfg
        } else {
            var store = _subtitleStore
            store.color = color
            _subtitleStore = store

            let title = self.title(for: .normal) ?? (self.attributedTitle(for: .normal)?.string ?? "")
            let tFont = self.titleLabel?.font ?? .systemFont(ofSize: 16, weight: .semibold)
            let tColor = self.titleColor(for: .normal) ?? .white
            _rebuildLegacyTwoLine(title: title, titleFont: tFont, titleColor: tColor)
        }
        return self
    }
    /// 仅修改副标题字体（不改文字、不改颜色）
    @discardableResult
    func bySubtitleFontCompat(_ font: UIFont) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .plain()
            let current = cfg.attributedSubtitle ?? AttributedString(cfg.subtitle ?? "")
            var mutated = current
            mutated.font = font
            cfg.attributedSubtitle = mutated
            cfg.subtitle = nil
            configuration = cfg
        } else {
            var store = _subtitleStore
            store.font = font
            _subtitleStore = store

            let title = self.title(for: .normal) ?? (self.attributedTitle(for: .normal)?.string ?? "")
            let tFont = self.titleLabel?.font ?? .systemFont(ofSize: 16, weight: .semibold)
            let tColor = self.titleColor(for: .normal) ?? .white
            _rebuildLegacyTwoLine(title: title, titleFont: tFont, titleColor: tColor)
        }
        return self
    }
}
// MARK: - 交互 / 菜单 / 角色 / Pointer / Configuration 生命周期
extension UIButton {
    // MARK: 设置 UIAction 菜单
    @available(iOS 14.0, *)
    @discardableResult
    func byMenu(_ menu: UIMenu?) -> Self {
        self.menu = menu
        return self
    }
    // MARK: 是否把菜单作为主动作（长按/点按直接展示）
    @available(iOS 14.0, *)
    @discardableResult
    func byShowsMenuAsPrimaryAction(_ on: Bool) -> Self {
        self.showsMenuAsPrimaryAction = on
        return self
    }
    // MARK: 指针交互
    @available(iOS 13.4, *)
    @discardableResult
    func byPointerInteractionEnabled(_ on: Bool) -> Self {
        self.isPointerInteractionEnabled = on
        return self
    }
    // MARK: 按钮语义角色（.normal / .cancel / .destructive 等）
    @available(iOS 14.0, *)
    @discardableResult
    func byRole(_ role: UIButton.Role) -> Self {
        self.role = role
        return self
    }
    // MARK: 菜单元素排序策略（iOS16+）
    @available(iOS 16.0, *)
    @discardableResult
    func byPreferredMenuElementOrder(_ order: UIContextMenuConfiguration.ElementOrder) -> Self {
        self.preferredMenuElementOrder = order
        return self
    }
    // MARK: 主动作是否切换 selected（iOS15+）
    @available(iOS 15.0, *)
    @discardableResult
    func byChangesSelectionAsPrimaryAction(_ on: Bool) -> Self {
        self.changesSelectionAsPrimaryAction = on
        return self
    }
    // MARK: 配置自动更新（iOS15+）
    @available(iOS 15.0, *)
    @discardableResult
    func byAutomaticallyUpdatesConfiguration(_ on: Bool) -> Self {
        self.automaticallyUpdatesConfiguration = on
        return self
    }
    // MARK: 配置更新回调（iOS15+）
    @available(iOS 15.0, *)
    @discardableResult
    func byConfigurationUpdateHandler(_ handler: @escaping UIButton.ConfigurationUpdateHandler) -> Self {
        self.configurationUpdateHandler = handler
        return self
    }
    // MARK: 请求更新 configuration（iOS15+）
    @available(iOS 15.0, *)
    @discardableResult
    func bySetNeedsUpdateConfiguration() -> Self {
        self.setNeedsUpdateConfiguration()
        return self
    }
}
// MARK: - 便捷构造 & 背景色兜底（保留）
extension UIButton {
    /// Convenience constructor for UIButton.
    public convenience init(x: CGFloat,
                            y: CGFloat,
                            w: CGFloat,
                            h: CGFloat,
                            target: AnyObject,
                            action: Selector) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        addTarget(target, action: action, for: UIControl.Event.touchUpInside)
    }
    /// Set a background color for the button (用于低版本或非 normal state 兜底).
    public func setBgCor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
    /// iOS15 以下用 1×1 背景图模拟 per-state 背景色
    fileprivate func setBackgroundColor(_ color: UIColor, forState state: UIControl.State) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(img, for: state)
    }
}
// MARK: - 旋转动画（保留）
extension UIButton {
    public static let rotationKey = "jobs.rotation"
    public enum RotationScope {
        case imageView
        case wholeButton
        case layer(CALayer)
    }

    private func targetLayer(for scope: RotationScope) -> CALayer? {
        switch scope {
        case .imageView: return self.imageView?.layer ?? self.layer
        case .wholeButton: return self.layer
        case .layer(let l): return l
        }
    }

    public func isRotating(scope: RotationScope = .imageView,
                           key: String = UIButton.rotationKey) -> Bool {
        guard let tl = targetLayer(for: scope) else { return false }
        return tl.animation(forKey: key) != nil
    }

    @discardableResult
    public func setRotating(_ on: Bool,
                            scope: RotationScope = .imageView,
                            duration: CFTimeInterval = 1.0,
                            repeatCount: Float = .infinity,
                            clockwise: Bool = true,
                            key: String = UIButton.rotationKey,
                            resetTransformOnStop: Bool = true) -> Self {
        guard let tl = targetLayer(for: scope) else { return self }
        if on {
            guard tl.animation(forKey: key) == nil else { return self }
            let anim = CABasicAnimation(keyPath: "transform.rotation")
            let fullTurn = CGFloat.pi * 2 * (clockwise ? 1 : -1)
            anim.fromValue = 0
            anim.toValue = fullTurn
            anim.duration = max(0.001, duration)
            anim.repeatCount = repeatCount
            anim.isCumulative = true
            anim.isRemovedOnCompletion = false
            tl.add(anim, forKey: key)
        } else {
            tl.removeAnimation(forKey: key)
            if resetTransformOnStop {
                switch scope {
                case .imageView: self.imageView?.transform = .identity
                case .wholeButton: self.transform = .identity
                case .layer: break
                }
            }
        }
        return self
    }

    @discardableResult
    public func startRotating(duration: CFTimeInterval = 1.0,
                              scope: RotationScope = .imageView,
                              clockwise: Bool = true,
                              key: String = UIButton.rotationKey) -> Self {
        setRotating(true, scope: scope, duration: duration,
                    repeatCount: .infinity, clockwise: clockwise, key: key)
    }

    @discardableResult
    public func stopRotating(scope: RotationScope = .imageView,
                             key: String = UIButton.rotationKey,
                             resetTransformOnStop: Bool = true) -> Self {
        setRotating(false, scope: scope, duration: 0,
                    repeatCount: 0, clockwise: true,
                    key: key, resetTransformOnStop: resetTransformOnStop)
    }
}
// MARK: - 防止快速连点（保留）
extension UIButton {
    func disableAfterClick(interval: TimeInterval = 1.0) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.isUserInteractionEnabled = true
        }
    }
}
// MARK: - 闭包回调
private var actionKey: Void?
extension UIButton {
    /// 低版本兜底的闭包事件；iOS14+ 请优先使用 onTap（内部优先 UIAction）
    func addAction(_ action: @escaping (UIButton) -> Void) -> Self {
        objc_setAssociatedObject(self, &actionKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(handleAction(_:)), for: .touchUpInside)
        return self
    }

    @objc private func handleAction(_ sender: UIButton) {
        if let action = objc_getAssociatedObject(self, &actionKey) as? (UIButton) -> Void {
            action(sender)
        }
    }
}
// MARK: - 点按事统一入口
extension UIButton {
    // MARK: 点按事件（iOS14+ 使用 UIAction；低版本回退到上面的 addAction(_:)）
    @discardableResult
    func onTap(_ handler: @escaping (UIButton) -> Void) -> Self {
        if #available(iOS 14.0, *) {
            self.addAction(UIAction { [weak self] _ in
                guard let s = self else { return }
                handler(s)
            }, for: .touchUpInside)
        } else {
            _ = self.addAction(handler)
        }
        return self
    }
    // MARK: 长按事件（所有版本可用，使用 UILongPressGestureRecognizer）
    @discardableResult
    func onLongPress(minimumPressDuration: TimeInterval = 0.5,
                     _ handler: @escaping (UIButton, UILongPressGestureRecognizer) -> Void) -> Self {
        let gr = UILongPressGestureRecognizer(target: nil, action: nil)
        gr.minimumPressDuration = minimumPressDuration

        class _GRSleeve<T: UIGestureRecognizer> {
            let closure: (T) -> Void
            init(_ c: @escaping (T) -> Void) { closure = c }
            @objc func invoke(_ gr: UIGestureRecognizer) { if let g = gr as? T { closure(g) } }
        }

        let sleeve = _GRSleeve<UILongPressGestureRecognizer> { [weak self] g in
            guard let self else { return }
            handler(self, g)
        }
        gr.addTarget(sleeve, action: #selector(_GRSleeve<UILongPressGestureRecognizer>.invoke(_:)))
        objc_setAssociatedObject(gr, "[[gr_closure]]", sleeve, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        addGestureRecognizer(gr)
        isUserInteractionEnabled = true
        return self
    }
}
// MARK: - 把按钮切到 configuration 模式（无警告版）
@available(iOS 15.0, *)
public extension UIButton {
    @discardableResult
    func byAdoptConfigurationIfAvailable() -> Self {
        var cfg = self.configuration ?? .plain()
        if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
        if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
        self.configuration = cfg
        self.automaticallyUpdatesConfiguration = false
        return self
    }
}
// MARK: - 禁止再用 setTitle / setTitleColor / titleLabel?.font，全部改用下面这些方法。
@available(iOS 15.0, *)
public extension UIButton {
    /// 统一读取或创建 configuration
    @discardableResult
    func cfg(_ edit: (inout UIButton.Configuration) -> Void) -> Self {
        var c = self.configuration ?? .plain()
        edit(&c)
        self.configuration = c
        return self
    }
    /// 只在 Configuration 管线里设置标题（会清空 attributedTitle 的干扰）
    @discardableResult
    func cfgTitle(_ title: String?) -> Self {
        cfg { c in
            c.attributedTitle = nil
            c.title = title
        }
    }
    /// 标题颜色（旧的 setTitleColor 在 Configuration 下无效）
    @discardableResult
    func cfgTitleColor(_ color: UIColor) -> Self {
        cfg { $0.baseForegroundColor = color }
    }
    /// 背景色、圆角、内边距
    @discardableResult
    func cfgBackground(_ color: UIColor) -> Self { cfg { $0.baseBackgroundColor = color } }

    @discardableResult
    func cfgCorner(_ style: UIButton.Configuration.CornerStyle) -> Self { cfg { $0.cornerStyle = style } }

    @discardableResult
    func cfgInsets(_ insets: NSDirectionalEdgeInsets) -> Self { cfg { $0.contentInsets = insets } }
    /// 字体：只能通过 TextAttributesTransformer 设置
    @discardableResult
    func cfgFont(_ font: UIFont) -> Self {
        cfg { c in
            c.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var attrs = incoming
                attrs.font = font
                return attrs
            }
        }
    }
}
// MARK: - 关联属性：当前倒计时秒数（供 configurationUpdateHandler 拉取）
private var _jobsSecKey: Void?
public extension UIButton {
    /// 保存“当前倒计时剩余秒数”
    var jobs_sec: Int {
        get { (objc_getAssociatedObject(self, &_jobsSecKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &_jobsSecKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
