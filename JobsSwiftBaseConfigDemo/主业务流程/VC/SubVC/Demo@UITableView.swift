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
            // 下拉刷新（自定义 JobsHeaderAnimator）
            .pullDownWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isPullRefreshing else { return }
                self.isPullRefreshing = true
                print("⬇️ 下拉刷新触发")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // —— 演示：如果当前为空，则填充；否则打乱顺序 —— //
                    if self.items.isEmpty {
                        self.items = (1...10).map { "Row \($0)" }
                    } else {
                        self.items.shuffle()
                    }
                    self.isPullRefreshing = false
                    self.tableView.byReloadData()
                    self.tableView.pullDownStop()               // 结束下拉
                    self.updateFooterAvailability()
                    self.tableView.jobs_reloadEmptyViewAuto()   // 刷新空态显隐
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
                    // —— 演示：每次追加 5 条 —— //
                    let base = self.items.count
                    self.items += (1...5).map { "Row \(base + $0)" }

                    self.isLoadingMore = false
                    self.tableView.byReloadData()
                    self.tableView.pullUpStop()                 // 结束上拉
                    self.updateFooterAvailability()
                    self.tableView.jobs_reloadEmptyViewAuto()   // 刷新空态显隐
                    print("✅ 上拉加载完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@上拉加载更多")
                    .byReleaseToRefreshDescription("Jobs@松开立即加载")
                    .byLoadingMoreDescription("Jobs@加载中…")
                    .byNoMoreDataDescription("Jobs@没有更多数据")
            })

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
        self.jobsNav
        view.backgroundColor = .cyan
        jobsSetupGKNav(
            title: "UITableView@空态 Demo",
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
