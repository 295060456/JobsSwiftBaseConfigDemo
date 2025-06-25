//
//  UISwitch.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UISwitch {
    @discardableResult
    func byOn(_ on: Bool) -> Self {
        self.setOn(on, animated: false)
        return self
    }
    
    @discardableResult
    func byOnAnimated(_ on: Bool) -> Self {
        self.setOn(on, animated: true)
        return self
    }
    
    @discardableResult
    func byOnTintColor(_ color: UIColor) -> Self {
        self.onTintColor = color
        return self
    }

    @discardableResult
    func byThumbTintColor(_ color: UIColor) -> Self {
        self.thumbTintColor = color
        return self
    }

    @discardableResult
    func byEnabled(_ enabled: Bool) -> Self {
        self.isEnabled = enabled
        return self
    }
}
