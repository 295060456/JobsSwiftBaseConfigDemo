//
//  WheelDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

import UIKit
import SnapKit

final class WheelDemoVC: UIViewController {
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
            .bySpinDuration(8.0)        // 目标转 3 秒左右
            .byInitialVelocity(25.0)    // 显式指定初始角速度（rad/s）
            .byDecelerationRate(.normal)
            .byStopThreshold(0.05)
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
