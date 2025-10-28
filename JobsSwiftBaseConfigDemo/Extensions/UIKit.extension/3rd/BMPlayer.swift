//
//  BMPlayer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//
//  链式/语义化 DSL for BMPlayer
//  只依赖 BMPlayer 对外公开 API；不修改其内部实现。
//

import UIKit
import AVFoundation
import MediaPlayer
import SnapKit
import BMPlayer

// MARK: - 链式配置（byX）
public extension BMPlayer {
    // 代理
    @discardableResult
    func byDelegate(_ delegate: BMPlayerDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    // 返回按钮回调
    @discardableResult
    func byBack(_ block: ((Bool) -> Void)?) -> Self {
        self.backBlock = block
        return self
    }

    // 视频重力模式（填充策略）
    @discardableResult
    func byVideoGravity(_ gravity: AVLayerVideoGravity) -> Self {
        self.videoGravity = gravity
        return self
    }

    // 是否开启/禁用手势（整体开关）
    @discardableResult
    func byPanGestureEnabled(_ enabled: Bool) -> Self {
        self.panGesture?.isEnabled = enabled
        return self
    }

    // 更新全屏/非全屏 UI（外部状态机驱动时可主动触发）
    @discardableResult
    func byUpdateUI(isFullScreen: Bool) -> Self {
        self.updateUI(isFullScreen)
        return self
    }

    // 音量微调（增量，默认 0.1）
    @discardableResult
    func byVolumeUp(step: Float = 0.1) -> Self {
        self.addVolume(step: step)
        return self
    }

    @discardableResult
    func byVolumeDown(step: Float = 0.1) -> Self {
        self.reduceVolume(step: step)
        return self
    }

    // 绑定播放资源（可选首选清晰度、是否立即自动播）
    @discardableResult
    func byResource(_ resource: BMPlayerResource,
                    definitionIndex: Int = 0,
                    autoPlay: Bool = BMPlayerConf.shouldAutoPlay) -> Self {
        self.setVideo(resource: resource, definitionIndex: definitionIndex)
        if autoPlay { self.autoPlay() }
        return self
    }

    // 仅设置资源，不自动播放
    @discardableResult
    func byResourceNoAutoPlay(_ resource: BMPlayerResource,
                              definitionIndex: Int = 0) -> Self {
        self.setVideo(resource: resource, definitionIndex: definitionIndex)
        return self
    }

    // 约束辅助：将播放器添加到指定视图并用 SnapKit 约束
    @discardableResult
    func byAddTo(_ container: UIView,
                 make: (_ make: ConstraintMaker) -> Void) -> Self {
        container.addSubview(self)
        self.snp.makeConstraints { make($0) }
        return self
    }
}

// MARK: - 行为（byX）与控制（onX）
public extension BMPlayer {
    // 播放 / 暂停 / 自动播放
    @discardableResult
    func byPlay() -> Self {
        self.play()
        return self
    }

    /// allowAutoPlay = false 表示用户主动暂停（将阻断 viewWillAppear 的 autoPlay）
    @discardableResult
    func byPause(allowAutoPlay: Bool = false) -> Self {
        self.pause(allowAutoPlay: allowAutoPlay)
        return self
    }

    @discardableResult
    func byAutoPlayIfNeeded() -> Self {
        self.autoPlay()
        return self
    }

    // Seek
    @discardableResult
    func bySeek(to seconds: TimeInterval,
                completion: (() -> Void)? = nil) -> Self {
        self.seek(seconds, completion: completion)
        return self
    }
}

// MARK: - 事件回调（onX）
public extension BMPlayer {
    /// 播放进度回调 (current, total)
    @discardableResult
    func onPlayTimeChanged(_ block: @escaping (TimeInterval, TimeInterval) -> Void) -> Self {
        self.playTimeDidChange = block
        return self
    }

    /// 兼容旧回调（已废弃，尽量不用）
    @available(*, deprecated, message: "Use onIsPlayingStateChanged or onPlayStateChanged instead.")
    @discardableResult
    func onPlayStateDidChange(_ block: @escaping (Bool) -> Void) -> Self {
        self.playStateDidChange = block
        return self
    }

    /// 横竖屏/全屏状态变化（isFullScreen）
    @discardableResult
    func onOrientChanged(_ block: @escaping (Bool) -> Void) -> Self {
        self.playOrientChanged = block
        return self
    }

    /// 是否处于播放中状态变化（轻量）
    @discardableResult
    func onIsPlayingStateChanged(_ block: @escaping (Bool) -> Void) -> Self {
        self.isPlayingStateChanged = block
        return self
    }

    /// 播放器业务状态变化（更细粒度，BMPlayerState）
    @discardableResult
    func onPlayStateChanged(_ block: @escaping (BMPlayerState) -> Void) -> Self {
        self.playStateChanged = block
        return self
    }
}

// MARK: - 便捷构造（工厂/静态语义）
public extension BMPlayer {
    /// 直接创建并完成最常见的绑定：添加父视图、约束、资源、是否自动播
    static func make(in container: UIView,
                     constraints: (_ make: ConstraintMaker) -> Void,
                     resource: BMPlayerResource,
                     definitionIndex: Int = 0,
                     autoPlay: Bool = BMPlayerConf.shouldAutoPlay,
                     config: ((BMPlayer) -> Void)? = nil) -> BMPlayer {
        let p = BMPlayer()
            .byAddTo(container, make: constraints)
            .byResource(resource, definitionIndex: definitionIndex, autoPlay: autoPlay)
        config?(p)
        return p
    }
}

// MARK: - 语义糖（状态读取）
public extension BMPlayer {
    /// 是否在播（对外镜像，避免直接读内部图层）
    var isPlayingNow: Bool { self.isPlaying }

    /// 当前 AVPlayer（若你需要向下扩展）
    var av: AVPlayer? { self.avPlayer }
}
