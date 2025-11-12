//
//  Demo@SwiftEntryKit.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/11/11.
//

import UIKit
import SnapKit
import SwiftEntryKit
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
    let simple = EKSimpleMessage(image: image, title: titleLabel, description: descLabel)
    let notification = EKNotificationMessage(simpleMessage: simple)
    return EKNotificationMessageView(with: notification)
}

final class SwiftEntryKitDemoVC: BaseVC {
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

    private lazy var btnTopBanner: UIButton = {
        UIButton.sys()
            .byTitle("顶部 Banner（2s 自动消失）")
            .onTap { [weak self] (_: UIButton) in
                var attr = EKAttributes()
                    .byPosition(.top)
                    .byDuration(2)
                    .byBackground(.visualEffect(style: .dark))
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
                SwiftEntryKit.display(entry: makeMessageView(title: "已完成", desc: "数据保存成功", systemImage: "checkmark.circle.fill"),
                                      using: attr)
            }
    }()

    private lazy var btnCenterToast: UIButton = {
        UIButton.sys()
            .byTitle("中心 Toast（缩放进入）")
            .onTap { [weak self] (_: UIButton) in
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
                SwiftEntryKit.display(entry: makeMessageView(title: "提示", desc: "中心 Toast", systemImage: "bolt.fill"),
                                      using: attr)
            }
    }()

    private lazy var btnBottomSheet: UIButton = {
        UIButton.sys()
            .byTitle("底部半高 Sheet（可拖动&键盘避让）")
            .onTap { [weak self] (_: UIButton) in
                var attr = EKAttributes()
                    .byPosition(.bottom)
                    .byDuration(.infinity)
                    .byBackground(.color(color: EKColor(.secondarySystemBackground)))
                    .byScreen(.color(color: EKColor(UIColor(white: 0, alpha: 0.35))))
                    .byCorner(radius: 18, edges: .top(radius: 18))
                    .byShadow()
                    .byAbsorbTouches(true)       // 点击遮罩关闭
                    .byScrollable(swipeable: true)
                    .byDisplayMode(.inferred)
                    .byStatusBar(.inferred)
                    .byKeyboardAvoiding(.bind(offset: .init(bottom: 10, screenEdgeResistance: 20)))

                attr = attr.bySize(
                    width:  EKAttributes.PositionConstraints.Edge.offset(value: 0),
                    height: EKAttributes.PositionConstraints.Edge.ratio(value: 0.45)
                )

                let anim = EKAttributes.animTranslationInOut
                attr = attr.byEntrance(anim.entrance).byExit(anim.exit)
                SwiftEntryKit.display(entry: SheetContentView(),
                                      using: attr)
            }
    }()

    private lazy var btnFullscreen: UIButton = {
        UIButton.sys()
            .byTitle("全屏公告（点遮罩关闭）")
            .onTap { [weak self] (_: UIButton) in
                guard let self else { return }
                label.byVisible(YES)
                var attr = EKAttributes()
                    .byPosition(.center)
                    .byDuration(.infinity)
                    .byBackground(.color(color: EKColor(.clear)))
                    .byScreen(.color(color: EKColor(UIColor(white: 0, alpha: 0.6))))
                    .byEntryInteraction(.dismiss)     // 你已有的 DSL
                    .byScreenInteraction(.dismiss)    // 你已有的 DSL
                    .byDisplayMode(.dark)
                    .byStatusBar(.light)
                    .byWindow(level: .alerts)

                // 全屏
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
    }()

    private lazy var btnCenterConfirmToast: UIButton = {
        UIButton.sys()
            .byTitle("中心 Toast（确认按钮关闭）")
            .onTap { [weak self] (_: UIButton) in
                var attr = EKAttributes()
                    .byPosition(.center)
                    .byDuration(.infinity)  // 交互型：不自动消失
                    // 统一交给 EK 控制外观
                    .byBackground(.color(color: EKColor(.secondarySystemBackground)))
                    .byCorner(radius: 14)
                    .byShadow()
                    // 外部点击无效，必须点按钮
                    .byEntryInteraction(.absorbTouches)
                    .byScreenInteraction(.forward)
                    // 给一点儿半透明遮罩增强聚焦，但不响应关闭
                    .byScreen(.color(color: EKColor(UIColor(white: 0, alpha: 0.15))))
                    .byDisplayMode(.inferred)
                    .byStatusBar(.inferred)

                let anim = EKAttributes.animScaleInFadeOut
                attr = attr.byEntrance(anim.entrance).byExit(anim.exit)

                SwiftEntryKit.display(entry: ConfirmToastView().onConfirm {
                    SwiftEntryKit.dismiss()
                },using: attr)
            }
    }()

    private lazy var btnQueue: UIButton = {
        UIButton.sys()
            .byTitle("队列与优先级（先排队，再插队）")
            .onTap { [weak self] (_: UIButton) in
                func enqueue(_ title: String, priority: EKAttributes.Precedence.Priority = .normal) {
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
                    SwiftEntryKit.display(entry: makeMessageView(title: title, desc: "队列演示", systemImage: "list.bullet"),
                                          using: a)
                }

                enqueue("普通 #1")
                enqueue("普通 #2")
                enqueue("普通 #3")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    var a = EKAttributes()
                        .byPosition(.top)
                        .byDuration(1.8)
                        .byBackground(.color(color: EKColor(.systemYellow)))
                        .byCorner(radius: 12)
                        .byQueue(priority: .max, dropEnqueuedEntries: false)
                        .byHaptic(.success)

                    let anim = EKAttributes.animTranslationInOut
                    a = a.byEntrance(anim.entrance).byExit(anim.exit)
                    SwiftEntryKit.display(entry: makeMessageView(title: "⚡️ 高优先级覆盖", desc: "precedence.override", systemImage: "bolt.fill"),
                                          using: a)
                }
            }
    }()

    private lazy var btnStatusBar: UIButton = {
        UIButton.sys()
            .byTitle("状态栏样式切换（light/dark）")
            .onTap { [weak self] (_: UIButton) in
                var a1 = EKAttributes()
                    .byPosition(.top)
                    .byDuration(1.4)
                    .byBackground(.color(color: EKColor(.systemBlue)))
                    .byCorner(radius: 12)
                    .byStatusBar(.light)
                    .byHaptic(.success)
                let t = EKAttributes.animTranslationInOut
                a1 = a1.byEntrance(t.entrance).byExit(t.exit)
                SwiftEntryKit.display(entry: makeMessageView(title: "状态栏：Light", desc: "statusBar = .light", systemImage: "sun.max.fill"),
                                      using: a1)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    var a2 = EKAttributes()
                        .byPosition(.top)
                        .byDuration(1.4)
                        .byBackground(.color(color: EKColor(.systemGray6)))
                        .byCorner(radius: 12)
                        .byStatusBar(.dark)
                        .byHaptic(.warning)
                    let tt = EKAttributes.animTranslationInOut
                    a2 = a2.byEntrance(tt.entrance).byExit(tt.exit)
                    SwiftEntryKit.display(entry: makeMessageView(title: "状态栏：Dark", desc: "statusBar = .dark", systemImage: "moon.fill"),
                                          using: a2)
                }
            }
    }()

    private lazy var btnDismissAll: UIButton = {
        UIButton.sys()
            .byTitle("手动关闭所有")
            .onTap { (_: UIButton) in
                SwiftEntryKit.dismiss(.all, with: nil)
            }
    }()

    private lazy var container: UIView = {
        UIView().byBgColor(UIColor.black.withAlphaComponent(0.88))
    }()

    private lazy var label: UILabel = {
        UILabel()
            .byText("📢 这是一则全屏公告\n点空白可关闭")
            .byTextAlignment(.center)
            .byFont(.boldSystemFont(ofSize: 22))
            .byNumberOfLines(0)
            .byTextColor(.white)
            .byAddTo(container) { make in
                make.center.equalToSuperview()
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "SwiftEntryKit 全展示")
        [btnTopBanner,
         btnCenterToast,
         btnBottomSheet,
         btnFullscreen,
         btnCenterConfirmToast,
         btnQueue,
         btnStatusBar,
         btnDismissAll].forEach { stack.addArrangedSubview($0) }
    }
}
