//
//  DouyinFeedVC.swift
//

import UIKit
import SnapKit

final class DouyinFeedVC: BaseVC,
                          UITableViewDataSource,
                          UITableViewDelegate {
    // 数据
    private var items: [FeedItem] = []
    private var currentIndex = 0
    private var isPullRefreshing = false
    private var isLoadingMore    = false
    // ============================== UI：Table（Jobs 风格） ==============================
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(FeedVideoCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.none)
            .byNoSectionHeaderTopPadding()
            .byPagingEnabled(true)
            .byShowsVerticalScrollIndicator(false)

            .jobs_emptyButtonProvider { [unowned self] in
                UIButton(type: .system)
                    .byTitle("暂无视频", for: .normal)
                    .bySubTitle("点我加载示例数据", for: .normal)
                    .byImage("tray".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.items = FeedModel.loadAll()
                        self.tableView.byReloadData()
                    }
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }
            // 下拉刷新：重新加载本地/网络模型
            .pullDownWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isPullRefreshing else { return }
                self.isPullRefreshing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.items = FeedModel.loadAll()
                    self.isPullRefreshing = false
                    self.tableView.byReloadData()
                    self.tableView.pullDownStop()
                    self.updateFooterAvailability()
                    self.tableView.jobs_reloadEmptyViewAuto()
                    // 回到当前页并尝试播放
                    let idx = IndexPath(row: self.currentIndex, section: 0)
                    self.tableView.scrollToRow(at: idx, at: .top, animated: false)
                    self.playIfNeeded(at: idx)
                }
            }, config: { animator in
                animator
                    .byIdleDescription("下拉刷新")
                    .byReleaseToRefreshDescription("松开立即刷新")
                    .byLoadingDescription("正在刷新…")
                    .byNoMoreDataDescription("已经是最新")
            })
            // 上拉加载：抖音菜单无分页，这里直接“没有更多”
            .pullUpWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isLoadingMore else { return }
                self.isLoadingMore = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isLoadingMore = false
                    self.tableView.pullUpStop()
                    self.updateFooterAvailability()
                }
            }, config: { animator in
                animator
                    .byIdleDescription("上拉加载更多")
                    .byReleaseToRefreshDescription("松开立即加载")
                    .byLoadingMoreDescription("加载中…")
                    .byNoMoreDataDescription("没有更多视频")
            })

            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()
    // ============================== 生命周期 ==============================
    override func loadView() {
        super.loadView()
        // 数据
        items = FeedModel.loadAll()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        jobsSetupGKNav(title: "抖音纵滑")
        updateFooterAvailability()
        tableView.jobs_reloadEmptyViewAuto()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 首屏自动播放
        playIfNeeded(at: IndexPath(row: currentIndex, section: 0))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            PlayerCenter.shared.pause()
        }
    }
    // ============================== UITableViewDataSource ==============================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.bounds.height   // 全屏分页
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 若你项目里有类型安全的出队 API，用这行：
        let cell: FeedVideoCell = tableView.py_dequeueReusableCell(withType: FeedVideoCell.self, for: indexPath)
        // 没有的话，改回：
        // let cell = tableView.dequeueReusableCell(withIdentifier: FeedVideoCell.reuseID, for: indexPath) as! FeedVideoCell

        let m = items[indexPath.row]
        cell.fill(nickname: m.nickname, content: m.content)
        return cell
    }
    // ============================== 分页滚动触发播放 ==============================
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settleAndPlay(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { settleAndPlay(scrollView) }
    }
    private func settleAndPlay(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.y / max(1, scrollView.bounds.height)))
        currentIndex = max(0, min(items.count - 1, page))
        playIfNeeded(at: IndexPath(row: currentIndex, section: 0))
    }
    // ============================== 播放控制 ==============================
    private func playIfNeeded(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedVideoCell else { return }
        let m = items[indexPath.row]
        PlayerCenter.shared.attach(to: cell.playerHost)
        PlayerCenter.shared.play(url: m.videoURL)
    }
    // ============================== 工具 ==============================
    private func updateFooterAvailability() {
        // 这里没有分页，统一“没有更多”
        tableView.pullUpNoMore()
    }
}
