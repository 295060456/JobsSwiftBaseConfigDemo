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

//        JobsNetworkTrafficMonitor.shared
//            .byOnUpdate { [weak self] source, up, down in
//                guard let self else { return }
//
//                let upStr   = jobs_formatSpeed(up)
//                let downStr = jobs_formatSpeed(down)
//
//                let text = """
//                源: \(source.displayName)
//                ⬆︎ \(upStr)  ⬇︎ \(downStr)
//                """
//
//                view.makeNetworkListener().byText(text)
//            }
//            .byStart(interval: 1.0)

        JobsNetworkTrafficMonitor.shared
            .byOnUpdate { [weak self] source, up, down in
                guard let self else { return }

                let upStr   = jobs_formatSpeed(up)
                let downStr = jobs_formatSpeed(down)

                // 段落样式：居中 + 行距
                let paragraph = jobsMakeParagraphStyle { ps in
                    ps.alignment = .center
                    ps.lineSpacing = 2
                }

                // 用 JobsRichText 拼富文本
                let attr = JobsRichText.make([
                    // 第 1 行：源
                    JobsRichRun(.text("源: "))
                        .font(.systemFont(ofSize: 10, weight: .medium))
                        .color(.secondaryLabel),

                    JobsRichRun(.text(source.displayName))
                        .font(.systemFont(ofSize: 11, weight: .semibold))
                        .color(.white),

                    JobsRichRun(.text("\n")),

                    // 第 2 行：上行
                    JobsRichRun(.text("⬆︎ "))
                        .font(.systemFont(ofSize: 11))
                        .color(.systemGreen),

                    JobsRichRun(.text(upStr + "  "))
                        .font(.monospacedDigitSystemFont(ofSize: 11, weight: .medium))
                        .color(.white),

                    // 下行
                    JobsRichRun(.text("⬇︎ "))
                        .font(.systemFont(ofSize: 11))
                        .color(.systemRed),

                    JobsRichRun(.text(downStr))
                        .font(.monospacedDigitSystemFont(ofSize: 11, weight: .medium))
                        .color(.white)
                ], paragraphStyle: paragraph)

                // 单例悬浮 Label + 富文本
                self.view
                    .makeNetworkListener()
                    .byAttributedString(attr)
            }
            .byStart(interval: 1.0)

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
