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
import ObjectiveC
// MARK: 语法糖🍬
extension UIView {
    // MARK: 设置UI
    @discardableResult
    func byBgColor(_ color: UIColor?) -> Self {
        backgroundColor = color
        return self
    }

    @discardableResult
    func byHidden(_ hidden: Bool) -> Self {
        isHidden = hidden
        return self
    }

    @discardableResult
    func byAlpha(_ a: CGFloat) -> Self {
        alpha = a
        return self
    }
    /// 统一圆角：按钮走 UIButton.Configuration 方案，其他视图保持原始 layer 逻辑
    @discardableResult
    func byCornerRadius(_ radius: CGFloat) -> Self {
        let r = max(0, radius)
        // === 按钮：套用 byBtnCornerRadius 的实现（maskedCorners=nil, isContinuous=true） ===
        if let btn = self as? UIButton {
            if #available(iOS 15.0, *), var cfg = btn.configuration {
                cfg.cornerStyle = .fixed
                var bg = cfg.background
                bg.cornerRadius = r
                cfg.background = bg
                btn.configuration = cfg
            }
            btn.layer.cornerRadius = r
            if #available(iOS 13.0, *) {
                btn.layer.cornerCurve = .continuous
            }
            // maskedCorners 默认不传（等同 nil），因此这里不改 maskedCorners
            btn.clipsToBounds = (r > 0)
            return self
        }
        // === 非按钮 ===
        self.layer.cornerRadius = r
        return self
    }
    // MARK: 设置Layer
    /// 裁剪超出边界
    @discardableResult
    func byClipsToBounds(_ enabled: Bool = true) -> Self {
        clipsToBounds = enabled
        return self
    }

    @discardableResult
    func byMasksToBounds(_ masksToBounds: Bool) -> Self {
        layer.masksToBounds = masksToBounds
        return self
    }

    @discardableResult
    func byBorderColor(_ color: UIColor) -> Self {
        layer.borderColor = color.cgColor
        return self
    }

    @discardableResult
    func byBorderWidth(_ width: CGFloat) -> Self {
        layer.borderWidth = width
        return self
    }
    // MARK: - UIView · Geometry / Transform / Scale / Touch
    /// 几何
    @discardableResult
    func byFrame(_ f: CGRect) -> Self {
        frame = f
        return self
    }

    @discardableResult
    func byBounds(_ b: CGRect) -> Self {
        bounds = b
        return self
    }

    @discardableResult
    func byCenter(_ c: CGPoint) -> Self {
        center = c
        return self
    }
    /// 2D/3D 变换
    @discardableResult
    func byTransform(_ transf: CGAffineTransform) -> Self {
        transform = transf
        return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    func byTransform3D(_ t3d: CATransform3D) -> Self {
        transform3D = t3d
        return self
    }
    /// 缩放因子（渲染分辨率）
    @available(iOS 4.0, *)
    @discardableResult
    func byContentScaleFactor(_ scale: CGFloat) -> Self {
        contentScaleFactor = scale
        return self
    }
    /// 锚点（注意：会影响 frame，需要配合 position/center 调整）
    @available(iOS 16.0, *)
    @discardableResult
    func byAnchorPoint(_ anchor: CGPoint) -> Self {
        anchorPoint = anchor
        return self
    }
    /// 触摸行为
    @discardableResult
    func byMultipleTouchEnabled(_ enabled: Bool) -> Self {
        isMultipleTouchEnabled = enabled
        return self
    }

    @discardableResult
    func byExclusiveTouch(_ enabled: Bool) -> Self {
        isExclusiveTouch = enabled
        return self
    }
    // MARK: 尺寸@绝对设置
    @discardableResult
    func bySize(_ size: CGSize) -> Self {
        frame.size = size
        return self
    }

    @discardableResult
    func bySize(width: CGFloat, height: CGFloat) -> Self {
        frame.size = CGSize(width: width, height: height)
        return self
    }

    @discardableResult
    func byWidth(_ width: CGFloat) -> Self {
        var f = frame; f.size.width = width; frame = f
        return self
    }

    @discardableResult
    func byHeight(_ height: CGFloat) -> Self {
        var f = frame; f.size.height = height; frame = f
        return self
    }
    // MARK: 尺寸@相对偏移叠加
    /// 在当前宽度基础上叠加偏移（正负皆可）
    @discardableResult
    func byWidthOffset(_ delta: CGFloat) -> Self {
        var f = frame; f.size.width += delta; frame = f
        return self
    }
    /// 在当前高度基础上叠加偏移（正负皆可）
    @discardableResult
    func byHeightOffset(_ delta: CGFloat) -> Self {
        var f = frame; f.size.height += delta; frame = f
        return self
    }
    /// 同时对宽高做偏移（正负皆可）
    @discardableResult
    func bySizeOffset(width dw: CGFloat = 0, height dh: CGFloat = 0) -> Self {
        var f = frame; f.size.width += dw; f.size.height += dh; frame = f
        return self
    }
    // MARK: Frame@绝对设置
    @discardableResult
    func byFrame(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        var f = frame
        if let x = x { f.origin.x = x }
        if let y = y { f.origin.y = y }
        if let w = width { f.size.width = w }
        if let h = height { f.size.height = h }
        frame = f
        return self
    }
    // MARK: Frame@相对偏移叠加
    /// 在当前 x/y 基础上叠加偏移
    @discardableResult
    func byOriginOffset(dx: CGFloat = 0, dy: CGFloat = 0) -> Self {
        var f = frame; f.origin.x += dx; f.origin.y += dy; frame = f
        return self
    }
    @discardableResult
    func byOriginXOffset(_ dx: CGFloat = 0) -> Self {
        var f = frame; f.origin.x += dx; frame = f
        return self
    }
    @discardableResult
    func byOriginYOffset(_ dy: CGFloat = 0) -> Self {
        var f = frame; f.origin.y += dy; frame = f
        return self
    }
    /// 在当前 frame 基础上整体偏移（位置 + 尺寸）
    @discardableResult
    func byFrameOffset(dx: CGFloat = 0, dy: CGFloat = 0, dw: CGFloat = 0, dh: CGFloat = 0) -> Self {
        var f = frame
        f.origin.x += dx; f.origin.y += dy
        f.size.width += dw; f.size.height += dh
        frame = f
        return self
    }
    // MARK: 位置
    @discardableResult
    func byOrigin(_ point: CGPoint) -> Self {
        frame.origin = point
        return self
    }
    /// 在当前中心点基础上叠加偏移
    @discardableResult
    func byCenterOffset(dx: CGFloat = 0, dy: CGFloat = 0) -> Self {
        center = CGPoint(x: center.x + dx, y: center.y + dy)
        return self
    }
    // MARK: - UIView · Subview Hierarchy
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
    // MARK: - UIView · Autoresizing / Layout Margins / Safe Area
    /// 是否对子视图做 autoresize
    @discardableResult
    func byAutoresizesSubviews(_ enabled: Bool) -> Self {
        autoresizesSubviews = enabled
        return self
    }
    /// 自伸缩掩码
    @discardableResult
    func byAutoresizingMask(_ mask: UIView.AutoresizingMask) -> Self {
        autoresizingMask = mask
        return self
    }
    /// 传统 layoutMargins
    @available(iOS 8.0, *)
    @discardableResult
    func byLayoutMargins(_ insets: UIEdgeInsets) -> Self {
        layoutMargins = insets
        return self
    }
    /// 方向化的 layoutMargins（更现代）
    @available(iOS 11.0, *)
    @discardableResult
    func byDirectionalLayoutMargins(_ insets: NSDirectionalEdgeInsets) -> Self {
        directionalLayoutMargins = insets
        return self
    }
    /// 是否继承父视图的 layoutMargins
    @available(iOS 8.0, *)
    @discardableResult
    func byPreservesSuperviewLayoutMargins(_ enabled: Bool) -> Self {
        preservesSuperviewLayoutMargins = enabled
        return self
    }
    /// 是否将 safeArea 纳入 layoutMargins 计算
    @available(iOS 11.0, *)
    @discardableResult
    func byInsetsLayoutMarginsFromSafeArea(_ enabled: Bool) -> Self {
        insetsLayoutMarginsFromSafeArea = enabled
        return self
    }
    // MARK: - UIView · Layout Triggers
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
    // MARK: 其他
    @discardableResult
    func byContentMode(_ mode: UIView.ContentMode) -> Self {
        contentMode = mode;
        return self
    }

    @discardableResult
    func byTag(_ T: Int) -> Self {
        tag = T
        return self
    }

    @discardableResult
    func byUserInteractionEnabled(_ enabled: Bool) -> Self {
        isUserInteractionEnabled = enabled
        return self
    }
    /// 手势封装：添加手势以后返回这个手势本身@常用于链式调用
    @discardableResult
    func jobs_addGesture<T: UIGestureRecognizer>(_ gesture: T?) -> T? {
        guard let gesture = gesture else { return nil }
        addGestureRecognizer(gesture)
        return gesture
    }
    /// 刷新UI
    @discardableResult
    func refresh()-> Self{
        setNeedsLayout()
        layoutIfNeeded()
        return self
    }

    @discardableResult
    public func byActivate() -> Self {
        // 下一帧：让父视图先布局，再让自己重建，避免首帧 bounds==0 的问题
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
            setNeedsLayout()
        }
        return self
    }
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
    // MARK: - 手势通用闭包盒子
    private final class _GestureActionBox {
        let action: (UIGestureRecognizer) -> Void
        init(_ action: @escaping (UIGestureRecognizer) -> Void) { self.action = action }
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

        let tap = jobs_addGesture(
            UITapGestureRecognizer
                .byConfig { gr in
                    (objc_getAssociatedObject(gr, &GestureKeys.tapKey) as? _GestureActionBox)?.action(gr)
                    print("Tap 触发 on: \(String(describing: gr.view))")
                }
                .byTaps(taps)                       // 双击
                .byTouches(1)                       // 单指
                .byCancelsTouchesInView(cancelsTouchesInView)
                .byRequiresExclusiveTouchType(requiresExclusiveTouchType)
                .byEnabled(true)
                .byName("customTap"))!

        objc_setAssociatedObject(self, &GestureKeys.tapKey, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(tap, &GestureKeys.tapKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口：无参数（向下兼容）
    @discardableResult
    func addTapAction(_ action: @escaping () -> Void) -> Self {
        addTapAction { _ in action() }
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

        let long = jobs_addGesture(UILongPressGestureRecognizer
            .byConfig { gr in
                (objc_getAssociatedObject(gr, &GestureKeys.longKey) as? _GestureActionBox)?.action(gr)
            }
            .byMinDuration(minimumPressDuration)              // 最小按压时长
            .byMovement(allowableMovement)                    // 允许移动距离
            .byTouches(numberOfTouchesRequired)               // 单指
        )!

        objc_setAssociatedObject(self, &GestureKeys.longKey, long, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(long, &GestureKeys.longKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addLongPressAction(_ action: @escaping () -> Void) -> Self {
        addLongPressAction { _ in action() }
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

        let pan = jobs_addGesture(UIPanGestureRecognizer
            .byConfig { sender in
                (objc_getAssociatedObject(sender, &GestureKeys.panKey) as? _GestureActionBox)?.action(sender)
            }
            .byMinTouches(minimumNumberOfTouches)
            .byMaxTouches(maximumNumberOfTouches)
            .byCancelsTouchesInView(true))!

        objc_setAssociatedObject(self, &GestureKeys.panKey, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(pan, &GestureKeys.panKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addPanAction(_ action: @escaping () -> Void) -> Self {
        addPanAction { _ in action() }
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

        let swipe = jobs_addGesture(UISwipeGestureRecognizer
            .byConfig { sender in
                print("👉 右滑触发")
                (objc_getAssociatedObject(sender, &GestureKeys.swipeKey) as? _GestureActionBox)?.action(sender)
            }
            .byDirection(direction)
            .byTouches(numberOfTouchesRequired))!

        objc_setAssociatedObject(self, &GestureKeys.swipeKey, swipe, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(swipe, &GestureKeys.swipeKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addSwipeAction(_ action: @escaping () -> Void) -> Self {
        addSwipeAction { _ in action() }
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

        let pinch = jobs_addGesture(UIPinchGestureRecognizer
            .byConfig { _ in }
            .byOnScaleChange { sender, scale in
                (objc_getAssociatedObject(sender, &GestureKeys.pinchKey) as? _GestureActionBox)?.action(sender)
            }
        )!

        objc_setAssociatedObject(self, &GestureKeys.pinchKey, pinch, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(pinch, &GestureKeys.pinchKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }
    /// 旧接口兼容
    @discardableResult
    func addPinchAction(_ action: @escaping () -> Void) -> Self {
        addPinchAction { _ in action() }
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

        let rotate = jobs_addGesture(UIRotationGestureRecognizer
            .byConfig { _ in }
            .byOnRotationChange { sender, r in
                (objc_getAssociatedObject(sender, &GestureKeys.rotateKey) as? _GestureActionBox)?.action(sender)
            })!

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
        let gr = jobs_addGesture(
            UITapGestureRecognizer
                .byConfig { gr in
                    (objc_getAssociatedObject(gr, &GestureKeys.tapKey) as? _GestureActionBox)?.action(gr)
                    print("Tap 触发 on: \(String(describing: gr.view))")
                }
                .byTaps(taps)                       // 双击
                .byTouches(1)                       // 单指
                .byCancelsTouchesInView(cancelsTouchesInView)
                .byRequiresExclusiveTouchType(requiresExclusiveTouchType)
                .byEnabled(true)
                .byName("customTap"))!
        // 复用单实例版里“gesture -> box”的关联键（每个 recognizer 独立存一份）
        objc_setAssociatedObject(gr, &GestureKeys.tapKey, _GestureActionBox(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        map[id] = gr
        _setGrMap(map, for: &GestureMultiKeys.tapMap)
        return id
    }
    /// 提供一个便于链式的重载：自己指定 id，可继续链式
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

        let gr = jobs_addGesture(UILongPressGestureRecognizer
            .byConfig { gr in
                (objc_getAssociatedObject(gr, &GestureKeys.longKey) as? _GestureActionBox)?.action(gr)
            }
            .byMinDuration(minimumPressDuration)              // 最小按压时长
            .byMovement(allowableMovement)                    // 允许移动距离
            .byTouches(numberOfTouchesRequired)               // 单指
        )!

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
        _ = addLongPressActionMulti(id: id,
                                    minimumPressDuration: minimumPressDuration,
                                    allowableMovement: allowableMovement,
                                    numberOfTouchesRequired: numberOfTouchesRequired,
                                    action)
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

        let gr = jobs_addGesture(UIPanGestureRecognizer
            .byConfig { sender in
                (objc_getAssociatedObject(sender, &GestureKeys.panKey) as? _GestureActionBox)?.action(sender)
            }
            .byMinTouches(minimumNumberOfTouches)
            .byMaxTouches(maximumNumberOfTouches)
            .byCancelsTouchesInView(true))!

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
        _ = addPanActionMulti(id: id,
                              minimumNumberOfTouches: minimumNumberOfTouches,
                              maximumNumberOfTouches: maximumNumberOfTouches,
                              action)
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

        let gr = jobs_addGesture(UISwipeGestureRecognizer
            .byConfig { sender in
                print("👉 右滑触发")
                (objc_getAssociatedObject(sender, &GestureKeys.swipeKey) as? _GestureActionBox)?.action(sender)
            }
            .byDirection(direction)
            .byTouches(numberOfTouchesRequired))!

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

        let gr = jobs_addGesture(UIPinchGestureRecognizer
            .byConfig { _ in }
            .byOnScaleChange { sender, scale in
                (objc_getAssociatedObject(sender, &GestureKeys.pinchKey) as? _GestureActionBox)?.action(sender)
            }
        )!

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

public extension UIView {
    func _allSubviews() -> [UIView] { subviews + subviews.flatMap { $0._allSubviews() } }
    func _firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let s = self as? T { return s }
        for v in subviews { if let hit = v._firstSubview(of: type) { return hit } }
        return nil
    }
    /// 递归收集指定类型的所有子视图（避免与已有 `_allSubviews()` 重名）
    func _recursiveSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        for sub in subviews {
            if let t = sub as? T { result.append(t) }
            result.append(contentsOf: sub._recursiveSubviews(of: type))
        }
        return result
    }
    /// 向上寻找满足条件的祖先
    func _firstAncestor(where predicate: (UIView) -> Bool) -> UIView? {
        var p = superview
        while let v = p {
            if predicate(v) { return v }
            p = v.superview
        }
        return nil
    }
}
// MARK: - UIView.keyboardHeight (Observable<CGFloat>)
#if canImport(RxSwift) && canImport(RxCocoa)
import RxSwift
import RxCocoa
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
            let window = UIApplication.jobsKeyWindow()
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
#endif
/// 对 SnapKit 的封装
#if canImport(SnapKit)
import SnapKit
public extension UIView {
    // MARK: - 添加到父视图
    @discardableResult
    func byAddTo(_ superview: UIView,
                 _ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        superview.addSubview(self)
        if let closure {
            self.snp.makeConstraints(closure)
        }
        return self
    }
    // MARK: - 链式 makeConstraints
    @discardableResult
    func byMakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        self.snp.makeConstraints(closure)
        return self
    }
    // MARK: - 链式 remakeConstraints
    @discardableResult
    func byRemakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        self.snp.remakeConstraints(closure)
        return self
    }
    // MARK: - 链式 updateConstraints
    @discardableResult
    func byUpdateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        self.snp.updateConstraints(closure)
        return self
    }
    // MARK: - 链式 removeConstraints
    @discardableResult
    func byRemoveConstraints() -> Self {
        self.snp.removeConstraints()
        return self
    }
}
#endif

//  功能：给任意 UIView 增加悬浮能力（可拖拽、吸附、尊重安全区），默认挂在活动窗口。
//  风格：链式 DSL（.suspend / .bySuspend），主线程 API 使用 @MainActor 保障。
//  注意：悬浮 view 使用 frame 驱动，勿再对其添加 AutoLayout 约束。
//  依赖：UIKit + ObjectiveC 运行时
//

// ================================== 悬浮配置 ==================================
public extension UIView {
    /// 吸附策略
    enum SuspendDocking {
        /// 不吸附（停在哪算哪）
        case none
        /// 吸附最近的左右边
        case nearestEdge
        /// 吸附最近的四个角
        case nearestCorner
    }
    /// 悬浮行为配置
    struct SuspendConfig {
        /// 指定容器；默认挂到活动 window（多 scene 兼容）
        public var container: UIView? = nil
        /// 初始尺寸；当 view.size == .zero 时生效
        public var fallbackSize: CGSize = CGSize(width: 56, height: 56)
        /// 初始位置；nil 则使用右下角（安全区内 + insets）
        public var initialOrigin: CGPoint? = nil
        /// 是否允许拖拽
        public var draggable: Bool = true
        /// 吸附策略
        public var docking: SuspendDocking = .nearestEdge
        /// 对容器安全区的额外边距（会叠加到 safeAreaInsets 上）
        public var insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        /// 结束吸附是否动画
        public var animated: Bool = true
        /// 贴边时是否震动反馈
        public var hapticOnDock: Bool = false
        /// 拖动过程是否限制在容器内
        public var confineInContainer: Bool = true

        public init() {}
        public static var `default`: SuspendConfig { .init() }
    }
}

public extension UIView.SuspendConfig {
    // 工厂：链式外建
    static func dsl(_ build: (inout Self) -> Void) -> Self {
        var cfg = Self.default
        build(&cfg)
        return cfg
    }
    // Non-mutating：返回新副本，适合链式
    @discardableResult func byContainer(_ v: UIView?) -> Self { var c = self; c.container = v; return c }
    @discardableResult func byFallbackSize(_ v: CGSize) -> Self { var c = self; c.fallbackSize = v; return c }
    @discardableResult func byDocking(_ v: UIView.SuspendDocking) -> Self { var c = self; c.docking = v; return c }
    @discardableResult func byInitialOrigin(_ v: CGPoint?) -> Self { var c = self; c.initialOrigin = v; return c }
    @discardableResult func byDraggable(_ v: Bool) -> Self { var c = self; c.draggable = v; return c }
    @discardableResult func byInsets(_ v: UIEdgeInsets) -> Self { var c = self; c.insets = v; return c }
    @discardableResult func byInsets(top: CGFloat? = nil, left: CGFloat? = nil,
                                     bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        var c = self
        c.insets = UIEdgeInsets(
            top: top ?? c.insets.top,
            left: left ?? c.insets.left,
            bottom: bottom ?? c.insets.bottom,
            right: right ?? c.insets.right
        )
        return c
    }
    @discardableResult func byAnimated(_ v: Bool) -> Self { var c = self; c.animated = v; return c }
    @discardableResult func byHapticOnDock(_ v: Bool) -> Self { var c = self; c.hapticOnDock = v; return c }
    @discardableResult func byConfineInContainer(_ v: Bool) -> Self { var c = self; c.confineInContainer = v; return c }
}

public extension UIView {
    /// 是否已经悬浮（关联对象标记）
    var isSuspended: Bool {
        (objc_getAssociatedObject(self, &SuspendKeys.suspendedKey) as? Bool) ?? false
    }
    /// 解除悬浮：从容器移除并清理内部手势/配置
    @MainActor
    func unsuspend() {
        guard isSuspended else { return }
        if let pan = objc_getAssociatedObject(self, &SuspendKeys.panKey) as? UIPanGestureRecognizer {
            removeGestureRecognizer(pan)
        }
        objc_setAssociatedObject(self, &SuspendKeys.panKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SuspendKeys.configKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SuspendKeys.suspendedKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        removeFromSuperview()
    }
    /// 悬浮：挂到活动窗口或指定容器；支持拖拽/吸附/安全区
    /// - Parameter config: 悬浮配置（有默认值）
    /// - Returns: Self（链式）
    @discardableResult
    @MainActor
    func suspend(_ config: SuspendConfig = .default) -> Self {
        // 1) 保存配置
        objc_setAssociatedObject(self, &SuspendKeys.configKey, config, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 2) 选择容器
        let container: UIView = config.container ?? (UIApplication.jobsKeyWindow() ?? Self._fallbackWindow())
        // 3) 如果当前无父视图 -> 挂到容器
        if superview == nil {
            container.addSubview(self)
        }
        // 4) 尺寸兜底
        if bounds.size == .zero {
            frame.size = config.fallbackSize
        }
        // 5) 初始位置
        if let origin = config.initialOrigin {
            frame.origin = origin
        } else if frame.origin == .zero {
            // 默认：右下角（安全区 + insets 内）
            let b = Self._availableBounds(in: container, extraInsets: config.insets)
            frame.origin = CGPoint(x: b.maxX - frame.width, y: b.maxY - frame.height)
        }
        // 6) 约束在容器可用范围内
        if config.confineInContainer {
            _clampFrameWithinContainer()
        }
        // 7) 拖拽手势
        if config.draggable {
            let pan: UIPanGestureRecognizer
            if let old = objc_getAssociatedObject(self, &SuspendKeys.panKey) as? UIPanGestureRecognizer {
                pan = old
            } else {
                pan = UIPanGestureRecognizer(target: self, action: #selector(_onPan(_:)))
                addGestureRecognizer(pan)
                objc_setAssociatedObject(self, &SuspendKeys.panKey, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        // 8) 标记已悬浮
        objc_setAssociatedObject(self, &SuspendKeys.suspendedKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    @discardableResult
    @MainActor
    func bySuspend(_ build: (SuspendConfig) -> SuspendConfig) -> Self {
        suspend(build(.default))
    }
}
// =============================== 手势 & 算法实现 ===============================
private extension UIView {
    @objc func _onPan(_ pan: UIPanGestureRecognizer) {
        guard
            let config = objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig
        else { return }

        let container: UIView = superview ?? (UIApplication.jobsKeyWindow() ?? UIView._fallbackWindow())

        let translation = pan.translation(in: container)
        pan.setTranslation(.zero, in: container)
        // 拖动更新 frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y

        if config.confineInContainer {
            _clampFrameWithinContainer()
        }
        // 结束时吸附
        if pan.state == .ended || pan.state == .cancelled || pan.state == .failed {
            switch config.docking {
            case .none:
                break
            case .nearestEdge:
                _dockToNearestEdge(animated: config.animated, haptic: config.hapticOnDock)
            case .nearestCorner:
                _dockToNearestCorner(animated: config.animated, haptic: config.hapticOnDock)
            }
        }
    }
    /// 将 frame 限制在容器的可用区域内（含安全区 + 额外 insets）
    func _clampFrameWithinContainer() {
        let container = superview ?? (UIApplication.jobsKeyWindow() ?? UIView._fallbackWindow())
        let insets = (objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig)?.insets ?? .zero
        let b = UIView._availableBounds(in: container, extraInsets: insets)

        var x = max(b.minX, min(frame.origin.x, b.maxX - frame.width))
        var y = max(b.minY, min(frame.origin.y, b.maxY - frame.height))
        if !x.isFinite { x = b.minX }
        if !y.isFinite { y = b.minY }
        frame.origin = CGPoint(x: x, y: y)
    }
    /// 吸附到最近的左右边
    func _dockToNearestEdge(animated: Bool, haptic: Bool) {
        let container = superview ?? (UIApplication.jobsKeyWindow() ?? UIView._fallbackWindow())
        let insets = (objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig)?.insets ?? .zero
        let b = UIView._availableBounds(in: container, extraInsets: insets)

        let centerX = frame.midX
        let toLeft = (centerX - b.minX) < (b.maxX - centerX)
        let targetX = toLeft ? b.minX : (b.maxX - frame.width)
        let targetY = max(b.minY, min(frame.origin.y, b.maxY - frame.height))

        let apply = { self.frame.origin = CGPoint(x: targetX, y: targetY) }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: apply)
        } else {
            apply()
        }
        if haptic { _hapticLight() }
    }
    /// 吸附到最近的四角
    func _dockToNearestCorner(animated: Bool, haptic: Bool) {
        let container = superview ?? (UIApplication.jobsKeyWindow() ?? UIView._fallbackWindow())
        let insets = (objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig)?.insets ?? .zero
        let b = UIView._availableBounds(in: container, extraInsets: insets)

        let targets: [CGPoint] = [
            CGPoint(x: b.minX, y: b.minY),                             // 左上
            CGPoint(x: b.maxX - frame.width, y: b.minY),               // 右上
            CGPoint(x: b.minX, y: b.maxY - frame.height),              // 左下
            CGPoint(x: b.maxX - frame.width, y: b.maxY - frame.height) // 右下
        ]

        let cur = frame.origin
        let nearest = targets.min { lhs, rhs in
            hypot(lhs.x - cur.x, lhs.y - cur.y) < hypot(rhs.x - cur.x, rhs.y - cur.y)
        } ?? cur

        let apply = { self.frame.origin = nearest }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: apply)
        } else {
            apply()
        }
        if haptic { _hapticLight() }
    }

    func _hapticLight() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        g.impactOccurred()
    }
}
// ================================ 窗口 & 几何 ================================
private extension UIView {
    /// 构造一个兜底窗口（极少会走到这里）
    static func _fallbackWindow() -> UIWindow {
        if #available(iOS 13.0, *),
           let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first {
            let win = UIWindow(windowScene: scene)
            win.frame = scene.coordinateSpace.bounds
            win.windowLevel = .alert + 1
            win.isHidden = false
            if win.rootViewController == nil {
                win.rootViewController = UIViewController()
            }
            return win
        } else {
            let win = UIWindow(frame: UIScreen.main.bounds)
            win.windowLevel = .alert + 1
            win.isHidden = false
            if win.rootViewController == nil {
                win.rootViewController = UIViewController()
            }
            return win
        }
    }
    /// 容器可用区域：安全区 + 额外 insets
    static func _availableBounds(in container: UIView, extraInsets: UIEdgeInsets) -> CGRect {
        let safe = container.safeAreaInsets
        let ins = UIEdgeInsets(
            top: safe.top + extraInsets.top,
            left: safe.left + extraInsets.left,
            bottom: safe.bottom + extraInsets.bottom,
            right: safe.right + extraInsets.right
        )
        return container.bounds.inset(by: ins)
    }
}

private enum SuspendKeys {
    /// 使用 UInt8 哨兵地址，避免字符串 Key 冲突
    static var configKey: UInt8 = 0
    static var panKey: UInt8 = 0
    static var suspendedKey: UInt8 = 0
}
/** 用法示例
     // 悬浮（可按需指定 container）
     UIView().bySuspend { cfg in
         cfg.fallbackSize = CGSize(width: 88, height: 44)   // 给标题/副标题更宽松的空间
         cfg.docking = .nearestEdge
         cfg.insets = UIEdgeInsets(top: 20, left: 16, bottom: 34, right: 16)
         cfg.hapticOnDock = true
     }
 */
