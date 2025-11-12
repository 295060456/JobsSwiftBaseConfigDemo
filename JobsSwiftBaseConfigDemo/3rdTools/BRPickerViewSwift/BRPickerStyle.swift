//
//  BRPickerStyle.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit

public struct BRPickerStyle {
    public var title: String?
    public var titleFont: UIFont = .systemFont(ofSize: 17, weight: .semibold)
    public var titleColor: UIColor = .label

    public var doneText: String = "完成"
    public var doneFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    public var doneColor: UIColor = .systemBlue

    public var cancelText: String = "取消"
    public var cancelFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    public var cancelColor: UIColor = .secondaryLabel

    public var toolbarBackgroundColor: UIColor = .secondarySystemBackground
    public var pickerBackgroundColor: UIColor = .systemBackground
    public var separatorColor: UIColor = .separator

    public var isAutoSelect: Bool = false
    public var allowTouchToDismiss: Bool = true
    public var cornerRadius: CGFloat = 14
    public var maskAlpha: CGFloat = 0.25

    // 文本选择
    public var rowHeight: CGFloat = 44
    public var columnWidth: CGFloat? = nil
    public var columnSpacing: CGFloat = 8

    // 日期选择
    public var minuteInterval: Int = 1
    public var use12HourClock: Bool = false

    public init(title: String? = nil) { self.title = title }
}
