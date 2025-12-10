//
//  PlayerDetailVC.swift
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

final class PlayerDetailVC: BaseVC {
    private let item: FeedItem
    init(item: FeedItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 懒加载：播放器（用你的链式 API：byResource + byAddTo）
    private lazy var player: BMPlayer = { [unowned self] in
        // 1) 统一构造 Resource
        let def = BMPlayerResourceDefinition(url: item.videoURL, definition: "默认")
        let res = BMPlayerResource(name: item.id, definitions: [def], cover: item.headImg)

        // 2) 一步完成：resource + 回调 + 约束（byAddTo）
        return BMPlayer()
            .byResource(res, definitionIndex: 0, autoPlay: true)
            .byVideoGravity(.resizeAspect)     // 需要铺满可改 .resizeAspectFill
            .byPanGestureEnabled(true)
            .byBack { [weak self] isFull in
                guard let self else { return }
                if !isFull { self.navigationController?.popViewController(animated: true) }
            }
            .byAddTo(view) { [unowned self] make in
                if self.view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom)
                } else {
                    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                }
                make.left.right.equalToSuperview()
                // 16:9 等比高度
                make.height.equalTo(self.view.snp.width)
                    .multipliedBy(9.0 / 16.0)
                    .priority(750)
            }
    }()

    // MARK: - 懒加载：正文
    private lazy var contentLabel: UILabel = { [unowned self] in
        UILabel()
            .byNumberOfLines(0)
            .byText(item.content.isEmpty ? " " : item.content)
            .byTextColor(.label)
            .byFont(.preferredFont(forTextStyle: .body))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.player.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(12)
                make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(12).priority(750)
            }
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: JobsText(item.nickname))
        player.byVisible(YES)
        contentLabel.byVisible(YES)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { player.byPause() }   // 阻断后续 autoPlay
    }
}
