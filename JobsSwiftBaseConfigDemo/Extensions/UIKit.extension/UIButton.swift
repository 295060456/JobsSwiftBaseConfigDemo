//
//  UIButton.swift
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

extension UIButton {
    @discardableResult
    func byTitle(_ title: String?, for state: UIControl.State = .normal) -> Self {
        self.setTitle(title, for: state)
        return self
    }

    @discardableResult
    func byTitleColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func byFont(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }

    @discardableResult
    func byImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setImage(image, for: state)
        return self
    }

    @discardableResult
    func byBackgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.setBackgroundImage(image, for: state)
        return self
    }
}
/**
 // 1. 只让按钮里的图片转
 button.startRotating(duration: 0.8, scope: .imageView)
 // 2. 整个按钮转
 button.startRotating(duration: 1.2, scope: .wholeButton)
 // 3. 逆时针转
 button.startRotating(duration: 1.0, scope: .imageView, clockwise: false)
 // 4. 停止旋转并复位
 button.stopRotating(scope: .imageView)
 // 5. 判断当前是否在转
 if button.isRotating(scope: .wholeButton) {
     button.stopRotating(scope: .wholeButton)
 }
 */
extension UIButton {
    /// Convenience constructor for UIButton.
    public convenience init(x: CGFloat,
                            y: CGFloat,
                            w: CGFloat,
                            h: CGFloat,
                            target: AnyObject,
                            action: Selector) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        addTarget(target, action: action, for: UIControl.Event.touchUpInside)
    }
    /// Set a background color for the button.
    public func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension UIButton {
    // MARK: - 旋转动画 Key
    /// 默认动画 key（公开，让默认参数可见）
    public static let rotationKey = "jobs.rotation"
    // MARK: - 旋转作用域枚举@旋转的目标范围
    public enum RotationScope {
        case imageView              // 只转按钮的 imageView
        case wholeButton            // 整个按钮
        case layer(CALayer)         // 自定义某个 Layer
    }
    // MARK: - 找到旋转目标 Layer
    private func targetLayer(for scope: RotationScope) -> CALayer? {
        switch scope {
        case .imageView:
            return self.imageView?.layer ?? self.layer
        case .wholeButton:
            return self.layer
        case .layer(let l):
            return l
        }
    }
    // MARK: - 检查目标是否正在旋转
    public func isRotating(scope: RotationScope = .imageView,
                           key: String = UIButton.rotationKey) -> Bool {
        guard let tl = targetLayer(for: scope) else { return false }
        return tl.animation(forKey: key) != nil
    }
    // MARK: - 设置旋转状态@设置旋转（开_关）
    @discardableResult
    public func setRotating(_ on: Bool,
                            scope: RotationScope = .imageView,
                            duration: CFTimeInterval = 1.0,
                            repeatCount: Float = .infinity,
                            clockwise: Bool = true,
                            key: String = UIButton.rotationKey,
                            resetTransformOnStop: Bool = true) -> Self {
        guard let tl = targetLayer(for: scope) else { return self }

        if on {
            // 已在旋转就跳过
            guard tl.animation(forKey: key) == nil else { return self }

            let anim = CABasicAnimation(keyPath: "transform.rotation")
            let fullTurn = CGFloat.pi * 2 * (clockwise ? 1 : -1)
            anim.fromValue = 0
            anim.toValue = fullTurn
            anim.duration = max(0.001, duration)
            anim.repeatCount = repeatCount
            anim.isCumulative = true
            anim.isRemovedOnCompletion = false
            tl.add(anim, forKey: key)

        } else {
            tl.removeAnimation(forKey: key)
            if resetTransformOnStop {
                switch scope {
                case .imageView:
                    self.imageView?.transform = .identity
                case .wholeButton:
                    self.transform = .identity
                case .layer:
                    // 自定义 Layer 不强行 reset
                    break
                }
            }
        }
        return self
    }
    // MARK: - 快捷封装@开始旋转
    @discardableResult
    public func startRotating(duration: CFTimeInterval = 1.0,
                              scope: RotationScope = .imageView,
                              clockwise: Bool = true,
                              key: String = UIButton.rotationKey) -> Self {
        setRotating(true, scope: scope, duration: duration,
                    repeatCount: .infinity, clockwise: clockwise, key: key)
    }
    // MARK: - 快捷封装@停止旋转
    @discardableResult
    public func stopRotating(scope: RotationScope = .imageView,
                             key: String = UIButton.rotationKey,
                             resetTransformOnStop: Bool = true) -> Self {
        setRotating(false, scope: scope, duration: 0,
                    repeatCount: 0, clockwise: true,
                    key: key, resetTransformOnStop: resetTransformOnStop)
    }
}
// MARK: - 防止用户快速连续点按钮
extension UIButton {
    func disableAfterClick(interval: TimeInterval = 1.0) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.isUserInteractionEnabled = true
        }
    }
}
// MARK: - 给按钮添加闭包回调
private var actionKey: Void?
extension UIButton {
    func addAction(_ action: @escaping (UIButton) -> Void) {
        objc_setAssociatedObject(self, &actionKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(handleAction(_:)), for: .touchUpInside)
    }

    @objc private func handleAction(_ sender: UIButton) {
        if let action = objc_getAssociatedObject(self, &actionKey) as? (UIButton) -> Void {
            action(sender)
        }
    }
}
