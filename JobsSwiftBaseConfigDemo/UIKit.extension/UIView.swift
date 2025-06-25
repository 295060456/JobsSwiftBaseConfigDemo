//
//  UIView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIView {
    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    func byCornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        return self
    }

    @discardableResult
    func byBorderColor(_ color: UIColor, width: CGFloat = 1) -> Self {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        return self
    }

    @discardableResult
    func byHidden(_ hidden: Bool) -> Self {
        self.isHidden = hidden
        return self
    }

    @discardableResult
    func byAlpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }

    @discardableResult
    func byTag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }

    @discardableResult
    func byUserInteractionEnabled(_ enabled: Bool) -> Self {
        self.isUserInteractionEnabled = enabled
        return self
    }
}
// MARK: - 手势封装
extension UIView {
    @discardableResult
    func jobs_addGesture<T: UIGestureRecognizer>(_ gesture: T?) -> T? {
        guard let gesture = gesture else { return nil }
        self.addGestureRecognizer(gesture)
        return gesture
    }
}
