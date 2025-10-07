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
        if #available(iOS 15.0, *), var cfg = self.configuration {
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
    // 统一：在 configuration 模式也能生效
    @discardableResult
    func byTitleFont(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        if #available(iOS 15.0, *), self.configuration != nil {
            var cfg = self.configuration ?? .filled()
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var attrs = incoming
                attrs.font = font
                return attrs
            }
            self.configuration = cfg
        }
        return self
    }

    @discardableResult
    func byTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        if #available(iOS 15.0, *), var cfg = self.configuration {
            if state == .normal {
                cfg.baseForegroundColor = color
                self.configuration = cfg
            }
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
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
}
// MARK: - 进阶：按 state 的链式代理
extension UIButton {
    /// 按 state 的链式代理（class + 强引用，安全）
    final class StateProxy {
        fileprivate let button: UIButton
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
        /// 背景色（state 级）：iOS15+ normal 走 configuration，其它/低版本用 1×1 背景图兜底
        @discardableResult
        func backgroundColor(_ color: UIColor) -> UIButton {
            if #available(iOS 15.0, *), state == .normal {
                var cfg = button.configuration ?? .filled()
                cfg.baseBackgroundColor = color
                // 同时填充 UIBackgroundConfiguration，兼容定制皮肤
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
        // 可选：副标题的 state 级链式（无富文本版）
        @discardableResult
        func subTitle(_ text: String?) -> UIButton { button.bySubTitle(text, for: state) }
        @discardableResult
        func subTitleFont(_ font: UIFont) -> UIButton { button.bySubTitleFont(font, for: state) }
        @discardableResult
        func subTitleColor(_ color: UIColor) -> UIButton { button.bySubTitleColor(color, for: state) }
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
            var cfg = self.configuration ?? .filled()
            cfg.baseBackgroundColor = color
            var bg = cfg.background
            bg.backgroundColor = color
            cfg.background = bg
            // 同步 title / 颜色，避免只见底色不见字
            if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
            if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
            self.configuration = cfg
        } else {
            self.setBgCor(color, forState: state) // 低版本兜底
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
            var cfg = configuration ?? .filled()
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
            var cfg = configuration ?? .filled()
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
            var cfg = configuration ?? .filled()
            cfg.imagePadding = (insets.left + insets.right) / 2
            configuration = cfg
        } else {
            self.imageEdgeInsets = insets
        }
        return self
    }
    // MARK: iOS15+ 建议用 contentInsets/副标题；旧版保留 titleEdgeInsets
    @discardableResult
    func byTitleEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
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
            var cfg = configuration ?? .filled()
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
        var cfg = configuration ?? .filled()
        mutate(&cfg)
        configuration = cfg
        return self
    }
}
// MARK: - Subtitle：无富文本版（iOS15+ 用 subtitle + transformer；iOS14- 两行字符串降级）
private struct _JobsSubPackNoAttr {
    var text: String = ""
    var font: UIFont?
    var color: UIColor?
}
private var _jobsSubDictKey_noAttr: UInt8 = 0
private var _jobsSubtitleHandlerInstalledKey: UInt8 = 0

private extension UIControl.State {
    var raw: UInt { rawValue }
}

private extension UIButton {
    // 每个按钮维护一份：stateRawValue -> SubPack
    var _subDict_noAttr: [UInt: _JobsSubPackNoAttr] {
        get { (objc_getAssociatedObject(self, &_jobsSubDictKey_noAttr) as? [UInt: _JobsSubPackNoAttr]) ?? [:] }
        set { objc_setAssociatedObject(self, &_jobsSubDictKey_noAttr, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _subPack_noAttr(for state: UIControl.State, create: Bool = true) -> _JobsSubPackNoAttr {
        var d = _subDict_noAttr
        if let p = d[state.raw] { return p }
        if create {
            let p = _JobsSubPackNoAttr()
            d[state.raw] = p
            _subDict_noAttr = d
            return p
        }
        return _JobsSubPackNoAttr()
    }

    func _setSubPack_noAttr(_ p: _JobsSubPackNoAttr, for state: UIControl.State) {
        var d = _subDict_noAttr; d[state.raw] = p; _subDict_noAttr = d
        _ensureSubtitleHandler_noAttrInstalled()
        if #available(iOS 15.0, *) { setNeedsUpdateConfiguration() }
    }
    // iOS 15+：把当前 state 的 pack 写进 configuration（不使用富文本）
    func _ensureSubtitleHandler_noAttrInstalled() {
        guard #available(iOS 15.0, *) else { return }
        if (objc_getAssociatedObject(self, &_jobsSubtitleHandlerInstalledKey) as? Bool) == true { return }
        objc_setAssociatedObject(self, &_jobsSubtitleHandlerInstalledKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let existing = self.configurationUpdateHandler
        self.automaticallyUpdatesConfiguration = true
        self.configurationUpdateHandler = { [weak self] btn in
            existing?(btn)
            guard let self = self else { return }

            let st = btn.state
            let pack = self._subDict_noAttr[st.raw] ?? self._subDict_noAttr[UIControl.State.normal.rawValue]

            var cfg = btn.configuration ?? .filled()

            // 确保 title 已同步（有 title 更稳定地布局 subtitle）
            if cfg.title == nil,
               let t = btn.title(for: .normal),
               !t.isEmpty {
                cfg.title = t
            }
            cfg.titleAlignment = .center

            // 写入/清空 subtitle（String 版）
            let t = pack?.text ?? ""
            cfg.subtitle = t.isEmpty ? nil : t

            // 用 transformer 赋 font/color（仍然不是富文本）
            let f = pack?.font
            let c = pack?.color
            cfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var a = incoming
                if let f { a.font = f }
                if let c { a.foregroundColor = c }
                return a
            }
            btn.configuration = cfg
        }
    }
    // iOS14-：把某个 state 的主标题 + 副标题拼两行（纯字符串）
    func _legacy_applySubtitle_noAttr(text: String?, for state: UIControl.State) {
        let titleText = self.title(for: state)
            ?? self.attributedTitle(for: state)?.string
            ?? self.title(for: .normal)
            ?? self.attributedTitle(for: .normal)?.string
            ?? ""
        let full = text.map { titleText.isEmpty ? $0 : "\(titleText)\n\($0)" } ?? titleText
        setTitle(full, for: state)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
    }
}

public extension UIButton {
    /// 设置副标题（String），支持 per-state。iOS15+ 走 configuration.subtitle；iOS14- 拼两行字符串。
    @discardableResult
    func bySubTitle(_ text: String?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.text = text ?? ""; _setSubPack_noAttr(p, for: state)
            if self.state == state || state == .normal { setNeedsUpdateConfiguration() }
        } else {
            _legacy_applySubtitle_noAttr(text: text, for: state)
        }
        return self
    }
    /// 设置副标题字体（per-state，iOS15+ 有效）
    @discardableResult
    func bySubTitleFont(_ font: UIFont, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.font = font; _setSubPack_noAttr(p, for: state)
        } else {
            // iOS14-：纯字符串方案，无法只改副标题字体
        }
        return self
    }
    /// 设置副标题颜色（per-state，iOS15+ 有效）
    @discardableResult
    func bySubTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.color = color; _setSubPack_noAttr(p, for: state)
        } else {
            // iOS14-：纯字符串方案，无法只改副标题颜色
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
// MARK: - 闭包回调（低版本兜底）
private var actionKey: Void?
extension UIButton {
    func jobs_addTapClosure(_ action: @escaping (UIButton) -> Void) -> Self {
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
// MARK: - 点按事件统一入口 + 的别名
extension UIButton {
    /// iOS14+ 使用 UIAction；低版本回退到 addAction(_:)
    @discardableResult
    func onTap(_ handler: @escaping (UIButton) -> Void) -> Self {
        if #available(iOS 14.0, *) {
            (self as UIControl).addAction(UIAction { [weak self] _ in
                guard let s = self else { return }
                handler(s)
            }, for: .touchUpInside)
        } else {
            _ = self.jobs_addTapClosure(handler)
        }
        return self
    }
    // MARK: 长按事件（所有版本可用）
    @discardableResult
    func onLongPress(minimumPressDuration: TimeInterval = 0.5,
                     _ handler: @escaping (UIButton, UILongPressGestureRecognizer) -> Void) -> Self {
        let gr = UILongPressGestureRecognizer(target: nil, action: nil)
        gr.minimumPressDuration = minimumPressDuration

        class _GRSleeve<T: UIGestureRecognizer> {
            let closure: (T) -> Void
            init(_ c: @escaping (T) -> Void) { closure = c }
            @objc func invoke(_ g: UIGestureRecognizer) { if let gg = g as? T { closure(gg) } }
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
        var cfg = self.configuration ?? .filled()
        if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
        if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
        self.configuration = cfg
        self.automaticallyUpdatesConfiguration = true
        return self
    }
}
// MARK: - Configuration 快速编辑（可选保留）
@available(iOS 15.0, *)
public extension UIButton {
    @discardableResult
    func cfg(_ edit: (inout UIButton.Configuration) -> Void) -> Self {
        var c = self.configuration ?? .filled()
        edit(&c)
        self.configuration = c
        return self
    }

    @discardableResult
    func cfgTitle(_ title: String?) -> Self {
        cfg { c in
            c.attributedTitle = nil
            c.title = title
        }
    }

    @discardableResult
    func cfgTitleColor(_ color: UIColor) -> Self {
        cfg { $0.baseForegroundColor = color }
    }

    @discardableResult
    func cfgBackground(_ color: UIColor) -> Self { cfg { $0.baseBackgroundColor = color } }

    @discardableResult
    func cfgCorner(_ style: UIButton.Configuration.CornerStyle) -> Self { cfg { $0.cornerStyle = style } }

    @discardableResult
    func cfgInsets(_ insets: NSDirectionalEdgeInsets) -> Self { cfg { $0.contentInsets = insets } }

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
// MARK: - 关联属性：当前倒计时秒数（保留）
private var _jobsSecKey: Void?
public extension UIButton {
    var jobs_sec: Int {
        get { (objc_getAssociatedObject(self, &_jobsSecKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &_jobsSecKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
// MARK: - UIButton · 富文本：主标题 & 副标题（一个入参）
public extension UIButton {
    /// 主标题富文本（NSAttributedString）
    @discardableResult
    func byRichTitle(_ rich: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            cfg.attributedTitle = rich.map { AttributedString($0) }
            self.configuration = cfg
        } else {
            _setLegacyRichTitle(rich, for: state); _applyLegacyComposite(for: state)
        }
        return self
    }
    /// 副标题富文本（NSAttributedString）
    @discardableResult
    func byRichSubTitle(_ rich: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            // iOS 15+ 的 subtitle 也支持 AttributedString
            cfg.attributedSubtitle = rich.map { AttributedString($0) }
            self.configuration = cfg
        } else {
            _setLegacyRichSubTitle(rich, for: state); _applyLegacyComposite(for: state)
        }
        return self
    }
}
// MARK: - iOS 15- 兼容：用换行把 主/副 合成一份 attributedTitle
private var _richTitleKey: UInt8 = 0
private var _richSubKey:   UInt8 = 0
private extension UIButton {
    typealias StateRaw = UInt

    var _legacyRichTitleMap: [StateRaw: NSAttributedString] {
        get { objc_getAssociatedObject(self, &_richTitleKey) as? [StateRaw: NSAttributedString] ?? [:] }
        set { objc_setAssociatedObject(self, &_richTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var _legacyRichSubMap: [StateRaw: NSAttributedString] {
        get { objc_getAssociatedObject(self, &_richSubKey) as? [StateRaw: NSAttributedString] ?? [:] }
        set { objc_setAssociatedObject(self, &_richSubKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _setLegacyRichTitle(_ rich: NSAttributedString?, for state: UIControl.State) {
        var m = _legacyRichTitleMap
        let k = state.rawValue
        if let r = rich { m[k] = r } else { m.removeValue(forKey: k) }
        _legacyRichTitleMap = m
    }
    func _setLegacyRichSubTitle(_ rich: NSAttributedString?, for state: UIControl.State) {
        var m = _legacyRichSubMap
        let k = state.rawValue
        if let r = rich { m[k] = r } else { m.removeValue(forKey: k) }
        _legacyRichSubMap = m
    }

    func _applyLegacyComposite(for state: UIControl.State) {
        let k = state.rawValue
        let title = _legacyRichTitleMap[k]
        let sub   = _legacyRichSubMap[k]

        switch (title, sub) {
        case (nil, nil):
            setAttributedTitle(nil, for: state)
        case let (t?, nil):
            setAttributedTitle(t, for: state)
        case let (nil, s?):
            setAttributedTitle(s, for: state)
        case let (t?, s?):
            titleLabel?.byNumberOfLines(0)
                .byTextAlignment(.center)
            byAttributedTitle(NSMutableAttributedString()
                .add(t)
                .add("\n".rich)
                .add(s), for: state)
        }
    }
}
// MARK: - 倒计时事件（统一 JobsTimer 协议版）
private var _jobsCountdownTickKey: UInt8 = 0
private var _jobsCountdownFinishKey: UInt8 = 0
private var _jobsCountdownTimerCoreKey: UInt8 = 0
public extension UIButton {
    @discardableResult
    func onJobsCountdownTick(_ block: @escaping (_ remain: Int, _ total: Int) -> Void) -> Self {
        objc_setAssociatedObject(self, &_jobsCountdownTickKey, block, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onJobsCountdownFinish(_ block: @escaping () -> Void) -> Self {
        objc_setAssociatedObject(self, &_jobsCountdownFinishKey, block, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func startJobsCountdown(total: Int,
                            interval: TimeInterval = 1.0,
                            kind: JobsTimerKind = .gcd) -> Self {
        stopJobsCountdown()
        guard total > 0 else { return self }

        isEnabled = false
        var remain = total
        setTitle("\(remain)s", for: .normal)

        let cfg = JobsTimerConfig(interval: interval, repeats: true, tolerance: 0.01, queue: .main)
        let timer = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            remain -= 1
            if remain > 0 {
                self.setTitle("\(remain)s", for: .normal)

                // 简版 tick（原有的）
                if let tick = objc_getAssociatedObject(self, &_jobsCountdownTickKey) as? (Int, Int) -> Void {
                    tick(remain, total)
                }
                // ✅ 新增：带内核的 tick
                if let ex = objc_getAssociatedObject(self, &_jobsCountdownTickExKey)
                    as? (UIButton, Int, Int, JobsTimerKind) -> Void {
                    ex(self, remain, total, kind)
                }
            } else {
                // ✅ 新增：带内核的完成回调（放在 stop 前，避免 stop 清理后拿不到 self 状态）
                if let ex = objc_getAssociatedObject(self, &_jobsCountdownFinishExKey)
                    as? (UIButton, JobsTimerKind) -> Void {
                    ex(self, kind)
                }
                // 触发的收尾逻辑（会调用简版 finish 回调、复原按钮等）
                self.stopJobsCountdown(triggerFinish: true)
            }
        }

        objc_setAssociatedObject(self, &_jobsCountdownTimerCoreKey, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        timer.start()
        return self
    }

    @discardableResult
    func stopJobsCountdown(triggerFinish: Bool = false) -> Self {
        if let t = objc_getAssociatedObject(self, &_jobsCountdownTimerCoreKey) as? JobsTimerProtocol {
            t.stop()
        }
        objc_setAssociatedObject(self, &_jobsCountdownTimerCoreKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        isEnabled = true
        setTitle("重新获取", for: .normal)

        if triggerFinish,
           let fin = objc_getAssociatedObject(self, &_jobsCountdownFinishKey) as? () -> Void {
            fin()
        }
        return self
    }
}
// MARK: - 倒计时 · 事件回调（带内核）
private var _jobsCountdownTickExKey: UInt8 = 0
private var _jobsCountdownFinishExKey: UInt8 = 0

public extension UIButton {
    /// 带按钮 & 内核信息的 tick 回调（与 onTap 同级）
    @discardableResult
    func onCountdownTick(_ handler: @escaping (_ button: UIButton,
                                                   _ remain: Int,
                                                   _ total: Int,
                                                   _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_jobsCountdownTickExKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    /// 带按钮 & 内核信息的完成回调（与 onTap 同级）
    @discardableResult
    func onCountdownFinish(_ handler: @escaping (_ button: UIButton,
                                                     _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_jobsCountdownFinishExKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
}
