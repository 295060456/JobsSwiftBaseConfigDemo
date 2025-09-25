//
//  UIButton.swift
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

extension UIButton {
    @discardableResult
    func byTitle(_ title: String?, for state: UIControl.State = .normal) -> Self {
        self.setTitle(title, for: state)
        return self
    }

    @discardableResult
    func byTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func byFont(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }

    @discardableResult
    func byImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setImage(image, for: state)
        return self
    }

    @discardableResult
    func byBackgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setBackgroundImage(image, for: state)
        return self
    }
}

