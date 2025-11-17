//
//  PlayerRemoteVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import UIKit
import SnapKit
import BMPlayer

final class PlayerRemoteVC: BaseVC {
    deinit {
        JobsNetworkTrafficMonitor.shared.stop()
    }
    // MARK: - 懒加载：播放器
    private lazy var player: BMPlayer = { [unowned self] in
        BMPlayer()
            .byResource(BMPlayerResource(
                name: "BigBuckBunny",
                definitions: [
                    BMPlayerResourceDefinition(
                        url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4".url!,
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
    // MARK: - 生命周期
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
