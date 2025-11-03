//
//  CollectionCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/10.
//

import UIKit
import SnapKit

class CollectionCell: UICollectionViewCell {

    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }

    func config(title: String, image: UIImage) {
        titleLabel.text = title
        imageView.image = image
    }
}

