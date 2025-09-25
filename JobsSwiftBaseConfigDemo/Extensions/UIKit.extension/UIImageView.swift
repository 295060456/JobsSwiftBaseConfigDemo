//
//  UIImageView.swift
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

extension UIImageView {
    @discardableResult
    func byImage(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }

    @discardableResult
    func byContentMode(_ mode: UIView.ContentMode) -> Self {
        self.contentMode = mode
        return self
    }

    @discardableResult
    func byClipsToBounds(_ clips: Bool) -> Self {
        self.clipsToBounds = clips
        return self
    }
}
