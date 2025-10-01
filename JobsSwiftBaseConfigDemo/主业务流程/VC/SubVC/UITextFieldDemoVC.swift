//
//  UITextFieldDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import NSObject_Rx
import ObjectiveC

final class UITextFieldDemoVC: UIViewController,
                                UITextFieldDelegate,
                                HasDisposeBag {
    // MARK: - UI
    // 左边信封图标
    private static func makeIcon(_ name: String) -> UIImageView {
        let iv = UIImageView(image: UIImage(systemName: name))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        return iv
    }

    // 顶部工具条（“完成”）
    private lazy var accessory: UIToolbar = {
        let bar = UIToolbar()
        bar.items = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem()
                .byTitle("完成")
                .byTitleFont(.systemFont(ofSize: 15))
                .byTitleColor(.systemYellow)
                .byStyle(.done)
                .onTap { [weak self] _ in
                    guard let self = self else { return }   // ✅ 确保生命周期安全
                    view.endEditing(true)
                },
        ]
        bar.sizeToFit()
        return bar
    }()

    // 邮箱输入框
    private lazy var emailTF: UITextField = {
        let tf = UITextField()
            // 数据源
            .byDelegate(self)
            // 基础视觉
            .byPlaceholder("请输入邮箱（至少 3 个字符）")
            .byTextColor(.label)
            .byFont(.systemFont(ofSize: 16))
            .byTextAlignment(.natural)
            .byBorderStyle(.roundedRect)
            .byClearButtonMode(.whileEditing)

            .byInputAccessoryView(accessory)
            // 键盘
            .byKeyboardType(.emailAddress)
            .byKeyboardAppearance(.dark)
            .byReturnKeyType(.next)
            .byEnablesReturnKeyAutomatically(true)
            // 智能输入
            .byAutocapitalizationType(.none)
            .byAutocorrectionType(.no)
            .bySpellCheckingType(.no)
            .bySmartQuotesType(.no)
            .bySmartDashesType(.no)
            .bySmartInsertDeleteType(.no)
            // 内容类型
            .byTextContentType(.emailAddress)
            // 编辑属性
            .byAllowsEditingTextAttributes(true)
            .byDefaultTextAttributes([.kern: 0.5]) // 字距
            .byTypingAttributes([.foregroundColor: UIColor.label])
            // 左/右视图
            //.byLeftView(makeIcon("envelope"), mode: .always)
            .byLeftIcon(UIImage(systemName: "envelope"),
                        tint: .secondaryLabel,
                        size: .init(width: 18, height: 18),
                        leading: 12, spacing: 8)
        // iOS 17+
        if #available(iOS 17.0, *) {
            tf.byInlinePredictionType(.default)
        }
        // iOS 18+（演示：即使邮箱框也能设置，不影响）
        if #available(iOS 18.0, *) {
            tf.byMathExpressionCompletionType(.default)
              .byWritingToolsBehavior(.default)
              .byAllowedWritingToolsResultOptions([])
        }
        return tf
    }()

    // 密码输入框（带“眼睛”）@byLimitLength（5）
    private lazy var passwordTF: UITextField = {
        let tf = UITextField()
            .byDelegate(self) // 数据源
            .byPlaceholder("请输入密码（6-20 位）")
            .bySecureTextEntry(true)
            .byInputAccessoryView(passwordAccessory)
            .byBorderStyle(.roundedRect)
            .byReturnKeyType(.done)
            .byTextContentType(.password)
            .byPasswordRules(nil) // 也可自定义
//            .byLeftView(Self.makeIcon("lock"), mode: .always)
            .byLeftIcon(UIImage(systemName: "lock"),
                        tint: .secondaryLabel,
                        size: .init(width: 18, height: 18),
                        leading: 12, spacing: 8)
            .byRightView(UIButton(type: .system)
                .byImage(UIImage(systemName: "eye.slash"), for: .normal)   // 未选中
                .byImage(UIImage(systemName: "eye"), for: .selected)       // 选中
                .byContentEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6))
                .onTap { [weak self] sender in
                    guard let self else { return }                // 或写成 guard let strongSelf = self else { return }
                    sender.isSelected.toggle()
                    self.passwordTF.isSecureTextEntry.toggle()
                    self.passwordTF.togglePasswordVisibility()    // 你自己的游标/清空修复
                }, mode: .always)
            .byAllowsNumberPadPopover(true) // iPad 数字键盘弹窗
            .byInputView(datePicker) // 演示自定义 inputView：点密码框弹日期（纯展示，不建议真实项目这么用）
            .byLimitLength(5)

        return tf
    }()

    // 可选：给密码框自定义 inputAccessoryView
    private lazy var passwordAccessory: UIToolbar = {
        let bar = UIToolbar()
        bar.items = [
            UIBarButtonItem()
                .byTitle("清空")
                .byTitleFont(.systemFont(ofSize: 15))
                .byTitleColor(.systemRed)
                .byStyle(.plain)
                .onTap { [weak self] _ in
                    guard let self = self else { return }   // ✅ 确保生命周期安全
                    self.passwordTF.text = ""
                    // 也可以：self.passwordTF.rx.text.onNext("")
                },
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem()
                .byTitle("完成")
                .byTitleFont(.systemFont(ofSize: 15))
                .byTitleColor(.systemYellow)
                .byStyle(.done)
                .onTap { [weak self] _ in
                    guard let self = self else { return }   // ✅ 确保生命周期安全
                    view.endEditing(true)
                },
        ]
        bar.sizeToFit()
        return bar
    }()

    // 自定义 inputView（示例：日期选择器，只为展示 byInputView 用法）
    private lazy var datePicker: UIDatePicker = {
        return UIDatePicker()
            .byPreferredDatePickerStyle(.wheels)
            .byDatePickerMode(.date)
    }()

    override func loadView() {
        super.loadView()
        // 建议在 App 启动时调用一次
        UITextField.enableDeleteBackwardBroadcast()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UITextField 全量演示"
        view.backgroundColor = .systemBackground

        // MARK: 布局
        view.addSubview(emailTF)
        view.addSubview(passwordTF)
        emailTF.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        passwordTF.snp.makeConstraints {
            $0.top.equalTo(emailTF.snp.bottom).offset(16)
            $0.left.right.height.equalTo(emailTF)
        }

        // MARK: Rx 绑定 —— 删除键广播
        emailTF.didPressDelete
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                print("🗑 delete on emailTF:", self.emailTF.text ?? "")
            })
            .disposed(by: rx.disposeBag)

        // MARK: Rx 绑定 —— 邮箱：去空格 + 最长 8 + 简单规则
        emailTF.textInput(
            maxLength: 8,
            formatter: { $0.trimmingCharacters(in: .whitespaces) },
            validator: { $0.count >= 3 && $0.contains("@") }
        ).isValid
            .subscribe(onNext: { print("📧 email valid:", $0) })
            .disposed(by: rx.disposeBag)

        // MARK: Rx 绑定 —— 密码：不做任何限制，只是监听（不要传 nil，直接用默认）
        passwordTF.textInput(
            maxLength: 5,
            formatter: { $0.trimmingCharacters(in: .whitespaces) },
            validator: nil
        )
        .isValid
        .subscribe(onNext: { print("🔐 password valid:", $0) })
        .disposed(by: rx.disposeBag)

        // MARK: 监听删除键（无 .rx）
        passwordTF.didPressDelete
            .subscribe(onNext: { print("delete pressed") })
            .disposed(by: rx.disposeBag)
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTF {
            passwordTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
