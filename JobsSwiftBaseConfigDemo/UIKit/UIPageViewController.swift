//
//  UIPageViewController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIPageViewController {
    @discardableResult
    func byViewControllers(_ viewControllers: [UIViewController], direction: NavigationDirection, animated: Bool = true, completion: ((Bool) -> Void)? = nil) -> Self {
        self.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
        return self
    }

    @discardableResult
    func byDataSource(_ dataSource: UIPageViewControllerDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult
    func byDelegate(_ delegate: UIPageViewControllerDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byTransitionStyle(_ style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) -> Self {
        return UIPageViewController(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
}
