//
//  UIView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import UIKit

extension UIView {
    @discardableResult
    func byBgColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    func byCornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        return self
    }

    @discardableResult
    func byMasksToBounds(_ masksToBounds: Bool) -> Self {
        self.layer.masksToBounds = masksToBounds
        return self
    }

    @discardableResult
    func byBorderColor(_ color: UIColor) -> Self {
        self.layer.borderColor = color.cgColor
        return self
    }

    @discardableResult
    func byBorderWidth(_ width: CGFloat) -> Self {
        self.layer.borderWidth = width
        return self
    }

    @discardableResult
    func byHidden(_ hidden: Bool) -> Self {
        self.isHidden = hidden
        return self
    }

    @discardableResult
    func byAlpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }

    @discardableResult
    func byTag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }

    @discardableResult
    func byUserInteractionEnabled(_ enabled: Bool) -> Self {
        self.isUserInteractionEnabled = enabled
        return self
    }
}
// MARK: - UIView · Geometry / Transform / Scale / Touch
extension UIView {
    // 几何
    @discardableResult
    func byFrame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }

    @discardableResult
    func byBounds(_ bounds: CGRect) -> Self {
        self.bounds = bounds
        return self
    }

    @discardableResult
    func byCenter(_ center: CGPoint) -> Self {
        self.center = center
        return self
    }

    // 2D/3D 变换
    @discardableResult
    func byTransform(_ transform: CGAffineTransform) -> Self {
        self.transform = transform
        return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    func byTransform3D(_ t3d: CATransform3D) -> Self {
        self.transform3D = t3d
        return self
    }

    // 缩放因子（渲染分辨率）
    @available(iOS 4.0, *)
    @discardableResult
    func byContentScaleFactor(_ scale: CGFloat) -> Self {
        self.contentScaleFactor = scale
        return self
    }

    // 锚点（注意：会影响 frame，需要配合 position/center 调整）
    @available(iOS 16.0, *)
    @discardableResult
    func byAnchorPoint(_ anchor: CGPoint) -> Self {
        self.anchorPoint = anchor
        return self
    }

    // 触摸行为
    @discardableResult
    func byMultipleTouchEnabled(_ enabled: Bool) -> Self {
        self.isMultipleTouchEnabled = enabled
        return self
    }

    @discardableResult
    func byExclusiveTouch(_ enabled: Bool) -> Self {
        self.isExclusiveTouch = enabled
        return self
    }
}
// MARK: - UIView · Subview Hierarchy
extension UIView {
    /// 添加子视图（链式）✅ 返回调用者（父视图）
    @discardableResult
    func byAddSubviewRetSuper(_ view: UIView) -> Self {
        addSubview(view)
        return self //
    }
    /// 添加子视图（链式）✅ 返回子视图
    @discardableResult
    func byAddSubviewRetSub<T: UIView>(_ view: T) -> T {
        addSubview(view)
        return view
    }
    /// 在指定层级插入 ✅ 返回调用者（父视图）
    @discardableResult
    func byInsertSubview(_ view: UIView, at index: Int) -> Self {
        insertSubview(view, at: index)
        return self
    }
    /// 在指定层级插入 ✅ 返回子视图
    @discardableResult
    func byInsertSubviewRetSub<T: UIView>(_ view: T, at index: Int) -> T {
        insertSubview(view, at: index)
        return view
    }
    /// 在某视图之下插入 ✅ 返回调用者（父视图）
    @discardableResult
    func byInsertSubview(_ view: UIView, below sibling: UIView) -> Self {
        insertSubview(view, belowSubview: sibling)
        return self
    }
    /// 在某视图之下插入 ✅ 返回子视图
    @discardableResult
    func byInsertSubviewRetSub<T: UIView>(_ view: T, below sibling: UIView) -> T {
        insertSubview(view, belowSubview: sibling)
        return view
    }
    /// 在某视图之上插入 ✅ 返回调用者（父视图）
    @discardableResult
    func byInsertSubview(_ view: UIView, above sibling: UIView) -> Self {
        insertSubview(view, aboveSubview: sibling)
        return self
    }
    /// 在某视图之上插入 ✅ 返回子视图
    @discardableResult
    func byInsertSubviewRetSub<T: UIView>(_ view: T, above sibling: UIView) -> T {
        insertSubview(view, aboveSubview: sibling)
        return view
    }
    /// 交换两个下标的子视图 ✅ 返回调用者（父视图）
    @discardableResult
    func byExchangeSubview(at i: Int, with j: Int) -> Self {
        exchangeSubview(at: i, withSubviewAt: j)
        return self
    }
    /// 置顶 ✅ 返回调用者（父视图）
    @discardableResult
    func byBringToFront(_ view: UIView) -> Self {
        bringSubviewToFront(view)
        return self
    }
    /// 置顶 ✅ 返回子视图
    @discardableResult
    func byBringToFrontRetSub<T: UIView>(_ view: T) -> T {
        bringSubviewToFront(view)
        return view
    }
    /// 置底 ✅ 返回调用者（父视图）
    @discardableResult
    func bySendToBack(_ view: UIView) -> Self {
        sendSubviewToBack(view)
        return self
    }
    /// 置底 ✅ 返回子视图
    @discardableResult
    func bySendToBackRetSub<T: UIView>(_ view: T) -> T {
        sendSubviewToBack(view)
        return view
    }
    /// 移除自身 ✅ 返回调用者（父视图）
    @discardableResult
    func byRemoveFromSuperview() -> Self {
        removeFromSuperview()
        return self
    }
    /// 移除所有子视图（便捷）
    @discardableResult
    func byRemoveAllSubviews() -> Self {
        subviews.forEach { $0.removeFromSuperview() }
        return self
    }
}
// MARK: - UIView · Autoresizing / Layout Margins / Safe Area
extension UIView {
    /// 是否对子视图做 autoresize
    @discardableResult
    func byAutoresizesSubviews(_ enabled: Bool) -> Self {
        self.autoresizesSubviews = enabled
        return self
    }
    /// 自伸缩掩码
    @discardableResult
    func byAutoresizingMask(_ mask: UIView.AutoresizingMask) -> Self {
        self.autoresizingMask = mask
        return self
    }
    /// 传统 layoutMargins
    @available(iOS 8.0, *)
    @discardableResult
    func byLayoutMargins(_ insets: UIEdgeInsets) -> Self {
        self.layoutMargins = insets
        return self
    }
    /// 方向化的 layoutMargins（更现代）
    @available(iOS 11.0, *)
    @discardableResult
    func byDirectionalLayoutMargins(_ insets: NSDirectionalEdgeInsets) -> Self {
        self.directionalLayoutMargins = insets
        return self
    }
    /// 是否继承父视图的 layoutMargins
    @available(iOS 8.0, *)
    @discardableResult
    func byPreservesSuperviewLayoutMargins(_ enabled: Bool) -> Self {
        self.preservesSuperviewLayoutMargins = enabled
        return self
    }
    /// 是否将 safeArea 纳入 layoutMargins 计算
    @available(iOS 11.0, *)
    @discardableResult
    func byInsetsLayoutMarginsFromSafeArea(_ enabled: Bool) -> Self {
        self.insetsLayoutMarginsFromSafeArea = enabled
        return self
    }
}
// MARK: - UIView · Layout Triggers
extension UIView {
    /// 标记需要布局
    @discardableResult
    func bySetNeedsLayout() -> Self {
        setNeedsLayout()
        return self
    }

    /// 立即布局
    @discardableResult
    func byLayoutIfNeeded() -> Self {
        layoutIfNeeded()
        return self
    }

    /// 自适应到指定尺寸（仅设置，不触发布局）
    @discardableResult
    func bySizeThatFits(_ size: CGSize) -> Self {
        _ = sizeThatFits(size)
        return self
    }

    /// 自身尺寸适配
    @discardableResult
    func bySizeToFit() -> Self {
        sizeToFit()
        return self
    }
}
// MARK: - 手势封装
extension UIView {
    @discardableResult
    func jobs_addGesture<T: UIGestureRecognizer>(_ gesture: T?) -> T? {
        guard let gesture = gesture else { return nil }
        self.addGestureRecognizer(gesture)
        return gesture
    }
}

