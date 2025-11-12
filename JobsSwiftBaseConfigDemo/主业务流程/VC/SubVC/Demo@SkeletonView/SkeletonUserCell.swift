//
//  SkeletonUserCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit
import SkeletonView

final class SkeletonUserCell: UITableViewCell {
    // MARK: - UI（lazy）
    private lazy var avatar: UIImageView = {
        let iv = UIImageView()
            .bySkeletonable()
            .bySkeletonCornerRadius(24)
            .byAddTo(contentView) { make in
                make.size.equalTo(CGSize(width: 48, height: 48))
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.top.greaterThanOrEqualToSuperview().offset(12)
                make.bottom.lessThanOrEqualToSuperview().inset(12)
            }
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 16, weight: .semibold))
            .byTextColor(.label)
            .byNumberOfLines(1)
            .bySkeletonable()
            .bySkeletonLinesCornerRadius(6)
    }()

    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .regular))
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(2)
            .bySkeletonable()
            .bySkeletonLinesCornerRadius(6)
            .bySkeletonLastLineFillPercent(60)
    }()

    private lazy var stack: UIStackView = {
        UIStackView()
            .byAxis(.vertical)
            .byAlignment(.fill)
            .byDistribution(.fill)
            .bySpacing(6)
            .byAddArrangedSubviews([titleLabel, subtitleLabel])
            .byAddTo(contentView) { [unowned self] make in
                make.leading.equalTo(avatar.snp.trailing).offset(12)
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalTo(avatar)
            }
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .secondarySystemGroupedBackground
        avatar.byVisible(YES)
        stack.byVisible(YES)
        self.bySkeletonable()
        contentView.bySkeletonable()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    // MARK: - Data
    func configure(with u: User) {
        avatar.backgroundColor = u.color
        titleLabel.byText(u.name)
        subtitleLabel.byText(u.detail)
    }
}
