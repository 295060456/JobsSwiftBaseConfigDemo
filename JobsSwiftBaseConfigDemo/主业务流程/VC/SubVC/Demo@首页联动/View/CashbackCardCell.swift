//
//  CashbackCardCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

final class CashbackCardCell: UITableViewCell {

    private let corner: CGFloat = 22

    private lazy var cardView: UIView = {
        var cardView =  UIView()
            .byCornerRadius(corner)
            .byAddTo(contentView) { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
            }

        cardView.layer.insertSublayer(gradient, at: 0)
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = .init(width: 0, height: 3)

        return cardView
    }()

    private lazy var iconWrap: UIView = {
        UIView()
            .byBgColor(.systemOrange)
            .byCornerRadius(12)
            .byAddTo(cardView) { make in
                make.leading.top.equalToSuperview().offset(18)
                make.size.equalTo(CGSize(width: 56, height: 56))
            }
    }()

    private lazy var iconView: UIImageView = {
        UIImageView(image: UIImage(systemName: "envelope.fill"))
            .byTintColor(.white)
            .byContentMode(.scaleAspectFit)
            .byAddTo(iconWrap) { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 30, height: 24))
            }
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("——")
            .byFont(.systemFont(ofSize: 20, weight: .semibold))
            .byTextColor(.label)
            .byAddTo(cardView) { [unowned self] make in
                make.leading.equalTo(iconWrap.snp.trailing).offset(16)
                make.trailing.equalTo(cardView).inset(16)
                make.top.equalTo(iconWrap.snp.top).offset(2)
            }
    }()

    private lazy var subLabel: UILabel = {
        UILabel()
            .byText("神秘彩金等你来拿")
            .byFont(.systemFont(ofSize: 16))
            .byTextColor(.secondaryLabel)
            .byAddTo(cardView) { [unowned self] make in
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalTo(titleLabel.snp.trailing)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.bottom.lessThanOrEqualTo(cardView).inset(16)
            }
    }()

    private lazy var gradient:CAGradientLayer = {
        CAGradientLayer()
            .byCGColors([
                UIColor(red: 0.90, green: 0.78, blue: 0.97, alpha: 1).cgColor, // #E6C7F7
                UIColor(red: 0.82, green: 0.72, blue: 0.95, alpha: 1).cgColor  // #D1B7F3
            ])
            .byStartPoint(CGPoint(x: 0, y: 0.5))
            .byEndPoint(CGPoint(x: 1, y: 0.5))
            .byCornerRadius(corner)

    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.byVisible(YES)
        iconWrap.byVisible(YES)
        iconView.byVisible(YES)
        titleLabel.byVisible(YES)
        subLabel.byVisible(YES)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = cardView.bounds
    }

    func configure(title: String, subtitle: String) {
        titleLabel.byText(title)
        subLabel.byText(subtitle)
    }
}
