//
//  UIButton+Jobs.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.

//  说明（本版仅“计时器”相关做了统一改造，UI 链式等其余原样保留）：
//  -----------------------------------------------------------------------------
//  - 外部只需一个“是否传 total”的参数差异，即可决定【正计时】（不传）或【倒计时】（传）。
//  - 计时器实例统一挂在按钮上：`button.timer`（不再使用 jobsTimer）。
//  - 统一链式事件（与 onTap 同级）：
//      `onTimerTick { btn, current, total?, kind in ... }`
//      `onTimerFinish { btn, kind in ... }`
//    语义化别名（倒计时专用）：`onCountdownTick` / `onCountdownFinish`。
//  - 统一控制 API：
//      `startTimer(total: Int? = nil, interval: TimeInterval = 1.0, kind: JobsTimerKind = .gcd)`
//      `pauseTimer()` / `resumeTimer()` / `fireTimerOnce()` / `stopTimer()`
//    并保留兼容封装：`startJobsTimer(...)` 等（内部转调新 API）。
//  - 内建按钮级状态机：`timerState`（idle / running / paused / stopped），可用
//      `onTimerStateChange { btn, old, new in ... }` 订阅；
//    默认的 UI 变化已内置（想自己接管就设置 onTimerStateChange 覆盖）。
//

#if os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS)
import UIKit
#endif

import Foundation
import ObjectiveC
// MARK: - 基础链式（保留）
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
// MARK: - 进阶：按 state 的链式代理（保留）
extension UIButton {
    final class StateProxy {
        fileprivate let button: UIButton
        let state: UIControl.State

        init(button: UIButton, state: UIControl.State) {
            self.button = button
            self.state = state
        }

        @discardableResult
        func title(_ text: String?) -> UIButton { button.setTitle(text, for: state); return button }
        @discardableResult
        func attributedTitle(_ text: NSAttributedString?) -> UIButton { button.setAttributedTitle(text, for: state); return button }
        @discardableResult
        func titleColor(_ color: UIColor?) -> UIButton { button.setTitleColor(color, for: state); return button }
        @discardableResult
        func titleShadowColor(_ color: UIColor?) -> UIButton { button.setTitleShadowColor(color, for: state); return button }
        @discardableResult
        func image(_ image: UIImage?) -> UIButton { button.setImage(image, for: state); return button }

        @available(iOS 13.0, *)
        @discardableResult
        func preferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?) -> UIButton {
            button.setPreferredSymbolConfiguration(configuration, forImageIn: state); return button
        }

        @discardableResult
        func backgroundColor(_ color: UIColor) -> UIButton {
            if #available(iOS 15.0, *), state == .normal {
                var cfg = button.configuration ?? .filled()
                cfg.baseBackgroundColor = color
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
        func backgroundImage(_ image: UIImage?) -> UIButton { button.setBackgroundImage(image, for: state); return button }

        @discardableResult
        func subTitle(_ text: String?) -> UIButton { button.bySubTitle(text, for: state) }
        @discardableResult
        func subTitleFont(_ font: UIFont) -> UIButton { button.bySubTitleFont(font, for: state) }
        @discardableResult
        func subTitleColor(_ color: UIColor) -> UIButton { button.bySubTitleColor(color, for: state) }
    }

    func `for`(_ state: UIControl.State) -> StateProxy { StateProxy(button: self, state: state) }
}
// MARK: - 布局 / 外观（保留）
extension UIButton {
    @discardableResult
    func byBackgroundColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *), state == .normal {
            var cfg = self.configuration ?? .filled()
            cfg.baseBackgroundColor = color
            var bg = cfg.background
            bg.backgroundColor = color
            cfg.background = bg
            if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty { cfg.title = t }
            if cfg.baseForegroundColor == nil, let tc = self.titleColor(for: .normal) { cfg.baseForegroundColor = tc }
            self.configuration = cfg
        } else {
            self.setBgCor(color, forState: state)
        }
        return self
    }

    @discardableResult
    func byNormalBgColor(_ color: UIColor) -> Self { byBackgroundColor(color, for: .normal) }

    @discardableResult
    func byNumberOfLines(_ lines: Int) -> Self { titleLabel?.numberOfLines = lines; return self }

    @discardableResult
    func byLineBreakMode(_ mode: NSLineBreakMode) -> Self { titleLabel?.lineBreakMode = mode; return self }

    @discardableResult
    func byTitleAlignment(_ alignment: NSTextAlignment) -> Self { titleLabel?.textAlignment = alignment; return self }

    @discardableResult
    func byContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = insets
            configuration = cfg
        } else {
            contentEdgeInsets = UIEdgeInsets(top: insets.top, left: insets.leading, bottom: insets.bottom, right: insets.trailing)
        }
        return self
    }

    @discardableResult
    func byContentEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
            configuration = cfg
        } else {
            self.contentEdgeInsets = insets
        }
        return self
    }

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

    @discardableResult
    func byTitleEdgeInsets(_ insets: UIEdgeInsets) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
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

    @discardableResult
    func byImagePlacement(_ placement: NSDirectionalRectEdge, padding: CGFloat = 8) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = configuration ?? .filled()
            cfg.imagePlacement = placement
            cfg.imagePadding = padding
            configuration = cfg
        } else {
            switch placement {
            case .leading:  semanticContentAttribute = .forceLeftToRight
            case .trailing: semanticContentAttribute = .forceRightToLeft
            case .top, .bottom:
                let inset = padding / 2
                contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            default: break
            }
        }
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byConfiguration(_ mutate: (inout UIButton.Configuration) -> Void) -> Self {
        var cfg = configuration ?? .filled()
        mutate(&cfg)
        configuration = cfg
        return self
    }
}
private extension UIControl.State { var raw: UInt { rawValue } }
// MARK: - Subtitle：无富文本版（保留）
private struct _JobsSubPackNoAttr {
    var text: String = ""
    var font: UIFont?
    var color: UIColor?
}
private var _jobsSubDictKey_noAttr: UInt8 = 0
private var _jobsSubtitleHandlerInstalledKey: UInt8 = 0
private extension UIButton {
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
            if cfg.title == nil, let t = btn.title(for: .normal), !t.isEmpty { cfg.title = t }
            cfg.titleAlignment = .center

            let t = pack?.text ?? ""
            cfg.subtitle = t.isEmpty ? nil : t

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

    @discardableResult
    func bySubTitleFont(_ font: UIFont, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.font = font; _setSubPack_noAttr(p, for: state)
        }
        return self
    }

    @discardableResult
    func bySubTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var p = _subPack_noAttr(for: state); p.color = color; _setSubPack_noAttr(p, for: state)
        }
        return self
    }
}
// MARK: - 交互 / 菜单 / 角色 / Pointer / Configuration 生命周期（保留）
extension UIButton {
    @available(iOS 14.0, *)
    @discardableResult
    func byMenu(_ menu: UIMenu?) -> Self { self.menu = menu; return self }

    @available(iOS 14.0, *)
    @discardableResult
    func byShowsMenuAsPrimaryAction(_ on: Bool) -> Self { self.showsMenuAsPrimaryAction = on; return self }

    @available(iOS 13.4, *)
    @discardableResult
    func byPointerInteractionEnabled(_ on: Bool) -> Self { self.isPointerInteractionEnabled = on; return self }

    @available(iOS 14.0, *)
    @discardableResult
    func byRole(_ role: UIButton.Role) -> Self { self.role = role; return self }

    @available(iOS 16.0, *)
    @discardableResult
    func byPreferredMenuElementOrder(_ order: UIContextMenuConfiguration.ElementOrder) -> Self {
        self.preferredMenuElementOrder = order; return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byChangesSelectionAsPrimaryAction(_ on: Bool) -> Self { self.changesSelectionAsPrimaryAction = on; return self }

    @available(iOS 15.0, *)
    @discardableResult
    func byAutomaticallyUpdatesConfiguration(_ on: Bool) -> Self { self.automaticallyUpdatesConfiguration = on; return self }

    @available(iOS 15.0, *)
    @discardableResult
    func byConfigurationUpdateHandler(_ handler: @escaping UIButton.ConfigurationUpdateHandler) -> Self {
        self.configurationUpdateHandler = handler; return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func bySetNeedsUpdateConfiguration() -> Self { self.setNeedsUpdateConfiguration(); return self }
}
// MARK: - 便捷构造 & 背景色兜底（保留）
extension UIButton {
    public convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, target: AnyObject, action: Selector) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        addTarget(target, action: action, for: .touchUpInside)
    }

    public func setBgCor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }

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
// MARK: - 旋转动画
extension UIButton {
    public static let rotationKey = "jobs.rotation"
    public enum RotationScope { case imageView, wholeButton, layer(CALayer) }

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
// MARK: - 防止快速连点
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
    /// 统一底层实现：存闭包 + 绑定/去重
    @discardableResult
    private func _bindTapClosure(_ action: @escaping (UIButton) -> Void,
                                 for events: UIControl.Event = .touchUpInside) -> Self {
        // 存最新闭包
        objc_setAssociatedObject(self, &actionKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        // 去重（避免多次 addTarget 导致重复触发）
        removeTarget(self, action: #selector(_jobsHandleAction(_:)), for: events)
        addTarget(self, action: #selector(_jobsHandleAction(_:)), for: events)
        return self
    }
    /// 旧接口：jobs_addTapClosure（保留）
    @discardableResult
    func jobs_addTapClosure(_ action: @escaping (UIButton) -> Void,
                            for events: UIControl.Event = .touchUpInside) -> Self {
        _bindTapClosure(action, for: events)
    }
    /// 旧接口：addAction（保留，但建议新代码用 onTap）
    @discardableResult
    func addAction(_ action: @escaping (UIButton) -> Void,
                   for events: UIControl.Event = .touchUpInside) -> Self {
        _bindTapClosure(action, for: events)
    }

    @objc private func _jobsHandleAction(_ sender: UIButton) {
        if let action = objc_getAssociatedObject(self, &actionKey) as? (UIButton) -> Void {
            action(sender)
        }
    }
}
// MARK: - 点按事件统一入口
extension UIButton {
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

    @discardableResult
    func onLongPress(minimumPressDuration: TimeInterval = 0.5,
                     _ handler: @escaping (UIButton, UILongPressGestureRecognizer) -> Void) -> Self {
        let gr = UILongPressGestureRecognizer(target: nil, action: nil)

        class _GRSleeve<T: UIGestureRecognizer> {
            let closure: (T) -> Void
            init(_ c: @escaping (T) -> Void) { closure = c }
            @objc func invoke(_ g: UIGestureRecognizer) { if let gg = g as? T { closure(gg) } }
        }

        gr.minimumPressDuration = minimumPressDuration
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
// MARK: - 把按钮切到 configuration 模式
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
// MARK: - Configuration 快速编辑
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
    func cfgTitle(_ title: String?) -> Self { cfg { c in c.attributedTitle = nil; c.title = title } }

    @discardableResult
    func cfgTitleColor(_ color: UIColor) -> Self { cfg { $0.baseForegroundColor = color } }

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
// MARK: - 关联属性：当前倒计时秒数
private var _jobsSecKey: Void?
public extension UIButton {
    var jobs_sec: Int {
        get { (objc_getAssociatedObject(self, &_jobsSecKey) as? Int) ?? 0 }
        set { objc_setAssociatedObject(self, &_jobsSecKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
// MARK: - UIButton · 富文本
public extension UIButton {
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

    @discardableResult
    func byRichSubTitle(_ rich: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            cfg.attributedSubtitle = rich.map { AttributedString($0) }
            self.configuration = cfg
        } else {
            _setLegacyRichSubTitle(rich, for: state); _applyLegacyComposite(for: state)
        }
        return self
    }
}

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
            titleLabel?.byNumberOfLines(0).byTextAlignment(.center)
            byAttributedTitle(NSMutableAttributedString()
                .add(t)
                .add("\n".rich)
                .add(s), for: state)
        }
    }
}
// MARK: - 统一计时器
// 兼容：JobsTimerKind / JobsTimerConfig / JobsTimerProtocol / JobsTimerFactory
// 内部模式：正计时 / 倒计时
private enum _TimerMode {
    case countUp(elapsed: Int)
    case countdown(remain: Int, total: Int)
}
// 判断是否为倒计时
private extension _TimerMode {
    var isCountdown: Bool {
        if case .countdown = self { return true }
        return false
    }
}
// 事件回调（统一）
private var _timerTickAnyKey: UInt8   = 0   // (UIButton, Int, Int?, JobsTimerKind) -> Void
private var _timerFinishAnyKey: UInt8 = 0   // (UIButton, JobsTimerKind) -> Void
// 兼容：旧的“倒计时专用”简版事件（只给 remain/total）
private var _legacyCountdownTickKey:   UInt8 = 0  // (Int, Int) -> Void
private var _legacyCountdownFinishKey: UInt8 = 0  // () -> Void
// 计时器核心 & 运行元数据
private var _timerCoreKey:  UInt8 = 0  // JobsTimerProtocol
private var _timerKindKey:  UInt8 = 0  // JobsTimerKind
private var _timerModeKey:  UInt8 = 0  // _TimerMode
// 状态机
public enum TimerState { case idle, running, paused, stopped }
private var _timerStateKey: UInt8 = 0
private var _timerStateDidChangeKey: UInt8 = 0
public extension UIButton {
    // MARK: - 对外可取的“内部计时器”
    var timer: JobsTimerProtocol? {
        get { objc_getAssociatedObject(self, &_timerCoreKey) as? JobsTimerProtocol }
        set { objc_setAssociatedObject(self, &_timerCoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    // MARK: - 状态机（带默认 UI）
    var timerState: TimerState {
        get { (objc_getAssociatedObject(self, &_timerStateKey) as? TimerState) ?? .idle }
        set {
            let old = timerState
            objc_setAssociatedObject(self, &_timerStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let hook = objc_getAssociatedObject(self, &_timerStateDidChangeKey) as? (UIButton, TimerState, TimerState) -> Void {
                hook(self, old, newValue)
            } else {
                applyDefaultTimerUI(for: newValue)
            }
            if #available(iOS 15.0, *) { setNeedsUpdateConfiguration() }
        }
    }

    typealias TimerStateChangeHandler = (_ button: UIButton,
                                         _ oldState: TimerState,
                                         _ newState: TimerState) -> Void

    @discardableResult
    func onTimerStateChange(_ handler: @escaping TimerStateChangeHandler) -> Self {
        objc_setAssociatedObject(self, &_timerStateDidChangeKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    private func applyDefaultTimerUI(for state: TimerState) {
        switch state {
        case .idle, .stopped:
            isEnabled = true; alpha = 1.0
        case .running:
            isEnabled = true; alpha = 1.0
        case .paused:
            isEnabled = true; alpha = 0.85
        }
    }
    // MARK: - 与 onTap 同级：统一事件
    @discardableResult
    func onTimerTick(_ handler: @escaping (_ button: UIButton,
                                           _ current: Int,        // 正计时=elapsed；倒计时=remain
                                           _ total: Int?,         // 正计时=nil；倒计时=total
                                           _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_timerTickAnyKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onTimerFinish(_ handler: @escaping (_ button: UIButton,
                                             _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_timerFinishAnyKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
    // 语义化别名（倒计时）
    @discardableResult
    func onCountdownTick(_ handler: @escaping (_ button: UIButton,
                                               _ remain: Int, _ total: Int,
                                               _ kind: JobsTimerKind) -> Void) -> Self {
        return onTimerTick { btn, current, totalOpt, kind in
            if let total = totalOpt { handler(btn, current, total, kind) }
        }
    }

    @discardableResult
    func onCountdownFinish(_ handler: @escaping (_ button: UIButton,
                                                 _ kind: JobsTimerKind) -> Void) -> Self {
        return onTimerFinish(handler)
    }
    // MARK: - 启动（统一：正计时/倒计时）
    @discardableResult
    func startTimer(total: Int? = nil,
                    interval: TimeInterval = 1.0,
                    kind: JobsTimerKind = .gcd) -> Self {
        stopTimer() // 清旧
        // 初始模式 + 初始 UI
        if let total {
            objc_setAssociatedObject(self, &_timerModeKey, _TimerMode.countdown(remain: total, total: total), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            isEnabled = false
            setTitle("\(total)s", for: .normal)
        } else {
            objc_setAssociatedObject(self, &_timerModeKey, _TimerMode.countUp(elapsed: 0), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setTitle("0", for: .normal)
        }
        objc_setAssociatedObject(self, &_timerKindKey, kind, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 构建定时器核心
        let cfg = JobsTimerConfig(interval: interval, repeats: true, tolerance: 0.01, queue: .main)
        let core = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            guard var mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode else { return }
            let k = (objc_getAssociatedObject(self, &_timerKindKey) as? JobsTimerKind) ?? kind

            switch mode {
            case .countUp(let elapsed0):
                let elapsed = elapsed0 + 1
                mode = .countUp(elapsed: elapsed)
                objc_setAssociatedObject(self, &_timerModeKey, mode, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                self.setTitle("\(elapsed)", for: .normal)
                // 主回调
                if let tick = objc_getAssociatedObject(self, &_timerTickAnyKey)
                    as? (UIButton, Int, Int?, JobsTimerKind) -> Void {
                    tick(self, elapsed, nil, k)
                }

            case .countdown(let remain0, let total):
                let remain = remain0 - 1
                if remain > 0 {
                    mode = .countdown(remain: remain, total: total)
                    objc_setAssociatedObject(self, &_timerModeKey, mode, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                    self.setTitle("\(remain)s", for: .normal)
                    // 主回调
                    if let tick = objc_getAssociatedObject(self, &_timerTickAnyKey)
                        as? (UIButton, Int, Int?, JobsTimerKind) -> Void {
                        tick(self, remain, total, k)
                    }
                    // 兼容：旧简版回调
                    if let legacy = objc_getAssociatedObject(self, &_legacyCountdownTickKey) as? (Int, Int) -> Void {
                        legacy(remain, total)
                    }
                } else {
                    // 完成：先发回调，再清理
                    if let fin = objc_getAssociatedObject(self, &_timerFinishAnyKey)
                        as? (UIButton, JobsTimerKind) -> Void {
                        fin(self, k)
                    }
                    if let legacyFin = objc_getAssociatedObject(self, &_legacyCountdownFinishKey) as? () -> Void {
                        legacyFin()
                    }
                    self.stopTimer()
                    self.isEnabled = true
                    self.setTitle("重新获取", for: .normal)
                }
            }
        }
        // 挂载 & 启动
        self.timer = core
        self.timerState = .running
        core.start()
        return self
    }
    // MARK: - 控制
    @discardableResult
    func pauseTimer() -> Self {
        (self.timer)?.pause()
        self.timerState = .paused
        return self
    }

    @discardableResult
    func resumeTimer() -> Self {
        (self.timer)?.resume()
        self.timerState = .running
        return self
    }

    @discardableResult
    func fireTimerOnce() -> Self {
        let mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode
        (self.timer)?.fireOnce()
        self.timerState = .stopped
        if mode?.isCountdown == true {
            self.isEnabled = true
            self.setTitle("重新获取", for: .normal)   // 或者恢复为初始文案 "获取验证码"
        }
        return self
    }

    @discardableResult
    func stopTimer() -> Self {
        let mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode
        if let c = self.timer { c.stop() }
        self.timer = nil
        objc_setAssociatedObject(self, &_timerModeKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.timerState = .stopped
        if mode?.isCountdown == true {
            self.isEnabled = true
            self.setTitle("重新获取", for: .normal)   // 或恢复初始文案 "获取验证码"
        }
        return self
    }
}
// MARK: - 兼容层（可选）：保留旧命名，内部转调新 API
public extension UIButton {
    @discardableResult
    func startJobsTimer(total: Int? = nil,
                        interval: TimeInterval = 1.0,
                        kind: JobsTimerKind = .gcd) -> Self {
        startTimer(total: total, interval: interval, kind: kind)
    }

    @discardableResult
    func pauseJobsTimer() -> Self { pauseTimer() }

    @discardableResult
    func resumeJobsTimer() -> Self { resumeTimer() }

    @discardableResult
    func fireJobsTimerOnce() -> Self { fireTimerOnce() }

    @discardableResult
    func stopJobsTimer() -> Self { stopTimer() }
    // 旧的 “倒计时专用” API —— 仍可用（内部走统一引擎）
    @discardableResult
    func startJobsCountdown(total: Int,
                            interval: TimeInterval = 1.0,
                            kind: JobsTimerKind = .gcd) -> Self {
        startTimer(total: total, interval: interval, kind: kind)
    }

    @discardableResult
    func stopJobsCountdown(triggerFinish: Bool = false) -> Self {
        if triggerFinish {
            // 立即触发 finish（仅用于倒计时语义）
            if let k = objc_getAssociatedObject(self, &_timerKindKey) as? JobsTimerKind,
               let fin = objc_getAssociatedObject(self, &_timerFinishAnyKey) as? (UIButton, JobsTimerKind) -> Void {
                fin(self, k)
            }
            if let legacyFin = objc_getAssociatedObject(self, &_legacyCountdownFinishKey) as? () -> Void {
                legacyFin()
            }
        }
        return stopTimer()
    }
    // 旧事件的注册（仅简版 remain/total）
    @discardableResult
    func onJobsCountdownTick(_ block: @escaping (_ remain: Int, _ total: Int) -> Void) -> Self {
        objc_setAssociatedObject(self, &_legacyCountdownTickKey, block, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onJobsCountdownFinish(_ block: @escaping () -> Void) -> Self {
        objc_setAssociatedObject(self, &_legacyCountdownFinishKey, block, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
}
