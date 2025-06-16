//
//  UIBarButtonItem.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIBarButtonItem {
    static func item(title: String?, style: UIBarButtonItem.Style, target: Any?, action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(title: title, style: style, target: target, action: action)
    }

    static func item(image: UIImage?, style: UIBarButtonItem.Style, target: Any?, action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(image: image, style: style, target: target, action: action)
    }

    @discardableResult
    func byTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func byEnabled(_ enabled: Bool) -> Self {
        self.isEnabled = enabled
        return self
    }

    @discardableResult
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
}
