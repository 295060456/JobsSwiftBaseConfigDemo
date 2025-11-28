//
//  LuckyWheelDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

import UIKit
import SnapKit

final class LuckyWheelDemoVC: BaseVC {
    private lazy var wheelView: LuckyWheelView = {
        LuckyWheelView()
            .bySegments([
                .init(text: "一等奖",
                      textFont: .systemFont(ofSize: 12, weight: .medium),
                      textColor: .white,
                      backgroundColor: .systemRed,
                      placeholderImage: "globe".sysImg,
                      imageURLString:"https://picsum.photos/30"),
                .init(text: "二等奖",
                      textFont: .systemFont(ofSize: 12, weight: .medium),
                      textColor: .white,
                      backgroundColor: .systemOrange,
                      placeholderImage: "message".sysImg,
                      imageURLString:"https://picsum.photos/30"),
                .init(text: "谢谢参与",
                      textFont: .systemFont(ofSize: 12, weight: .medium),
                      textColor: .white,
                      backgroundColor: .systemGray,
                      placeholderImage: "tray".sysImg,
                      imageURLString:"https://picsum.photos/30"),
            ])
            .bySpinDuration(3.0)
            .byInitialVelocity(25.0)
            .byPanRotationEnabled(true)
            .onSegmentTap { idx in
                toastBy("🍀 短按扇形 index = \(idx)")
            }
            .onSegmentLongPress { idx, gr in
                if gr.state == .began {
                    toastBy("👆 长按开始 index = \(idx)")
                }
            }
            .byAddTo(view) { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(300)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "抽奖转盘",
            rightButtons: [
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("pause.circle.fill".sysImg, for: .normal)
                    .byImage("pause.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        wheelView.stopSpin()
                    }
            ]
        )
        wheelView.byVisible(YES)
    }
}
