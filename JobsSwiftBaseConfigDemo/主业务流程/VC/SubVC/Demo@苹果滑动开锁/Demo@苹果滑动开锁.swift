//
//  Demo@苹果滑动开锁.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/29/25.
//

import UIKit
import SnapKit

final class SlideToUnlockDemoVC: BaseVC {
    private lazy var slideView: SlideToUnlockView = {
        SlideToUnlockView()
            .byBgColor(.clear)
            .byOnUnlock {[weak self] in
                guard let self else { return }
                print("✅ 已滑到最右侧，执行解锁 block")
                goBack(nil)
            }
            .byAddTo(view) { [unowned self] make in
                make.center.equalToSuperview()
                make.width.equalTo(260)
                make.height.equalTo(56)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor(.systemBackground)
        slideView.byVisible(YES)
    }
}
