//
//  Demo@SwiftEntryKit.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/11/11.
//

import UIKit
import SnapKit
import SwiftEntryKit
// MARK: - EKAttributes 小型链式包装（已按 SwiftEntryKit 的真实类型修正）
private extension EKAttributes {
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
    func byShadow(color: UIColor = .black, opacity: Float = 0.15, radius: CGFloat = 10) -> Self {
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
private extension EKAttributes {
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
// MARK: - 内置消息工厂（颜色用 EKColor 包装）
private func makeMessageView(title: String, desc: String, systemImage: String) -> UIView {
    let titleLabel = EKProperty.LabelContent(
        text: title,
        style: .init(font: .boldSystemFont(ofSize: 16), color: EKColor(.label))
    )
    let descLabel = EKProperty.LabelContent(
        text: desc,
        style: .init(font: .systemFont(ofSize: 14), color: EKColor(.secondaryLabel))
    )
    let image = EKProperty.ImageContent(image: UIImage(systemName: systemImage)!)

    // ① 先创建 SimpleMessage
    let simple = EKSimpleMessage(image: image, title: titleLabel, description: descLabel)

    // ② 用 SimpleMessage 构造 NotificationMessage（不带按钮）
    let notification = EKNotificationMessage(simpleMessage: simple)

    // ③ 再塞进 NotificationMessageView
    return EKNotificationMessageView(with: notification)
}
// MARK: - 自定义底部表单（键盘联动）
private final class SheetContentView: UIView, UITextFieldDelegate {
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("底部表单（键盘联动）")
            .byFont(.boldSystemFont(ofSize: 18))
            .byTextColor(.label)
            .byAddTo(self) { make in
                make.top.equalToSuperview().inset(16)
                make.left.right.equalToSuperview().inset(16)
            }
    }()
    private lazy var textField: UITextField = {
        UITextField()
            .byPlaceholder("输入点什么…")
            .byBorderStyle(.roundedRect)
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(40)
            }
    }()
    private lazy var confirmBtn: UIButton = {
        UIButton.sys()
            .byTitle("确定")
            .onJobsTap { [weak self] (_: UIButton) in
                self?.endEditing(true)
                SwiftEntryKit.dismiss()
            }
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(textField.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(44)
                make.bottom.equalToSuperview().inset(20)
            }
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemBackground
        _ = titleLabel; _ = textField; _ = confirmBtn
    }
    required init?(coder: NSCoder) { fatalError() }
}
// MARK: - Demo VC
final class SwiftEntryKitDemoVC: BaseVC {
    // MARK: - UI（懒加载）
    private lazy var stack: UIStackView = {
        UIStackView()
            .byAxis(.vertical)
            .byAlignment(.fill)
            .byDistribution(.fill)
            .bySpacing(10)
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.equalToSuperview().inset(16)
                    make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
                } else {
                    make.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
                }
            }
    }()

    private func makeButton(_ title: String, _ action: Selector) -> UIButton {
        UIButton.sys()
            .byTitle(title)
            .onJobsTap { [weak self] (_: UIButton) in
                _ = self?.perform(action)
            }
    }

    private lazy var btnTopBanner     = makeButton("顶部 Banner（2s 自动消失）", #selector(showTopBanner))
    private lazy var btnCenterToast   = makeButton("中心 Toast（缩放进入）", #selector(showCenterToast))
    private lazy var btnBottomSheet   = makeButton("底部半高 Sheet（可拖动&键盘避让）", #selector(showBottomSheet))
    private lazy var btnFullscreen    = makeButton("全屏公告（点遮罩关闭）", #selector(showFullscreenNotice))
    private lazy var btnQueue         = makeButton("队列与优先级（先排队，再插队）", #selector(showQueueAndPriority))
    private lazy var btnStatusBar     = makeButton("状态栏样式切换（light/dark）", #selector(showStatusBarLight))
    private lazy var btnDismissAll    = makeButton("手动关闭所有", #selector(dismissAll))

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "SwiftEntryKit 全展示"
        )

        [
            btnTopBanner,
            btnCenterToast,
            btnBottomSheet,
            btnFullscreen,
            btnQueue,
            btnStatusBar,
            btnDismissAll
        ].forEach { stack.addArrangedSubview($0) }
    }

    // MARK: - Actions

    // 1) 顶部 Banner
    @objc private func showTopBanner() {
        let v = makeMessageView(title: "已完成", desc: "数据保存成功", systemImage: "checkmark.circle.fill")

        var attr = EKAttributes()
            .byPosition(.top)
            .byDuration(2)
            .byBackground(.visualEffect(style: .dark))              // 毛玻璃：.light/.dark/.extraLight
            .byScreen(.color(color: EKColor(.clear)))
            .byCorner(radius: 14)
            .byShadow()
            .byHaptic(.success)
            .byAbsorbTouches(false)
            .byDisplayMode(.inferred)
            .byStatusBar(.inferred)
            .byWindow(level: .normal)

        let anim = EKAttributes.animTranslationInOut
        attr = attr.byEntrance(anim.entrance).byExit(anim.exit)

        SwiftEntryKit.display(entry: v, using: attr)
    }

    // 2) 中心 Toast（缩放 + 淡出）
    @objc private func showCenterToast() {
        let v = makeMessageView(title: "提示", desc: "中心 Toast", systemImage: "bolt.fill")

        var attr = EKAttributes()
            .byPosition(.center)
            .byDuration(1.6)
            .byBackground(.color(color: EKColor(.label)))
            .byScreen(.color(color: EKColor(.clear)))
            .byCorner(radius: 12)
            .byHaptic(.warning)
            .byAbsorbTouches(false)
            .byDisplayMode(.light)
            .byStatusBar(.inferred)

        let anim = EKAttributes.animScaleInFadeOut
        attr = attr.byEntrance(anim.entrance).byExit(anim.exit)

        SwiftEntryKit.display(entry: v, using: attr)
    }

    // 3) 底部半高 Sheet（可拖动 + 键盘避让）
    @objc private func showBottomSheet() {
        let sheet = SheetContentView()

        var attr = EKAttributes()
            .byPosition(.bottom)
            .byDuration(.infinity) // 交互型
            .byBackground(.color(color: EKColor(.secondarySystemBackground)))
            .byScreen(.color(color: EKColor(UIColor(white: 0, alpha: 0.35))))
            .byCorner(radius: 18, edges: .top(radius: 18))
            .byShadow()
            .byAbsorbTouches(true)       // 点击遮罩关闭
            .byScrollable(swipeable: true)
            .byDisplayMode(.inferred)
            .byStatusBar(.inferred)
            .byKeyboardAvoiding(.bind(offset: .init(bottom: 10, screenEdgeResistance: 20)))

        // 半高（Edge 显式类型）
        attr = attr.bySize(
            width:  EKAttributes.PositionConstraints.Edge.offset(value: 0),
            height: EKAttributes.PositionConstraints.Edge.ratio(value: 0.45)
        )

        let anim = EKAttributes.animTranslationInOut
        attr = attr.byEntrance(anim.entrance).byExit(anim.exit)

        SwiftEntryKit.display(entry: sheet, using: attr)
    }

    // 4) 全屏公告（遮罩可关闭）
    @objc private func showFullscreenNotice() {
        let label = UILabel()
            .byText("📢 这是一则全屏公告\n点空白可关闭")
            .byTextAlignment(.center)
            .byFont(.boldSystemFont(ofSize: 22))
            .byNumberOfLines(0)
            .byTextColor(.white)

        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.88)
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
        }

        var attr = EKAttributes()
            .byPosition(.center)
            .byDuration(.infinity)
            .byBackground(.color(color: EKColor(.clear)))
            .byScreen(.color(color: EKColor(UIColor(white: 0, alpha: 0.6))))
            .byAbsorbTouches(true)
            .byDisplayMode(.dark)
            .byStatusBar(.light)
            .byWindow(level: .alerts)

        // 全屏（Size 显式）
        var c = attr.positionConstraints
        c.size = EKAttributes.PositionConstraints.Size(
            width:  .offset(value: 0),
            height: .offset(value: 0)
        )
        attr.positionConstraints = c

        let anim = EKAttributes.animScaleInFadeOut
        attr = attr.byEntrance(anim.entrance).byExit(anim.exit)

        SwiftEntryKit.display(entry: container, using: attr)
    }

    // 5) 队列与优先级（先排队 3 个，再插高优先级覆盖）
    @objc private func showQueueAndPriority() {
        func enqueue(_ title: String, priority: EKAttributes.Precedence.Priority = .normal) {
            let v = makeMessageView(title: title, desc: "队列演示", systemImage: "list.bullet")
            var a = EKAttributes()
                .byPosition(.top)
                .byDuration(1.2)
                .byBackground(.visualEffect(style: .dark))
                .byCorner(radius: 12)
                .byShadow()
                .byQueue(priority: priority, dropEnqueuedEntries: false)
                .byHaptic(.success)

            let anim = EKAttributes.animTranslationInOut
            a = a.byEntrance(anim.entrance).byExit(anim.exit)
            SwiftEntryKit.display(entry: v, using: a)
        }

        enqueue("普通 #1")
        enqueue("普通 #2")
        enqueue("普通 #3")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let v = makeMessageView(title: "⚡️ 高优先级覆盖", desc: "precedence.override", systemImage: "bolt.fill")
            var a = EKAttributes()
                .byPosition(.top)
                .byDuration(1.8)
                .byBackground(.color(color: EKColor(.systemYellow)))
                .byCorner(radius: 12)
                .byQueue(priority: .max, dropEnqueuedEntries: false)
                .byHaptic(.success)

            let anim = EKAttributes.animTranslationInOut
            a = a.byEntrance(anim.entrance).byExit(anim.exit)
            SwiftEntryKit.display(entry: v, using: a)
        }
    }

    // 6) 状态栏样式切换（light/dark）
    @objc private func showStatusBarLight() {
        let v1 = makeMessageView(title: "状态栏：Light", desc: "statusBar = .light", systemImage: "sun.max.fill")
        var a1 = EKAttributes()
            .byPosition(.top)
            .byDuration(1.4)
            .byBackground(.color(color: EKColor(.systemBlue)))
            .byCorner(radius: 12)
            .byStatusBar(.light)
            .byHaptic(.success)
        let t = EKAttributes.animTranslationInOut
        a1 = a1.byEntrance(t.entrance).byExit(t.exit)
        SwiftEntryKit.display(entry: v1, using: a1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let v2 = makeMessageView(title: "状态栏：Dark", desc: "statusBar = .dark", systemImage: "moon.fill")
            var a2 = EKAttributes()
                .byPosition(.top)
                .byDuration(1.4)
                .byBackground(.color(color: EKColor(.systemGray6)))
                .byCorner(radius: 12)
                .byStatusBar(.dark)
                .byHaptic(.warning)
            let tt = EKAttributes.animTranslationInOut
            a2 = a2.byEntrance(tt.entrance).byExit(tt.exit)
            SwiftEntryKit.display(entry: v2, using: a2)
        }
    }

    // 7) 手动关闭
    @objc private func dismissAll() {
        SwiftEntryKit.dismiss(.all, with: nil)
    }
}
