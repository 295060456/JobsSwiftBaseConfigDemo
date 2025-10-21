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
import ObjectiveC.runtime
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
    /// 是否可见：true 显示；false 隐藏（折叠布局）
    @MainActor
    @discardableResult
    func byVisible(_ visible: Bool) -> Self {
        self.byHidden(!visible)
        self.byAlpha(visible ? 1 : 0)
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
    func byBorderColor(_ color: UIColor?) -> Self {
        layer.borderColor = color?.cgColor   // 传 nil 会清掉边框颜色
         if color == nil { layer.borderWidth = 0 }
        return self
    }

    @discardableResult
    func byZPosition(_ z: CGFloat) -> Self {
        layer.zPosition = z
        return self
    }

    @discardableResult
    func byBorderWidth(_ width: CGFloat) -> Self {
        layer.borderWidth = width
        return self
    }
    // 单项：半径
    @discardableResult
    func byShadowRadius(_ radius: CGFloat) -> Self {
        layer.shadowRadius = radius
        return self
    }

    @discardableResult
    func byShadowColor(_ color: UIColor?) -> Self {
        layer.shadowColor = color?.cgColor
        return self
    }

    @discardableResult
    func byShadowOpacity(_ opacity: Float = 0.0) -> Self {
        layer.shadowOpacity = opacity
        return self
    }

    @discardableResult
    func byShadowOffset(_ offset: CGSize = CGSizeZero) -> Self {
        layer.shadowOffset = offset
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
    /// 刷新UI@标记即可（让系统合帧处理）：适合大多数情况
    @MainActor
    @discardableResult
    func refresh()-> Self{
        setNeedsLayout()  // 下帧再布局
        layoutIfNeeded()  // 立刻完成布局（当前 runloop）
        return self
    }
    /// 刷新UI@标记即可（让系统合帧处理）：适合大多数情况
    @MainActor
    @discardableResult
    func refreshNow() -> Self {
        setNeedsLayout()     // 下帧再布局
        /// 最后同步布局会改变尺寸/路径，应在布局完成后再决定要画什么
        /// 所以把 setNeedsDisplay() 放到 layoutIfNeeded() 之后 更合理
        layoutIfNeeded()     // 立刻完成布局（当前 runloop）
        /// 只当确实重写了 draw(_:) /或者 使用自定义 layerClass 自绘时才需要 setNeedsDisplay()
        setNeedsDisplay()    // 标记（下帧）需要重绘（基于新布局），不是布局
        // 如必须同步把图也画出来（少用，重）：
        // layer.displayIfNeeded()
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
// MARK: - SnapKit
#if canImport(SnapKit)
import SnapKit
/// SnapKit 语法糖🍬
public extension UIView {
    // MARK: - 添加约束
    @discardableResult
    func byAdd(_ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        if let closure {
            self.snp.makeConstraints(closure)
        }
        return self
    }
    // MARK: - 添加到父视图
    @discardableResult
    func byAddTo(_ superview: UIView,
                 _ closure: ((_ make: ConstraintMaker) -> Void)? = nil) -> Self {
        superview.addSubview(self)
        byAdd(closure)
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
// MARK: - 给任意 UIView 增加悬浮能力（可拖拽、吸附、尊重安全区），默认挂在活动窗口。
// 风格：链式 DSL（.suspend / .bySuspend），主线程 API 使用 @MainActor 保障。
// 注意：悬浮 view 使用 frame 驱动，勿再对其添加 AutoLayout 约束。
// 依赖：UIKit + ObjectiveC 运行时
/**【用法示例】
     /// 悬浮（可按需指定 container）
     UIView().bySuspend { cfg in
         cfg.fallbackSize = CGSize(width: 88, height: 44)   // 给标题/副标题更宽松的空间
         cfg.docking = .nearestEdge
         cfg.insets = UIEdgeInsets(top: 20, left: 16, bottom: 34, right: 16)
         cfg.hapticOnDock = true
     }
 */
// MARK: - 悬浮视图@配置
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
    /// 工厂：链式外建
    static func dsl(_ build: (inout Self) -> Void) -> Self {
        var cfg = Self.default
        build(&cfg)
        return cfg
    }
    /// Non-mutating：返回新副本，适合链式
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

private enum SuspendKeys {
    /// 使用 UInt8 哨兵地址，避免字符串 Key 冲突
    static var configKey: UInt8 = 0
    static var panKey: UInt8 = 0
    static var suspendedKey: UInt8 = 0
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
        objc_setAssociatedObject(self, &SuspendKeys.configKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SuspendKeys.panKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &SuspendKeys.suspendedKey, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        removeFromSuperview()
    }
    /// 悬浮：挂到活动窗口或指定容器；支持拖拽/吸附/安全区
    /// - Parameter config: 悬浮配置（有默认值）
    /// - Returns: Self（链式）
    @discardableResult
    @MainActor
    func suspend(_ config: SuspendConfig = .default) -> Self {
        /// 保存配置
        objc_setAssociatedObject(self, &SuspendKeys.configKey, config, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        /// 选择容器
        let container: UIView = config.container ?? (UIApplication.jobsKeyWindow() ?? Self._fallbackWindow())
        /// 如果当前无父视图 -> 挂到容器
        if superview == nil {
            container.addSubview(self)
        }
        /// 尺寸兜底
        if bounds.size == .zero {
            frame.size = config.fallbackSize
        }
        /// 初始位置
        if let origin = config.initialOrigin {
            frame.origin = origin
        } else if frame.origin == .zero {
            // 默认：右下角（安全区 + insets 内）
            let b = Self._availableBounds(in: container, extraInsets: config.insets)
            frame.origin = CGPoint(x: b.maxX - frame.width, y: b.maxY - frame.height)
        }
        /// 约束在容器可用范围内
        if config.confineInContainer {
            _clampFrameWithinContainer()
        }
        /// 拖拽手势
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
// MARK: - 悬浮视图@手势算法实现
private extension UIView {
    @objc func _onPan(_ pan: UIPanGestureRecognizer) {
        guard
            let config = objc_getAssociatedObject(self, &SuspendKeys.configKey) as? UIView.SuspendConfig
        else { return }

        let container: UIView = superview ?? (UIApplication.jobsKeyWindow() ?? UIView._fallbackWindow())

        let translation = pan.translation(in: container)
        pan.setTranslation(.zero, in: container)
        /// 拖动更新 frame
        frame.origin.x += translation.x
        frame.origin.y += translation.y

        if config.confineInContainer {
            _clampFrameWithinContainer()
        }
        /// 结束时吸附
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
// MARK: - 悬浮视图@窗口几何
private extension UIView {
    /// 构造一个兜底窗口（极少会走到这里）
    static func _fallbackWindow() -> UIWindow {
        if #available(iOS 13.0, *),
           let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first {
            let win = UIWindow(windowScene: scene)
                .byFrame(scene.coordinateSpace.bounds)
                .byWindowLevel(.alert + 1)
                .byHidden(false)
            if win.rootViewController == nil {
                win.rootViewController = UIViewController()
            }
            return win
        } else {
            let win = UIWindow(frame: UIScreen.main.bounds)
                .byWindowLevel(.alert + 1)
                .byHidden(false)
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
// MARK: - 公共类型@右上角角标
public enum RTBadgeContent {
    case text(String)
    case attributed(NSAttributedString)
    case custom(UIView)
}

public struct RTBadgeConfig {
    public var backgroundColor: UIColor = .systemRed
    public var textColor: UIColor = .white
    public var font: UIFont = .systemFont(ofSize: 12, weight: .semibold)
    /// nil = 自动按高度一半做胶囊圆角；给值则为固定圆角
    public var cornerRadius: CGFloat? = nil
    public var insets: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
    /// (+x 向右, +y 向下)。右上角常用：(-4, 4)
    public var offset: UIOffset = .init(horizontal: -4, vertical: 4)
    public var maxWidth: CGFloat = 200
    public var borderColor: UIColor? = nil
    public var borderWidth: CGFloat = 0
    public var shadowColor: UIColor? = nil
    public var shadowRadius: CGFloat = 0
    public var shadowOpacity: Float = 0
    public var shadowOffset: CGSize = .zero
    public var zIndex: CGFloat = 9999
    public init() {}
}

public extension RTBadgeConfig {
    @discardableResult func byOffset(_ v: UIOffset = .init(horizontal: -6, vertical: 6)) -> Self { var c=self; c.offset=v; return c }
    @discardableResult func byInsets(_ v: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)) -> Self { var c=self; c.insets=v; return c }
    @discardableResult func byInset(_ v: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)) -> Self { var c=self; c.insets=v; return c }
    @discardableResult func byBgColor(_ v: UIColor = .systemRed) -> Self { var c=self; c.backgroundColor=v; return c }
    @discardableResult func byTextColor(_ v: UIColor = .white) -> Self { var c=self; c.textColor=v; return c }
    @discardableResult func byFont(_ v: UIFont = .systemFont(ofSize: 11, weight: .bold)) -> Self { var c=self; c.font=v; return c }
    @discardableResult func byCornerRadius(_ v: CGFloat? = nil) -> Self { var c=self; c.cornerRadius=v; return c }
    @discardableResult func byBorder(color: UIColor? = nil, width: CGFloat = 0) -> Self { var c=self; c.borderColor=color; c.borderWidth=width; return c }
    @discardableResult func byMaxWidth(_ v: CGFloat = 200) -> Self { var c=self; c.maxWidth=v; return c }
    @discardableResult func byZIndex(_ v: CGFloat = 9999) -> Self { var c=self; c.zIndex=v; return c }
    @discardableResult
    func byShadow(color: UIColor? = UIColor.black.withAlphaComponent(0.25),
                  radius: CGFloat = 2,
                  opacity: Float = 0.6,
                  offset: CGSize = .init(width: 0, height: 1)) -> Self {
        var c = self
        c.shadowColor = color
        c.shadowRadius = radius
        c.shadowOpacity = opacity
        c.shadowOffset = offset
        return c
    }
}

public extension UIView {
    /// 右上角角标：添加/更新，内容自定义（SnapKit 约束）
    @discardableResult
    func byCornerBadge(_ content: RTBadgeContent,
                       build: ((RTBadgeConfig) -> RTBadgeConfig)? = nil) -> Self {
        assert(Thread.isMainThread, "UI must be updated on main thread")
        var cfg = RTBadgeConfig()
        if let build = build { cfg = build(cfg) }

        let container = ensureRTBadgeContainer()
        if container.superview !== self { addSubview(container) }

        container.byUserInteractionEnabled(false)
            .byMasksToBounds(false)
            .byBorderColor(cfg.borderColor)
            .byZPosition(cfg.zIndex)
            .byBgColor(cfg.backgroundColor)
            .byBorderWidth(cfg.borderWidth)

        if let sc = cfg.shadowColor {
            container.byShadowColor(sc)
                .byShadowRadius(cfg.shadowRadius)
                .byShadowOpacity(cfg.shadowOpacity)
                .byShadowOffset(cfg.shadowOffset)
        } else {
            container.byShadowOpacity(cfg.shadowOpacity)
        }
        /// 内容
        install(content, into: container, config: cfg)
        /// 右上角定位（SnapKit）
        installRTBadgeConstraints(container: container,
                                  offset: cfg.offset,
                                  maxWidth: cfg.maxWidth)
        /// 圆角
        if let r = cfg.cornerRadius {
            container.autoCapsule = false
            container.byShadowRadius(r)
        } else {
            container.autoCapsule = true // 在 layoutSubviews 按高度一半
            container.refresh()
        }

        return self
    }
    /// 右上角角标：快捷文本
    @discardableResult
    func byCornerBadgeText(_ text: String,
                           build: ((RTBadgeConfig) -> RTBadgeConfig)? = nil) -> Self {
        byCornerBadge(.text(text), build: build)
    }
    /// 右上角小红点（纯圆）
    @discardableResult
    func byCornerDot(diameter: CGFloat = 8,
                     offset: UIOffset = .init(horizontal: -4, vertical: 4),
                     color: UIColor = .systemRed) -> Self {
        return byCornerBadge(.custom(UIView()
            .byBgColor(color)
            .byCornerRadius(diameter / 2)
            .byAdd({ make in
                make.width.height.equalTo(diameter)
            }))) { cfg in
                cfg.byInset(.zero)
                    .byCornerRadius(diameter / 2)
                    .byOffset(offset)
                    .byBgColor(.clear)
                    .byBorder(color: nil, width: 0)
                    .byShadow(color: nil)
        }
    }
    /// 显示/隐藏（右上角）
    @discardableResult
    func setCornerBadgeHidden(_ hidden: Bool,
                              animated: Bool = false,
                              duration: TimeInterval = 0.2) -> Self {
        guard let v = rt_badgeContainer() else { return self }
        let work = { v.alpha = hidden ? 0 : 1 }
        animated ? UIView.animate(withDuration: duration, animations: work) : work()
        return self
    }
    /// 移除（右上角）
    @discardableResult
    func removeCornerBadge() -> Self {
        rt_badgeContainer()?.removeFromSuperview()
        setRTBadgeContainer(nil)
        return self
    }
}

private final class _BadgeContainerView: UIView {
    var autoCapsule: Bool = true
    override func layoutSubviews() {
        super.layoutSubviews()
        if autoCapsule {
            byCornerRadius(bounds.height / 2)
        }
    }
}

private final class _InsetLabel: UILabel {
    /// 文本内容的内边距（默认为 .zero）
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInsets else { return }
            invalidateIntrinsicContentSize()
            refresh()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    /// 实际绘制：直接在缩减后的区域画
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }
    /// 参与 Auto Layout 的固有尺寸：加上内边距
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + contentInsets.left + contentInsets.right,
                      height: s.height + contentInsets.top + contentInsets.bottom)
    }
    /// 计算文本绘制矩形：先缩进，再把结果外扩回去（系统要求）
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        /// 先将可用区域减去内边距
        let insetBounds = bounds.inset(by: contentInsets)
        /// 让父类在缩减后的区域中排版
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        /// 再把结果外扩回原坐标系（相当于“反向”内边距）
        let out = UIEdgeInsets(top: -contentInsets.top, left: -contentInsets.left,
                               bottom: -contentInsets.bottom, right: -contentInsets.right)
        return textRect.inset(by: out)
    }
}
// MARK: - 链式 DSL
private extension _InsetLabel {
    /// 直接设置 UIEdgeInsets
    @discardableResult
    func byContentInsets(_ insets: UIEdgeInsets) -> Self {
        self.contentInsets = insets
        return self
    }
    /// 上下左右等距
    @discardableResult
    func byContentInsets(_ all: CGFloat) -> Self {
        self.contentInsets = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        return self
    }
    /// 垂直/水平 分量设置（例如 vertical=6, horizontal=10）
    @discardableResult
    func byContentInsets(vertical v: CGFloat, horizontal h: CGFloat) -> Self {
        self.contentInsets = UIEdgeInsets(top: v, left: h, bottom: v, right: h)
        return self
    }
    /// 分别指定四边
    @discardableResult
    func byContentInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        self.contentInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
}
// 仅一个 key（右上角）
private enum _RTBadgeKey { static var tr: UInt8 = 0 }
private extension UIView {

    func ensureRTBadgeContainer() -> _BadgeContainerView {
        if let v = rt_badgeContainer() as? _BadgeContainerView { return v }
        let v = _BadgeContainerView()
        setRTBadgeContainer(v)
        addSubview(v)
        return v
    }

    func rt_badgeContainer() -> UIView? {
        objc_getAssociatedObject(self, &_RTBadgeKey.tr) as? UIView
    }

    func setRTBadgeContainer(_ v: UIView?) {
        objc_setAssociatedObject(self, &_RTBadgeKey.tr, v, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func install(_ content: RTBadgeContent, into container: _BadgeContainerView, config: RTBadgeConfig) {
        container.subviews.forEach { $0.removeFromSuperview() }

        switch content {
        case .text(let s):
            let label = _InsetLabel()
                .byText(s)
                .byTextColor(config.textColor)
                .byFont(config.font)
                .byNumberOfLines(1)
                .byContentInsets(config.insets)
            container.addSubview(label)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.snp.makeConstraints { $0.edges.equalToSuperview() }

        case .attributed(let attr):
            let label = _InsetLabel()
                .byAttributedString(attr)
                .byTextColor(config.textColor)
                .byFont(config.font)
                .byNumberOfLines(1)
                .byContentInsets(config.insets)
            container.addSubview(label)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.snp.makeConstraints { $0.edges.equalToSuperview() }

        case .custom(let view):
            container.addSubview(view)
            view.snp.makeConstraints { $0.edges.equalToSuperview().inset(config.insets) }
        }
    }
    /// 右上角定位（统一 remake，避免重复约束）
    func installRTBadgeConstraints(container: UIView,
                                   offset: UIOffset,
                                   maxWidth: CGFloat) {
        // ② installRTBadgeConstraints(container:offset:maxWidth:)
        container.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(offset.vertical)
            // ❌ 原来：make.right.equalToSuperview().offset(-offset.horizontal)
            // ✅ 应该：
            make.right.equalToSuperview().offset(offset.horizontal)
            make.width.lessThanOrEqualTo(maxWidth)
        }
        container.setContentCompressionResistancePriority(.required, for: .horizontal)
        container.setContentHuggingPriority(.required, for: .horizontal)
    }
}
// MARK: - 回调协议：任何宿主视图（含 BaseWebView）都可感知 NavBar 显隐变化并自行调整内部布局
@MainActor
public protocol JobsNavBarHost: AnyObject {
    /// enabled: true=已安装；false=已移除
    func jobsNavBarDidToggle(enabled: Bool, navBar: JobsNavBar)
}
// MARK: - 关联对象 Key（用 UInt8 的地址唯一标识）
private enum _JobsNavBarAO {
    static var bar:  UInt8 = 0
    static var conf: UInt8 = 0
}
// MARK: - 配置体（挂在 UIView 上，而不是某个具体子类）
public extension UIView {
    struct JobsNavBarConfig {
        public var enabled: Bool = false
        public var style: JobsNavBar.Style = .init()
        public var titleProvider: JobsNavBar.TitleProvider? = nil          // nil -> 隐藏标题；不设=由宿主决定
        public var backButtonProvider: JobsNavBar.BackButtonProvider? = nil// nil -> 隐藏返回键
        public var onBack: JobsNavBar.BackHandler? = nil                   // 未设置则由宿主兜底
        public var layout: ((JobsNavBar, ConstraintMaker, UIView) -> Void)? = nil // 自定义布局
        public var backButtonLayout: ((JobsNavBar, UIButton, ConstraintMaker) -> Void)? = nil
        public init() {}
    }
}
// MARK: - 公开：取到当前视图身上的 NavBar（只读）
public extension UIView {
    var jobsNavBar: JobsNavBar? {
        objc_getAssociatedObject(self, &_JobsNavBarAO.bar) as? JobsNavBar
    }
}
// MARK: - 私有：配置读写 + 应用
@MainActor
private extension UIView {
    var _jobsNavBarConfig: JobsNavBarConfig {
        get { (objc_getAssociatedObject(self, &_JobsNavBarAO.conf) as? JobsNavBarConfig) ?? .init() }
        set { objc_setAssociatedObject(self, &_JobsNavBarAO.conf, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func _setJobsNavBar(_ bar: JobsNavBar?) {
        objc_setAssociatedObject(self, &_JobsNavBarAO.bar, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func _applyNavBarConfig() {
        let cfg = _jobsNavBarConfig
        if cfg.enabled {
            let bar: JobsNavBar
            if let b = jobsNavBar {
                bar = b
                bar.style = cfg.style
            } else {
                bar = JobsNavBar(style: cfg.style)
                addSubview(bar)
                _setJobsNavBar(bar)
            }

            // 提供器（返回 nil -> 隐藏）
            bar.titleProvider = cfg.titleProvider
            bar.backButtonProvider = cfg.backButtonProvider

            // ✅ 透传外层 backButtonLayout（触发 didSet -> 只重排约束，不重复 add）
            bar.backButtonLayout = cfg.backButtonLayout

            // 返回行为
            if let onBack = cfg.onBack { bar.onBack = onBack }

            // 布局 NavBar 本体（与返回键无关）
            bar.snp.remakeConstraints { make in
                if let L = cfg.layout {
                    L(bar, make, self)
                } else {
                    make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                    make.left.right.equalToSuperview()
                }
            }

            // ❌ 不再调用 bar.jobsNavBarRefresh()，避免重复重建
            // 属性 didSet 已经触发必要的重排
            (self as? JobsNavBarHost)?.jobsNavBarDidToggle(enabled: true, navBar: bar)
        } else {
            if let bar = jobsNavBar {
                bar.removeFromSuperview()
                _setJobsNavBar(nil)
                (self as? JobsNavBarHost)?.jobsNavBarDidToggle(enabled: false, navBar: bar)
            }
        }
    }
}

@MainActor
public extension UIView {
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        // 只查一层足够；要递归可以展开
        return subviews.first { $0 is T } as? T
    }
}
// MARK: - UIView 链式 DSL（任何 UIView 均可使用）
@MainActor
public extension UIView {
    @discardableResult
    func byNavBarEnabled(_ on: Bool = true) -> Self {
        var c = _jobsNavBarConfig
        c.enabled = on
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }

    @discardableResult
    func byNavBarStyle(_ edit: (inout JobsNavBar.Style) -> Void) -> Self {
        var c = _jobsNavBarConfig
        edit(&c.style)
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 自定义标题（返回 nil -> 隐藏；不设置则留给宿主绑定，例如绑定到 webView.title）
    @discardableResult
    func byNavBarTitleProvider(_ p: @escaping JobsNavBar.TitleProvider) -> Self {
        var c = _jobsNavBarConfig
        c.titleProvider = p
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 自定义返回键（返回 nil -> 隐藏）
    @discardableResult
    func byNavBarBackButtonProvider(_ p: @escaping JobsNavBar.BackButtonProvider) -> Self {
        var c = _jobsNavBarConfig
        c.backButtonProvider = p
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 自定义返回键@约束
    @discardableResult
    func byNavBarBackButtonLayout(_ layout: @escaping JobsNavBar.BackButtonLayout) -> Self {
        var c = _jobsNavBarConfig
        c.backButtonLayout = layout
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 返回行为（比如“优先 webView.goBack，否则 pop”）
    @discardableResult
    func byNavBarOnBack(_ h: @escaping JobsNavBar.BackHandler) -> Self {
        var c = _jobsNavBarConfig
        c.onBack = h
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
    /// 覆盖默认布局（默认：贴宿主 safeArea 顶，左右铺满）
    @discardableResult
    func byNavBarLayout(_ layout: @escaping (JobsNavBar, ConstraintMaker, UIView) -> Void) -> Self {
        var c = _jobsNavBarConfig
        c.layout = layout
        _jobsNavBarConfig = c
        _applyNavBarConfig()
        return self
    }
}
#endif

#if canImport(GKNavigationBarSwift) && canImport(SnapKit)
import GKNavigationBarSwift
@MainActor
public extension UIView {
    /// 是否存在可见的“导航栏类视图”（优先 GKNavigationBar，其次 UINavigationBar）
    /// - Parameter deep: 是否递归遍历整棵子树（默认 true）
    func jobs_hasVisibleTopBar(deep: Bool = true) -> Bool {
        return jobs_existingTopBar(deep: deep) != nil
    }
    /// 返回已存在的“导航栏类视图”（不触发懒加载），找不到返回 nil。
    /// 类型统一用 UIView?，外部无需依赖 GKNavigationBar 的符号。
    func jobs_existingTopBar(deep: Bool = true) -> UIView? {
        #if canImport(GKNavigationBarSwift)
        if let nb = jobs_firstSubview(of: GKNavigationBar.self, deep: deep),
           !nb.isHidden, nb.alpha > 0.001 {
            return nb
        }
        #endif
        if let nb = jobs_firstSubview(of: UINavigationBar.self, deep: deep),
           !nb.isHidden, nb.alpha > 0.001 {
            return nb
        }
        return nil
    }
    // MARK: - 私有工具：按类型查找已存在的子视图（不会触发任何懒创建）
    private func jobs_firstSubview<T: UIView>(of type: T.Type, deep: Bool) -> T? {
        // 先一层
        if let hit = subviews.first(where: { $0 is T }) as? T { return hit }
        // 需要递归则继续
        guard deep else { return nil }
        for v in subviews {
            if let hit: T = v.jobs_firstSubview(of: type, deep: true) { return hit }
        }
        return nil
    }
}
#endif
