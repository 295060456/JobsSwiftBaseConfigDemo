//
//  RootListVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/29/25.
//

import UIKit
import ESPullToRefresh
import GKNavigationBarSwift

final class RootListVC: UIViewController {

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
        ("中国大陆公民身份证号码校验 Demo", CNIDDemoVC.self)
    ]

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    // 防抖标记
    private var isPullRefreshing = false
    private var isLoadingMore    = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefresh()
    }
    // MARK: - UI（GK 自绘导航）
    private func setupUI() {
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
    }
    // MARK: - TableView
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.contentInset = UIEdgeInsets(top: UIApplication.jobsSafeTopInset,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
    }
    // MARK: - ESPullToRefresh
    private func setupRefresh() {
        // 下拉刷新
        tableView.es.addPullToRefresh { [weak self] in
            guard let self = self, !self.isPullRefreshing else { return }
            self.isPullRefreshing = true
            print("⬇️ 下拉刷新触发")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isPullRefreshing = false
                self.tableView.reloadData()
                self.tableView.es.stopPullToRefresh()
                self.updateFooterAvailability()
                print("✅ 下拉刷新完成")
            }
        }
        // 上拉加载
        tableView.es.addInfiniteScrolling { [weak self] in
            guard let self = self, !self.isLoadingMore else { return }
            self.isLoadingMore = true
            print("⬆️ 上拉加载触发")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLoadingMore = false
                self.tableView.es.stopLoadingMore()
                print("✅ 上拉加载完成")
                self.updateFooterAvailability()
            }
        }

        updateFooterAvailability()
    }
    // MARK: - 动态控制 Footer 显隐
    private func updateFooterAvailability() {
        tableView.layoutIfNeeded()
        let contentH = tableView.contentSize.height
        let visibleH = tableView.bounds.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom
        let enableLoadMore = contentH > visibleH + 20
        tableView.es.base.footer?.isHidden = !enableLoadMore
        if !enableLoadMore {
            tableView.es.stopLoadingMore()
        }
    }
    // MARK: - 按钮动作
    private func toggleTheme() {
        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let win = ws.windows.first else { return }
        win.overrideUserInterfaceStyle = (win.overrideUserInterfaceStyle == .dark) ? .light : .dark
        print("🌓 主题已切换 -> \(win.overrideUserInterfaceStyle == .dark ? "Dark" : "Light")")
    }

    private func toggleLanguage() {
        print("🌐 切换语言 tapped（占位）")
    }

    private func stopRefreshing() {
        print("🛑 手动停止刷新")
        isPullRefreshing = false
        isLoadingMore    = false
        tableView.es.stopPullToRefresh()
        tableView.es.stopLoadingMore()
    }
}
// MARK: - DataSource & Delegate
extension RootListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = demos[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = demos[indexPath.row].vcType.init()
        vc.title = demos[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFooterAvailability()
    }
}
