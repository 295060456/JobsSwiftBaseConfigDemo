//
//  UILabel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit
import Foundation
import ObjectiveC

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

    // MARK: 显示样式（把旧枚举语义映射到具体行为）
    @discardableResult
    func makeLabelByShowingType(_ type: UILabelShowingType) -> Self {
        superview?.layoutIfNeeded()
        switch type {
        case .type01:
            // 一行 + 省略号
            numberOfLines = 1
            lineBreakMode = .byTruncatingTail

        case .type02:
            // 一行 + 裁剪（如需滚动，外层包 UIScrollView 再放 label）
            numberOfLines = 1
            lineBreakMode = .byClipping
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.defaultLow, for: .horizontal)

        case .type03:
            // 一行，不定宽，定高，定字体 → 让宽度自适应
            numberOfLines = 1
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .horizontal)

        case .type04:
            // 一行，定宽定高，通过缩小字体完整显示
            numberOfLines = 1
            adjustsFontSizeToFitWidth = true
            minimumScaleFactor = 0.6
            lineBreakMode = .byClipping

        case .type05:
            // 多行，定宽不定高，定字体
            numberOfLines = 0
            lineBreakMode = .byWordWrapping
        }
        return self
    }

    // MARK: 方向变换（使用 CATextLayer，避免富文本/对齐丢失）
    @discardableResult
    func transformLayer(_ direction: TransformLayerDirectionType) -> Self {
        superview?.layoutIfNeeded()

        // 清理旧 layer（避免重复叠加）
        layer.sublayers?
            .filter { $0 is CATextLayer && $0.name == "JobsTextLayer" }
            .forEach { $0.removeFromSuperlayer() }

        let textLayer = CATextLayer()
        textLayer.name = "JobsTextLayer"
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .fromNSTextAlignment(textAlignment)
        textLayer.truncationMode = (lineBreakMode == .byTruncatingHead) ? .start :
                                   (lineBreakMode == .byTruncatingMiddle) ? .middle :
                                   (lineBreakMode == .byTruncatingTail) ? .end : .none
        textLayer.isWrapped = (numberOfLines == 0)

        if let attributed = attributedText {
            textLayer.string = attributed
        } else {
            textLayer.string = text ?? ""
            textLayer.foregroundColor = textColor.cgColor
            textLayer.font = font
            textLayer.fontSize = font.pointSize
        }
        textLayer.frame = bounds

        switch direction {
        case .up:
            break
        case .left:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
        case .down:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        case .right:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
        }

        layer.addSublayer(textLayer)
        textColor = .clear // 只显示 layer 的文字
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
