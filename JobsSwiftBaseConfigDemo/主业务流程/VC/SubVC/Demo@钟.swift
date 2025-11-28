//
//  Demo@钟.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

import UIKit
import SnapKit

final class ClockDemoVC: BaseVC {
    private lazy var clockView: JobsClockView = {
        JobsClockView()
            .byAddTo(view) { [unowned self] make in
                make.center.equalToSuperview()
                make.width.height.equalTo(240)   // 正方形表盘
            }
    }()
    // 如果你想要一个外壳容器再加阴影、圆角，也可以懒加载一个 container，再把 clockView 加进去
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        jobsSetupGKNav(
            title: "倒计时按钮"
        )
        clockView.byVisible(YES)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 页面展示后开始走表
//        clockView.start(kind: .gcd)
        // 想要秒针顺滑可以换成 .displayLink + interval = 1/60
         clockView.start(kind: .displayLink)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 离开页面可以停掉，避免后台白跑
        clockView.stop()
    }
}
