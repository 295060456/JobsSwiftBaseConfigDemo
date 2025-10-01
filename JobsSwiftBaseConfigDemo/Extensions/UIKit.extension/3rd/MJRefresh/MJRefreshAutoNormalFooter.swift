//
//  JXCustomFooter.swift
//  JinXiIndonesia
//
//  Created by mac on 14/12/24.
//

import MJRefresh

extension MJRefreshAutoNormalFooter {
    static func customFooter(refreshingTarget target: Any?, refreshingAction action: Selector?) -> MJRefreshAutoNormalFooter {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: target as Any, refreshingAction: action!)
        
        // 自定义刷新状态文本
        footer.setTitle("MJRefreshAutoFooterIdleText".localized(), for: .idle)          // 普通状态
        footer.setTitle("MJRefreshBackFooterPullingText".localized(), for: .pulling)            // 松开加载状态
        footer.setTitle("MJRefreshBackFooterRefreshingText".localized(), for: .refreshing)    // 正在加载状态
        footer.setTitle("MJRefreshBackFooterNoMoreDataText".localized(), for: .noMoreData)        // 没有更多数据状态

        // 可选：调整样式
        footer.stateLabel?.font = UIFont.systemFont(ofSize: 12)        // 状态文本字体
        footer.stateLabel?.textColor = UIColor.gray                   // 状态文本颜色
        footer.stateLabel?.textAlignment = .center                    // 文本对齐方式

        // 设置是否自动隐藏（例如没有更多数据时隐藏 Footer）
        footer.isHidden = false // 默认显示，可以根据需求设置隐藏逻辑

        return footer
    }
}
