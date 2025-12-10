//
//  FeedListVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import SnapKit

final class FeedListVC: BaseVC,
                        UITableViewDataSource,
                        UITableViewDelegate {

    private var allItems: [FeedItem] = []
    private var items: [FeedItem] = []
    private var page = 1
    private let pageSize = 10
    private var isPullRefreshing = false
    private var isLoadingMore    = false

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(FeedListCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()
            // 空态按钮（点击加载首屏）
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton(type: .system)
                    .byTitle("暂无数据", for: .normal)
                    .bySubTitle("点我加载本地示例数据", for: .normal)
                    .byImage("tray".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in self?.reloadFromJSON() }
                    .jobs_setEmptyLayout { _, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "信息流预览"
        )
        tableView.byVisible(YES)
    }

    private func reloadFromJSON() {
        allItems = FeedModel.loadAll()
        page = 1
        items = FeedModel.page(all: allItems, page: page, pageSize: pageSize)
        tableView.byReloadData()
        updateFooterAvailability()
        tableView.jobs_reloadEmptyViewAuto()
    }

    fileprivate func updateFooterAvailability() {
        if items.count >= allItems.count && !items.isEmpty {
            /// TODO
        }
    }
    // MARK: DataSource / Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.py_dequeueReusableCell(withType: FeedListCell.self, for: indexPath)
        cell.fill(items[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PlayerDetailVC(item: items[indexPath.row]).byPush(self)
    }
}
