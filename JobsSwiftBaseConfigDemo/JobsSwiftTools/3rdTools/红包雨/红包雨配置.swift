//
//  RedPacketRainConfig.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//
import Foundation
// MARK: - 红包雨配置
public struct RedPacketRainConfig {
    /// 每次生成红包的间隔
    public var spawnInterval: TimeInterval
    /// 最小下落时长
    public var minFallDuration: TimeInterval
    /// 最大下落时长
    public var maxFallDuration: TimeInterval
    /// 红包尺寸
    public var packetSize: CGSize
    /// 屏幕上最多同时存在多少个红包
    public var maxConcurrentCount: Int
    /// 生成区域的内边距（控制左右 / 顶部安全区）
    public var spawnInsets: UIEdgeInsets
    /// 是否可以点按
    public var tapEnabled: Bool
    /// 红包图片（不传就用红色方块做占位）
    public var packetImage: UIImage?

    public init(
        spawnInterval: TimeInterval = 0.25,
        minFallDuration: TimeInterval = 2.5,
        maxFallDuration: TimeInterval = 4.0,
        packetSize: CGSize = CGSize(width: 44, height: 54),
        maxConcurrentCount: Int = 60,
        spawnInsets: UIEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10),
        tapEnabled: Bool = true,
        packetImage: UIImage? = nil
    ) {
        self.spawnInterval = spawnInterval
        self.minFallDuration = minFallDuration
        self.maxFallDuration = maxFallDuration
        self.packetSize = packetSize
        self.maxConcurrentCount = maxConcurrentCount
        self.spawnInsets = spawnInsets
        self.tapEnabled = tapEnabled
        self.packetImage = packetImage
    }

    public static var `default`: RedPacketRainConfig {
        RedPacketRainConfig()
    }
}
