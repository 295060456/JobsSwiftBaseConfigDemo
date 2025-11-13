//
//  BaseTableViewCellBySubtitle.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/13/25.
//

import UIKit
/// 左侧一张图 + 左侧一个主标题 + 左侧一个副标题（位于主标题垂直下方）
class BaseTableViewCellBySubtitle: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
