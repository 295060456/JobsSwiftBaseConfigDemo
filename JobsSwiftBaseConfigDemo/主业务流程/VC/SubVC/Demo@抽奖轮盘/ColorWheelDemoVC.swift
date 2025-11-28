//
//  WheelDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

import UIKit
import SnapKit

final class WheelDemoVC: BaseVC {
    private lazy var wheelView: ColorWheelView = {
        ColorWheelView()
            .byColors([
                .systemRed,
                .systemOrange,
                .systemYellow,
                .systemGreen,
                .systemBlue,
                .systemPurple
            ])
            .bySpinDuration(3.0)              // 大概转 3 秒
            .byInitialVelocity(25.0)          // 不想用时间推，也可以直接指定初速度
            .byPanRotationEnabled(YES)        // 允许手势拖动旋转
            .onSegmentTap { idx in
                print("🍀 短按扇形 index = \(idx)")
            }
            .onSegmentLongPress { idx, gr in
                if gr.state == .began {
                    print("👆 长按开始 index = \(idx)")
                } else if gr.state == .ended {
                    print("👆 长按结束 index = \(idx)")
                }
            }
            .byAddTo(view) { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(260)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "抽奖转盘"
        )
        wheelView.byVisible(YES)
    }
}
