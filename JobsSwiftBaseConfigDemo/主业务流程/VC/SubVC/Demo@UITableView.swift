//
//  Demo@UITableView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/22/25.
//
//  演示：UITableView 空态按钮（UIScrollView 层统一实现）+ 下拉刷新/上拉加载文案 DSL
//  依赖：SnapKit、UIScrollView+JobsEmptyButton.swift、JobsHeaderAnimator+DSL.swift、JobsFooterAnimator+DSL.swift
//

import UIKit
import SnapKit

final class EmptyTableViewDemoVC: BaseVC,
                                  UITableViewDataSource,
                                  UITableViewDelegate {
    // ================================== 数据源 & 状态 ==================================
    private var items: [String] = []                 // 初始为空 -> 触发空态
    private var isPullRefreshing = false
    private var isLoadingMore = false

    // ================================== UI：TableView（按你给的写法） ==================================
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UITableViewCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()
        
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton(type: .system)
                    .byTitle("暂无数据", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("tray".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.items = (1...10).map { "Row \($0)" }
                        self.tableView.reloadData()   // ✅ reload 后会自动评估空态，无需你再手动调用
                    }
                    // 可选：不满意默认居中 -> 自定义布局
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }

//            .byContentInset(UIEdgeInsets(
//                top: UIApplication.jobsSafeTopInset + 30,
//                left: 0,
//                bottom: 0,
//                right: 0
//            ))


            .byAddTo(view) {[unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()

    // ================================== 生命周期 ==================================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        jobsSetupGKNav(
            title: "UITableView@@空态刷新",
            rightButtons: [
                UIButton(type: .system)
                    /// 按钮图片@图文关系
                    .byImage("moon.circle.fill".sysImg, for: .normal)
                    .byImage("moon.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        print("🛑 手动停止刷新")
                        items.removeAll()
                        tableView.byReloadData()
                        updateFooterAvailability()
                        tableView.jobs_reloadEmptyViewAuto()
                    },
                UIButton(type: .system)
                    /// 按钮图片@图文关系
                    .byImage("globe".sysImg, for: .normal)
                    .byImage("globe".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        if items.isEmpty {
                            items = (1...12).map { "Row \($0)" }
                        } else {
                            let base = items.count
                            items += (1...6).map { "Row \(base + $0)" }
                        }
                        tableView.byReloadData()
                        updateFooterAvailability()
                        tableView.jobs_reloadEmptyViewAuto()
                    }
            ]
        )
        tableView.byVisible(true)
    }
    // ================================== Footer 可用性（示例实现） ==================================
    private func updateFooterAvailability() {
        // 这里仅打印，避免耦合第三方；你可替换为 noticeNoMoreData()/resetNoMoreData() 等
        if items.count >= 30 {
            print("🚫 没有更多数据了（示例）")
        } else {
            print("✅ 允许继续上拉加载（示例）")
        }
    }
    // ================================== UITableViewDataSource & Delegate ==================================
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    // 先确保注册：tableView.registerCell(UITableViewCell.self)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.py_dequeueReusableCell(withType: UITableViewCell.self, for: indexPath)
        if #available(iOS 14.0, *) {
            var cfg = cell.defaultContentConfiguration()
            cfg.text = items[indexPath.row]
            cfg.secondaryText = "Section \(indexPath.section) · Row \(indexPath.row)"
            cell.contentConfiguration = cfg
        } else {
            // iOS 13 及以下：没有 contentConfiguration，就直接设文本
            cell.byText(items[indexPath.row])
                .byDetailText("Section \(indexPath.section) · Row \(indexPath.row)")
            // 注意：想显示 detailTextLabel，需要用 .subtitle 风格创建/注册对应 cell
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅ didSelect Row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
