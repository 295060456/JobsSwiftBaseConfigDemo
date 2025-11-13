//
//  BaseTableViewCellByValue2.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/13/25.
//

import UIKit
/// 左侧留一个图片的位置 + 左侧一个主标题 + 左侧一个副标题（紧贴主标题）
class BaseTableViewCellByValue2: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
