//
//  TabBarDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 10/16/25.
//

import UIKit
import SnapKit

// MARK: - Demo：多按钮（>5）以便直观看 ScrollView 横向滑动
final class TabBarDemoVC: BaseVC {
    // MARK: JobsTabBarCtrl（链式点语法 + 中间按钮凸起 + 横竖屏自适应）
    private lazy var tabCtrl: JobsTabBarCtrl = {
        JobsTabBarCtrl()
            .bySwipeEnabled(true)
            .byHorizontalOnly(true)                // ✅ 只允许横向
            .bySuppressChildVerticalScrolls(true)  // ✅（可选）禁子 VC 内纵向滚动
            .byBarBackgroundColor(.secondarySystemBackground)
            .byCustomBarHeight(nil)              // 默认：49 + 安全区
            .byBarBottomOffset(0)                // 贴底
            .byBarBackgroundImage(nil)
            // 布局策略（1 居中；2~5 等分；>5 继续按“5 等分”的单元宽/间距去排，超出横滑）
            .byContentInset(.init(top: 6, left: 12, bottom: 6, right: 12))
            .byEqualSpacing(10)
            .byEqualVisibleRange(2...5)
            .byLockUnitToMaxEqualCount(true)
            .byAutoRelayoutForBoundsChange(true)
            // 首次构建回调（此处无需处理）
            .onButtonsBuilt { _ in }
            // 每次布局后：做“中间按钮凸起”（横竖屏都会回调）
            .onButtonsLayoutedWeakOwner { owner, btns in
                guard !btns.isEmpty else { return }
                btns[2].byHeightOffset(0)
                    .byOriginYOffset(-24)
                    .byCornerRadius(14)
            }.byDataSource(
                buttons: [
                    /// 普通按钮@（无副标题、不配置事件、无富文本）
                    UIButton(type: .system)
                        .byNormalBgColor(.clear)
                        .byTitle("首页", for: .normal)
                        .byTitleColor(.label, for: .normal)
                        .byTitleColor(.systemRed, for: .selected)
                        .byTitleFont(.systemFont(ofSize: 12, weight: .semibold))
                        .byImage("house".sysImg, for: .normal)
                        .byImage("house.fill".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byTapSound("Sound.wav")
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10))
                        .byCornerBadgeText("NEW") { cfg in
                            cfg.byOffset(.init(horizontal: -6, vertical: 6))
                                .byInset(.init(top: 2, left: 6, bottom: 2, right: 6))
                                .byBgColor(.systemRed)
                                .byFont(.systemFont(ofSize: 11, weight: .bold))
                                .byShadow(color: UIColor.black.withAlphaComponent(0.25),
                                          radius: 2,
                                          opacity: 0.6,
                                          offset: .init(width: 0, height: 1))
                        },
                    /// 普通按钮@（配置事件）
                    UIButton(type: .system)
                        .byNormalBgColor(.clear)
                        .byTitle("优惠", for: .normal)
                        .byTitleColor(.label, for: .normal)
                        .byTitleColor(.systemRed, for: .selected)
                        .byTitleFont(.systemFont(ofSize: 12, weight: .medium))
                        .byImage("tag".sysImg, for: .normal)
                        .byImage("tag.fill".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byTapSound("Sound.wav")
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10))
                        .byCornerDot(diameter: 10, offset: .init(horizontal: -4, vertical: 4))// 红点
                        /// 事件触发@点按
                        .onTap { [weak self] sender in
                            guard let self else { return }
                            sender.isSelected.toggle()
                            if sender.isSelected {
                                sender.byCornerDot(diameter: 10, offset: .init(horizontal: -4, vertical: 4))
                            } else {
                                sender.removeCornerBadge()
                            }
                            toastBy("优惠@点按事件")
                        }
                        /// 事件触发@长按
                        .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                             if gr.state == .began {
                                 btn.alpha = 0.6
                                 print("长按开始 on \(btn)")
                                 toastBy("优惠@长按事件")
                             } else if gr.state == .ended || gr.state == .cancelled {
                                 btn.alpha = 1.0
                                 print("长按结束")
                             }
                         },
                    /// 普通按钮@（富文本）
                    UIButton(type: .system)
                        .byNormalBgColor(.clear)
                        .byRichTitle(JobsRichText.make([
                            JobsRichRun(.text("¥99")).font(.systemFont(ofSize: 10, weight: .semibold)).color(.systemRed),
                            JobsRichRun(.text(" /月")).font(.systemFont(ofSize: 12)).color(.green)
                        ]))         // ✅ 主标题富文本：一个入参
                        .byRichSubTitle(JobsRichText.make([
                            JobsRichRun(.text("原价 ")).font(.systemFont(ofSize: 10)).color(.blue.withAlphaComponent(0.8)),
                            JobsRichRun(.text("¥199")).font(.systemFont(ofSize: 12, weight: .medium)).color(.systemYellow)
                        ]))        // ✅ 副标题富文本：一个入参
                        .byImage("creditcard".sysImg, for: .normal)
                        .byImage("creditcard.fill".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10)),
                    UIButton(type: .system)
                        .byNormalBgColor(.clear)
                        .byTitle("好友", for: .normal)
                        .byTitleColor(.label, for: .normal)
                        .byTitleColor(.systemRed, for: .selected)
                        .byTitleFont(.systemFont(ofSize: 12, weight: .medium))
                        .byImage("person.2".sysImg, for: .normal)
                        .byImage("person.2.fill".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10)),
                    /// 倒计时按钮@（点击触发）
                    UIButton(type: .system)
                        .byTitle("活动", for: .normal)
                        .byTitleColor(.label, for: .normal)
                        .byTitleColor(.systemRed, for: .selected)
                        .byTitleFont(.systemFont(ofSize: 12, weight: .medium))
                        .bySubTitle("倒计时", for: .normal)
                        .bySubTitleColor(.label, for: .normal)
                        .bySubTitleColor(.systemRed, for: .selected)
                        .bySubTitleFont(.systemFont(ofSize: 12, weight: .medium))
                        .byImage("sparkles".sysImg, for: .normal)
                        .byImage("sparkles".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10))
                        .onCountdownTick { [weak self] btn, remain, total, kind in
                            guard let self else { return }
                            print("⏱️ [\(kind.jobs_displayName)] \(remain)/\(total)")
                            btn.byTitle("还剩", for: .normal)
                                .byTitle("还剩", for: .selected)
                                .bySubTitle("\(remain)s", for: .normal)
                                .bySubTitle("\(remain)s", for: .selected)
                        }
                        .onCountdownFinish { _, kind in
                            print("✅ [\(kind.jobs_displayName)] 倒计时完成")
                        }
                        .onTap { [weak self] btn in
                            guard let self else { return }
                            /// 点击以后倒计时
                            btn.startTimer(
                                total: 300, // ❤️ 传 total => 倒计时
                                interval: 1.0,
                                kind: .gcd
                            )
                            // 关键：等 startTimer 把 "10s" 设好后再加前缀，避免被覆盖
                            DispatchQueue.main.async {
                                btn.byTitle("还剩", for: .normal)
                                    .byTitle("还剩", for: .selected)
                                    .bySubTitle("\(300)s", for: .normal)
                                    .bySubTitle("\(300)s", for: .selected)
                            }
                        },
                    UIButton(type: .system)
                        .byNormalBgColor(.clear)
                        .byTitle("客服", for: .normal)
                        .byTitleColor(.label, for: .normal)
                        .byTitleColor(.systemRed, for: .selected)
                        .byTitleFont(.systemFont(ofSize: 12, weight: .medium))
                        .byImage("message".sysImg, for: .normal)
                        .byImage("message.fill".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10)),
                    /// 普通按钮@（展示副标题）
                    UIButton(type: .system)
                        .byNormalBgColor(.clear)
                        .byTitle("我的", for: .normal)
                        .byTitleColor(.label, for: .normal)
                        .byTitleColor(.systemRed, for: .selected)
                        .byTitleFont(.systemFont(ofSize: 12, weight: .semibold))
                        .bySubTitle("未登录", for: .normal)
                        .bySubTitleColor(.label, for: .normal)
                        .bySubTitleColor(.systemRed, for: .selected)
                        .bySubTitleFont(.systemFont(ofSize: 10, weight: .semibold))
                        .byImage("person.crop.circle".sysImg, for: .normal)
                        .byImage("person.crop.circle.fill".sysImg, for: .selected)
                        .byImagePlacement(.top)
                        .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10))],
                controllers: [
                    HomeVC(),
                    DiscountVC(),
                    WalletVC(),
                    FriendsVC(),
                    ActivityVC(),
                    ServiceVC()
                ]
            )
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "JobsTabBarCtrl@横滑 Demo（>5 个按钮）")

        addChild(tabCtrl)
        view.addSubview(tabCtrl.view)
        tabCtrl.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        tabCtrl.didMove(toParent: self)
    }
}
// MARK: - 示例子页（简化）
final class HomeVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "首页")
    }
}

final class DiscountVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
        jobsSetupGKNav(title: "优惠")
    }
}

final class WalletVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        jobsSetupGKNav(title: "钱包")
    }
}

final class FriendsVC: BaseVC {
    private lazy var exampleButton: UIButton = {
        UIButton(type: .system)
            /// 普通字符串@设置主标题
            .byTitle("显示", for: .normal)
            .byTitle("隐藏", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            /// 事件触发@点按
            .onTap { [weak self] sender in
                guard let self else { return }
                DemoDetailVC()
                    .byData(DemoModel(id: 7, title: "详情"))
                    .onResult { id in
                        print("回来了 id=\(id)")
                    }
                    .byPush(self)           // 自带防重入，连点不重复
                    .byCompletion{
                        print("❤️结束❤️")
                    }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10)
                make.center.equalToSuperview()
                make.height.equalTo(44)
                make.width.equalTo(44)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        jobsSetupGKNav(title: "好友")
        exampleButton.byAlpha(1)
    }
}

final class ActivityVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        jobsSetupGKNav(title: "活动")
    }
}

final class ServiceVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        jobsSetupGKNav(title: "客服")
    }
}
