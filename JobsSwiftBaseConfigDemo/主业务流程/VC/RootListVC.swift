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

    private let demos: [(title: String, vcType: UIViewController.Type)] = [
        ("ViewController", ViewController.self),
        ("UITextField Demo", UITextFieldDemoVC.self),
        ("UITextView Demo", UITextViewDemoVC.self),
        ("RichText Demo", RichTextDemoVC.self),
        ("UIButton Demo", UIButtonDemoVC.self),
        ("SafetyPush Demo", SafetyPushDemoVC.self),
        ("SafetyPresent Demo", SafetyPresentDemoVC.self),
        ("JobsCountdown Demo", JobsCountdownDemoVC.self),
        ("Keyboard Demo", KeyboardDemoVC.self),
        ("ControlEvents Demo", JobsControlEventsDemoVC.self),
        ("PicLoad Demo", PicLoadDemoVC.self),
        ("中国大陆公民身份证号码校验 Demo", CNIDDemoVC.self),
        ("Toast Demo", ToastDemoVC.self),
        ("Timer Demo", TimerDemoVC.self),
        ("JobsOpen Demo", JobsOpenDemoVC.self)
    ]

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
                animator.idleDescription = "下拉刷新"
                animator.releaseToRefreshDescription = "松开立即刷新"
                animator.loadingDescription = "正在刷新中..."
                animator.noMoreDataDescription = "已经是最新数据"
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
                animator.idleDescription = "上拉加载更多"
                animator.releaseToRefreshDescription = "松开立即加载"
                animator.loadingMoreDescription = "加载中..."
                animator.noMoreDataDescription = "已经到底了～"
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
