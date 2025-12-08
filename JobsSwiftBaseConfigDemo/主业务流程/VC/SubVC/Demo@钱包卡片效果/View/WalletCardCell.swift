//
//  WalletCardCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/5/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
// MARK: - 普通银行卡 Cell（懒加载 + byAddTo）
final class WalletCardCell: UICollectionViewCell {
    private let horizontalInset: CGFloat = 16
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
            .byStartPoint(CGPoint(x: 0, y: 0))
            .byEndPoint(CGPoint(x: 1, y: 1))
            .byCornerRadius(14)
        contentView.layer.insertSublayer(layer, at: 0)
        return layer
    }()

    private lazy var logoView: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFit)
            .byTintColor(.white.withAlphaComponent(0.9))
            .byImage("creditcard.fill".sysImg)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalToSuperview().offset(12)
                make.right.equalToSuperview().inset(self.horizontalInset)
                make.width.equalTo(30)
                make.height.equalTo(22)
            }
    }()

    private lazy var bankLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 18, weight: .semibold))
            .byTextColor(.white)
            .byAddTo(contentView) { [unowned self] make in
                make.left.equalToSuperview().offset(self.horizontalInset)
                make.centerY.equalTo(self.logoView.snp.centerY)
            }
    }()


    private lazy var numberLabel: UILabel = {
      UILabel()
            .byFont(.monospacedDigitSystemFont(ofSize: 16, weight: .medium))
            .byTextColor(.white.withAlphaComponent(0.95))
            .byAddTo(contentView) { [unowned self] make in
                make.left.equalTo(self.bankLabel)
                make.bottom.equalToSuperview().inset(18)
            }
    }()

    private lazy var holderLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .regular))
            .byTextColor(.white.withAlphaComponent(0.8))
            .byAddTo(contentView) { [unowned self] make in
                make.left.equalTo(self.bankLabel)
                make.bottom.equalTo(self.numberLabel.snp.top).offset(-6)
            }
    }()

    private lazy var brandLabel: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .medium))
            .byTextColor(.white.withAlphaComponent(0.9))
            .byTextAlignment(.right)
            .byAddTo(contentView) { [unowned self] make in
                make.right.equalToSuperview().inset(self.horizontalInset)
                make.centerY.equalTo(self.holderLabel.snp.centerY)
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 6)

        // 触发懒加载创建 UI
        gradientLayer.byHidden(NO)
        logoView.byVisible(YES)
        bankLabel.byVisible(YES)
        numberLabel.byVisible(YES)
        holderLabel.byVisible(YES)
        brandLabel.byVisible(YES)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds,
                                                    cornerRadius: 14).cgPath
    }
    // MARK: - 配置
    func configure(with card: WalletCard, isHighlightedCard: Bool) {
        bankLabel.byText(card.bankName)
        numberLabel.byText("**** \(card.lastDigits)")
        holderLabel.byText(card.holder)
        brandLabel.byText(card.brand)
        gradientLayer.colors = card.gradientColors.map { $0.cgColor }
        applyHighlight(isHighlightedCard, animated: false)
    }

    private func applyHighlight(_ highlighted: Bool, animated: Bool) {
        let block = {
            self.transform = highlighted ? CGAffineTransform(scaleX: 1.02, y: 1.02) : .identity
            self.layer.shadowOpacity = highlighted ? 0.3 : 0.18
        }
        if animated {
            UIView.animate(withDuration: 0.18,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: block)
        } else {
            block()
        }
    }

    override var isHighlighted: Bool {
        didSet { applyHighlight(isHighlighted || isSelected, animated: true) }
    }

    override var isSelected: Bool {
        didSet { applyHighlight(isHighlighted || isSelected, animated: true) }
    }
}
// MARK: - “添加银行卡” Cell（懒加载 + byAddTo）
final class WalletAddCardCell: UICollectionViewCell {
    private let horizontalInset: CGFloat = 20
    private lazy var dashedBorder: CAShapeLayer = {
        CAShapeLayer()
            .byStrokeColor(.systemGray3)
            .byFillColor(.clear)
            .byLineDashPattern([6, 4])
            .byLineWidth(1)
            .byAddTo(self.layer)
    }()

    private lazy var iconView: UIImageView = {
        UIImageView()
            .byImage("plus.circle.fill".sysImg)
            .byTintColor(.systemBlue)
            .byContentMode(.scaleAspectFit)
            .byAddTo(contentView) { make in
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview().offset(-40)
                make.width.height.equalTo(26)
        }
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("添加新的银行卡".tr)
            .byFont(.systemFont(ofSize: 15, weight: .medium))
            .byTextColor(.systemBlue)
            .byAddTo(contentView) { [unowned self] make in
                make.left.equalTo(self.iconView.snp.right).offset(12)
                make.centerY.equalToSuperview()
            }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.secondarySystemBackground
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true

        dashedBorder.byHidden(NO);
        iconView.byVisible(YES)
        titleLabel.byVisible(YES)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 14).cgPath
        dashedBorder.path = path
        dashedBorder.frame = bounds
    }
}
