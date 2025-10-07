//
//  UITextField.swift
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
import ObjectiveC.runtime

public enum JobsTFKeys {
    static var limitBag = UInt8(0)
    static var textInputActive = UInt8(0)
}
// MARK: 🧱组件模型：RxTextInput：一个输入框的“响应式视图模型”，把常用流打包给
public struct RxTextInput {
    /// 原始文本（可选）与非可选文本（orEmpty）
    public let text: Observable<String?>
    public let textOrEmpty: Observable<String>
    /// 去首尾空格
    public let trimmed: Observable<String>
    /// 是否正在编辑
    public let isEditing: Observable<Bool>
    /// 删除键事件 / 回车事件
    public let didPressDelete: Observable<Void>
    public let didPressReturn: Observable<Void>
    /// 实时有效性（基于 validator）。每当输入框内容变化，就会根据传入的 validator 校验规则动态发出 true 或 false。
    public let isValid: Observable<Bool>
    /// 将“格式化后的文本”回写到 textField（避免光标跳动做了节制）
    public let formattedBinder: Binder<String>
}
// MARK: ✏️ UITextField 链式配置
public extension UITextField {
    // MARK: 🌸 基础文本属性
    @discardableResult
    func byPlaceholder(_ placeholder: String?) -> Self {
        self.placeholder = placeholder
        return self
    }

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
    func byBorderStyle(_ style: UITextField.BorderStyle) -> Self {
        self.borderStyle = style
        return self
    }
    // MARK: 🧱 占位/背景样式
    @available(iOS 6.0, *)
    @discardableResult
    func byAttributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }

    @available(iOS 6.0, *)
    @discardableResult
    func byAttributedPlaceholder(_ attributedPlaceholder: NSAttributedString?) -> Self {
        self.attributedPlaceholder = attributedPlaceholder
        return self
    }

    @discardableResult
    func byBackground(_ image: UIImage?) -> Self {
        self.background = image
        return self
    }

    @discardableResult
    func byDisabledBackground(_ image: UIImage?) -> Self {
        self.disabledBackground = image
        return self
    }
    // MARK: 🧠 输入控制行为
    @discardableResult
    func byClearsOnBeginEditing(_ clears: Bool) -> Self {
        self.clearsOnBeginEditing = clears
        return self
    }

    @discardableResult
    func byClearsOnInsertion(_ clears: Bool) -> Self {
        self.clearsOnInsertion = clears
        return self
    }

    @discardableResult
    func byAdjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjusts
        return self
    }

    @discardableResult
    func byMinimumFontSize(_ size: CGFloat) -> Self {
        self.minimumFontSize = size
        return self
    }

    @discardableResult
    func bySecureTextEntry(_ secure: Bool) -> Self {
        self.isSecureTextEntry = secure
        return self
    }
    // MARK: ⌨️ 键盘行为
    @discardableResult
    func byKeyboardType(_ type: UIKeyboardType) -> Self {
        self.keyboardType = type
        return self
    }

    @discardableResult
    func byKeyboardAppearance(_ appearance: UIKeyboardAppearance) -> Self {
        self.keyboardAppearance = appearance
        return self
    }

    @discardableResult
    func byReturnKeyType(_ type: UIReturnKeyType) -> Self {
        self.returnKeyType = type
        return self
    }

    @discardableResult
    func byEnablesReturnKeyAutomatically(_ enabled: Bool) -> Self {
        self.enablesReturnKeyAutomatically = enabled
        return self
    }
    // MARK: 🧠 智能输入特性
    @discardableResult
    func byAutocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = type
        return self
    }

    @discardableResult
    func byAutocorrectionType(_ type: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = type
        return self
    }

    @discardableResult
    func bySpellCheckingType(_ type: UITextSpellCheckingType) -> Self {
        self.spellCheckingType = type
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func bySmartQuotesType(_ type: UITextSmartQuotesType) -> Self {
        self.smartQuotesType = type
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func bySmartDashesType(_ type: UITextSmartDashesType) -> Self {
        self.smartDashesType = type
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func bySmartInsertDeleteType(_ type: UITextSmartInsertDeleteType) -> Self {
        self.smartInsertDeleteType = type
        return self
    }

    @available(iOS 17.0, *)
    @discardableResult
    func byInlinePredictionType(_ type: UITextInlinePredictionType) -> Self {
        self.inlinePredictionType = type
        return self
    }
    // MARK: 🧠 iOS 18+ 新特性
    @available(iOS 18.0, *)
    @discardableResult
    func byMathExpressionCompletionType(_ type: UITextMathExpressionCompletionType) -> Self {
        self.mathExpressionCompletionType = type
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byWritingToolsBehavior(_ behavior: UIWritingToolsBehavior) -> Self {
        self.writingToolsBehavior = behavior
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byAllowedWritingToolsResultOptions(_ options: UIWritingToolsResultOptions) -> Self {
        self.allowedWritingToolsResultOptions = options
        return self
    }
    // MARK: 🔠 内容类型 / 密码规则
    @discardableResult
    func byTextContentType(_ type: UITextContentType) -> Self {
        self.textContentType = type
        return self
    }

    @available(iOS 12.0, *)
    @discardableResult
    func byPasswordRules(_ rules: UITextInputPasswordRules?) -> Self {
        self.passwordRules = rules
        return self
    }
    // MARK: 🎨 左右视图 / 清除按钮
    @discardableResult
    func byClearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        self.clearButtonMode = mode
        return self
    }

    @discardableResult
    func byLeftView(_ view: UIView?, mode: UITextField.ViewMode = .always) -> Self {
        self.leftView = view
        self.leftViewMode = mode
        return self
    }

    @discardableResult
    func byRightView(_ view: UIView?, mode: UITextField.ViewMode = .always) -> Self {
        self.rightView = view
        self.rightViewMode = mode
        return self
    }

    @available(iOS 7.0, *)
    @discardableResult
    func byDefaultTextAttributes(_ attrs: [NSAttributedString.Key : Any]) -> Self {
        self.defaultTextAttributes = attrs
        return self
    }

    @available(iOS 6.0, *)
    @discardableResult
    func byAllowsEditingTextAttributes(_ allows: Bool) -> Self {
        self.allowsEditingTextAttributes = allows
        return self
    }

    @available(iOS 6.0, *)
    @discardableResult
    func byTypingAttributes(_ attrs: [NSAttributedString.Key : Any]?) -> Self {
        self.typingAttributes = attrs
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
    // ⚠️ delegate 弱引用属性：仅便捷设置，别强持有
    @discardableResult
    func byDelegate(_ delegate: UITextFieldDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}
// MARK: - 左侧图标 & 纯留白
public extension UITextField {
    /// 设置左侧图标，并精确控制：leading（到边距）和 spacing（到文字）
    @discardableResult
    func byLeftIcon(
        _ image: UIImage?,
        tint: UIColor? = nil,
        size: CGSize = .init(width: 18, height: 18),
        leading: CGFloat = 12,      // 图标距 TextField 左边缘
        spacing: CGFloat = 8        // 图标与文字之间
    ) -> Self {
        guard let image else {
            leftView = nil
            leftViewMode = .never
            return self
        }

        let iv = UIImageView(image: tint == nil ? image : image.withRenderingMode(.alwaysTemplate))
        iv.tintColor = tint
        iv.contentMode = .scaleAspectFit
        iv.frame = CGRect(origin: .zero, size: size)

        let containerW = leading + size.width + spacing
        let containerH = max(24, size.height)    // 高度随便给，系统会垂直居中
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerW, height: containerH))

        // 把图标放到带 leading 的位置
        iv.center = CGPoint(x: leading + size.width / 2, y: container.bounds.midY)
        iv.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        container.addSubview(iv)

        leftView = container
        leftViewMode = .always
        return self
    }
    /// 仅设置左侧留白（没有图标），常用于单纯增加文本左内边距
    @discardableResult
    func byLeftPadding(_ padding: CGFloat) -> Self {
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 1))
        spacer.isUserInteractionEnabled = false
        leftView = spacer
        leftViewMode = .always
        return self
    }
}
// MARK: ⚙️ 一次性开启 deleteBackward 广播
public extension UITextField {
    /// 通知名：当任意 UITextField 发生 deleteBackward 时派发（object = 当前 textField）
    static let didPressDeleteNotification = Notification.Name("UITextField.didPressDelete")
    /// 只在首次加载时执行一次
    private static let _swizzleDeleteBackwardImplementation: Void = {
        let cls: AnyClass = UITextField.self

        let originalSelector = #selector(UITextField.deleteBackward)
        let swizzledSelector = #selector(UITextField._rx_swizzled_deleteBackward)

        guard
            let originalMethod = class_getInstanceMethod(cls, originalSelector),
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    /// 触发静态属性以完成 swizzle（App 生命周期里找个合适地方触发一次即可）
    /// 必须调用一次，否则 swizzle 不生效
    /// 一旦调用，全局所有 UITextField 都支持删除监听
    static func enableDeleteBackwardBroadcast() {
        _ = self._swizzleDeleteBackwardImplementation
    }
    /// 被交换后的实现：先调用原始实现，再发通知
    @objc private func _rx_swizzled_deleteBackward() {
        // 调用原始 deleteBackward（交换后原始实现映射到此方法名）
        self._rx_swizzled_deleteBackward()
        // 广播删除事件（object 带上当前 textField）
        NotificationCenter.default.post(
            name: UITextField.didPressDeleteNotification,
            object: self,
            userInfo: nil
        )
    }
}
/**
     passwordTextField.isSecureTextEntry = true

     @IBAction func toggleEyeButtonTapped(_ sender: UIButton) {
         passwordTextField.isSecureTextEntry.toggle()
         passwordTextField.togglePasswordVisibility()
     }
 */
// MARK: 用于在切换 isSecureTextEntry（明文/密文）后，修复 iOS 的文字丢失、光标闪烁和位置偏移问题，确保切换显示稳定、内容不丢失、光标正常。
public extension UITextField {
    func togglePasswordVisibility() {
        /// 临时去掉光标颜色（防止闪烁）
        let existingTintColor = tintColor
        tintColor = .clear
        /// 修复 iOS 的文字丢失 bug
        /// Bug 背景：当把 isSecureTextEntry 从 false 改回 true 时，如果用户光标不在最后、继续输入新字，系统会直接清空原有文字（奇怪的行为）。
        /// 修复思路：先删掉当前内容；再用 replace() 写回去；这样系统会重新渲染文字，但不会清空输入
        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        /// 因为切换 secure 模式时，字体宽度变了（圆点 ● 的宽度不同于明文字体），所以光标位置可能偏移。
        /// 做法是：暂时清空 selectedTextRange，再设置回去（强制让系统重新计算光标位置）
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
        ///恢复光标颜色
        self.tintColor = existingTintColor
    }
}
// MARK: 限制输入框最大长度（不能与textInput进行混用，优先级:textInput > byLimitLength）
public extension UITextField {
    /// 仅做“纯限长”；与 textInput 互斥
    @discardableResult
    func byLimitLength(_ maxLength: Int) -> Self {
        guard maxLength > 0 else { return self }

        // 若已启用 textInput，则跳过（避免双向回写冲突）
        if (objc_getAssociatedObject(self, &JobsTFKeys.textInputActive) as? Bool) == true {
            #if DEBUG
            print("⚠️ byLimitLength 与 textInput 互斥：已启用 textInput，忽略限长。")
            #endif
            return self
        }

        // 为当前 textField 挂一个专用 DisposeBag（重复调用会覆盖旧的）
        let bag = DisposeBag()
        objc_setAssociatedObject(self, &JobsTFKeys.limitBag, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 基于 Character 截断（避免拆 emoji/合成字符）
        rx.text.orEmpty
            .map { [weak self] text -> String in
                // 组字中（中文/日文等 IME）不动它
                if let tf = self, tf.markedTextRange != nil { return text }
                return text.count > maxLength ? String(text.prefix(maxLength)) : text
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: rx.text)
            .disposed(by: bag)

        return self
    }
}
// MARK: - Rx 快捷桥接（去掉 .rx,给 UITextField 直接用）
public extension UITextField {
    /// 删除键事件（等价 rx.didPressDelete）
    var didPressDelete: ControlEvent<Void> { rx.didPressDelete }
    /// Return 键事件
    var didPressReturn: ControlEvent<Void> { rx.didPressReturn }
    /// 开始/结束编辑
    var didBeginEditingEvent: ControlEvent<Void> { rx.didBeginEditing }
    var didEndEditingEvent:   ControlEvent<Void> { rx.didEndEditing }
    /// 一体化输入模型（等价 rx.textInput(...)）
    @discardableResult
    func textInput(
        maxLength: Int? = nil,
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> Bool)? = nil,
        distinct: Bool = true
    ) -> RxTextInput {
        let v = validator ?? { _ in true }
        return rx.textInput(maxLength: maxLength,
                            formatter: formatter,
                            validator: v,
                            distinct: distinct)
    }
    /// 文本流（等价于 rx.text.orEmpty.asObservable()）
    var textStream: Observable<String> {
        rx.text.orEmpty.asObservable()
    }
    /// 便捷监听（自动 distinct）
    @discardableResult
    func onText(_ handler: @escaping (String) -> Void) -> Disposable {
        rx.text.orEmpty
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: handler)
    }
}
// MARK: - 设置富文本（UITextField）
public extension UITextField {
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil) {
        self.attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
    }
}
