//
//  UIPageControl.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIPageControl {
    @discardableResult
    func byNumberOfPages(_ count: Int) -> Self {
        self.numberOfPages = count
        return self
    }

    @discardableResult
    func byCurrentPage(_ page: Int) -> Self {
        self.currentPage = page
        return self
    }

    @discardableResult
    func byPageIndicatorTintColor(_ color: UIColor) -> Self {
        self.pageIndicatorTintColor = color
        return self
    }

    @discardableResult
    func byCurrentPageIndicatorTintColor(_ color: UIColor) -> Self {
        self.currentPageIndicatorTintColor = color
        return self
    }
}
