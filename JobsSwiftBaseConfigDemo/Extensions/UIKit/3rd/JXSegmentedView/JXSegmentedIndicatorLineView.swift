//
//  JXSegmentedIndicatorLineView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
#if canImport(JXSegmentedView)
import JXSegmentedView
/// Line 指示器专属
public extension JXSegmentedIndicatorLineView {
    @discardableResult func byLineStyle(_ s: JXSegmentedIndicatorLineStyle) -> Self { lineStyle = s; return self }
    /// 仅对 `.lengthenOffset` 生效
    @discardableResult func byLineScrollOffsetX(_ x: CGFloat) -> Self { lineScrollOffsetX = x; return self }
}
#endif
