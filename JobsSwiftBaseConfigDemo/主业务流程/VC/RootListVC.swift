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
        ("PicLoad Demo", PicLoadDemoVC.self)
    ]

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // 防抖标记：避免重复触发
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
        gk_navTitle = "Demo 列表"

        // 左上角
        let leftBtn = UIButton(type: .system)
        leftBtn.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        leftBtn.tintColor = .systemBlue
        leftBtn.addAction(UIAction { _ in
            print("✅ 左上角按钮 tapped OK")
        }, for: .touchUpInside)
        gk_navLeftBarButtonItem = UIBarButtonItem(customView: leftBtn)

        // 右上角：主题 / 语言 / 停止刷新
        let themeBtn = makeNavButton(symbol: "moon.circle.fill", tint: .systemIndigo) { [weak self] in
            self?.toggleTheme()
        }
        let langBtn  = makeNavButton(symbol: "globe", tint: .systemGreen) { [weak self] in
            self?.toggleLanguage()
        }
        let stopBtn  = makeNavButton(symbol: "stop.circle.fill", tint: .systemRed) { [weak self] in
            self?.stopRefreshing()
        }
        gk_navRightBarButtonItems = [
            UIBarButtonItem(customView: themeBtn),
            UIBarButtonItem(customView: langBtn),
            UIBarButtonItem(customView: stopBtn)
        ]
    }

    private func makeNavButton(symbol: String, tint: UIColor, action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: symbol), for: .normal)
        b.tintColor = tint
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        // 统一按钮尺寸，避免点击区域过小
        b.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        return b
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
        // 下拉
        tableView.es.addPullToRefresh { [weak self] in
            guard let self = self, !self.isPullRefreshing else { return }
            self.isPullRefreshing = true
            print("⬇️ 下拉刷新触发")
            // 模拟请求
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isPullRefreshing = false
                self.tableView.reloadData()
                self.tableView.es.stopPullToRefresh()
                // 首次刷新后再决定是否开启“上拉加载”
                self.updateFooterAvailability()
                print("✅ 下拉刷新完成")
            }
        }

        // 上拉
        tableView.es.addInfiniteScrolling { [weak self] in
            guard let self = self, !self.isLoadingMore else { return }
            self.isLoadingMore = true
            print("⬆️ 上拉加载触发")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLoadingMore = false
                // 模拟：这次没有更多了
                self.tableView.es.stopLoadingMore()
                // 如果确定没有更多：self.tableView.es.noticeNoMoreData()
                print("✅ 上拉加载完成")
                self.updateFooterAvailability()
            }
        }

        // 初次进入只开启下拉；上拉根据内容高度动态开关
        updateFooterAvailability()
    }

    /// 当内容高度不足一屏时，隐藏或禁用上拉，避免“刚进来就触发/循环触发”
    private func updateFooterAvailability() {
        tableView.layoutIfNeeded()
        let contentH = tableView.contentSize.height
        let visibleH = tableView.bounds.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom
        let enableLoadMore = contentH > visibleH + 20   // 留一点阈值
        tableView.es.base.footer?.isHidden = !enableLoadMore
        if !enableLoadMore {
            // 防御：正在加载时强制停止
            tableView.es.stopLoadingMore()
        }
    }

    // MARK: - 右上角动作
    private func toggleTheme() {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let win = ws.windows.first {
            win.overrideUserInterfaceStyle = (win.overrideUserInterfaceStyle == .dark) ? .light : .dark
            print("🌓 主题已切换 -> \(win.overrideUserInterfaceStyle == .dark ? "Dark" : "Light")")
        }
    }

    private func toggleLanguage() {
        print("🌐 切换语言 tapped（占位，后续接入多语言方案）")
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { demos.count }

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
        // 内容变化时动态判断是否需要显示 footer，避免循环触发
        updateFooterAvailability()
    }
}
