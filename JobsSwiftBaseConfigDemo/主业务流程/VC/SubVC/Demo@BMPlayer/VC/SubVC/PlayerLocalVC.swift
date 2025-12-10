//
//  PlayerLocalVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import BMPlayer
import SnapKit

final class PlayerLocalVC: BaseVC {
    // MARK: - 懒加载：播放器
    private lazy var player: BMPlayer = { [unowned self] in
        BMPlayer()
            .byResource(BMPlayerResource(
                name: "welcome_video",
                definitions: [
                    BMPlayerResourceDefinition(
                        url: "welcome_video.mp4".bundleMediaURLRequire,
                        definition: "本地"
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
//                    make.left.right.bottom.equalToSuperview()
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
        jobsSetupGKNav(title: "本地单播")
        player.byVisible(YES)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            player.byPause()          // 阻断后续 autoPlay
        }
    }
}
