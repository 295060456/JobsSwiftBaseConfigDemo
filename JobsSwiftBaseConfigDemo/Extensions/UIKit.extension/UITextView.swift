//
//  UITextView.swift
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
import RxSwift
import RxCocoa
// MARK:  让返回值可继续接 Rx 操作符
public struct TextInputStream: ObservableConvertibleType {
    public typealias Element = String
    fileprivate let source: Observable<String>
    fileprivate let validator: (String) -> Bool
    public func asObservable() -> Observable<String> { source }
    public var isValid: Observable<Bool> { source.map(validator) }
}
// MARK: 🧱 组件模型（UITextView 版）
public struct RxTextViewInput {
    public let text: Observable<String?>
    public let textOrEmpty: Observable<String>
    public let trimmed: Observable<String>

    public let isEditing: Observable<Bool>
    public let didPressDelete: Observable<Void>
    public let didChange: ControlEvent<Void> // 文本变化事件

    public let isValid: Observable<Bool>
    public let formattedBinder: Binder<String>
}
// MARK:
public enum TwoWayInitial {
    case fromRelay   // 默认：用 relay 覆盖 view
    case fromView    // 用 view 的当前值覆盖 relay
}

public extension UITextView {
    /// 通用输入绑定：带格式化 / 校验 / 最大长度 / 去重
    /// 返回 TextInputStream，支持 .isValid()
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: @escaping (String) -> Bool = { _ in true },
        distinct: Bool = true,
        equals: ((String, String) -> Bool)? = nil   // 自定义去重比较（可选）
    ) -> TextInputStream {

        var stream = self.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { [weak self] raw -> String in
                guard let self else { return raw }

                // 组合输入阶段（中文/日文等 IME）不要强行改 text，避免光标跳动
                if self.markedTextRange != nil { return raw }

                var formatted = formatter?(raw) ?? raw

                if let max = maxLength, formatted.count > max {
                    formatted = String(formatted.prefix(max))
                }

                if self.text != formatted {
                    let sel = self.selectedRange
                    self.text = formatted
                    self.selectedRange = sel
                }
                return formatted
            }

        if distinct {
            if let eq = equals {
                stream = stream.distinctUntilChanged(eq)
            } else {
                stream = stream.distinctUntilChanged()
            }
        }
        return TextInputStream(source: stream, validator: validator)
    }
}

public extension UITextView {
    // MARK:  文本基础属性
    @discardableResult
    func byText(_ text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    func byTextColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func byFont(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    func byTextAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    func byAttributedText(_ attrText: NSAttributedString) -> Self {
        self.attributedText = attrText
        return self
    }

    @discardableResult
    func byTypingAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        self.typingAttributes = attrs
        return self
    }
    // MARK: 可编辑与交互
    @discardableResult
    func byEditable(_ editable: Bool) -> Self {
        self.isEditable = editable
        return self
    }

    @discardableResult
    func bySelectable(_ selectable: Bool) -> Self {
        self.isSelectable = selectable
        return self
    }

    @discardableResult
    func byDataDetectorTypes(_ types: UIDataDetectorTypes) -> Self {
        self.dataDetectorTypes = types
        return self
    }

    @discardableResult
    func byAllowsEditingTextAttributes(_ allow: Bool) -> Self {
        self.allowsEditingTextAttributes = allow
        return self
    }
    // MARK: 输入相关
    @discardableResult
    func byKeyboardType(_ type: UIKeyboardType) -> Self {
        self.keyboardType = type
        return self
    }

    @discardableResult
    func byInputView(_ view: UIView?) -> Self {
        self.inputView = view
        return self
    }

    @discardableResult
    func byInputAccessoryView(_ view: UIView?) -> Self {
        self.inputAccessoryView = view
        return self
    }

    @discardableResult
    func byClearsOnInsertion(_ clear: Bool) -> Self {
        self.clearsOnInsertion = clear
        return self
    }
    // MARK: 富文本与链接样式
    @discardableResult
    func byLinkTextAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        self.linkTextAttributes = attrs
        return self
    }

    @discardableResult
    @available(iOS 13.0, *)
    func byUsesStandardTextScaling(_ enable: Bool) -> Self {
        self.usesStandardTextScaling = enable
        return self
    }
    // MARK: 布局与内边距
    @discardableResult
    func byTextContainerInset(_ inset: UIEdgeInsets) -> Self {
        self.textContainerInset = inset
        return self
    }
    // MARK: 滚动与范围
    @discardableResult
    func byScrollToVisible(range: NSRange) -> Self {
        self.scrollRangeToVisible(range)
        return self
    }
    // MARK: 查找功能 (iOS 16+)
    @available(iOS 16.0, *)
    @discardableResult
    func byFindInteractionEnabled(_ enable: Bool) -> Self {
        self.isFindInteractionEnabled = enable
        return self
    }
    // MARK: 边框样式 (iOS 17+)
    @available(iOS 17.0, *)
    @discardableResult
    func byBorderStyle(_ style: UITextView.BorderStyle) -> Self {
        self.borderStyle = style
        return self
    }
    // MARK: 高亮显示 (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byTextHighlightAttributes(_ attrs: [NSAttributedString.Key: Any]) -> Self {
        self.textHighlightAttributes = attrs
        return self
    }
    // MARK:  Writing Tools (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byWritingToolsBehavior(_ behavior: UIWritingToolsBehavior) -> Self {
        self.writingToolsBehavior = behavior
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byAllowedWritingToolsResultOptions(_ options: UIWritingToolsResultOptions) -> Self {
        var safe = options
        // ⚠️ iOS 18.0 / 18.1 暂不支持 table（部分机型连 list 也不行）
        safe.remove(.table)
        // safe.remove(.list) // 如果遇到崩溃，再打开这一行

        self.allowedWritingToolsResultOptions = safe
        return self
    }
    // MARK: 富文本格式配置 (iOS 18+)
    @available(iOS 18.0, *)
    @discardableResult
    func byTextFormattingConfiguration(_ config: UITextFormattingViewController.Configuration) -> Self {
        self.textFormattingConfiguration = config
        return self
    }
    // MARK: 代理设置
    @discardableResult
    func byDelegate(_ delegate: UITextViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}

public extension UITextView {
    // MARK: 统一的圆角边框样式（跨 iOS 版本）
    @discardableResult
    func byRoundedBorder(
        color: UIColor = .systemGray4,
        width: CGFloat = 1,
        radius: CGFloat = 8,
        background: UIColor? = nil
    ) -> Self {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = radius
        layer.masksToBounds = true
        if let bg = background { self.backgroundColor = bg }
        return self
    }
    // MARK: 类似“bezel”的外观（简易版）
    @discardableResult
    func byBezelLike(
        radius: CGFloat = 8
    ) -> Self {
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = radius
        layer.masksToBounds = true
        backgroundColor = .secondarySystemBackground
        return self
    }
}
// MARK: ⚙️ deleteBackward 广播（UITextView）
public extension UITextView {
    static let didPressDeleteNotification = Notification.Name("UITextView.didPressDelete")

    private static let _swizzleOnce: Void = {
        let cls: AnyClass = UITextView.self
        let originalSel = #selector(UITextView.deleteBackward)
        let swizzledSel = #selector(UITextView._jobs_swizzled_deleteBackward)
        guard
            let ori = class_getInstanceMethod(cls, originalSel),
            let swz = class_getInstanceMethod(cls, swizzledSel)
        else { return }
        method_exchangeImplementations(ori, swz)
    }()
    /// 在 App 启动时调用一次（与 UITextField 的启用相互独立）
    static func enableDeleteBackwardBroadcast() {
        _ = self._swizzleOnce
    }

    @objc private func _jobs_swizzled_deleteBackward() {
        self._jobs_swizzled_deleteBackward()
        NotificationCenter.default.post(name: UITextView.didPressDeleteNotification, object: self)
    }
}
// MARK: 🧩 Reactive 扩展（基础事件）
public extension Reactive where Base: UITextView {
    /// 删除键（空文本也会触发）
    var didPressDelete: ControlEvent<Void> {
        let src = NotificationCenter.default.rx
            .notification(UITextView.didPressDeleteNotification, object: base)
            .map { _ in () }
        return ControlEvent(events: src)
    }
    /// Return（注意：UITextView 默认回车是“换行”而非“结束编辑”，
    /// 如需把回车当“完成”，建议使用 shouldChangeTextIn delegate 或键盘 toolbar）
    var didPressReturnAsNewline: ControlEvent<Void> {
        let src = base.rx.didChange
            .withLatestFrom(base.rx.text.orEmpty) { _, text in text }
            .map { _ in () }
        return ControlEvent(events: src)
    }
}
// MARK: 🧠 入口：textView 版 textInput
public extension Reactive where Base: UITextView {
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: @escaping (String) -> Bool = { _ in true },
        distinct: Bool = true
    ) -> RxTextViewInput {

        let rawText = base.rx.text.asObservable()
        let textOrEmpty = base.rx.text.orEmpty.asObservable()
        let trimmed = textOrEmpty.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let began = base.rx.didBeginEditing.map { true }.asObservable()
        let ended = base.rx.didEndEditing.map { false }.asObservable()
        let isEditing = Observable.merge(began, ended)
            .startWith(base.isFirstResponder)

        let deleteEvt = base.rx.didPressDelete.asObservable()
        let didChangeEvt = base.rx.didChange // ControlEvent<Void>

        let bag = DisposeBag()

        let process: (String) -> String = { input in
            var s = input
            if let f = formatter { s = f(s) }
            if let m = maxLength, s.count > m {
                s = String(s.unicodeScalars.prefix(m).map(Character.init))
            }
            return s
        }

        textOrEmpty
            .map(process)
            .withLatestFrom(textOrEmpty) { processed, original in (processed, original) }
            .filter { $0.0 != $0.1 }
            .map { $0.0 }
            .bind(to: base.rx.text)
            .disposed(by: bag)

        let validity = trimmed
            .map(validator)
            .distinctUntilChanged()

        let formattedBinder = Binder<String>(base) { tv, value in
            let v = process(value)
            if tv.text != v { tv.text = v }
        }

        let textOut: Observable<String?> = distinct ? rawText.distinctUntilChanged { ($0 ?? "") == ($1 ?? "") } : rawText
        let textOrEmptyOut: Observable<String> = distinct ? textOrEmpty.distinctUntilChanged() : textOrEmpty
        let trimmedOut: Observable<String> = distinct ? trimmed.distinctUntilChanged() : trimmed

        return RxTextViewInput(
            text: textOut,
            textOrEmpty: textOrEmptyOut,
            trimmed: trimmedOut,
            isEditing: isEditing.distinctUntilChanged(),
            didPressDelete: deleteEvt,
            didChange: didChangeEvt,
            isValid: validity,
            formattedBinder: formattedBinder
        )
    }
    /// UITextView 与 BehaviorRelay<String> 双向绑定
    func bindTwoWay(_ relay: BehaviorRelay<String>) -> Disposable {
        let d1 = self.text.orEmpty
            .distinctUntilChanged()
            .bind(onNext: { relay.accept($0) })

        let d2 = relay
            .distinctUntilChanged()
            .bind(to: self.text)

        return Disposables.create(d1, d2)
    }
}
// MARK: - Rx 快捷桥接（去掉 .rx,给 UITextView 直接用）
public extension UITextView {
    // MARK: 通用输入绑定：带格式化 / 校验 / 最大长度 / 去重
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: @escaping (String) -> Bool = { _ in true },
        distinct: Bool = true
    ) -> Observable<String> {
        // 1) 基础流：去首尾空白、格式化、截断并回写 UI
        var stream = self.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { [weak self] raw -> String in
                guard let self else { return raw }
                // IME 组合输入期间（中文/日文拼写）不要强行改 text，避免光标跳动
                if self.markedTextRange != nil { return raw }

                var formatted = formatter?(raw) ?? raw

                if let max = maxLength, formatted.count > max {
                    formatted = String(formatted.prefix(max))
                }

                if self.text != formatted {
                    // 保留光标位置的写法（尽量减少跳动）
                    let selected = self.selectedRange
                    self.text = formatted
                    self.selectedRange = selected
                }
                return formatted
            }
        // 2) 按需去重
        if distinct {
            stream = stream.distinctUntilChanged()
        }
        // 3) 过滤非法值
        return stream.filter { validator($0) }
    }
    // MARK: 双向绑定：TextView <-> BehaviorRelay<String>
    /// - Parameter relay: 行为Relay
    /// - Returns: Disposable（用于释放绑定）
    @discardableResult
    func bindTwoWay(_ relay: BehaviorRelay<String>, initial: TwoWayInitial = .fromRelay) -> Disposable {
        // 初始同步
        switch initial {
        case .fromRelay:
            if self.text != relay.value { self.text = relay.value }
        case .fromView:
            relay.accept(self.text ?? "")
        }

        // View → Relay
        let d1 = self.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(onNext: { relay.accept($0) })

        // Relay → View
        let d2 = relay.asDriver()
            .distinctUntilChanged()
            .drive(self.rx.text)

        return Disposables.create(d1, d2)
    }
    var didPressDelete: Observable<Void> {
        rx.didPressDelete.asObservable()
    }
}
// MARK: 设置富文本
public extension UITextView {
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil) {
        self.attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
        self.isEditable = false
        self.isScrollEnabled = false
        self.dataDetectorTypes = [] // 仅走自定义 link
    }
}
// MARK: - 私有代理（手势 + 命中计算）
private final class _LinkTapProxy: NSObject, UIGestureRecognizerDelegate {
    let relay = PublishRelay<URL>()

    @objc func handleTap(_ gr: UITapGestureRecognizer) {
        guard let tv = gr.view as? UITextView else { return }

        // 1) 将点击点转换到 textContainer 坐标，并考虑 inset
        let lm  = tv.layoutManager
        let tc  = tv.textContainer
        var pt  = gr.location(in: tv)
        pt.x   -= tv.textContainerInset.left
        pt.y   -= tv.textContainerInset.top

        // 2) glyph → char index
        let glyphIndex = lm.glyphIndex(for: pt, in: tc)
        let charIndex  = lm.characterIndexForGlyph(at: glyphIndex)
        guard charIndex < tv.attributedText.length else { return }

        // 3) 命中检测：点击必须落在该 glyph 的有效 rect 内（避免空白区域误触）
        var usedRect = lm.lineFragmentUsedRect(forGlyphAt: glyphIndex, effectiveRange: nil, withoutAdditionalLayout: true)
        usedRect.origin.x += tv.textContainerInset.left
        usedRect.origin.y += tv.textContainerInset.top
        guard usedRect.contains(gr.location(in: tv)) else { return }

        // 4) 取属性（支持 URL 或 String）
        var eff = NSRange(location: 0, length: 0)
        let attrs = tv.attributedText.attributes(at: charIndex, effectiveRange: &eff)

        if let v = attrs[NSAttributedString.Key.link] {
            if let url = v as? URL {
                relay.accept(url)
            } else if let s = v as? String, let url = URL(string: s) {
                relay.accept(url)
            }
        }
    }
    // 与系统手势并发，避免被内建选择/链接手势抢走
    func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
}
private var kProxyKey: UInt8 = 0
private var kTapKey:   UInt8 = 0
// MARK: - Rx 扩展（原生写法保留）
public extension Reactive where Base: UITextView {
    var linkTap: ControlEvent<URL> {
        let proxy: _LinkTapProxy
        if let p = objc_getAssociatedObject(base, &kProxyKey) as? _LinkTapProxy {
            proxy = p
        } else {
            proxy = _LinkTapProxy()
            objc_setAssociatedObject(base, &kProxyKey, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // 交互配置：让手势优先可用
            base.isEditable = false
            base.isSelectable = false        // ⬅️ 关键：关掉系统选择/链接交互，避免“吞”掉 tap
            base.isScrollEnabled = false
            base.dataDetectorTypes = []      // 仅走自定义 link
            base.isUserInteractionEnabled = true
            base.delaysContentTouches = false

            let tap = UITapGestureRecognizer(target: proxy, action: #selector(_LinkTapProxy.handleTap(_:)))
            tap.cancelsTouchesInView = true
            tap.delegate = proxy             // ⬅️ 允许并发识别
            base.addGestureRecognizer(tap)
            objc_setAssociatedObject(base, &kTapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return ControlEvent(events: proxy.relay.asObservable())
    }
}
// MARK: - 语义扩展：tv.linkTap（省略 .rx）
public extension UITextView {
    var linkTap: Observable<URL> { self.rx.linkTap.asObservable() }
}
