//
//  PlayerRemoteVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import SnapKit
import BMPlayer

final class PlayerRemoteVC: BaseVC {
    deinit {
        JobsNetworkTrafficMonitorStop()  /// 停止网络实时监听
        JobsCancelWaitNetworkDataReady() /// 停止网络数据源监听
    }
    /// 播放器
    private lazy var player: BMPlayer = { [unowned self] in
        BMPlayer()
            .byResource(BMPlayerResource(
                name: "BigBuckBunny",
                definitions: [
                    BMPlayerResourceDefinition(
//                        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4".url!,
                        url: "http://cdn3.toronto360.tv:8081/toronto360/hd/playlist.m3u8".url!, // 信号源📶：巴基斯坦电视台
                        definition: "默认"
                    )
                ],
                cover: nil,
                subtitles: nil
            ), definitionIndex: 0, autoPlay: true)
            .byVideoGravity(.resizeAspect)      // 需要铺满可改 .resizeAspectFill
            .byPanGestureEnabled(true)
            .byBack { [weak self] isFull in
                guard let self else { return }
                if !isFull { self.navigationController?.popViewController(animated: true) }
            }
            .byAddTo(view) { [unowned self] make in
                if self.view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(400)
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()

    override func loadView() {
        super.loadView()
        jobsWaitNetworkDataReady(
            onWiFiReady: {
                print("✅ Wi-Fi 已有真实流量")
            },
            onCellularReady: {
                print("✅ 蜂窝已实际可用，可以走后续逻辑")
                // 比如这里再去重试接口、发起播放等
            }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        networkRichListenerBy(view)
        jobsSetupGKNav(title: "网络单播")
        player.byVisible(YES)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            player.byPause()          // 阻断后续 autoPlay
        }
    }
}
