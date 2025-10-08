//
//  UIButtonConfiguration.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/8/25.
//

import UIKit

@available(iOS 15.0, tvOS 15.0, *)
public extension UIButton.Configuration {
    // ---------- 便捷风格切换 ----------
    @discardableResult func byPlain() -> Self {
        var c = self; c = .plain(); return c
    }
    @discardableResult func byGray() -> Self {
        var c = self; c = .gray(); return c
    }
    @discardableResult func byTinted() -> Self {
        var c = self; c = .tinted(); return c
    }
    @discardableResult func byFilled() -> Self {
        var c = self; c = .filled(); return c
    }
    @discardableResult func byBorderless() -> Self {
        var c = self; c = .borderless(); return c
    }
    @discardableResult func byBordered() -> Self {
        var c = self; c = .bordered(); return c
    }
    @discardableResult func byBorderedTinted() -> Self {
        var c = self; c = .borderedTinted(); return c
    }
    @discardableResult func byBorderedProminent() -> Self {
        var c = self; c = .borderedProminent(); return c
    }

    // ---------- 标题 / 副标题 ----------
    @discardableResult func byTitle(_ title: String?) -> Self {
        var c = self; c.title = title; return c
    }
    @discardableResult func byAttributedTitle(_ title: AttributedString?) -> Self {
        var c = self; c.attributedTitle = title; return c
    }
    @discardableResult func bySubtitle(_ subtitle: String?) -> Self {
        var c = self; c.subtitle = subtitle; return c
    }
    @discardableResult func byAttributedSubtitle(_ subtitle: AttributedString?) -> Self {
        var c = self; c.attributedSubtitle = subtitle; return c
    }
    @discardableResult func byTitleAlignment(_ alignment: UIButton.Configuration.TitleAlignment) -> Self {
        var c = self; c.titleAlignment = alignment; return c
    }
    @discardableResult func byTitlePadding(_ padding: CGFloat) -> Self {
        var c = self; c.titlePadding = padding; return c
    }

    // ---------- 颜色 ----------
    @discardableResult func byBaseForeground(_ color: UIColor?) -> Self {
        var c = self; c.baseForegroundColor = color; return c
    }
    @discardableResult func byBaseBackground(_ color: UIColor?) -> Self {
        var c = self; c.baseBackgroundColor = color; return c
    }
    @discardableResult func byImageColorTransformer(_ transformer: UIConfigurationColorTransformer?) -> Self {
        var c = self; c.imageColorTransformer = transformer; return c
    }

    // ---------- 图像 ----------
    @discardableResult func byImage(_ image: UIImage?) -> Self {
        var c = self; c.image = image; return c
    }
    @discardableResult func byPreferredSymbolConfig(_ cfg: UIImage.SymbolConfiguration?) -> Self {
        var c = self; c.preferredSymbolConfigurationForImage = cfg; return c
    }
    @discardableResult func byImagePlacement(_ placement: NSDirectionalRectEdge) -> Self {
        var c = self; c.imagePlacement = placement; return c
    }
    @discardableResult func byImagePadding(_ padding: CGFloat) -> Self {
        var c = self; c.imagePadding = padding; return c
    }

    // ---------- 布局 / 尺寸 ----------
    @discardableResult func byContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        var c = self; c.contentInsets = insets; return c
    }
    @discardableResult func bySetDefaultContentInsets() -> Self {
        var c = self; c.setDefaultContentInsets(); return c
    }
    @discardableResult func byButtonSize(_ size: UIButton.Configuration.Size) -> Self {
        var c = self; c.buttonSize = size; return c
    }
    @discardableResult func byCornerStyle(_ style: UIButton.Configuration.CornerStyle) -> Self {
        var c = self; c.cornerStyle = style; return c
    }

    // ---------- 行为 ----------
    @discardableResult func byAutoUpdateForSelection(_ enabled: Bool) -> Self {
        var c = self; c.automaticallyUpdateForSelection = enabled; return c
    }
    @discardableResult func byShowsActivity(_ show: Bool) -> Self {
        var c = self; c.showsActivityIndicator = show; return c
    }

    // ---------- iOS 16+ 指示器 ----------
    @available(iOS 16.0, tvOS 16.0, *)
    @discardableResult func byIndicator(_ indicator: UIButton.Configuration.Indicator) -> Self {
        var c = self; c.indicator = indicator; return c
    }
    @available(iOS 16.0, tvOS 16.0, *)
    @discardableResult func byIndicatorColorTransformer(_ transformer: UIConfigurationColorTransformer?) -> Self {
        var c = self; c.indicatorColorTransformer = transformer; return c
    }

    // ---------- iOS 26+ 符号转场（Xcode 16 / iOS 18+ 可能会看到） ----------
    @available(iOS 26.0, tvOS 26.0, *)
    @discardableResult func bySymbolContentTransition(_ t: UISymbolContentTransition?) -> Self {
        var c = self; c.symbolContentTransition = t; return c
    }

    // ---------- 背景 ----------
    @discardableResult func byBackground(_ background: UIBackgroundConfiguration) -> Self {
        var c = self; c.background = background; return c
    }
}
