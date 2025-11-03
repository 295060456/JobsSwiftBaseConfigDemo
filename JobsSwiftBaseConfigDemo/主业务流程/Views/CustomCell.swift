//
//  CustomCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/10.
//

import UIKit
import SnapKit

class CustomCell: UITableViewCell {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.font = .boldSystemFont(ofSize: 16)
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(15)
        }
    }

    func config(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
