//
//  CashbackRootVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit
import JXSegmentedView

final class CashbackRootVC: BaseVC {
    // MARK: - Data
    private let segments = ["活动", "任务", "VIP", "利息宝", "返水"]
    // MARK: - Segment DataSource（懒加载 + 链式）
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        JXSegmentedTitleDataSource()
            .byTitles(segments)
            .byTitleNormalColor(.secondaryLabel)
            .byTitleSelectedColor(.systemOrange)
            .byTitleNormalFont(.systemFont(ofSize: 16, weight: .regular))
            .byTitleSelectedFont(.systemFont(ofSize: 16, weight: .semibold))
            .byColorGradientEnabled(true)
            // 推荐：用 CoreText 测宽，规避 NSString/AttributedString 在少数环境下的崩
            .byWidthForTitle { [unowned self] title in
                jobsCTTextWidth(title, font: segmentedDataSource.titleNormalFont)
            }
    }()
    // MARK: - Indicator（懒加载 + 链式）
    private lazy var indicator: JXSegmentedIndicatorLineView = {
        JXSegmentedIndicatorLineView()
            .byIndicatorWidth(28)
            .byIndicatorHeight(3)
            .byIndicatorColor(.systemOrange)
            .byVerticalOffset(3)
            .byLineStyle(.normal)
    }()
    // MARK: - SegmentedView（懒加载 + 链式）
    private lazy var segmentedView: JXSegmentedView = {
        JXSegmentedView()
            .byDataSource(segmentedDataSource)
            .byDelegate(self)
            .byIndicators([indicator])
            .byContentEdgeInsets(left: JXSegmentedViewAutomaticDimension,
                                 right: JXSegmentedViewAutomaticDimension)
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                }
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
            }
    }()
    // 顶部分隔线（与你的写法保持一致）
    private lazy var segmentedHairline: UIView = {
        UIView()
            .byBgColor(UIColor.separator)
            .byAddTo(segmentedView) { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5)
            }
    }()
    // MARK: - ListContainer（懒加载 + 链式）
    private lazy var listContainer: JXSegmentedListContainerView = {
        JXSegmentedListContainerView.make(dataSource: self)             // 工厂方法
            .byPagingEnabled(true)
            .byBounces(false)
            .byShowsIndicators(horizontal: false, vertical: false)
            .byNeverAdjustContentInset()
            .byBind(to: segmentedView, defaultIndex: 4)                  // 绑定并设置默认选中“返水”
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(segmentedView.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "示例 · 返水页签")
        // 触发懒加载
        segmentedView.byVisible(YES)
        segmentedHairline.byVisible(YES)
        listContainer.byVisible(YES)
    }
}
// MARK: - JXSegmentedViewDelegate
extension CashbackRootVC: JXSegmentedViewDelegate {}
// MARK: - JXSegmentedListContainerViewDataSource
extension CashbackRootVC: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        segments.count
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView,
                           initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if segments[index] == "返水" {
            return RebatePageVC()
        } else {
            return PlaceholderListVC(title: segments[index])
        }
    }
}
