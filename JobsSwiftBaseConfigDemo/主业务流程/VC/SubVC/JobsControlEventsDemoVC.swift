//
//  JobsControlEventsDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/01.
//

import UIKit
import SnapKit

final class JobsControlEventsDemoVC: UIViewController {

    // 统一用一个垂直栈承载所有 Demo
    private let stack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 14
        $0.distribution = .equalSpacing
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIControl/UIButton 事件链式 Demo"
        view.backgroundColor = .systemBackground

        setupLayout()
        buildDemos()

        // 点击空白收键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingNow))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setupLayout() {
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func buildDemos() {
        demo_Switch_onJobsChange()
        demo_DatePicker_onJobsChange()
        demo_Slider_onJobsChange()
        demo_TextField_onJobsEvent()
        demo_Button_onTap()
    }

    // MARK: - 26.1 在 UIControl 层的演示
    /// UISwitch → onJobsChange
    private func demo_Switch_onJobsChange() {
        addSectionTitle("26.1-1️⃣  UISwitch：onJobsChange(.valueChanged)")
        stack.addArrangedSubview(UISwitch()
            .onJobsChange { (sw: UISwitch) in
                print("开关状态：\(sw.isOn)")
            })
    }
    /// UIDatePicker → onJobsChange
    private func demo_DatePicker_onJobsChange() {
        addSectionTitle("26.1-2️⃣  UIDatePicker：onJobsChange(.valueChanged)")
        stack.addArrangedSubview(UIDatePicker()
            .byDatePickerMode(.date)                           // 你的链式样式
            .byPreferredDatePickerStyle(.wheels)               // 你的链式样式
            .onJobsChange { (picker :UIDatePicker) in
                print("选择日期：\(picker.date)")
            })
    }
    /// UISlider → onJobsChange
    private func demo_Slider_onJobsChange() {
        addSectionTitle("26.1-3️⃣  UISlider：onJobsChange(.valueChanged)")
        stack.addArrangedSubview(UISlider()
            .byMinimumValue(0)
            .byMaximumValue(100)
            .byValue(30)
            .onJobsChange { (s:UISlider) in
                print("滑块值：\(s.value)")
            })
    }
    /// UITextField → onJobsEvent(.editingChanged)
    private func demo_TextField_onJobsEvent() {
        addSectionTitle("26.1-4️⃣  UITextField：onJobsEvent(.editingChanged)")
        stack.addArrangedSubview(UITextField()
            .byBorderStyle(.roundedRect)
            .byPlaceholder("输入点什么…")
            .onJobsEvent(.editingChanged) { (tf:UITextField) in
            print("文字变化：\(tf.text ?? "")")
        })
    }
    // MARK: - 26.2 在 UIButton 层的演示（保留你原有 onTap）
    private func demo_Button_onTap() {
        addSectionTitle("26.2 🔘 UIButton：onTap（UIButton 专属 UIAction）")
        stack.addArrangedSubview(UIButton(type: .system)
                                 // 普通文字：未选中状态标题
                                 .byTitle("显示", for: .normal)
                                 // 选中状态标题
                                 .byTitle("隐藏", for: .selected)
                                 // 文字颜色：区分状态
                                 .byTitleColor(.systemBlue, for: .normal)
                                 .byTitleColor(.systemRed, for: .selected)
                                 // 字体统一
                                 .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
                                 // 图标（SF Symbol）
                                 .byImage(UIImage(systemName: "eye.slash"), for: .normal)   // 未选中图标
                                 .byImage(UIImage(systemName: "eye"), for: .selected)       // 选中图标
                                 // 图文内边距
                                 .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
                                 // 图标与文字间距
                                 .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
                                 // 点按事件（统一入口）
                                 .onTap { [weak self] btn in
                                     guard let self else { return }
                                     btn.isSelected.toggle()                  // 切换选中状态
                                     print("👁")
                                 })
    }
    // MARK: - Helpers
    private func addSectionTitle(_ text: String) {
        stack.addArrangedSubview(UILabel().byText(text)
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byTextColor(.secondaryLabel))
    }

    @objc private func endEditingNow() {
        view.endEditing(true)
    }
}
