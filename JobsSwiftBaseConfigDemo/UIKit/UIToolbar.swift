//
//  UIToolbar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIToolbar {
    @discardableResult
    func bySetItemsAnimated(_ items: [UIBarButtonItem]?) -> Self {
        self.setItems(items, animated: true)
        return self
    }
    
    @discardableResult
    func bySetItems(_ items: [UIBarButtonItem]?) -> Self {
        self.setItems(items, animated: false)
        return self
    }

    @discardableResult
    func byBarStyle(_ style: UIBarStyle) -> Self {
        self.barStyle = style
        return self
    }

    @discardableResult
    func byTranslucent(_ isTranslucent: Bool) -> Self {
        self.isTranslucent = isTranslucent
        return self
    }

    @discardableResult
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }

    @discardableResult
    func byBackgroundImage(_ image: UIImage?,
                           forToolbarPosition position: UIBarPosition,
                           barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(image,
                                forToolbarPosition: position,
                                barMetrics: barMetrics)
        return self
    }
}
