//
//  SafetyPushDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 2025/09/30.
//

import UIKit
import SnapKit

final class SafetyPushDemoVC: BaseVC {
    // MARK: - Buttons（逐个老老实实创建，链式 + 就地约束）
    private lazy var topButton: UIButton = {
        UIButton.sys()
            .byTitle("从上进入", for: .normal)
            .byTitle("从上进入 ✓", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed,  for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .bySubTitle("Push from Top", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 13))
            .byImage("arrow.down.to.line".sysImg, for: .normal)
            .byImage("arrow.down.to.line.compact".sysImg, for: .selected)
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { [unowned self] b in
                b.isSelected.toggle()
                DemoDetailVC()
                    .byData("https://www.baidu.com")
                    .byDirection(.fromTop)      // 👈 上
                    .byPush(self)
                    .byCompletion { print("❤️结束❤️ fromTop") }
            }
            .byCornerDot(diameter: 8, offset: .init(horizontal: -4, vertical: 4))
            .byCornerBadgeText("TOP") { cfg in
                cfg.byOffset(.init(horizontal: -6, vertical: 6))
                    .byInset(.init(top: 2, left: 6, bottom: 2, right: 6))
                    .byBgColor(.systemRed)
                    .byFont(.systemFont(ofSize: 11, weight: .bold))
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
            .byAlpha(0) // 进来先 0，viewDidLoad 再统一置 1
    }()

    private lazy var bottomButton: UIButton = {
        UIButton.sys()
            .byTitle("从下进入", for: .normal)
            .byTitle("从下进入 ✓", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed,  for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .bySubTitle("Push from Bottom", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 13))
            .byImage("arrow.up.to.line".sysImg, for: .normal)
            .byImage("arrow.up.to.line.compact".sysImg, for: .selected)
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { [unowned self] b in
                b.isSelected.toggle()
                DemoDetailVC()
                    .byData("https://www.baidu.com")
                    .byDirection(.fromBottom)   // 👈 下
                    .byPush(self)
                    .byCompletion { print("❤️结束❤️ fromBottom") }
            }
            .byCornerDot(diameter: 8, offset: .init(horizontal: -4, vertical: 4))
            .byCornerBadgeText("BOTTOM") { cfg in
                cfg.byOffset(.init(horizontal: -6, vertical: 6))
                    .byInset(.init(top: 2, left: 6, bottom: 2, right: 6))
                    .byBgColor(.systemRed)
                    .byFont(.systemFont(ofSize: 11, weight: .bold))
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.topButton.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
            .byAlpha(0)
    }()

    private lazy var leftButton: UIButton = {
        UIButton.sys()
            .byTitle("从左进入", for: .normal)
            .byTitle("从左进入 ✓", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed,  for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .bySubTitle("Push from Left", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 13))
            .byImage("arrow.right.to.line".sysImg, for: .normal)
            .byImage("arrow.right.to.line.compact".sysImg, for: .selected)
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { [unowned self] b in
                b.isSelected.toggle()
                DemoDetailVC()
                    .byData("https://www.baidu.com")
                    .byDirection(.fromLeft)     // 👈 左
                    .byPush(self)
                    .byCompletion { print("❤️结束❤️ fromLeft") }
            }
            .byCornerDot(diameter: 8, offset: .init(horizontal: -4, vertical: 4))
            .byCornerBadgeText("LEFT") { cfg in
                cfg.byOffset(.init(horizontal: -6, vertical: 6))
                    .byInset(.init(top: 2, left: 6, bottom: 2, right: 6))
                    .byBgColor(.systemRed)
                    .byFont(.systemFont(ofSize: 11, weight: .bold))
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.bottomButton.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
            .byAlpha(0)
    }()

    private lazy var rightButton: UIButton = {
        UIButton.sys()
            .byTitle("从右进入（系统默认）", for: .normal)
            .byTitle("从右进入 ✓", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed,  for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .bySubTitle("Push from Right", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 13))
            .byImage("arrow.left.to.line".sysImg, for: .normal)
            .byImage("arrow.left.to.line.compact".sysImg, for: .selected)
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { [unowned self] b in
                b.isSelected.toggle()
                DemoDetailVC()
                    .byData("https://www.baidu.com")
                    .byDirection(.fromRight)    // 👈 右（等同系统默认）
                    .byPush(self)
                    .byCompletion { print("❤️结束❤️ fromRight") }
            }
            .byCornerDot(diameter: 8, offset: .init(horizontal: -4, vertical: 4))
            .byCornerBadgeText("RIGHT") { cfg in
                cfg.byOffset(.init(horizontal: -6, vertical: 6))
                    .byInset(.init(top: 2, left: 6, bottom: 2, right: 6))
                    .byBgColor(.systemRed)
                    .byFont(.systemFont(ofSize: 11, weight: .bold))
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.leftButton.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
            .byAlpha(0)
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "🚦 Safety Push Demo")
        view.backgroundColor = .systemBackground
        // 用的时候直接置可见
        topButton.byVisible(YES)
        bottomButton.byVisible(YES)
        leftButton.byVisible(YES)
        rightButton.byVisible(YES)
    }
}
