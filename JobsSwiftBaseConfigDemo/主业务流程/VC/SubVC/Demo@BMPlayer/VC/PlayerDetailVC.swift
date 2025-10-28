//
//  PlayerDetailVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import UIKit
import BMPlayer
import SnapKit
import AVFoundation

final class PlayerDetailVC: BaseVC {
    private let item: FeedItem
    init(item: FeedItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    // MARK: - 懒加载：播放器
    private lazy var player: BMPlayer = { [unowned self] in
        // 1) 统一构造 Resource（你的 BMPlayer 若有 subtitles 初始化器，按需替换）
        let def = BMPlayerResourceDefinition(url: item.videoURL, definition: "默认")
        let res = BMPlayerResource(name: item.id, definitions: [def], cover: item.headImg)

        // 2) 一步构建：add + constraints + resource + autoPlay + 回调
        return BMPlayer.make(in: self.view,
                             constraints: { make in
                                 make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                                 make.leading.trailing.equalToSuperview()
                                 make.height.equalTo(self.view.snp.width).multipliedBy(9.0/16.0)
                             },
                             resource: res,
                             definitionIndex: 0,
                             autoPlay: true) { p in
            p.byVideoGravity(.resizeAspect)       // 需要铺满可改 .resizeAspectFill
             .byPanGestureEnabled(true)
             .byBack { [weak self] isFull in
                 guard let self else { return }
                 if !isFull { self.navigationController?.popViewController(animated: true) }
             }
             // .onPlayTimeChanged { cur, total in ... }
             // .onPlayStateChanged { state in ... }
        }
    }()
    // MARK: - 懒加载：正文
    private lazy var contentLabel: UILabel = { [unowned self] in
        UILabel().byNumberOfLines(0)
            .byText(item.content.isEmpty ? " " : item.content)
            .byTextColor(.label)
            .byFont(.preferredFont(forTextStyle: .body))
            .byAddTo(view) {[unowned self] make in
                make.top.equalTo(self.player.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(12)
            }
    }()
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: JobsText(item.nickname)
        )
        player.byVisible(YES)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { player.byPause() }   // 阻断后续 autoPlay
    }
}
