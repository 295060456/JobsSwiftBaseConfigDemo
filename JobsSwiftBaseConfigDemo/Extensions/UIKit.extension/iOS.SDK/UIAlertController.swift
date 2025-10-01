//
//  UIAlertController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension UIAlertController {
    static func alert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }

    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        self.addAction(action)
        return self
    }

    @discardableResult
    func addCancelAction(title: String = "取消", handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        return self.addAction(title: title, style: .cancel, handler: handler)
    }

    @discardableResult
    func addDestructiveAction(title: String, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        return self.addAction(title: title, style: .destructive, handler: handler)
    }

    func present(in viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.present(self, animated: animated, completion: completion)
    }
}
