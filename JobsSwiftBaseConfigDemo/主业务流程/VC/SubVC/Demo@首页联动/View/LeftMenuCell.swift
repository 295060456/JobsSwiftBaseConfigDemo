//
//  LeftMenuCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

final class LeftMenuCell: UITableViewCell {

    private lazy var indicator: UIView = {
        UIView()
            .byBgColor(.systemOrange)
            .byAddTo(contentView) { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(4)
                make.height.equalTo(22)
            }
    }()

    private lazy var iconView: UIImageView = {
        UIImageView(image: UIImage(systemName: "star"))
            .byTintColor(.systemGray)
            .byContentMode(.scaleAspectFit)
            .byAddTo(contentView) { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 18, height: 18))
            }
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("--")
            .byFont(.systemFont(ofSize: 15, weight: .regular))
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.leading.equalTo(iconView.snp.trailing).offset(10)
                make.trailing.lessThanOrEqualToSuperview().inset(8)
                make.centerY.equalTo(iconView.snp.centerY)
            }
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        indicator.byHidden(YES)
        iconView.byVisible(YES)
        titleLabel.byVisible(YES)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(icon: String, title: String, selected: Bool) {
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        indicator.isHidden = !selected
        titleLabel.textColor = selected ? .label : .secondaryLabel
        iconView.tintColor = selected ? .systemOrange : .systemGray
        contentView.backgroundColor = selected
            ? UIColor.systemOrange.withAlphaComponent(0.15) // 浅橙底，贴近截图
            : .clear
    }
}
// MARK: - DSL
extension LeftMenuCell {
    /// 一次性设置：图标 + 标题 + 选中态
    @discardableResult
    func byMenu(icon: String,
                title: String,
                selected: Bool) -> Self {
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        return byMenuSelected(selected)
    }
    /// 仅更新选中态（便于复用）
    @discardableResult
    func byMenuSelected(_ selected: Bool) -> Self {
        indicator.isHidden = !selected
        titleLabel.byTextColor(selected ? .label : .secondaryLabel)
        iconView.byTintColor(selected ? .systemOrange : .systemGray)
        contentView.byBgColor(
            selected ? UIColor.systemOrange.withAlphaComponent(0.15) : .clear
        )
        return self
    }
    /// 仅更新标题或图标（可选）
    @discardableResult
    func byMenuTitle(_ text: String) -> Self { titleLabel.text = text; return self }

    @discardableResult
    func byMenuIcon(_ name: String) -> Self {
        iconView.image = UIImage(systemName: name); return self
    }
}
