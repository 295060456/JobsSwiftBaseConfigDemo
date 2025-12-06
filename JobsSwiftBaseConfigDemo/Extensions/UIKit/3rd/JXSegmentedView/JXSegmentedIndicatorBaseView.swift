//
//  JXSegmentedIndicatorBaseView.swift
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
/// 共用：基类可链式配置
public extension JXSegmentedIndicatorBaseView {
    @discardableResult func byIndicatorColor(_ v: UIColor) -> Self { indicatorColor = v; return self }
    @discardableResult func byIndicatorHeight(_ v: CGFloat) -> Self { indicatorHeight = v; return self }
    @discardableResult func byIndicatorWidth(_ v: CGFloat) -> Self { indicatorWidth = v; return self }
    @discardableResult func byVerticalOffset(_ v: CGFloat) -> Self { verticalOffset = v; return self }
    @discardableResult func byPosition(_ p: JXSegmentedIndicatorPosition) -> Self { indicatorPosition = p; return self }
    /// 传具体数值；如需“自动圆角=高度/2”，传 JXSegmentedViewAutomaticDimension
    @discardableResult func byIndicatorCornerRadius(_ v: CGFloat) -> Self { indicatorCornerRadius = v; return self }
}
#endif
