//
//  UIKitModel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/18.
//

import Foundation
import UIKit
import KakaJSON
// MARK: - BaseModel
class BaseModel: NSObject, NSCoding, NSSecureCoding {
    /// NSSecureCoding 支持
    static var supportsSecureCoding: Bool {
        return true
    }
    /// NSCoding
    required init?(coder: NSCoder) {
        super.init()
        // 解码属性请在子类实现
    }

    func encode(with coder: NSCoder) {
        // 编码属性请在子类实现
    }
}
// MARK: - UIButtonModel
class UIButtonModel: BaseModel {
    /// 位置尺寸
    var leftViewWidth: CGFloat = 0
    var rightViewWidth: CGFloat = 0
    var titleWidth: CGFloat = 0
    var subTitleWidth: CGFloat = 0
    /// 未选中状态数据源
    var normal_titles: [String]?
    var normal_titleFonts: [UIFont]?
    var normal_titleCors: [UIColor]?
    var normal_attributedTitles: [NSAttributedString]?

    var normal_subTitles: [String]?
    var normal_subTitleFonts: [UIFont]?
    var normal_subTitleCors: [UIColor]?
    var normal_attributedSubtitles: [NSAttributedString]?

    var normal_baseBackgroundColors: [UIColor]?
    var normal_backgroundImages: [UIImage]?
    var normal_images: [UIImage]?
    var imagePaddings: [NSNumber]?
    /// 已选中状态数据源
    var selected_titles: [String]?
    var selected_titleFonts: [UIFont]?
    var selected_titleCors: [UIColor]?
    var selected_attributedTitles: [NSAttributedString]?

    var selected_subTitles: [String]?
    var selected_subTitleFonts: [UIFont]?
    var selected_subTitleCors: [UIColor]?
    var selected_attributedSubtitles: [NSAttributedString]?

    var selected_baseBackgroundColors: [UIColor]?
    var selected_backgroundImages: [UIImage]?
    var selected_Images: [UIImage]?
    var selected_imagePaddings: [NSNumber]?
    /// 点击事件
    var primaryAction: UIAction?
    var clickEventBlock: JobsReturnIDByIDBlock?
    var longPressGestureEventBlock: JobsReturnIDByIDBlock?
    var onClickBlock: jobsByBtnBlock?
    var onLongPressGestureEventBlock: jobsByBtnBlock?
    /// UI 约束
    var masonryBlock: jobsByMASConstraintMakerBlock?
    /// 计时器
    var timerManager: NSTimerManager?
    /// 按钮挂载
    var data: Any?
    var view: UIView?
    /// 保留测试字段
    var jobsReturnedTestBlock: JobsReturnRACDisposableByReturnIDByIDBlocks?
    var jobsTestBlock: jobsByVoidBlock?
    ///  Convertible 协议
    required init() {}
}
// MARK: - UITextFieldModel
class UITextFieldModel: BaseModel {
    
}
// MARK: - UITextModel
class UITextModel: BaseModel {
    
}
// MARK: - UIViewModel
class UIViewModel: BaseModel {
    
}
