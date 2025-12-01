//
//  UIButton+BRPickerAdditions.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

public extension UIButton {
    // 角标（红点）
    @discardableResult
    func byCornerDot(diameter: CGFloat = 8, offset: UIOffset = .zero) -> Self {
        let tag = 9527
        let dot: UIView = viewWithTag(tag) ?? {
            let v = UIView()
            v.tag = tag
            v.layer.cornerRadius = diameter / 2
            v.backgroundColor = .systemRed
            addSubview(v)
            return v
        }()
        dot.snp.remakeConstraints { make in
            make.size.equalTo(CGSize(width: diameter, height: diameter))
            make.top.equalToSuperview().offset(offset.vertical)
            make.trailing.equalToSuperview().offset(offset.horizontal)
        }
        return self
    }

    // 角标（文字）
    struct BRBadgeConfig {
        public var offset: UIOffset = .zero
        public var inset: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
        public var bgColor: UIColor = .systemRed
        public var font: UIFont = .systemFont(ofSize: 11, weight: .bold)
        public var shadow: (UIColor, CGFloat, Float, CGSize)?
    }

    @discardableResult
    func byCornerBadgeText(_ text: String, _ config: (inout BRBadgeConfig) -> Void) -> Self {
        var cfg = BRBadgeConfig()
        config(&cfg)

        let tag = 9528
        let label: UILabel = (viewWithTag(tag) as? UILabel) ?? {
            let l = UILabel()
            l.tag = tag
            l.textAlignment = .center
            l.clipsToBounds = true
            addSubview(l)
            return l
        }()

        // 样式
        label.text = text
        label.font = cfg.font
        label.textColor = .white
        label.backgroundColor = cfg.bgColor

        // 用字体计算内容尺寸，再把 padding 算进去
        let raw = (text as NSString).size(withAttributes: [.font: cfg.font])
        let badgeW = ceil(raw.width  + cfg.inset.left + cfg.inset.right)
        let badgeH = ceil(raw.height + cfg.inset.top  + cfg.inset.bottom)

        // 关键点：一次性 remake 所有约束（含 width/height），避免 update 找不到目标约束
        label.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(cfg.offset.vertical)
            make.trailing.equalToSuperview().offset(cfg.offset.horizontal)
            make.height.equalTo(badgeH)
            make.width.greaterThanOrEqualTo(badgeW)
        }

        label.layer.cornerRadius = max(10, badgeH / 2)

        if let s = cfg.shadow {
            label.layer.shadowColor = s.0.cgColor
            label.layer.shadowRadius = s.1
            label.layer.shadowOpacity = s.2
            label.layer.shadowOffset = s.3
        }
        return self
    }
}

