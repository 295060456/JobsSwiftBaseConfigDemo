//
//  JXSegmentedListContainerView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

#if canImport(JXSegmentedView)
import JXSegmentedView
public extension JXSegmentedListContainerView {
    // MARK: 行为&外观
    /// 初始化阈值（0~1，默认 0.01）
    @discardableResult
    func byInitListPercent(_ p: CGFloat) -> Self {
        self.initListPercent = p; return self
    }

    @discardableResult
    func byListCellBackgroundColor(_ color: UIColor) -> Self {
        self.listCellBackgroundColor = color; return self
    }
    /// 默认选中 index（务必与 segmentedView.defaultSelectedIndex 保持一致）
    @discardableResult
    func byDefaultSelectedIndex(_ index: Int) -> Self {
        self.defaultSelectedIndex = index; return self
    }

    // MARK: Scroll 属性（scrollView/collectionView 统一写）
    @discardableResult
    func byPagingEnabled(_ on: Bool = true) -> Self {
        self.scrollView.isPagingEnabled = on; return self
    }

    @discardableResult
    func byBounces(_ on: Bool = false) -> Self {
        self.scrollView.bounces = on; return self
    }

    @discardableResult
    func byShowsIndicators(horizontal: Bool = false, vertical: Bool = false) -> Self {
        self.scrollView.showsHorizontalScrollIndicator = horizontal
        self.scrollView.showsVerticalScrollIndicator = vertical
        return self
    }

    @discardableResult
    func byScrollsToTop(_ on: Bool = false) -> Self {
        self.scrollView.scrollsToTop = on; return self
    }

    @discardableResult
    func byDecelerationRate(_ rate: UIScrollView.DecelerationRate) -> Self {
        self.scrollView.decelerationRate = rate; return self
    }

    @discardableResult
    func byNeverAdjustContentInset() -> Self {
        if #available(iOS 11.0, *) { self.scrollView.contentInsetAdjustmentBehavior = .never }
        return self
    }
    // MARK: 绑定 / 刷新
    /// 绑定到 SegmentedView（等价于 `segmentedView.listContainer = self`）
    @discardableResult
    func byBind(to segmentedView: JXSegmentedView, defaultIndex: Int? = nil) -> Self {
        if let i = defaultIndex { self.defaultSelectedIndex = i; segmentedView.defaultSelectedIndex = i }
        segmentedView.listContainer = self
        return self
    }
    /// 触发 reload
    @discardableResult
    func byReload() -> Self { self.reloadData(); return self }
}
// MARK: - 便捷工厂
public extension JXSegmentedListContainerView {
    static func make(dataSource: JXSegmentedListContainerViewDataSource,
                     type: JXSegmentedListContainerType = .scrollView) -> JXSegmentedListContainerView {
        JXSegmentedListContainerView(dataSource: dataSource, type: type)
    }
}

#endif
