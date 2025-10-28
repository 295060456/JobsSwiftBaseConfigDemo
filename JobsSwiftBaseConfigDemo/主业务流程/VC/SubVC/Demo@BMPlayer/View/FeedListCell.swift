//
//  FeedListCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import UIKit
import SnapKit

final class FeedListCell: UITableViewCell {
    private var task: URLSessionDataTask?
    // MARK: - 懒加载 UI
    private lazy var cover: UIImageView = { [unowned self] in
        UIImageView()
            .byBgColor(.secondarySystemBackground)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds(true)
            .byAddTo(contentView) { [unowned self] make in
                make.top.leading.trailing.equalToSuperview().inset(12)
                make.height.equalTo(cover.snp.width).multipliedBy(9.0 / 16.0)
            }
    }()

    private lazy var playIcon: UIImageView = { [unowned self] in
        UIImageView()
            .byImage(UIImage(systemName: "play.circle.fill"))
            .byTintColor(.white)
            .byContentMode(.scaleAspectFit)
            .byAlpha(0.9)
            .byAddTo(cover) { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(56)
            }
    }()

    private lazy var nameLabel: UILabel = { [unowned self] in
        UILabel()
            .byFont(.boldSystemFont(ofSize: 16))
            .byTextColor(.label)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(cover.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(12)
            }
    }()

    private lazy var contentLabel: UILabel = { [unowned self] in
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(2)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(nameLabel.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview().inset(12)
                make.bottom.equalToSuperview().inset(12)
            }
    }()

    // MARK: - 生命周期
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground
        cover.byVisible(YES)
        playIcon.byVisible(YES)
        nameLabel.byVisible(YES)
        contentLabel.byVisible(YES)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel(); task = nil
        cover.image = nil
        nameLabel.text = nil
        contentLabel.text = nil
    }

    func fill(_ item: FeedItem) {
        nameLabel.byText(item.nickname)
        contentLabel.byText(item.content.isEmpty ? " " : item.content)
        task = ImageLoader.shared.load(url: item.headImg, into: cover, placeholder: nil)
    }
}
