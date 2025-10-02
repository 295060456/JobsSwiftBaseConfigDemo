//
//  CNIDDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 2025/10/2.
//

import UIKit
import SnapKit

final class CNIDDemoVC: UIViewController {

    private lazy var textField: UITextField = {
        UITextField()
            .byPlaceholder("请输入身份证号码")
            .byBorderStyle(.roundedRect)
            .byClearButtonMode(.whileEditing)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10.h)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var exampleButton: UIButton = {
        UIButton(type: .system)
            .byTitle("自动填入示例")
            .byTitleFont(.systemFont(ofSize: 15))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.textField.text = "510105199307315321"
                self.resultLabel.text = nil
            }.byAddTo(view) { [unowned self] make in
                make.top.equalTo(textField.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.height.equalTo(36)
            }
    }()

    private lazy var checkButton: UIButton = {
        UIButton(type: .system)
            .byTitle("开始校验")
            .byTitleFont(.boldSystemFont(ofSize: 16))
            .onTap { [weak self] _ in
                guard let self else { return }
                let input = textField.text ?? ""
                guard !input.isEmpty else {
                    updateResult("❌ 请输入身份证号码", success: false)
                    return
                }

                do {
                    let normalized = try CNID.validate(input)
                    updateResult("✅ 校验成功\n标准化结果：\(normalized)", success: true)
                } catch {
                    updateResult("❌ \(error)", success: false)
                }
            }.byAddTo(view) { [unowned self] make in
                make.top.equalTo(exampleButton.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
            }
    }()

    private lazy var resultLabel: UILabel = {
        UILabel()
            .byTextAlignment(.center)
            .byFont(.systemFont(ofSize: 16))
            .byNumberOfLines(0)
            .byTextColor(.secondaryLabel)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(checkButton.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(
            title: "身份证校验 Demo"
        )
        view.backgroundColor = .systemBackground
        textField.alpha = 1;// 输入框
        exampleButton.alpha = 1;// 示例按钮（自动填充）
        checkButton.alpha = 1;// 校验按钮
        resultLabel.alpha = 1;// 结果标签
    }
    // MARK: - 更新显示结果
    private func updateResult(_ text: String, success: Bool) {
        resultLabel.text = text
        resultLabel.textColor = success ? .systemGreen : .systemRed
    }
}
