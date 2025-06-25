//
//  UINavigationController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UINavigationController {
    @discardableResult
    func pushViewControllerByAnimated(_ viewController: UIViewController) -> Self {
        self.pushViewController(viewController, animated: true)
        return self
    }
    
    @discardableResult
    func pushViewController(_ viewController: UIViewController) -> Self {
        self.pushViewController(viewController, animated: false)
        return self
    }

    @discardableResult
    func popViewControllerByAnimated() -> Self {
        self.popViewController(animated: true)
        return self
    }
    
    @discardableResult
    func popViewController() -> Self {
        self.popViewController(animated: false)
        return self
    }

    @discardableResult
    func byNavigationBarHiddenByAnimated(_ hidden: Bool) -> Self {
        self.setNavigationBarHidden(hidden, animated: true)
        return self
    }
    
    @discardableResult
    func byNavigationBarHidden(_ hidden: Bool) -> Self {
        self.setNavigationBarHidden(hidden, animated: false)
        return self
    }

    @discardableResult
    func byViewControllersByAnimated(_ controllers: [UIViewController]) -> Self {
        self.setViewControllers(controllers, animated: true)
        return self
    }
    
    @discardableResult
    func byViewControllers(_ controllers: [UIViewController]) -> Self {
        self.setViewControllers(controllers, animated: false)
        return self
    }
    
}
