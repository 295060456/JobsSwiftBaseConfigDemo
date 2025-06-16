//
//  UIDatePicker.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIDatePicker {
    @discardableResult
    func byDateByAnimated(_ date: Date) -> Self {
        self.setDate(date, animated: true)
        return self
    }
    
    @discardableResult
    func byDateBy(_ date: Date) -> Self {
        self.setDate(date, animated: false)
        return self
    }

    @discardableResult
    func byDatePickerMode(_ mode: UIDatePicker.Mode) -> Self {
        self.datePickerMode = mode
        return self
    }

    @discardableResult
    func byMinimumDate(_ date: Date?) -> Self {
        self.minimumDate = date
        return self
    }

    @discardableResult
    func byMaximumDate(_ date: Date?) -> Self {
        self.maximumDate = date
        return self
    }

    @discardableResult
    func byPreferredDatePickerStyle(_ style: UIDatePickerStyle) -> Self {
        self.preferredDatePickerStyle = style
        return self
    }
}
