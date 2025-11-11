//
//  LiveMsgCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//
import UIKit
import SnapKit

final class LiveMsgCell: UITableViewCell {
    private lazy var bubble: UIView = {
        UIView()
            .byBgColor(.secondarySystemBackground)
            .byCornerRadius(12)
            .byMasksToBounds(true)
            .byAddTo(contentView) {[unowned self] make in
                make.top.equalToSuperview().offset(6)
                make.bottom.equalToSuperview().inset(6)
                make.leading.equalToSuperview().offset(12)
                make.trailing.lessThanOrEqualToSuperview().inset(12)
            }
    }()
    private lazy var label: UILabel = {
        UILabel()
            .byNumberOfLines(0)
            .byFont(.systemFont(ofSize: 16))
            .byTextColor(.label)
            .byAddTo(bubble) {[unowned self] make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
            }
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        bubble.byVisible(YES)
        label.byVisible(YES)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ m: LiveMsg) -> Self{
        label.byText(m.text)
        return self
    }

    func playAppearAnimation() {
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: 22)
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.contentView.alpha = 1
            self.contentView.transform = .identity
        }
    }
}
