//
//  RootListVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/29/25.
//

import UIKit
import GKNavigationBarSwift
import ESPullToRefresh   // 由扩展内部使用

final class RootListVC: BaseVC {

    deinit {
        suspendBtn.stopTimer()
        suspendSpinBtn.stopTimer()
    }

    private let demos: [(title: String, vcType: UIViewController.Type)] = [
        ("ViewController", ViewController.self),
        ("✍️ UITextField", UITextFieldDemoVC.self),
        ("✍️ UITextView", UITextViewDemoVC.self),
        ("🌋 富文本", RichTextDemoVC.self),
        ("🌋 普通文本和富文本的融合数据类型", JobsTextDemoVC.self),
        ("🌍 JobsTabBarCtrl", TabBarDemoVC.self),
        ("📷 鉴权后调用相机/相册", PhotoAlbumDemoVC.self),
        ("🛢️ 解码", SafeCodableDemoVC.self),
        ("🔘 按钮", UIButtonDemoVC.self),
        ("🛜 Moya网络请求框架", MoyaDemoVC.self),
        ("🛜 Alamofire网络请求框架", AFDemoVC.self),
        ("🧧 TraitChange", TraitChangeDemoVC.self),
        ("⛑️ 支持上下左右安全Push和原路返回", SafetyPushDemoVC.self),
        ("⛑️ 安全Present", SafetyPresentDemoVC.self),
        ("📹 播放器@BMPlayer", DemoMenuVC.self),
        ("🗄️ UITableView", EmptyTableViewDemoVC.self),
        ("🗄️ UICollectionView", EmptyCollectionViewDemoVC.self),
        ("🐎 跑马灯/🛞 轮播图", JobsMarqueeDemoVC.self),
        ("🐎 二维码/条形码", QRCodeDemoVC.self),
        ("🌞 BaseWebView", BaseWebViewDemoVC.self),
        ("💥 JobsCountdown", JobsCountdownDemoVC.self),
        ("⏰ Timer", TimerDemoVC.self),
        ("⌨️ 键盘", KeyboardDemoVC.self),
        ("🕹️ ControlEvents", JobsControlEventsDemoVC.self),
        ("🏞️ 图片加载", PicLoadDemoVC.self),
        ("👮 中国大陆公民身份证号码校验", CNIDDemoVC.self),
        ("🏷️ Toast", ToastDemoVC.self),
        ("⚠️ 系统的弹出框", UIAlertDemoVC.self),
        ("🚀 JobsOpen", JobsOpenDemoVC.self)
    ]

    private lazy var suspendLab: UILabel = {
        UILabel()
            .byText("VIP")
            .byTextColor(.yellow)
            .byFont(.boldSystemFont(ofSize: 14))
            .byTextAlignment(.center)
            .byBgCor(.systemRed)
            .byCornerRadius(12)
            .byMasksToBounds(true)
            .byUserInteractionEnabled(true)
            .suspend(
                .default
                    .byContainer(view)
                    .byFallbackSize(CGSize(width: 88, height: 44))
                    .byStart(.point(CGPoint(x: 100, y: 200))) // 起始点
                    .byHapticOnDock(true)
            )
    }()

    private lazy var suspendBtn: UIButton = {
        UIButton(type: .system)
            .byTitle("开始", for: .normal)
            .byTitleFont(.systemFont(ofSize: 22, weight: .bold))
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemBlue, for: .normal)
            .byCornerRadius(10)
            .byMasksToBounds(true)
            .startTimer(total: nil,
                        interval: 1.0,
                        kind: .gcd)
            // 每 tick：更新时间 & 最近触发时间
            .onTimerTick { [weak self] btn, elapsed, _, kind in
                guard let self else { return }
                if btn.title(for: .normal) != "VIP" {
                    btn.byTitle("VIP", for: .normal)
                }
                btn.bySubTitle(nowClock(), for: .normal)
                btn.bySetNeedsUpdateConfiguration()
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
//                if gr.state == .began { btn.alpha = 0.6 }
//                else if gr.state == .ended || gr.state == .cancelled { btn.alpha = 1.0 }
                JobsToast.show(
                    text: "长按了悬浮按钮",
                    config: JobsToast.Config()
                        .byBgColor(.systemGreen.withAlphaComponent(0.9))
                        .byCornerRadius(12)
                )
            }
            // 点击开始：不传 total => 正计时
            .onTap { [weak self] btn in
                guard let self else { return }
                JobsToast.show(
                    text: "点击了悬浮按钮",
                    config: JobsToast.Config()
                        .byBgColor(.systemGreen.withAlphaComponent(0.9))
                        .byCornerRadius(12)
                )
//                btn.startTimer(total: nil,
//                               interval: 1.0,
//                               kind: .gcd)
            }
            .bySuspend { cfg in
                cfg
                    .byContainer(view)
//                    .byStart(.topLeft)
                    .byStart(.point(CGPoint(x: 0, y: 200))) // 起始点（可用区域坐标）
                    .byFallbackSize(CGSize(width: 90, height: 50))
                    .byDocking(.nearestEdge)
                    .byHapticOnDock(true)
            }
    }()

    private lazy var suspendSpinBtn: UIButton = {
        UIButton(type: .system)
            .byTitle("0", for: .normal) // 中间数字：秒
            .byTitleFont(.systemFont(ofSize: 22, weight: .bold))
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemOrange, for: .normal)
            .byCornerRadius(25)
            .byMasksToBounds(true)

            // 正计时：每秒触发一次
            .startTimer(total: nil, interval: 1.0, kind: .gcd)

            // 每 tick：更新中心数字
            .onTimerTick { [weak self] btn, elapsed, _, _ in
                guard let _ = self else { return }
                let sec = Int(elapsed)             // 累计秒
                // 只有变化时才刷新，避免不必要的重绘
                if btn.title(for: .normal) != "\(sec)" {
                    btn.byTitle("\(sec)", for: .normal)
                        .bySetNeedsUpdateConfiguration()
                }
            }
            // 长按：原逻辑
            .onLongPress(minimumPressDuration: 0.8) { btn, _ in
                JobsToast.show(
                    text: "长按了悬浮按钮",
                    config: JobsToast.Config()
                        .byBgColor(.systemGreen.withAlphaComponent(0.9))
                        .byCornerRadius(12)
                )
            }
            // 点击：保持原来的 Toast（不改动计时逻辑）
            .onTap { [weak self] btn in
                guard let _ = self else { return }
                btn.playTapBounce(haptic: .light)  // 👈 临时放大→回弹（不注册任何手势/事件）
                if btn.jobs_isSpinning {
                    // 暂停旋转
                    btn.bySpinPause()
                    // 暂停计时（保留已累计秒，不重置）
                    btn.timer?.pause()        // ✅ 推荐：你的统一内核挂在 button.timer 上
                    // 如果你有封装方法，则用：btn.pauseTimer()
                    JobsToast.show(
                        text: "已暂停旋转 & 计时",
                        config: .init().byBgColor(.systemGreen.withAlphaComponent(0.9)).byCornerRadius(12)
                    )
                } else {
                    // 恢复旋转
                    btn.bySpinStart()
                    // 恢复计时（从暂停处继续累加）
                    btn.timer?.resume()       // ✅ 推荐
                    // 如果你有封装方法，则用：btn.resumeTimer()
                    JobsToast.show(
                        text: "继续旋转 & 计时",
                        config: .init().byBgColor(.systemGreen.withAlphaComponent(0.9)).byCornerRadius(12)
                    )
                }
            }
            // 悬浮配置
            .bySuspend { cfg in
                cfg
                    .byContainer(view)
//                    .byStart(.bottomRight)
                    .byStart(.point(CGPoint(x: Screen.width - 60, y: Screen.height - 100))) // 起始点（可用区域坐标）
                    .byFallbackSize(CGSize(width: 50, height: 50))
                    .byHapticOnDock(true)
            }
    }()

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UITableViewCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()
            .byContentInset(UIEdgeInsets(
                top: UIApplication.jobsSafeTopInset + 30,
                left: 0,
                bottom: 0,
                right: 0
            ))
            // 下拉刷新（自定义 JobsHeaderAnimator）
            .pullDownWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isPullRefreshing else { return }
                self.isPullRefreshing = true
                print("⬇️ 下拉刷新触发")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isPullRefreshing = false
                    self.tableView.byReloadData()
                    self.tableView.pullDownStop()               // 结束下拉
                    self.updateFooterAvailability()
                    print("✅ 下拉刷新完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@下拉刷新")
                    .byReleaseToRefreshDescription("Jobs@松开立即刷新")
                    .byLoadingDescription("Jobs@正在刷新中...")
                    .byNoMoreDataDescription("Jobs@已经是最新数据")
            })
            // 上拉加载（自定义 JobsFooterAnimator）
            .pullUpWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isLoadingMore else { return }
                self.isLoadingMore = true
                print("⬆️ 上拉加载触发")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isLoadingMore = false
                    self.tableView.pullUpStop()                 // 结束上拉
                    self.updateFooterAvailability()
                    print("✅ 上拉加载完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@上拉加载更多")
                    .byReleaseToRefreshDescription("Jobs@松开立即加载")
                    .byLoadingMoreDescription("Jobs@加载中…")
                    .byNoMoreDataDescription("Jobs@没有更多数据")
            })
            .byAddTo(view) { make in
                make.edges.equalToSuperview()
            }
    }()

    // 防抖标记
    private var isPullRefreshing = false
    private var isLoadingMore    = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "Demo 列表",
            leftButton:UIButton.sys()
                .byFrame(CGRect(x: 0, y: 0, width: 32.w, height: 32.h))
                /// 按钮图片@图文关系
                .byImage("list.bullet".sysImg, for: .normal)
                .byImage("list.bullet".sysImg, for: .selected)
                /// 事件触发@点按
                .onTap { [weak self] sender in
                    guard let self else { return }
                    sender.isSelected.toggle()
                    debugOnly {  // 仅 Debug 执行
                        JobsToast.show(
                            text: "点按了列表按钮",
                            config: JobsToast.Config()
                                .byBgColor(.systemGreen.withAlphaComponent(0.9))
                                .byCornerRadius(12)
                        )
                    }
                }
                /// 事件触发@长按
                .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                     if gr.state == .began {
                         btn.alpha = 0.6
                         print("长按开始 on \(btn)")
                     } else if gr.state == .ended || gr.state == .cancelled {
                         btn.alpha = 1.0
                         print("长按结束")
                     }
                },
            rightButtons: [
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("moon.circle.fill".sysImg, for: .normal)
                    .byImage("moon.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let win = ws.windows.first else { return }
                        win.overrideUserInterfaceStyle =
                            (win.overrideUserInterfaceStyle == .dark) ? .light : .dark
                        print("🌓 主题已切换 -> \(win.overrideUserInterfaceStyle == .dark ? "Dark" : "Light")")
                    },
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("globe".sysImg, for: .normal)
                    .byImage("globe".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        print("🌐 切换语言 tapped（占位）")
                    },
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("stop.circle.fill".sysImg, for: .normal)
                    .byImage("stop.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        print("🛑 手动停止刷新")
                        isPullRefreshing = false
                        isLoadingMore    = false
                        tableView.pullDownStop()
                        tableView.pullUpStop()
                    }
            ]
        )
        tableView.byAlpha(1)
        updateFooterAvailability()
//        suspendLab.byAlpha(1)
        suspendSpinBtn.bySpinStart()
        suspendBtn.byVisible(YES)
    }
    // MARK: - Footer 自动显隐逻辑
    private func updateFooterAvailability() {
        tableView.layoutIfNeeded()
        let contentH = tableView.contentSize.height
        let visibleH = tableView.bounds.height
            - tableView.adjustedContentInset.top
            - tableView.adjustedContentInset.bottom
        let enableLoadMore = contentH > visibleH + 20

        tableView.footer?.isHidden = !enableLoadMore
        if !enableLoadMore {
            tableView.pullUpStop()
        }
    }
}
// MARK: - DataSource & Delegate
extension RootListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = demos[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        demos[indexPath.row].vcType.init().byPush(self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFooterAvailability()
    }
}
