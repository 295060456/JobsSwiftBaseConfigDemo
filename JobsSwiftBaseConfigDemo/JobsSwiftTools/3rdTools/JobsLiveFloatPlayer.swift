//
//  JobsLiveFloatPlayer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import BMPlayer
/// 全局悬浮直播播放器：不进新 VC，直接在当前界面/窗口浮出一个小窗直播
@MainActor
final class JobsLiveFloatPlayer : NSObject {
    static let shared = JobsLiveFloatPlayer()
    private override init() {}
    private var player: BMPlayer?
    // MARK: - 对外方法
    /// 显示悬浮直播窗口（默认你的本地 HaishinKit 推流地址）
    func showRemoteLive(
        url: URL = "http://192.168.65.91:8000/live/jobs_test/index.m3u8".url!,
        name: String = "网络单播",
        in container: UIView? = nil
    ) {
        let p: BMPlayer
        if let existing = player {
            p = existing
        } else {
            p = BMPlayer()
            player = p
        }
        // 播放器基础配置
        p.byResource(
            // 播放资源配置
            BMPlayerResource(
            name: name,
            definitions: [
                BMPlayerResourceDefinition(
                    url: url,
                    definition: "默认"
                )
            ],
            cover: nil,
            subtitles: nil
        ), definitionIndex: 0, autoPlay: true)
            .byVideoGravity(.resizeAspect)     // 小窗用等比适配即可
            .byPanGestureEnabled(true)
            .byBack { isFull in
                JobsLiveFloatPlayer.shared.hide()
            }
        .bySuspend { cfg in                                      // ❗重点：不加到某个 VC 的 view，而是直接挂悬浮
            cfg
                .byContainer(container)                          // 传入则挂这上面；不传则挂到 keyWindow
                .byFallbackSize(CGSize(width: 320, height: 224)) // 小窗
                .byStart(.bottomRight)                           // 初始在右下角
                .byDraggable(true)                               // 可拖拽
                .byDocking(.auto)                                // 自动根据起点吸附边/角
                .byAnimated(true)                                // 吸附有动画
                .byHapticOnDock(true)                            // 吸附轻微震动
                .byConfineInContainer(true)                      // 限制在安全区内
        }.byVisible(true)
        /// 开启屏幕常亮
        keepScreenOn()
    }
    /// 隐藏并销毁悬浮直播窗口
    func hide() {
        player?.unsuspend()    // 来自 UIView+悬浮.swift
        player = nil
    }
    /// 只暂停，不销毁
    func pause() {
        player?.byPause()
    }
    /// 重新播放当前流
    func resume() {
        player?.byVisible(true)
    }
}
