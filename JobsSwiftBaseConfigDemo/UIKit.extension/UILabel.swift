//
//  UILabel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit
import ObjectiveC

// MARK: - 枚举

public enum UILabelShowingType: Int {
    case oneLineTruncatingTail = 1
    case oneLineAutoWidthByFont
    case oneLineAutoFontByWidth
    case multiLineAutoHeightByFont
}

public enum TransformLayerDirectionType: UInt {
    case normalLTR
    case verticalTTB
    case upsideDown
}

// MARK: - UILabel 链式扩展

extension UILabel {
    @discardableResult
    func byText(_ text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    func byTextColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func byFont(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    func byTextAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    func byNumberOfLines(_ lines: Int) -> Self {
        self.numberOfLines = lines
        return self
    }

    @discardableResult
    func byLineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }

    @discardableResult
    func byBgCor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    func byAttributedString(_ attributed: NSAttributedString?) -> Self {
        self.attributedText = attributed
        return self
    }

    @discardableResult
    func byNextText(_ str: String?) -> Self {
        self.text = (self.text ?? "") + (str ?? "")
        return self
    }

    @discardableResult
    func byNextAttributedText(_ attributed: NSAttributedString?) -> Self {
        if let current = self.attributedText {
            let result = NSMutableAttributedString(attributedString: current)
            if let attributed { result.append(attributed) }
            self.attributedText = result
        } else {
            self.attributedText = attributed
        }
        return self
    }

    // 背景图 → 平铺色
    @discardableResult
    func bgImage(_ image: UIImage?) -> Self {
        if let img = image {
            self.backgroundColor = UIColor(patternImage: img)
        }
        return self
    }

    // 显示样式
    @discardableResult
    func makeLabelByShowingType(_ type: UILabelShowingType) -> Self {
        self.superview?.layoutIfNeeded()
        switch type {
        case .oneLineTruncatingTail:
            self.numberOfLines = 1
            self.lineBreakMode = .byTruncatingTail
        case .oneLineAutoWidthByFont:
            self.numberOfLines = 1
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .horizontal)
        case .oneLineAutoFontByWidth:
            self.numberOfLines = 1
            self.adjustsFontSizeToFitWidth = true
            self.minimumScaleFactor = 0.6
            self.lineBreakMode = .byClipping
        case .multiLineAutoHeightByFont:
            self.numberOfLines = 0
            self.lineBreakMode = .byWordWrapping
        }
        return self
    }

    // 简化版 transformLayer
    @discardableResult
    func transformLayer(_ direction: TransformLayerDirectionType) -> Self {
        self.superview?.layoutIfNeeded()
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .fromNSTextAlignment(self.textAlignment)
        if let attributed = self.attributedText {
            textLayer.string = attributed
        } else {
            textLayer.string = self.text ?? ""
        }
        textLayer.frame = self.bounds

        switch direction {
        case .normalLTR:
            break
        case .verticalTTB:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
        case .upsideDown:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        }

        self.layer.addSublayer(textLayer)
        self.textColor = .clear
        return self
    }
}

// MARK: - 辅助

private extension CATextLayerAlignmentMode {
    static func fromNSTextAlignment(_ a: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch a {
        case .left: return .left
        case .right: return .right
        case .center: return .center
        case .justified: return .justified
        case .natural: return .natural
        @unknown default: return .natural
        }
    }
}

/**
 
 let label = UILabel()
     .byFont(.systemFont(ofSize: 16))
     .byTextColor(.black)
     .byText("目录".localized())
     .byTextAlignment(.center)
     .makeLabelByShowingType(.oneLineTruncatingTail)
     .bgImage(UIImage(named: "bg_pattern"))
     .byNextText(" → More")
 
 */
