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
            // 空态按钮
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton.sys()
                    .byTitle("暂无数据（竖向）", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("square.grid.2x2".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.collectionViewV.byReloadData()
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
            .byAddTo(view) { [unowned self] make in
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
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UICollectionViewCell.self)
            .byBackgroundView(nil)
            .byDragInteractionEnabled(false)
            // 空态按钮
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton.sys()
                    .byTitle("暂无数据（横向）", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("rectangle.grid.1x2".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.collectionViewH.byReloadData()
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
            .byAddTo(view) { [unowned self] make in
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
