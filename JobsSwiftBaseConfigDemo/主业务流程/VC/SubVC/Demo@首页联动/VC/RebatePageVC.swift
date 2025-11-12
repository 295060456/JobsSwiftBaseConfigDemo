//
//  RebatePageVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit
import JXSegmentedView

final class RebatePageVC: BaseVC, JXSegmentedListContainerViewListDelegate {

    // 左侧菜单数据（与截图一致顺序，默认选中“棋牌.5”）
    private let menuItems: [LeftMenuItem] = [
        .init(icon: "star", title: "日常.5"),
        .init(icon: "star", title: "新人.5"),
        .init(icon: "star", title: "电子.5"),
        .init(icon: "star", title: "体育.5"),
        .init(icon: "star.fill", title: "棋牌.5"),
        .init(icon: "star", title: "真人.5"),
        .init(icon: "star", title: "捕鱼.5"),
        .init(icon: "star", title: "钱包教程.5")
    ]

    var items: [String] = (1...5).map { "返水 - 棋牌.5 活动 \($0)" }

    // 左侧菜单（灰底、右侧细分隔线）
    private lazy var menuView: LeftMenuView = {
        LeftMenuView(items: menuItems, defaultIndex: 4)
            .onSelectionChanged { [weak self] _ in
                self?.reloadForMenu()
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(8)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
                }
                make.leading.bottom.equalToSuperview()
                make.width.equalTo(112)
            }
    }()

    // 右侧列表（紫色卡片）
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(CashbackCardCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.none)
            .byNoSectionHeaderTopPadding()
            .byBgColor(UIColor.systemGroupedBackground)
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton(type: .system)
                    .byTitle("暂无数据", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("tray".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.items = (1...5).map { "返水 - \(self.menuView.currentTitle) 活动 \($0)" }
                        self.tableView.reloadData()
                    }
            }
            .configRefreshHeader(component: JobsDefaultHeader(), container: self, trigger: 66) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    self.items = (1...5).map { "返水 - \(self.menuView.currentTitle) 活动 \($0)" }
                    self.tableView.byReloadData()
                    self.tableView.switchRefreshHeader(to: .normal)
                }
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(8)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
                }
                make.leading.equalTo(menuView.snp.trailing).offset(16)
                make.trailing.bottom.equalToSuperview()
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        menuView.byVisible(YES)
        tableView.byVisible(YES)
    }

    private func reloadForMenu() {
        items = (1...5).map { "返水 - \(menuView.currentTitle) 活动 \($0)" }
        tableView.reloadData()
    }

    // JXSegmented
    func listView() -> UIView { view }
}
// 协议放分类
extension RebatePageVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CashbackCardCell = tableView.py_dequeueReusableCell(withType: CashbackCardCell.self, for: indexPath)
        cell.configure(title: items[indexPath.row], subtitle: "神秘彩金等你来拿")
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
