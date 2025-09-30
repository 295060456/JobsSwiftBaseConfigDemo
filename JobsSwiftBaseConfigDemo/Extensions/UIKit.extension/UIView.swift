//
//  UIView.swift
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

import RxSwift
import RxCocoa
import ObjectiveC
// MARK: 语法糖🍬
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
    /// 几何
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
    /// 2D/3D 变换
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
    /// 缩放因子（渲染分辨率）
    @available(iOS 4.0, *)
    @discardableResult
    func byContentScaleFactor(_ scale: CGFloat) -> Self {
        self.contentScaleFactor = scale
        return self
    }
    /// 锚点（注意：会影响 frame，需要配合 position/center 调整）
    @available(iOS 16.0, *)
    @discardableResult
    func byAnchorPoint(_ anchor: CGPoint) -> Self {
        self.anchorPoint = anchor
        return self
    }
    /// 触摸行为
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
// MARK: - 手势封装：添加手势以后返回这个手势本身（常用于链式调用）
extension UIView {
    @discardableResult
    func jobs_addGesture<T: UIGestureRecognizer>(_ gesture: T?) -> T? {
        guard let gesture = gesture else { return nil }
        self.addGestureRecognizer(gesture)
        return gesture
    }
}
// MARK: - 手势通用闭包盒子
private final class _GestureActionBox {
    let action: (UIGestureRecognizer) -> Void
    init(_ action: @escaping (UIGestureRecognizer) -> Void) { self.action = action }
}
/**
 // MARK: - 点击 Tap
 UIView().addGestureRecognizer(
     UITapGestureRecognizer
         .byConfig { gr in
             print("Tap 触发 on: \(String(describing: gr.view))")
         }
         .byTaps(2)                       // 双击
         .byTouches(1)                    // 单指
         .byCancelsTouchesInView(true)
         .byEnabled(true)
         .byName("customTap")
 )

 // MARK: - 长按 LongPress
 UIView().addGestureRecognizer(
     UILongPressGestureRecognizer
         .byConfig { gr in
             if gr.state == .began {
                 print("长按开始")
             } else if gr.state == .ended {
                 print("长按结束")
             }
         }
         .byMinDuration(0.8)              // 最小按压时长
         .byMovement(12)                  // 允许移动距离
         .byTouches(1)                    // 单指
 )

 // MARK: - 拖拽 Pan
 UIView().addGestureRecognizer(
     UIPanGestureRecognizer
         .byConfig { gr in
             let p = (gr as! UIPanGestureRecognizer).translation(in: gr.view)
             if gr.state == .changed {
                 print("拖拽中: \(p)")
             } else if gr.state == .ended {
                 print("拖拽结束")
             }
         }
         .byMinTouches(1)
         .byMaxTouches(2)
         .byCancelsTouchesInView(true)
 )

 // MARK: - 轻扫 Swipe（单方向）
 UIView().addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in
             print("👉 右滑触发")
         }
         .byDirection(.right)
         .byTouches(1)
 )

 // MARK: - 轻扫 Swipe（多方向）
 let swipeContainer = UIView()
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("← 左滑") }
         .byDirection(.left)
 )
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("→ 右滑") }
         .byDirection(.right)
 )
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("↑ 上滑") }
         .byDirection(.up)
 )
 swipeContainer.addGestureRecognizer(
     UISwipeGestureRecognizer
         .byConfig { _ in print("↓ 下滑") }
         .byDirection(.down)
 )

 // MARK: - 捏合 Pinch
 UIView().addGestureRecognizer(
     UIPinchGestureRecognizer
         .byConfig { _ in }
         .byOnScaleChange { gr, scale in
             if gr.state == .changed {
                 print("缩放比例: \(scale)")
             }
         }
         .byScale(1.0)
 )

 // MARK: - 旋转 Rotate
 UIView().addGestureRecognizer(
     UIRotationGestureRecognizer
         .byConfig { _ in }
         .byOnRotationChange { gr, r in
             if gr.state == .changed {
                 print("旋转角度(弧度): \(r)")
             }
         }
         .byRotation(0)
 )
 // MARK: - 直接设置手势（已锚定视图）
 let views = UIView()
     .addTapAction { gr in
         print("点击 \(gr.view!)")
     }
     .addLongPressAction { gr in
         if gr.state == .began { print("长按开始") }
     }
     .addPanAction { gr in
         let p = (gr as! UIPanGestureRecognizer).translation(in: gr.view)
         print("拖拽中: \(p)")
     }
     .addPinchAction { gr in
         let scale = (gr as! UIPinchGestureRecognizer).scale
         print("缩放比例：\(scale)")
     }
     .addRotationAction { gr in
         let rotation = (gr as! UIRotationGestureRecognizer).rotation
         print("旋转角度：\(rotation)")
     }

 // MARK: - 在已有的手势触发事件里面新增手势行为
 UIView().addGestureRecognizer(UISwipeGestureRecognizer()
     .byDirection(.left)
     .byAction { gr in print("左滑 \(gr.view!)") })

 // MARK: - 多个方向的 swipe 并存
 // 同一 view 上同时添加四个方向的 swipe
 let idL = view.addSwipeActionMulti(direction: .left)  { gr in print("←") }
 let idR = view.addSwipeActionMulti(direction: .right) { gr in print("→") }
 let idU = view.addSwipeActionMulti(direction: .up)    { gr in print("↑") }
 let idD = view.addSwipeActionMulti(direction: .down)  { gr in print("↓") }

 // 指定 id，方便链式与管理
 view.addSwipeActionMulti(use: "swipe.left", direction: .left) { _ in }
     .addSwipeActionMulti(use: "swipe.right", direction: .right) { _ in }

 // 精确移除某一个
 view.removeSwipeActionMulti(id: idL)
 // 或批量移除该类手势
 view.removeAllSwipeActionsMulti()
 */
// ================================== UIView + 手势 DSL（全量、兼容） ==================================
public extension UIView {
    // 每个手势类型独立 key（同时用于“view->gesture”和“gesture->box”）
    private struct GestureKeys {
        static var tapKey: UInt8 = 0
        static var longKey: UInt8 = 0
        static var panKey: UInt8 = 0
        static var swipeKey: UInt8 = 0
        static var pinchKey: UInt8 = 0
        static var rotateKey: UInt8 = 0
    }

    // MARK: - Tap（点击）
    /// 新接口：带 gesture；兼容链式配置
    @discardableResult
    func addTapAction(
        taps: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresExclusiveTouchType: Bool = false,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.tapKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(_gestureHandleTap(_:)))
        tap.numberOfTapsRequired = taps
        tap.cancelsTouchesInView = cancelsTouchesInView
        if #available(iOS 9.2, *) {
            tap.requiresExclusiveTouchType = requiresExclusiveTouchType
        }
        addGestureRecognizer(tap)

        objc_setAssociatedObject(self, &GestureKeys.tapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(tap, &GestureKeys.tapKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口：无参数（向下兼容）
    @discardableResult
    func addTapAction(_ action: @escaping () -> Void) -> Self {
        addTapAction { _ in action() }
    }
    @objc private func _gestureHandleTap(_ sender: UITapGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.tapKey) as? _GestureActionBox)?.action(sender)
    }
    func removeTapAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.tapKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.tapKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    // MARK: - LongPress（长按）
    @discardableResult
    func addLongPressAction(
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.longKey) as? UILongPressGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let long = UILongPressGestureRecognizer(target: self, action: #selector(_gestureHandleLong(_:)))
        long.minimumPressDuration = minimumPressDuration
        long.allowableMovement = allowableMovement
        long.numberOfTouchesRequired = numberOfTouchesRequired
        addGestureRecognizer(long)

        objc_setAssociatedObject(self, &GestureKeys.longKey, long, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(long, &GestureKeys.longKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addLongPressAction(_ action: @escaping () -> Void) -> Self {
        addLongPressAction { _ in action() }
    }
    @objc private func _gestureHandleLong(_ sender: UILongPressGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.longKey) as? _GestureActionBox)?.action(sender)
    }
    func removeLongPressAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.longKey) as? UILongPressGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.longKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    // MARK: - Pan（拖拽）
    @discardableResult
    func addPanAction(
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int.max,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.panKey) as? UIPanGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(_gestureHandlePan(_:)))
        pan.minimumNumberOfTouches = minimumNumberOfTouches
        if maximumNumberOfTouches != Int.max { pan.maximumNumberOfTouches = maximumNumberOfTouches }
        addGestureRecognizer(pan)

        objc_setAssociatedObject(self, &GestureKeys.panKey, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(pan, &GestureKeys.panKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addPanAction(_ action: @escaping () -> Void) -> Self {
        addPanAction { _ in action() }
    }
    @objc private func _gestureHandlePan(_ sender: UIPanGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.panKey) as? _GestureActionBox)?.action(sender)
    }
    func removePanAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.panKey) as? UIPanGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.panKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    // MARK: - Swipe（轻扫）
    @discardableResult
    func addSwipeAction(
        direction: UISwipeGestureRecognizer.Direction = .right,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.swipeKey) as? UISwipeGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(_gestureHandleSwipe(_:)))
        swipe.direction = direction
        swipe.numberOfTouchesRequired = numberOfTouchesRequired
        addGestureRecognizer(swipe)

        objc_setAssociatedObject(self, &GestureKeys.swipeKey, swipe, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(swipe, &GestureKeys.swipeKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addSwipeAction(_ action: @escaping () -> Void) -> Self {
        addSwipeAction { _ in action() }
    }
    @objc private func _gestureHandleSwipe(_ sender: UISwipeGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.swipeKey) as? _GestureActionBox)?.action(sender)
    }
    func removeSwipeAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.swipeKey) as? UISwipeGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.swipeKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    // MARK: - Pinch（捏合缩放）
    @discardableResult
    func addPinchAction(_ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.pinchKey) as? UIPinchGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(_gestureHandlePinch(_:)))
        addGestureRecognizer(pinch)

        objc_setAssociatedObject(self, &GestureKeys.pinchKey, pinch, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(pinch, &GestureKeys.pinchKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addPinchAction(_ action: @escaping () -> Void) -> Self {
        addPinchAction { _ in action() }
    }
    @objc private func _gestureHandlePinch(_ sender: UIPinchGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.pinchKey) as? _GestureActionBox)?.action(sender)
    }
    func removePinchAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.pinchKey) as? UIPinchGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.pinchKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    // MARK: - Rotation（旋转）
    @discardableResult
    func addRotationAction(_ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        isUserInteractionEnabled = true

        if let old = objc_getAssociatedObject(self, &GestureKeys.rotateKey) as? UIRotationGestureRecognizer {
            removeGestureRecognizer(old)
        }

        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(_gestureHandleRotate(_:)))
        addGestureRecognizer(rotate)

        objc_setAssociatedObject(self, &GestureKeys.rotateKey, rotate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(rotate, &GestureKeys.rotateKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addRotationAction(_ action: @escaping () -> Void) -> Self {
        addRotationAction { _ in action() }
    }
    @objc private func _gestureHandleRotate(_ sender: UIRotationGestureRecognizer) {
        (objc_getAssociatedObject(sender, &GestureKeys.rotateKey) as? _GestureActionBox)?.action(sender)
    }
    func removeRotationAction() {
        if let g = objc_getAssociatedObject(self, &GestureKeys.rotateKey) as? UIRotationGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &GestureKeys.rotateKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    // MARK: - 便利方法：一次性清理
    func removeAllGestureActions() {
        removeTapAction()
        removeLongPressAction()
        removePanAction()
        removeSwipeAction()
        removePinchAction()
        removeRotationAction()
    }
}
/**
     // 同一 view 上同时添加四个方向的 swipe
     let idL = view.addSwipeActionMulti(direction: .left)  { gr in print("←") }
     let idR = view.addSwipeActionMulti(direction: .right) { gr in print("→") }
     let idU = view.addSwipeActionMulti(direction: .up)    { gr in print("↑") }
     let idD = view.addSwipeActionMulti(direction: .down)  { gr in print("↓") }

     // 指定 id，方便链式与管理
     view.addSwipeActionMulti(use: "swipe.left", direction: .left) { _ in }
         .addSwipeActionMulti(use: "swipe.right", direction: .right) { _ in }

     // 精确移除某一个
     view.removeSwipeActionMulti(id: idL)
     // 或批量移除该类手势
     view.removeAllSwipeActionsMulti()
 */
// MARK: - 多个方向的 swipe 并存
public extension UIView {
    // 为每种手势维护一个 “id -> gesture” 的字典
    private struct GestureMultiKeys {
        static var tapMap:    UInt8 = 0
        static var longMap:   UInt8 = 0
        static var panMap:    UInt8 = 0
        static var swipeMap:  UInt8 = 0
        static var pinchMap:  UInt8 = 0
        static var rotateMap: UInt8 = 0
    }

    // 取/存 通用 map（view 维度）
    private func _grMap(for key: UnsafeRawPointer) -> [String: UIGestureRecognizer] {
        (objc_getAssociatedObject(self, key) as? [String: UIGestureRecognizer]) ?? [:]
    }
    private func _setGrMap(_ map: [String: UIGestureRecognizer], for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Tap（多实例）
    /// 返回生成的 id（便于后续精确移除）
    @discardableResult
    func addTapActionMulti(
        id: String = UUID().uuidString,
        taps: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresExclusiveTouchType: Bool = false,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.tapMap)
        // 如果同 id 已存在，先移除再覆盖
        if let old = map[id] as? UITapGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UITapGestureRecognizer(target: self, action: #selector(_gestureHandleTap(_:)))
        gr.numberOfTapsRequired = taps
        gr.cancelsTouchesInView = cancelsTouchesInView
        if #available(iOS 9.2, *) { gr.requiresExclusiveTouchType = requiresExclusiveTouchType }
        addGestureRecognizer(gr)

        // 复用单实例版里“gesture -> box”的关联键（每个 recognizer 独立存一份）
        objc_setAssociatedObject(gr, &GestureKeys.tapKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.tapMap)
        return id
    }

    /// 提供一个便于链式的重载：你自己指定 id，可继续链式
    @discardableResult
    func addTapActionMulti(
        use id: String,
        taps: Int = 1,
        cancelsTouchesInView: Bool = true,
        requiresExclusiveTouchType: Bool = false,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addTapActionMulti(id: id, taps: taps, cancelsTouchesInView: cancelsTouchesInView, requiresExclusiveTouchType: requiresExclusiveTouchType, action)
        return self
    }

    func removeTapActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.tapMap)
        if let g = map[id] {
            removeGestureRecognizer(g)
            map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.tapMap)
        }
    }
    func removeAllTapActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.tapMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll()
        _setGrMap(map, for: &GestureMultiKeys.tapMap)
    }

    // MARK: - LongPress（多实例）
    @discardableResult
    func addLongPressActionMulti(
        id: String = UUID().uuidString,
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.longMap)
        if let old = map[id] as? UILongPressGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UILongPressGestureRecognizer(target: self, action: #selector(_gestureHandleLong(_:)))
        gr.minimumPressDuration = minimumPressDuration
        gr.allowableMovement = allowableMovement
        gr.numberOfTouchesRequired = numberOfTouchesRequired
        addGestureRecognizer(gr)

        objc_setAssociatedObject(gr, &GestureKeys.longKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.longMap)
        return id
    }
    @discardableResult
    func addLongPressActionMulti(
        use id: String,
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addLongPressActionMulti(id: id, minimumPressDuration: minimumPressDuration, allowableMovement: allowableMovement, numberOfTouchesRequired: numberOfTouchesRequired, action)
        return self
    }
    func removeLongPressActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.longMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.longMap)
        }
    }
    func removeAllLongPressActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.longMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.longMap)
    }

    // MARK: - Pan（多实例）
    @discardableResult
    func addPanActionMulti(
        id: String = UUID().uuidString,
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int.max,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.panMap)
        if let old = map[id] as? UIPanGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UIPanGestureRecognizer(target: self, action: #selector(_gestureHandlePan(_:)))
        gr.minimumNumberOfTouches = minimumNumberOfTouches
        if maximumNumberOfTouches != Int.max { gr.maximumNumberOfTouches = maximumNumberOfTouches }
        addGestureRecognizer(gr)

        objc_setAssociatedObject(gr, &GestureKeys.panKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.panMap)
        return id
    }
    @discardableResult
    func addPanActionMulti(
        use id: String,
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int.max,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addPanActionMulti(id: id, minimumNumberOfTouches: minimumNumberOfTouches, maximumNumberOfTouches: maximumNumberOfTouches, action)
        return self
    }
    func removePanActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.panMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.panMap)
        }
    }
    func removeAllPanActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.panMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.panMap)
    }

    // MARK: - Swipe（多实例）
    @discardableResult
    func addSwipeActionMulti(
        id: String = UUID().uuidString,
        direction: UISwipeGestureRecognizer.Direction = .right,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.swipeMap)
        if let old = map[id] as? UISwipeGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UISwipeGestureRecognizer(target: self, action: #selector(_gestureHandleSwipe(_:)))
        gr.direction = direction
        gr.numberOfTouchesRequired = numberOfTouchesRequired
        addGestureRecognizer(gr)

        objc_setAssociatedObject(gr, &GestureKeys.swipeKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.swipeMap)
        return id
    }
    @discardableResult
    func addSwipeActionMulti(
        use id: String,
        direction: UISwipeGestureRecognizer.Direction = .right,
        numberOfTouchesRequired: Int = 1,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> Self {
        _ = addSwipeActionMulti(id: id, direction: direction, numberOfTouchesRequired: numberOfTouchesRequired, action)
        return self
    }
    func removeSwipeActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.swipeMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.swipeMap)
        }
    }
    func removeAllSwipeActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.swipeMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.swipeMap)
    }

    // MARK: - Pinch（多实例）
    @discardableResult
    func addPinchActionMulti(
        id: String = UUID().uuidString,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.pinchMap)
        if let old = map[id] as? UIPinchGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UIPinchGestureRecognizer(target: self, action: #selector(_gestureHandlePinch(_:)))
        addGestureRecognizer(gr)

        objc_setAssociatedObject(gr, &GestureKeys.pinchKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.pinchMap)
        return id
    }
    @discardableResult
    func addPinchActionMulti(use id: String, _ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        _ = addPinchActionMulti(id: id, action)
        return self
    }
    func removePinchActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.pinchMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.pinchMap)
        }
    }
    func removeAllPinchActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.pinchMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.pinchMap)
    }

    // MARK: - Rotation（多实例）
    @discardableResult
    func addRotationActionMulti(
        id: String = UUID().uuidString,
        _ action: @escaping (UIGestureRecognizer) -> Void
    ) -> String {
        isUserInteractionEnabled = true

        var map = _grMap(for: &GestureMultiKeys.rotateMap)
        if let old = map[id] as? UIRotationGestureRecognizer { removeGestureRecognizer(old) }

        let gr = UIRotationGestureRecognizer(target: self, action: #selector(_gestureHandleRotate(_:)))
        addGestureRecognizer(gr)

        objc_setAssociatedObject(gr, &GestureKeys.rotateKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.rotateMap)
        return id
    }
    @discardableResult
    func addRotationActionMulti(use id: String, _ action: @escaping (UIGestureRecognizer) -> Void) -> Self {
        _ = addRotationActionMulti(id: id, action)
        return self
    }
    func removeRotationActionMulti(id: String) {
        var map = _grMap(for: &GestureMultiKeys.rotateMap)
        if let g = map[id] {
            removeGestureRecognizer(g); map.removeValue(forKey: id)
            _setGrMap(map, for: &GestureMultiKeys.rotateMap)
        }
    }
    func removeAllRotationActionsMulti() {
        var map = _grMap(for: &GestureMultiKeys.rotateMap)
        map.values.forEach { removeGestureRecognizer($0) }
        map.removeAll(); _setGrMap(map, for: &GestureMultiKeys.rotateMap)
    }
}
// MARK: - UIView.keyboardHeight (Observable<CGFloat>)
private var kKeyboardHeightKey: UInt8 = 0
public extension UIView {
    /// 监听当前视图所处界面的键盘可见高度（单位：pt）
    /// - 说明：
    ///   - 当键盘显示/隐藏/高度变化时发出事件
    ///   - 已扣除 `safeAreaInsets.bottom`，拿到的是“真实遮挡高度”
    ///   - 已做去重（distinctUntilChanged）与主线程派发
    var keyboardHeight: Observable<CGFloat> {
        // 缓存：确保同一视图多次访问用同一个 Observable
        if let cached = objc_getAssociatedObject(self, &kKeyboardHeightKey) as? Observable<CGFloat> {
            return cached
        }

        // 通知源
        let willShow  = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let willHide  = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let willChangeFrame = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)

        // 统一拿键盘 endFrame → 计算与当前视图的遮挡高度
        func height(from note: Notification) -> CGFloat {
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return 0
            }
            // 键盘是屏幕坐标，这里转到当前视图的坐标系，计算遮挡
            let window = self.window ?? UIApplication.shared.windows.first
            let endInView: CGRect = {
                if let win = window {
                    let rInWin = win.convert(frame, from: nil)
                    return self.convert(rInWin, from: win)
                } else {
                    // 没有 window 时退化处理
                    return self.convert(frame, from: nil)
                }
            }()
            // 视图底部到键盘顶部的重叠高度
            let overlap = max(0, self.bounds.maxY - endInView.minY)
            // 扣除底部安全区，得到真正需要上移/留白的高度
            let adjusted = max(0, overlap - self.safeAreaInsets.bottom)
            return adjusted.rounded(.towardZero) // 避免细微浮点波动
        }

        // 三类事件合并：
        // - show / changeFrame：计算高度
        // - hide：高度归零
        let showOrChange = Observable
            .merge(willShow, willChangeFrame)
            .map { height(from: $0) }

        let hide = willHide
            .map { _ in CGFloat(0) }

        let stream = Observable
            .merge(showOrChange, hide)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            // 保证多订阅者共享一个上游订阅；最后一个订阅者取消后自动释放
            .share(replay: 1, scope: .whileConnected)

        objc_setAssociatedObject(self, &kKeyboardHeightKey, stream, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return stream
    }
}
