//
//  Untitled.swift
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

extension UIViewController {
    func doAsync(after delay: TimeInterval = 1.0,
                 _ block: @escaping (Self) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let strongSelf = self else { return }
            block(strongSelf as! Self)
        }
    }
}

extension UIViewController {
    @discardableResult
    func byTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        self.view.backgroundColor = color
        return self
    }

    @discardableResult
    func addChildVC(_ child: UIViewController) -> Self {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)
        return self
    }

    @discardableResult
    func removeFromParentVC() -> Self {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        return self
    }

    @discardableResult
    func byPresentModallyAnimated(_ viewController: UIViewController,
                                  completion: (() -> Void)? = nil) -> Self {
        self.present(viewController,
                     animated: true,
                     completion: completion)
        return self
    }
}
