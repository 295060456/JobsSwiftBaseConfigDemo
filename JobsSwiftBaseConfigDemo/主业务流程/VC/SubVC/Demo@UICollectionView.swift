//
//  Demo@UICollectionView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/22/25.
//

import UIKit
import SnapKit

final class EmptyCollectionViewDemoVC: BaseVC,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegate,
                                       UICollectionViewDelegateFlowLayout {

    // ============================== 数据源 & 状态 ==============================
    private var items: [String] = []                 // 初始为空 -> 触发空态
    private var isPullRefreshing = false
    private var isLoadingMore = false

    // ============================== UI：CollectionView ==============================
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        UICollectionViewFlowLayout()
            .byScrollDirection(.vertical)
            .byMinimumLineSpacing(10)
            .byMinimumInteritemSpacing(10)
            .bySectionInset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
    }()

    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UICollectionViewCell.self)
            .byBackgroundView(nil)
            .byDragInteractionEnabled(false)

            // 空态按钮（与 UITableView Demo 一致）
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton.sys()
                    .byTitle("暂无数据", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("square.grid.2x2".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.items = (1...12).map { "Item \($0)" }
                        self.collectionView.byReloadData()        // ✅ reload 后自动评估空态
                    }
                    // 可选：自定义空态按钮布局
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }

            // 下拉刷新（JobsHeaderAnimator）
            .pullDownWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isPullRefreshing else { return }
                self.isPullRefreshing = true
                print("⬇️ 下拉刷新触发")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if self.items.isEmpty {
                        self.items = (1...12).map { "Item \($0)" }
                    } else {
                        self.items.shuffle()
                    }
                    self.isPullRefreshing = false
                    self.collectionView.byReloadData()
                    self.collectionView.pullDownStop()
                    self.updateFooterAvailability()
                    self.collectionView.jobs_reloadEmptyViewAuto()
                    print("✅ 下拉刷新完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@下拉刷新")
                    .byReleaseToRefreshDescription("Jobs@松开立即刷新")
                    .byLoadingDescription("Jobs@正在刷新中…")
                    .byNoMoreDataDescription("Jobs@已经是最新数据")
            })

            // 上拉加载（JobsFooterAnimator）
            .pullUpWithJobsAnimator({ [weak self] in
                guard let self = self, !self.isLoadingMore else { return }
                self.isLoadingMore = true
                print("⬆️ 上拉加载触发")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let base = self.items.count
                    self.items += (1...8).map { "Item \(base + $0)" }

                    self.isLoadingMore = false
                    self.collectionView.byReloadData()
                    self.collectionView.pullUpStop()
                    self.updateFooterAvailability()
                    self.collectionView.jobs_reloadEmptyViewAuto()
                    print("✅ 上拉加载完成")
                }
            }, config: { animator in
                animator
                    .byIdleDescription("Jobs@上拉加载更多")
                    .byReleaseToRefreshDescription("Jobs@松开立即加载")
                    .byLoadingMoreDescription("Jobs@加载中…")
                    .byNoMoreDataDescription("Jobs@没有更多数据")
            })

            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()

    // ============================== 生命周期 ==============================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        "".img
        jobsSetupGKNav(
            title: JobsText("UICollectionView@空态"),
            rightButtons: [
                // 清空
                UIButton.sys()
                    .byImage("xmark.bin".sysImg, for: .normal)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.items.removeAll()
                        self.collectionView.byReloadData()
                        self.updateFooterAvailability()
                        self.collectionView.jobs_reloadEmptyViewAuto()
                    },
                // 追加
                UIButton.sys()
                    .byImage("plus".sysImg, for: .normal)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        let base = self.items.count
                        self.items += (1...6).map { "Item \(base + $0)" }
                        self.collectionView.byReloadData()
                        self.updateFooterAvailability()
                        self.collectionView.jobs_reloadEmptyViewAuto()
                    }
            ]
        )
    }

    // ============================== Footer 可用性（示例） ==============================
    private func updateFooterAvailability() {
        if items.count >= 60 {
            print("🚫 没有更多数据了（示例）")
        } else {
            print("✅ 允许继续上拉加载（示例）")
        }
    }

    // ============================== UICollectionViewDataSource ==============================
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
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
                .byAddTo(cell.contentView) { make in     // ✅ 加到 contentView
                    make.edges.equalToSuperview().inset(8)
                }

            // 背景 & 圆角（只需设一次）
            cell.contentView.byBgColor(.secondarySystemBackground)
                .byCornerRadius(10)
                .byMasksToBounds(true)
        }

        label.text = items[indexPath.item]
        return cell
    }
    // ============================== UICollectionViewDelegate ==============================
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("✅ didSelect Item: \(indexPath.item)")
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    // ============================== UICollectionViewDelegateFlowLayout ==============================
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算 2 列卡片宽度（考虑 sectionInset / interItemSpacing）
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 100, height: 60)
        }
        let inset = layout.sectionInset
        let spacing = layout.minimumInteritemSpacing
        let columns: CGFloat = 2
        let totalH = inset.left + inset.right + (columns - 1) * spacing
        let w = floor((collectionView.bounds.width - totalH) / columns)
        return CGSize(width: w, height: 64)
    }
}
