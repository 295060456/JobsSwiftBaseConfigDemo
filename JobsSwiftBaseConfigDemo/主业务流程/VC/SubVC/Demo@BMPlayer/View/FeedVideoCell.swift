//
//  FeedVideoCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import UIKit
import SnapKit

final class FeedVideoCell: UITableViewCell {
    // 播放器真正挂载到这个容器（PlayerCenter 负责把 BMPlayer 迁移到这里）
    let playerHost = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .black

        contentView.addSubview(playerHost)
        playerHost.backgroundColor = .black
        playerHost.clipsToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18)
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.numberOfLines = 2

        playerHost.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-6)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(28)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func fill(nickname: String, content: String) {
        titleLabel.text = nickname
        subtitleLabel.text = content.isEmpty ? " " : content
    }
}
