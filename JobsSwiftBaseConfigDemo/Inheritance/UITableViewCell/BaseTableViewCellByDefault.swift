//
//  BaseTableViewCellByDefault.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/13/25.
//

import UIKit
/// 左侧一张图 + 左侧一个主标题 
class BaseTableViewCellByDefault: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
