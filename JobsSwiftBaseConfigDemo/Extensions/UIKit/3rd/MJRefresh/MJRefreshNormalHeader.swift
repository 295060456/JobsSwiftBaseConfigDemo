//
//  JXCustomHeader.swift
//  JinXiIndonesia
//
//  Created by mac on 14/12/24.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

#if canImport(MJRefresh)
import MJRefresh
extension MJRefreshNormalHeader {
    static func customHeader(refreshingTarget target: Any?, refreshingAction action: Selector?) -> MJRefreshNormalHeader {
        let header = MJRefreshNormalHeader(refreshingTarget: target as Any, refreshingAction: action!)

        header.setTitle("MJRefreshHeaderIdleText".tr, for: .idle)           // 普通状态
        header.setTitle("MJRefreshHeaderPullingText".tr, for: .pulling)        // 松开刷新状态
        header.setTitle("MJRefreshHeaderRefreshingText".tr, for: .refreshing)  // 正在刷新状态
        header.lastUpdatedTimeText = { (lastUpdatedTime) -> String in
            guard let time = lastUpdatedTime else { return "MJRefreshHeaderNoneLastDateText".tr } // 没有更新时间时显示
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return "MJRefreshHeaderLastTimeText".tr + formatter.string(from: time)
        }

        // 可选：调整字体和颜色
        header.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        header.stateLabel?.textColor = UIColor.gray
        header.lastUpdatedTimeLabel?.font = UIFont.systemFont(ofSize: 12)
        header.lastUpdatedTimeLabel?.textColor = UIColor.lightGray

        return header
    }
}
#endif
