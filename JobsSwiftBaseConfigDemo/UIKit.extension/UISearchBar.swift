//
//  UISearchBar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UISearchBar {
    @discardableResult
    func byDelegate(_ delegate: UISearchBarDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byPlaceholder(_ text: String) -> Self {
        self.placeholder = text
        return self
    }

    @discardableResult
    func byText(_ text: String) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    func byBarTintColor(_ color: UIColor) -> Self {
        self.barTintColor = color
        return self
    }

    @discardableResult
    func byShowsCancelButton(_ show: Bool) -> Self {
        self.showsCancelButton = show
        return self
    }
}
