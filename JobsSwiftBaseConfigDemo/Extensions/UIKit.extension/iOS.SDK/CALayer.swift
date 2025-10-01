//
//  CALayer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension CALayer {
    // MARK: - 背景色
    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        self.backgroundColor = color.cgColor
        return self
    }

    // MARK: - 圆角
    @discardableResult
    func byCornerRadius(_ radius: CGFloat) -> Self {
        self.cornerRadius = radius
        return self
    }

    // MARK: - 圆角遮罩
    @discardableResult
    func byMasksToBounds(_ enabled: Bool) -> Self {
        self.masksToBounds = enabled
        return self
    }

    // MARK: - 边框
    @discardableResult
    func byBorderColor(_ color: UIColor) -> Self {
        self.borderColor = color.cgColor
        return self
    }

    @discardableResult
    func byBorderWidth(_ width: CGFloat) -> Self {
        self.borderWidth = width
        return self
    }

    // MARK: - 透明度
    @discardableResult
    func byOpacity(_ value: Float) -> Self {
        self.opacity = value
        return self
    }

    // MARK: - 阴影
    @discardableResult
    func byShadow(color: UIColor,
                  opacity: Float = 0.5,
                  offset: CGSize = .zero,
                  radius: CGFloat = 3) -> Self {
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        self.shadowOffset = offset
        self.shadowRadius = radius
        return self
    }
}
