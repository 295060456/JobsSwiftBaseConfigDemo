//
//  UILabel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
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
    @discardableResult
    func byHugging(_ priority: UILayoutPriority,
                   axis: NSLayoutConstraint.Axis = .horizontal) -> Self {
        setContentHuggingPriority(priority, for: axis)
        return self
    }

    @discardableResult
    func byCompressionResistance(_ priority: UILayoutPriority,
                                 axis: NSLayoutConstraint.Axis = .horizontal) -> Self {
        setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
    // MARK: 背景图 → 平铺色
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
/// 一些功能性的
extension UILabel {
    // MARK: 设置富文本
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil) {
        self.attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
        self.isUserInteractionEnabled = false
    }
    // MARK: - 检测点击位置是否在指定富文本范围内
    func didTapAttributedText(in range: NSRange, at: UITapGestureRecognizer) -> Bool {
        guard let attributedText = attributedText else { return false }
        // 1️⃣ 创建 NSTextStorage 管理文本
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        // 2️⃣ 计算点击位置
        let location = at.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let offset = CGPoint(
            x: (bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationInTextContainer = CGPoint(
            x: location.x - offset.x,
            y: location.y - offset.y
        )
        // 3️⃣ 获取点击的字符索引
        let index = layoutManager.characterIndex(for: locationInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(index, range)
    }
    // MARK: 给 UILabel 里的文字加 下划线，并且可以指定下划线的颜色。
    func underline(color: UIColor) {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSAttributedString.Key.underlineColor,
                                          value: color,
                                          range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }
    }
}
