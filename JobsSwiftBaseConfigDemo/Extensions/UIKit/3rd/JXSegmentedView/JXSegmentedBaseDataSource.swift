//
//  JXSegmentedBaseDataSource.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import JXSegmentedView

public extension JXSegmentedBaseDataSource {
    @discardableResult func byItemWidth(_ v: CGFloat) -> Self { itemWidth = v; return self }
    @discardableResult func byItemWidthIncrement(_ v: CGFloat) -> Self { itemWidthIncrement = v; return self }
    @discardableResult func byItemSpacing(_ v: CGFloat) -> Self { itemSpacing = v; return self }
    @discardableResult func bySpacingAverage(_ on: Bool = true) -> Self { isItemSpacingAverageEnabled = on; return self }
    @discardableResult func byTransitionEnabled(_ on: Bool = true) -> Self { isItemTransitionEnabled = on; return self }
    /// 选中动画：可顺带改时长
    @discardableResult
    func bySelectedAnimable(_ on: Bool = true, duration: TimeInterval? = nil) -> Self {
        isSelectedAnimable = on
        if let d = duration { selectedAnimationDuration = d }
        return self
    }

    @discardableResult func byAnimationDuration(_ d: TimeInterval) -> Self { selectedAnimationDuration = d; return self }
    /// 宽度缩放：同时可配置 scale 与是否需要缩放动画
    @discardableResult
    func byItemWidthZoom(enabled: Bool = true, scale: CGFloat? = nil, animable: Bool? = nil) -> Self {
        isItemWidthZoomEnabled = enabled
        if let s = scale { itemWidthSelectedZoomScale = s }
        if let a = animable { isItemWidthZoomAnimable = a }
        return self
    }
    /// 一把梭：把自己挂到 segmentedView，并可设置指示器 + 选中索引
    @discardableResult
    func byAttach(to segmentedView: JXSegmentedView,
                  selectedIndex: Int = 0,
                  indicators: [JXSegmentedIndicatorProtocol]? = nil) -> Self {
        segmentedView.dataSource = self
        if let ins = indicators { segmentedView.indicators = ins }
        reloadData(selectedIndex: selectedIndex)
        segmentedView.reloadData()
        return self
    }
    /// 纯刷新
    @discardableResult func byReload(selectedIndex: Int = 0) -> Self {
        reloadData(selectedIndex: selectedIndex); return self
    }
}
