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
    }

    private let demos: [(title: String, vcType: UIViewController.Type)] = [
        ("ViewController", ViewController.self),
        ("✍️ UITextField Demo", UITextFieldDemoVC.self),
        ("✍️ UITextView Demo", UITextViewDemoVC.self),
        ("🌋 富文本 Demo", RichTextDemoVC.self),
        ("🌍 JobsTabBarCtrl Demo", TabBarDemoVC.self),
        ("📷 鉴权后调用相机/相册 Demo", PhotoAlbumDemoVC.self),
        ("🛢️ 解码 Demo", SafeCodableDemoVC.self),
        ("🔘 按钮 Demo", UIButtonDemoVC.self),
        ("🧧 TraitChange Demo", TraitChangeDemoVC.self),
        ("⛑️ SafetyPush Demo", SafetyPushDemoVC.self),
        ("⛑️ SafetyPresent Demo", SafetyPresentDemoVC.self),
        ("🐎 跑马灯/🛞 轮播图 Demo", JobsMarqueeDemoVC.self),
        ("🐎 二维码/条形码 Demo", QRCodeDemoVC.self),
        ("💥 JobsCountdown Demo", JobsCountdownDemoVC.self),
        ("⏰ Timer Demo", TimerDemoVC.self),
        ("⌨️ 键盘 Demo", KeyboardDemoVC.self),
        ("🕹️ ControlEvents Demo", JobsControlEventsDemoVC.self),
        ("🏞️ 图片加载Demo", PicLoadDemoVC.self),
        ("👮 中国大陆公民身份证号码校验 Demo", CNIDDemoVC.self),
        ("🏷️ Toast Demo", ToastDemoVC.self),
        ("⚠️ 系统的弹出框", UIAlertDemoVC.self),
        ("🚀 JobsOpen Demo", JobsOpenDemoVC.self)
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
                    .byDocking(.nearestEdge)
                    .byInsets(UIEdgeInsets(top: 20, left: 16, bottom: 34, right: 16))
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
                    .byFallbackSize(CGSize(width: 88, height: 44))
                    .byDocking(.nearestEdge)
                    .byInsets(UIEdgeInsets(top: 20, left: 16, bottom: 34, right: 16))
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
                animator.idleDescription = "Jobs@下拉刷新"
                animator.releaseToRefreshDescription = "Jobs@松开立即刷新"
                animator.loadingDescription = "Jobs@正在刷新中..."
                animator.noMoreDataDescription = "Jobs@已经是最新数据"
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
                animator.idleDescription = "Jobs@上拉加载更多"
                animator.releaseToRefreshDescription = "Jobs@松开立即加载"
                animator.loadingMoreDescription = "Jobs@加载中..."
                animator.noMoreDataDescription = "Jobs@已经到底了～"
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
            leftSymbol: "list.bullet",
            rightButtons: [
                ("moon.circle.fill", .systemIndigo, { [weak self] in self?.toggleTheme() }),
                ("globe", .systemGreen, { [weak self] in self?.toggleLanguage() }),
                ("stop.circle.fill", .systemRed, { [weak self] in self?.stopRefreshing() })
            ]
        )
        tableView.byAlpha(1)
        updateFooterAvailability()
//        suspendLab.byAlpha(1)
        suspendBtn.byAlpha(1)
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

    // MARK: - 按钮动作
    private func toggleTheme() {
        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let win = ws.windows.first else { return }
        win.overrideUserInterfaceStyle =
            (win.overrideUserInterfaceStyle == .dark) ? .light : .dark
        print("🌓 主题已切换 -> \(win.overrideUserInterfaceStyle == .dark ? "Dark" : "Light")")
    }

    private func toggleLanguage() {
        print("🌐 切换语言 tapped（占位）")
    }

    private func stopRefreshing() {
        print("🛑 手动停止刷新")
        isPullRefreshing = false
        isLoadingMore    = false
        tableView.pullDownStop()
        tableView.pullUpStop()
    }
}
// MARK: - DataSource & Delegate
extension RootListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = demos[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        demos[indexPath.row].vcType.init().byPush(self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFooterAvailability()
    }
}
