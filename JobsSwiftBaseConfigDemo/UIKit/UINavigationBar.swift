//
//  UINavigationBar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UINavigationBar {
    @discardableResult
    func byBarTintColor(_ color: UIColor) -> Self {
        self.barTintColor = color
        return self
    }

    @discardableResult
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }

    @discardableResult
    func byTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any]) -> Self {
        self.titleTextAttributes = attributes
        return self
    }

    @discardableResult
    func byTranslucent(_ isTranslucent: Bool) -> Self {
        self.isTranslucent = isTranslucent
        return self
    }

    @discardableResult
    func byBackgroundImageBy(_ image: UIImage?, for barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(image, for: barMetrics)
        return self
    }
}
