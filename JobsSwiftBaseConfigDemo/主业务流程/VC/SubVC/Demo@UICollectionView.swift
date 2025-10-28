//
//  Demo@UICollectionView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/22/25.
//
//  演示：同一 VC 中放置两个 UICollectionView
//  - 上：竖向滚动（.vertical）
//  - 下：横向滚动（.horizontal，接入 JobsRefresher 水平刷新）
//  依赖：SnapKit、UIScrollView+JobsEmptyButton.swift、JobsRefresher.swift（含 JobsHeader/JobsFooter Animator & DSL）
//

import UIKit
import SnapKit

final class EmptyCollectionViewDemoVC: BaseVC,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate,
                                       UICollectionViewDelegateFlowLayout {

    // ============================== 数据源 & 状态 ==============================
    // 竖向列表
    private var itemsV: [String] = []
    private var isPullRefreshingV = false
    private var isLoadingMoreV    = false
    // 横向列表
    private var itemsH: [String] = []
    private var isPullRefreshingH = false
    private var isLoadingMoreH    = false

    // ============================== UI：两个独立 FlowLayout ==============================
    private lazy var flowLayoutV: UICollectionViewFlowLayout = {
        UICollectionViewFlowLayout()
            .byScrollDirection(.vertical)
            .byMinimumLineSpacing(10)
            .byMinimumInteritemSpacing(10)
            .bySectionInset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
    }()

    private lazy var flowLayoutH: UICollectionViewFlowLayout = {
        UICollectionViewFlowLayout()
            .byScrollDirection(.horizontal)
            .byMinimumLineSpacing(12)
            .byMinimumInteritemSpacing(12)
            .bySectionInset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
    }()

    // ============================== UI：上面的【竖向】CollectionView ==============================
    private lazy var collectionViewV: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: flowLayoutV)
            .byBounces(true)
            .byAlwaysBounceVertical(true)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UICollectionViewCell.self)
            .byBackgroundView(nil)
            .byDragInteractionEnabled(false)
            .jobs_refreshSense(.insetFollow)
            // 空态按钮
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton.sys()
                    .byTitle("暂无数据（竖向）", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("square.grid.2x2".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.itemsV = (1...12).map { "Item \($0)" }
                        self.collectionViewV.byReloadData()
                        self.updateFooterAvailabilityV()
                        self.collectionViewV.jobs_reloadEmptyViewAuto()
                    }
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }

            // 下拉刷新（竖向）
            .pullDownWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isPullRefreshingV else { return }
                self.isPullRefreshingV = true
                print("⬇️[V] 下拉刷新触发")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if self.itemsV.isEmpty {
                        self.itemsV = (1...12).map { "Item \($0)" }
                    } else {
                        self.itemsV.shuffle()
                    }
                    self.isPullRefreshingV = false
                    self.collectionViewV.byReloadData()
                    self.collectionViewV.pullDownStop()
                    self.updateFooterAvailabilityV()
                    self.collectionViewV.jobs_reloadEmptyViewAuto()
                    print("✅[V] 下拉刷新完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@下拉刷新")
                    .byReleaseToRefreshDescription("Jobs@松开立即刷新")
                    .byLoadingDescription("Jobs@正在刷新中…")
                    .byNoMoreDataDescription("Jobs@已经是最新数据")
            })

            // 上拉加载（竖向）
            .pullUpWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isLoadingMoreV else { return }
                self.isLoadingMoreV = true
                print("⬆️[V] 上拉加载触发")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let base = self.itemsV.count
                    self.itemsV += (1...8).map { "Item \(base + $0)" }
                    self.isLoadingMoreV = false
                    self.collectionViewV.byReloadData()
                    self.collectionViewV.pullUpStop()
                    self.updateFooterAvailabilityV()
                    self.collectionViewV.jobs_reloadEmptyViewAuto()
                    print("✅[V] 上拉加载完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@上拉加载更多")
                    .byReleaseToRefreshDescription("Jobs@松开立即加载")
                    .byLoadingMoreDescription("Jobs@加载中…")
                    .byNoMoreDataDescription("Jobs@没有更多数据")
            }).byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview()
                make.height.equalTo(view.snp.height).multipliedBy(0.55) // 上面占 55%
            }
    }()

    // ============================== UI：下面的【横向】CollectionView ==============================
    private lazy var collectionViewH: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: flowLayoutH)
            .byBounces(true)
            .byAlwaysBounceHorizontal(true)
            .jobs_refreshAxis(.horizontal)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UICollectionViewCell.self)
            .byBackgroundView(nil)
            .byDragInteractionEnabled(false)
            .jobs_refreshAxis(.horizontal).jobs_refreshSense(.insetFollow)
            // 空态按钮
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton.sys()
                    .byTitle("暂无数据（横向）", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("rectangle.grid.1x2".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.itemsH = (1...10).map { "Card \($0)" }
                        self.collectionViewH.byReloadData()
                        self.updateFooterAvailabilityH()
                        self.collectionViewH.jobs_reloadEmptyViewAuto()
                    }
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-20)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }
            // ⭐️ 水平刷新：切换轴向
            .jobs_refreshAxis(.horizontal)
            // 左→右刷新（等价“下拉”）
            .pullDownWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isPullRefreshingH else { return }
                self.isPullRefreshingH = true
                print("⬅️[H] 左拉刷新触发")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if self.itemsH.isEmpty {
                        self.itemsH = (1...10).map { "Card \($0)" }
                    } else {
                        self.itemsH.shuffle()
                    }
                    self.isPullRefreshingH = false
                    self.collectionViewH.byReloadData()
                    self.collectionViewH.pullDownStop()
                    self.updateFooterAvailabilityH()
                    self.collectionViewH.jobs_reloadEmptyViewAuto()
                    print("✅[H] 左拉刷新完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("向右拉刷新")
                    .byReleaseToRefreshDescription("松开刷新")
                    .byLoadingDescription("刷新中…")
                    .byNoMoreDataDescription("—")
            })

            // 右→左加载（等价“上拉”）
            .pullUpWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isLoadingMoreH else { return }
                self.isLoadingMoreH = true
                print("➡️[H] 右拉加载触发")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let base = self.itemsH.count
                    self.itemsH += (1...6).map { "Card \(base + $0)" }
                    self.isLoadingMoreH = false
                    self.collectionViewH.byReloadData()
                    self.collectionViewH.pullUpStop()
                    self.updateFooterAvailabilityH()
                    self.collectionViewH.jobs_reloadEmptyViewAuto()
                    print("✅[H] 右拉加载完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("向左拉加载")
                    .byReleaseToRefreshDescription("松开加载")
                    .byLoadingMoreDescription("加载中…")
                    .byNoMoreDataDescription("没有更多了")
            }).byAddTo(view) { [unowned self] make in
                make.top.equalTo(collectionViewV.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(10)               // 下面占余下空间，高度自适应
            }
        
    }()

    // ============================== 生命周期 ==============================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "UICollectionView@空态刷新",
            rightButtons: [
                // 清空两个列表
                UIButton.sys()
                    .byImage("xmark.bin".sysImg, for: .normal)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        itemsV.removeAll(); itemsH.removeAll()
                        collectionViewV.byReloadData()
                        collectionViewH.byReloadData()
                        updateFooterAvailabilityV()
                        updateFooterAvailabilityH()
                        collectionViewV.jobs_reloadEmptyViewAuto()
                        collectionViewH.jobs_reloadEmptyViewAuto()
                    },
                // 追加两个列表
                UIButton.sys()
                    .byImage("plus".sysImg, for: .normal)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        let bV = itemsV.count
                        itemsV += (1...6).map { "Item \(bV + $0)" }
                        let bH = itemsH.count
                        itemsH += (1...5).map { "Card \(bH + $0)" }
                        collectionViewV.byReloadData()
                        collectionViewH.byReloadData()
                        updateFooterAvailabilityV()
                        updateFooterAvailabilityH()
                        collectionViewV.jobs_reloadEmptyViewAuto()
                        collectionViewH.jobs_reloadEmptyViewAuto()
                    }
            ]
        )
        // 布局：上竖向、下横向
        collectionViewV.byAlpha(1)
        collectionViewH.byAlpha(1)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         collectionViewV.pullDownStart() // 应该立刻看到“刷新中…”
         collectionViewH.pullDownStart() // 横向左拉等价“下拉”，也可测
        // 首屏就演示竖向 footer（上拉加载）
//        collectionViewV.pullUpStart() // 应该立刻看到“加载中…”
        // 可选：再演示横向 footer（右→左）
        // collectionViewH.pullUpStart()
    }
    // ============================== Footer 可用性（示例） ==============================
    private func updateFooterAvailabilityV() {
        if itemsV.count >= 60 { collectionViewV.pullUpNoMore() } else { collectionViewV.pullUpReset() }
    }
    private func updateFooterAvailabilityH() {
        if itemsH.count >= 40 { collectionViewH.pullUpNoMore() } else { collectionViewH.pullUpReset() }
    }
    // ============================== UICollectionViewDataSource ==============================
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === collectionViewV { return itemsV.count }
        return itemsH.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueCell(UICollectionViewCell.self, for: indexPath)

        let label: UILabel
        if let exist = cell.contentView.viewWithTag(1001) as? UILabel {
            label = exist
        } else {
            label = UILabel()
                .byNumberOfLines(1)
                .byTextAlignment(.center)
                .byFont(.systemFont(ofSize: 16, weight: .medium))
                .byTextColor(.label)
                .byTag(1001)
                .byAddTo(cell.contentView) { make in
                    make.edges.equalToSuperview().inset(8)
                }

            cell.contentView
                .byBgColor(.secondarySystemBackground)
                .byCornerRadius(10)
                .byMasksToBounds(true)
        }

        if collectionView === collectionViewV {
            label.text = itemsV[indexPath.item]
        } else {
            label.text = itemsH[indexPath.item]
        }
        return cell
    }
    // ============================== UICollectionViewDelegate ==============================
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === collectionViewV {
            print("✅[V] didSelect Item: \(indexPath.item)")
        } else {
            print("✅[H] didSelect Item: \(indexPath.item)")
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    // ============================== UICollectionViewDelegateFlowLayout ==============================
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === collectionViewV {
            // 竖向：两列网格
            guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 100, height: 64)
            }
            let inset = layout.sectionInset
            let spacing = layout.minimumInteritemSpacing
            let columns: CGFloat = 2
            let totalH = inset.left + inset.right + (columns - 1) * spacing
            let w = floor((collectionView.bounds.width - totalH) / columns)
            return CGSize(width: w, height: 64)
        } else {
            // 横向：卡片固定宽度，随高度自适应
            guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 120, height: 100)
            }
            let inset = layout.sectionInset
            let h = max(64, collectionView.bounds.height - inset.top - inset.bottom)
            return CGSize(width: 120, height: h - 6) // 轻微留白
        }
    }
}
