//
//  LiveInputBar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import SnapKit
// ============================== InputBar（inputAccessoryView） ==============================
final class LiveInputBar: UIView {
    /// 对外回调：点击发送按钮或在键盘上按“发送/回车”时触发
    var onSend: ((String) -> Void)?
    /// 是否在发送后清空文本（默认 true）
    var autoClearAfterSend: Bool = true
    /// 是否在发送后收起键盘（默认 true）
    var autoResignAfterSend: Bool = true

    lazy var tf: UITextField = {
        UITextField()
            .byBorderStyle(.roundedRect)
            .byPlaceholder("说点什么…")
            .byReturnKeyType(.send)
            .byEnablesReturnKeyAutomatically(true)          // 空文本禁用“发送”
            .onReturn { [weak self] _ in                    // ⌨️ 键盘“发送”
                self?.emitSend()
            }
            .onChange { tf, input, old, isDeleting in

            }
            .byAddTo(self) { make in
                make.leading.equalToSuperview().offset(22.w)
                make.trailing.equalToSuperview().offset(-22.w)
                make.centerY.equalToSuperview()
                make.height.equalTo(38.h)
            }
    }()

    private lazy var topLine: UIView = {
        UIView()
            .byBgColor(.separator)
            .byAddTo(self) { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5)
            }
    }()

    override var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: 52)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        byBgColor(.systemBackground)
        isUserInteractionEnabled = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        topLine.byVisible(YES)
        tf.byVisible(YES)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    /// 统一出口：采集文本 -> 回调给外部 -> 按配置清空/收键盘
    private func emitSend() {
        let text = (tf.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onSend?(text)
        if autoClearAfterSend { tf.text = nil }
        if autoResignAfterSend { tf.resignFirstResponder() }
    }
}

extension LiveInputBar {
    @discardableResult
    func onSend(_ handler: @escaping (String) -> Void) -> Self {
        self.onSend = handler
        return self
    }
    @discardableResult
    func byAutoClearAfterSend(_ flag: Bool) -> Self {
        self.autoClearAfterSend = flag;
        return self
    }
    @discardableResult
    func byAutoResignAfterSend(_ flag: Bool) -> Self {
        self.autoResignAfterSend = flag;
        return self
    }
}
