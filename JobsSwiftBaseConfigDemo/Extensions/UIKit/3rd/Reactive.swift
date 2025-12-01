//
//  Reactive.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/30/25.
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
import NSObject_Rx
// MARK: 键盘按键行为监听
public extension Reactive where Base: UITextField {
    /// 每次按下删除键都会触发（空文本时也会触发）
    var didPressDelete: ControlEvent<Void> {
        let source = NotificationCenter.default.rx
            .notification(UITextField.didPressDeleteNotification, object: base)
            .map { _ in () }
        return ControlEvent(events: source)
    }
    /// Return（editingDidEndOnExit）
    var didPressReturn: ControlEvent<Void> {
        controlEvent(.editingDidEndOnExit)
    }
    /// 开始/结束编辑
    var didBeginEditing: ControlEvent<Void> { controlEvent(.editingDidBegin) }
    var didEndEditing:   ControlEvent<Void> { controlEvent(.editingDidEnd)   }
}
/**
    | 输入序列                                    | distinct = true 是否回调                          |
    | ----------------------------------- | --------------------------------------------- |
    | "" → "A"                                    | ✅ 触发                                                   |
    | "A" → "AB"                               | ✅ 触发                                                   |
    | "AB" → "ABC"                          | ✅ 触发                                                    |
    | "A" → "A"（程序重复设同值） | ❌ 不触发                                                |
    | "A " →（trim 后是 "A"）           | trimmed/isValid 可能 ❌（修剪后没变） |
*/
// MARK: 🧠 规则模型：RxTextInput
// MARK: - 一体化模型（Reactive）
public extension Reactive where Base: UITextField {
    /// 与 `byLimitLength(_:)` 互斥：本方法会标记当前 TextField 已启用 textInput
    func textInput(
        maxLength: Int? = nil,                                 // 最大长度
        formatter: ((String) -> String)? = nil,                // 文本格式化（如 uppercased、trim 等）
        validator: @escaping (String) -> Bool = { _ in true }, // 校验规则（返回 true/false）
        distinct: Bool = true                                  // 输出去重
    ) -> RxTextInput {

        // ✅ 标记：该 TextField 已启用 textInput（供 byLimitLength 等功能做互斥判断）
        objc_setAssociatedObject(base,
                                 &JobsTFKeys.textInputActive,
                                 true,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 基础源
        let rawText     = base.rx.text.asObservable()               // String?
        let textOrEmpty = base.rx.text.orEmpty.asObservable()       // String
        let trimmed     = textOrEmpty.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        // 编辑态
        let began    = base.rx.didBeginEditing.map { true }.asObservable()
        let ended    = base.rx.didEndEditing  .map { false }.asObservable()
        let isEditing = Observable.merge(began, ended)
            .startWith(base.isFirstResponder)

        // 删除 / 回车
        let deleteEvt = base.rx.didPressDelete.asObservable()
        let returnEvt = base.rx.didPressReturn.asObservable()

        // 组合处理器：先 formatter 再 maxLength（按 Character 截断，避免拆 emoji/合成字符）
        let process: (String) -> String = { [weak base] input in
            // 1) 正在组字（中文/日文等 IME），直接放行
            if let tf = base, tf.markedTextRange != nil { return input }

            var s = input
            if let f = formatter { s = f(s) }
            if let m = maxLength, s.count > m {
                s = String(s.prefix(m))
            }
            return s
        }

        // 仅在需要改写时回写，避免光标跳跃
        _ = textOrEmpty
            .map(process)
            .withLatestFrom(textOrEmpty) { processed, original in (processed, original) }
            .filter { $0.0 != $0.1 }
            .map { $0.0 }
            .observe(on: MainScheduler.instance)
            .take(until: base.rx.deallocated)                 // 绑定到 textField 生命周期
            .bind(to: base.rx.text)

        // 有效性
        let validity = trimmed
            .map(validator)
            .distinctUntilChanged()

        // 外部“强制回写”的 Binder
        let formattedBinder = Binder<String>(base) { tf, value in
            if tf.markedTextRange != nil { return }          // IME 保护
            let v = process(value)
            if tf.text != v { tf.text = v }
        }

        // 输出去重策略
        let textOut: Observable<String?>       = distinct ? rawText.distinctUntilChanged { ($0 ?? "") == ($1 ?? "") } : rawText
        let textOrEmptyOut: Observable<String> = distinct ? textOrEmpty.distinctUntilChanged() : textOrEmpty
        let trimmedOut: Observable<String>     = distinct ? trimmed.distinctUntilChanged() : trimmed

        return RxTextInput(
            text: textOut,
            textOrEmpty: textOrEmptyOut,
            trimmed: trimmedOut,
            isEditing: isEditing.distinctUntilChanged(),
            didPressDelete: deleteEvt,
            didPressReturn: returnEvt,
            isValid: validity,
            formattedBinder: formattedBinder
        )
    }
}
// MARK: 🔁 双向绑定辅助
public extension Reactive where Base: UITextField {
    /// 把一个 BehaviorRelay<String> 与 UITextField 双向绑定
    /// - 注意：会自动去重，避免循环回写
    func bindTwoWay(_ relay: BehaviorRelay<String>) -> Disposable {
        let d1 = self.text.orEmpty
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { relay.accept($0) })
        let d2 = relay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: self.text)

        return Disposables.create(d1, d2)
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

extension Reactive where Base: UIView {
    /// 监听键盘高度变化（0 = 隐藏）
    var keyboardHeight: Observable<CGFloat> {
        let willShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }

        let willHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Observable.merge(willShow, willHide)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
    }
}
// MARK: - 全局关联 Key（用于 objc_setAssociatedObject）
private var kProxyKey: UInt8 = 0
private var kTapKey:  UInt8 = 0
public extension Reactive where Base: UITextView {
    /// Rx 扩展：点击富文本链接触发 URL 事件
    var linkTap: ControlEvent<URL> {
        // 👇 强类型拿 proxy，杜绝 .empty() 分支
        let proxy: _LinkTapProxy
        if let p = objc_getAssociatedObject(base, &kProxyKey) as? _LinkTapProxy {
            proxy = p
        } else {
            let p = _LinkTapProxy()            // ← 来自“原文件”，访问级别必须 ≥ internal
            proxy = p
            objc_setAssociatedObject(base, &kProxyKey, p, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // 交互配置（避免系统吞掉自定义 tap）
            base.isEditable = false
            base.isSelectable = false
            base.isScrollEnabled = false
            base.dataDetectorTypes = []
            base.isUserInteractionEnabled = true
            base.delaysContentTouches = false

            let tap = UITapGestureRecognizer(target: p, action: #selector(_LinkTapProxy.handleTap(_:)))
            tap.cancelsTouchesInView = true
            tap.delegate = p
            base.addGestureRecognizer(tap)
            objc_setAssociatedObject(base, &kTapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return ControlEvent(events: proxy.relay.asObservable())
    }
}
