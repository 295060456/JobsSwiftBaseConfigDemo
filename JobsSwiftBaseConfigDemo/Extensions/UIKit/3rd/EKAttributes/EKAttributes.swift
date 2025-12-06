//
//  EKAttributes.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

#if canImport(SwiftEntryKit)
import SwiftEntryKit
// MARK: - EKAttributes 小型链式包装（已按 SwiftEntryKit 的真实类型修正）
extension EKAttributes {
    @discardableResult
    func byPosition(_ p: EKAttributes.Position) -> Self { var a = self; a.position = p; return a }

    @discardableResult
    func byDuration(_ t: TimeInterval) -> Self { var a = self; a.displayDuration = t; return a }

    @discardableResult
    func byCorner(radius: CGFloat, edges: EKAttributes.RoundCorners = .all(radius: 0)) -> Self {
        var a = self
        switch edges {
        case .all: a.roundCorners = .all(radius: radius)
        default:   a.roundCorners = edges
        };return a
    }

    // opacity 是 Float，不是 CGFloat
    @discardableResult
    func byShadow(color: UIColor = .black,
                  opacity: Float = 0.15,
                  radius: CGFloat = 10) -> Self {
        var a = self
        a.shadow = .active(with: .init(color: EKColor(color),   // ⬅️ 这里用 EKColor(...)
                                       opacity: opacity,
                                       radius: radius))
        return a
    }

    @discardableResult
    func byEntrance(_ anim: EKAttributes.Animation) -> Self { var a = self; a.entranceAnimation = anim; return a }
    @discardableResult
    func byExit(_ anim: EKAttributes.Animation) -> Self { var a = self; a.exitAnimation = anim; return a }
    @discardableResult
    func byPop(_ pop: EKAttributes.PopBehavior) -> Self { var a = self; a.popBehavior = pop; return a }

    @discardableResult
    func byAbsorbTouches(_ on: Bool) -> Self {
        var a = self
        a.entryInteraction  = on ? .absorbTouches : .forward
        a.screenInteraction = on ? .dismiss       : .forward   // ⬅️ 用 .forward，库里没有 .none
        return a
    }

    func byDismissOnTap() -> Self {
        var a = self
        a.entryInteraction = .dismiss
        a.screenInteraction = .dismiss
        return a
    }

    @discardableResult
    func byEntryInteraction(_ on: UserInteraction) -> Self {
        var a = self
        a.entryInteraction  = on
        return a
    }

    @discardableResult
    func byScreenInteraction(_ on: UserInteraction) -> Self {
        var a = self
        a.screenInteraction = on
        return a
    }

    @discardableResult
    func byHaptic(_ type: EKAttributes.NotificationHapticFeedback) -> Self { var a = self; a.hapticFeedbackType = type; return a }

    @discardableResult
    func byKeyboardAvoiding(_ relation: EKAttributes.PositionConstraints.KeyboardRelation) -> Self {
        var a = self; var c = a.positionConstraints; c.keyboardRelation = relation; a.positionConstraints = c; return a
    }

    // Edge/Size 显式类型，避免推断失败
    @discardableResult
    func bySize(width: EKAttributes.PositionConstraints.Edge,
                height: EKAttributes.PositionConstraints.Edge) -> Self {
        var a = self; var c = a.positionConstraints
        c.size = .init(width: width, height: height)
        a.positionConstraints = c
        return a
    }

    @discardableResult
    func byDisplayMode(_ mode: EKAttributes.DisplayMode) -> Self { var a = self; a.displayMode = mode; return a }
    @discardableResult
    func byStatusBar(_ style: EKAttributes.StatusBar) -> Self { var a = self; a.statusBar = style; return a }
    @discardableResult
    func byQueue(priority: EKAttributes.Precedence.Priority = .normal,
                 dropEnqueuedEntries: Bool = false) -> Self {
        var a = self
        a.precedence = .override(priority: priority, dropEnqueuedEntries: dropEnqueuedEntries)
        return a
    }
    @discardableResult
    func byScrollable(swipeable: Bool = true) -> Self {
        var a = self
        a.scroll = .enabled(swipeable: swipeable, pullbackAnimation: .jolt)
        return a
    }
    @discardableResult
    func byWindow(level: EKAttributes.WindowLevel = .normal) -> Self { var a = self; a.windowLevel = level; return a }

    // 背景/遮罩
    @discardableResult
    func byBackground(_ bg: EKAttributes.BackgroundStyle) -> Self { var a = self; a.entryBackground = bg; return a }
    @discardableResult
    func byScreen(_ bg: EKAttributes.BackgroundStyle) -> Self { var a = self; a.screenBackground = bg; return a }
}
// MARK: - 动画预设
extension EKAttributes {
    static var animTranslationInOut: (entrance: EKAttributes.Animation, exit: EKAttributes.Animation) {
        let entrance = EKAttributes.Animation(
            translate: .init(duration: 0.32, spring: .init(damping: 1, initialVelocity: 0))
        )
        let exit = EKAttributes.Animation(translate: .init(duration: 0.2))
        return (entrance, exit)
    }
    static var animScaleInFadeOut: (entrance: EKAttributes.Animation, exit: EKAttributes.Animation) {
        let entrance = EKAttributes.Animation(scale: .init(from: 0.85, to: 1.0, duration: 0.28))
        let exit = EKAttributes.Animation(fade: .init(from: 1.0, to: 0.0, duration: 0.18))
        return (entrance, exit)
    }
}
#endif
