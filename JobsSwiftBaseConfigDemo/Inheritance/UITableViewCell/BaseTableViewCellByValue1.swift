//
//  BaseTableViewCellByValue1.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/13/25.
//

import UIKit
/// 左侧一张图 + 左侧一个主标题 + 右侧一个副标题
class BaseTableViewCellByValue1: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
