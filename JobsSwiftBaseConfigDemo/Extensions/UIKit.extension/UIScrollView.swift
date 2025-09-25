//
//  UIScrollView.swift
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
/// @discardableResult 即使调用这个方法后不使用它的返回值，也不要警告。
extension UIScrollView {

    @discardableResult
    func byContentSize(_ size: CGSize) -> Self {
        self.contentSize = size
        return self
    }

    @discardableResult
    func byContentOffsetBy(_ offset: CGPoint) -> Self {
        self.setContentOffset(offset, animated: false)
        return self
    }

    @discardableResult
    func byContentOffsetByAnimated(_ offset: CGPoint) -> Self {
        self.setContentOffset(offset, animated: true)
        return self
    }

    @discardableResult
    func byShowsVerticalScrollIndicator(_ show: Bool) -> Self {
        self.showsVerticalScrollIndicator = show
        return self
    }

    @discardableResult
    func byShowsHorizontalScrollIndicator(_ show: Bool) -> Self {
        self.showsHorizontalScrollIndicator = show
        return self
    }

    @discardableResult
    func byBounces(_ bounces: Bool) -> Self {
        self.bounces = bounces
        return self
    }

    @discardableResult
    func byAlwaysBounceVertical(_ enable: Bool) -> Self {
        self.alwaysBounceVertical = enable
        return self
    }

    @discardableResult
    func byAlwaysBounceHorizontal(_ enable: Bool) -> Self {
        self.alwaysBounceHorizontal = enable
        return self
    }

    @discardableResult
    func byPagingEnabled(_ enabled: Bool) -> Self {
        self.isPagingEnabled = enabled
        return self
    }

    @discardableResult
    func byScrollEnabled(_ enabled: Bool) -> Self {
        self.isScrollEnabled = enabled
        return self
    }

    @discardableResult
    func byDirectionalLockEnabled(_ enabled: Bool) -> Self {
        self.isDirectionalLockEnabled = enabled
        return self
    }

    @discardableResult
    func byScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.scrollIndicatorInsets = insets
        return self
    }

    @discardableResult
    func byContentInset(_ insets: UIEdgeInsets) -> Self {
        self.contentInset = insets
        return self
    }

    @discardableResult
    func byIndicatorStyle(_ style: UIScrollView.IndicatorStyle) -> Self {
        self.indicatorStyle = style
        return self
    }

    @discardableResult
    func byDelegate(_ delegate: UIScrollViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byKeyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        self.keyboardDismissMode = mode
        return self
    }

    @discardableResult
    func byRefreshControl(_ control: UIRefreshControl?) -> Self {
        self.refreshControl = control
        return self
    }

    @discardableResult
    func byDecelerationRate(_ rate: UIScrollView.DecelerationRate) -> Self {
        self.decelerationRate = rate
        return self
    }

    @discardableResult
    func byScrollsToTop(_ enabled: Bool) -> Self {
        self.scrollsToTop = enabled
        return self
    }
}
