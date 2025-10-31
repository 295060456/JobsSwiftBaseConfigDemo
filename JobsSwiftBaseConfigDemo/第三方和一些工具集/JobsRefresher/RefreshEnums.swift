//
//  RefreshEnums.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit

@MainActor
public enum MRKAxis {
    case vertical, horizontal
}

@MainActor
public enum MRKPosition {
    case header      // top
    case footer      // bottom
    case left
    case right

    public var axis: MRKAxis {
        switch self {
        case .header, .footer: return .vertical
        case .left, .right:    return .horizontal
        }
    }
}

@MainActor
public enum MRKState: Equatable {
    case idle                 // 初始/重置
    case pulling(progress: CGFloat)  // 拖拽进行中（0...1）
    case ready                // 达到阈值，松手即可触发
    case refreshing           // 刷新中
    case noMore               // 仅 footer 用：无更多数据
    case removed              // 组件被移除（不再响应）
}

@MainActor
public enum MRKSwitch {
    case refreshing
    case normal
    case removed
    case noMoreData           // 仅 footer 生效
}
