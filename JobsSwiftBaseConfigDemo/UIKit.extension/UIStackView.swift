//
//  UIStackView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIStackView {
    @discardableResult
    func byAxis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }

    @discardableResult
    func byDistribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    @discardableResult
    func byAlignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }

    @discardableResult
    func bySpacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    @discardableResult
    func addArrangedSubviews(_ views: UIView...) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        return self
    }
}
