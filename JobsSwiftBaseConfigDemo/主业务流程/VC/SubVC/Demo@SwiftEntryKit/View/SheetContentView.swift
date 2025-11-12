//
//  SheetContentView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//
import UIKit
import SwiftEntryKit
// MARK: - 自定义底部表单（键盘联动）
final class SheetContentView: UIView, UITextFieldDelegate {
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("底部表单（键盘联动）")
            .byFont(.boldSystemFont(ofSize: 18))
            .byTextColor(.label)
            .byAddTo(self) { make in
                make.top.equalToSuperview().inset(16)
                make.left.right.equalToSuperview().inset(16)
            }
    }()
    private lazy var textField: UITextField = {
        UITextField()
            .byPlaceholder("输入点什么…")
            .byBorderStyle(.roundedRect)
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(40)
            }
    }()
    private lazy var confirmBtn: UIButton = {
        UIButton.sys()
            .byTitle("确定")
            .onTap { [weak self] (_: UIButton) in
                self?.endEditing(true)
                SwiftEntryKit.dismiss()
            }
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(textField.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
                make.bottom.equalToSuperview().inset(20)
            }
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemBackground
        titleLabel.byVisible(YES)
        textField.byVisible(YES)
        confirmBtn.byVisible(YES)
    }
    required init?(coder: NSCoder) { fatalError() }
}
