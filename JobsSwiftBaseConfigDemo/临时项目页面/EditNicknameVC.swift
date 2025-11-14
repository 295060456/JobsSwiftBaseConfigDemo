//
//  EditNicknameVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/14/25.
//

import UIKit
import SnapKit

final class EditNicknameVC: UIViewController {

    /// 昵称输入框
    private lazy var nicknameField: UITextField = {
        UITextField()
            // 基础视觉
            .byPlaceholder("请输入昵称 长度12个字符")
            .byTextColor(.label)
            .byFont(.systemFont(ofSize: 16))
            .byTextAlignment(.natural)
            .byBorderStyle(.roundedRect)
            .byClearButtonMode(.whileEditing)
            // 键盘
            .byKeyboardType(.default)
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
            // 编辑属性
            .byAllowsEditingTextAttributes(true)
            .byDefaultTextAttributes([.kern: 0.5]) // 字距
            .byTypingAttributes([.foregroundColor: UIColor.label])
            .onChange { [weak self] tf, input, old, isDeleting in
                guard let self else { return }
                let text = input
                btn.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
            }
    }()

    private lazy var btn: UIButton = {
        UIButton.sys()
        /// 普通字符串@设置主标题
            .byTitle("保存", for: .normal)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            /// 事件触发@点按
            .onTap { [weak self] sender in
                guard let self else { return }
                jobsDismissKeyboard()
            }
    }()
    /// 底部说明文字
    private lazy var tipLabel: UILabel = {
        UILabel()
            .byText("长度限制12个字节，仅免费修改1次")
            .byFont(.systemFont(ofSize: 12))
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(0)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(nicknameField.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(16)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor(.systemGroupedBackground)
        jobsSetupGKNav(
            title: "编辑昵称",
            rightButtons: [btn]
        )

        nicknameField.byVisible(YES)
        tipLabel.byVisible(YES)
    }
}
