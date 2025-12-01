//
//  JXSegmentedTitleDataSource.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import JXSegmentedView
import ObjectiveC
// MARK: - 动态配置适配器（必须继承 NSObject）
public final class JobsSegmentedTitleClosureConfiguration: NSObject, JXSegmentedTitleDynamicConfiguration {
    public var numberOfLines: ((Int) -> Int)?
    public var normalColor:   ((Int) -> UIColor)?
    public var selectedColor: ((Int) -> UIColor)?
    public var normalFont:    ((Int) -> UIFont)?
    public var selectedFont:  ((Int) -> UIFont?)?

    public func titleNumberOfLines(at index: Int) -> Int {
        numberOfLines?(index) ?? 1
    }
    public func titleNormalColor(at index: Int) -> UIColor {
        normalColor?(index) ?? .black
    }
    public func titleSelectedColor(at index: Int) -> UIColor {
        selectedColor?(index) ?? .red
    }
    public func titleNormalFont(at index: Int) -> UIFont {
        normalFont?(index) ?? .systemFont(ofSize: 15)
    }
    public func titleSelectedFont(at index: Int) -> UIFont? {
        selectedFont?(index)
    }
}
// MARK: - 配置强引用（因为 dataSource.configuration 是 weak）
private var _jobs_cfg_holder_key: UInt8 = 0
private extension JXSegmentedTitleDataSource {
    var jobs_cfg_holder: AnyObject? {
        get { objc_getAssociatedObject(self, &_jobs_cfg_holder_key) as AnyObject? }
        set { objc_setAssociatedObject(self, &_jobs_cfg_holder_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
// MARK: - TitleDataSource 链式 DSL
public extension JXSegmentedTitleDataSource {
    @discardableResult func byTitles(_ v: [String]) -> Self { titles = v; return self }
    @discardableResult func byTitleNumberOfLines(_ n: Int) -> Self { titleNumberOfLines = n; return self }
    @discardableResult func byTitleNormalColor(_ c: UIColor) -> Self { titleNormalColor = c; return self }
    @discardableResult func byTitleSelectedColor(_ c: UIColor) -> Self { titleSelectedColor = c; return self }
    @discardableResult func byTitleColors(normal: UIColor, selected: UIColor) -> Self { titleNormalColor = normal; titleSelectedColor = selected; return self }
    @discardableResult func byTitleNormalFont(_ f: UIFont) -> Self { titleNormalFont = f; return self }
    @discardableResult func byTitleSelectedFont(_ f: UIFont?) -> Self { titleSelectedFont = f; return self }
    @discardableResult func byTitleFonts(normal: UIFont, selected: UIFont?) -> Self { titleNormalFont = normal; titleSelectedFont = selected; return self }
    @discardableResult func byColorGradientEnabled(_ on: Bool = true) -> Self { isTitleColorGradientEnabled = on; return self }
    @discardableResult func byZoomEnabled(_ on: Bool = true, scale: CGFloat? = nil) -> Self { isTitleZoomEnabled = on; if let s = scale { titleSelectedZoomScale = s }; return self }
    @discardableResult func byStrokeEnabled(_ on: Bool = true, selectedWidth: CGFloat? = nil) -> Self { isTitleStrokeWidthEnabled = on; if let w = selectedWidth { titleSelectedStrokeWidth = w }; return self }
    @discardableResult func byMaskEnabled(_ on: Bool = true) -> Self { isTitleMaskEnabled = on; return self }
    @discardableResult func byWidthForTitle(_ block: @escaping (String) -> CGFloat) -> Self { widthForTitleClosure = block; return self }

    /// 动态配置（按 index 定制），自动处理 weak 的强引
    @discardableResult
    func byDynamicConfiguration(_ build: (JobsSegmentedTitleClosureConfiguration) -> Void) -> Self {
        let cfg = JobsSegmentedTitleClosureConfiguration()
        build(cfg)
        configuration = cfg          // weak
        jobs_cfg_holder = cfg        // strong
        return self
    }

    /// 便捷绑定到 segmentedView
    @discardableResult
    func byAttach(to segmentedView: JXSegmentedView,
                  indicators: [JXSegmentedIndicatorProtocol]? = nil) -> Self {
        segmentedView.dataSource = self
        if let ins = indicators { segmentedView.indicators = ins }
        segmentedView.reloadData()
        return self
    }
}
