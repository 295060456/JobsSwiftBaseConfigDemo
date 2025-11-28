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
            .bySpinDuration(3.0)
            .byInitialVelocity(25.0)
            .onSegmentTap { idx in
                toastBy("🍀 短按扇形 index = \(idx)")
            }
            .onSegmentLongPress { idx, gr in
                if gr.state == .began {
                    toastBy("🍀 长按开始 index = \(idx)")
                } else if gr.state == .ended {
                    print("👆 长按结束 index = \(idx)")
                    toastBy("🍀 长按开始 index = \(idx)")
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
