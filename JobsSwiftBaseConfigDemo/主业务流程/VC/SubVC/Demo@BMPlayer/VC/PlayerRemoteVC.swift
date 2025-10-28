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
    // MARK: - 懒加载：播放器（用 DSL 一次性完成：add + constraints + resource + autoPlay + 回调）
    private lazy var player: BMPlayer = { [unowned self] in
        // 通过 DSL 工厂方法一次性完成：添加到 view、约束、绑定资源、自动播放与回调
        BMPlayer.make(in: self.view,
                             constraints: { make in
                                 make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
                                 make.leading.trailing.equalToSuperview()
                                 // 用容器的宽度建立 16:9 高度；与原 “等于自身宽度 * 9/16” 等价
                                 make.height.equalTo(self.view.snp.width)
                                     .multipliedBy(9.0 / 16.0)
                                     .priority(750)
                             },
                             resource: BMPlayerResource(name: "BigBuckBunny",
                                                        definitions: [BMPlayerResourceDefinition(url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4".url!, definition: "默认")],
                                                        cover: nil,
                                                        subtitles: nil),
                             definitionIndex: 0,
                             autoPlay: true) { p in
            p.byVideoGravity(.resizeAspect)       // 与原始表现一致；需要铺满可改为 .resizeAspectFill
             .byPanGestureEnabled(true)
             .byBack { [weak self] isFull in
                 guard let self else { return }
                 // 仅在非全屏时响应“返回”：退出当前 VC
                 if !isFull { self.navigationController?.popViewController(animated: true) }
             }
             // 需要的话可挂进度/状态回调：
             // .onPlayTimeChanged { cur, total in ... }
             // .onPlayStateChanged { state in ... }
        }
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "网络单播")
        // 触发懒加载（会完成 add/constraints/resource/autoplay）
        player.byVisible(YES)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            player.byPause()   // 阻断后续 autoPlay
        }
    }
}
