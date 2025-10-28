//
//  PlayerLocalVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import UIKit
import AVFoundation
import BMPlayer
import SnapKit

final class PlayerLocalVC: BaseVC {
    // MARK: - 懒加载：播放器（用 DSL 完成 add+constraints+resource+autoPlay+回调）
    private lazy var player: BMPlayer = { [unowned self] in
        BMPlayer.make(in: self.view,
                             constraints: { make in
                                 make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
                                 make.leading.trailing.equalToSuperview()
                                 make.height.equalTo(self.view.snp.width)
                                     .multipliedBy(9.0 / 16.0)
                                     .priority(750)
                             },
                             resource: BMPlayerResource(name: "welcome_video",
                                                        definitions: [BMPlayerResourceDefinition(url: "welcome_video.mp4".bundleMediaURLRequire, definition: "本地")],
                                                        cover: nil,
                                                        subtitles: nil),
                             definitionIndex: 0,
                             autoPlay: true) { p in
            p.byVideoGravity(.resizeAspect)     // 需要铺满可改 .resizeAspectFill
             .byPanGestureEnabled(true)
             .byBack { [weak self] isFull in
                 guard let self else { return }
                 if !isFull { self.navigationController?.popViewController(animated: true) }
             }
             // .onPlayTimeChanged { cur, total in ... }
             // .onPlayStateChanged { state in ... }
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
            player.byPause()  // 阻断后续 autoPlay
        }
    }
}
