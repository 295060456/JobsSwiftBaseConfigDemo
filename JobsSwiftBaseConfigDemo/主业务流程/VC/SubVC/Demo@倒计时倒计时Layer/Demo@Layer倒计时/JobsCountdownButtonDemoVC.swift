//
//  JobsCountdownButtonDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/12/10.
//

import UIKit
import SnapKit
/// 演示：按钮中间显示倒计时秒数，点击 = 开始 / 暂停 / 继续 / 完成后重新开始
final class JobsCountdownButtonDemoVC: BaseVC {
    private let horizontalInset: CGFloat = 40
    private let defaultTotalSeconds: Int = 10
    /// 记录当前剩余秒数（用于暂停提示）
    private var remainingSeconds: Int = 0
    // MARK: - UI
    /// 提示文案
    private lazy var hintLabel: UILabel = {
        UILabel()
            .byText("点击按钮：开始 / 暂停 / 继续（完成后再点 = 重新开始）".tr)
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(0)
            .byTextAlignment(.center)
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(30)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
                }
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
            }
    }()
    /// 倒计时演示按钮（同一套 API：传 total => 倒计时）
    private lazy var countdownButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("开始".tr + " \(defaultTotalSeconds)s", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.boldSystemFont(ofSize: 16))
            .byCornerRadius(8)
            // 每一秒回调：更新按钮标题 & 记录剩余秒数
            .onCountdownTick { [weak self] btn, remain, total, kind in
                guard let self else { return }
                self.remainingSeconds = remain
                print("⏱️ [\(kind.jobs_displayName)] remain=\(remain)s / total=\(total)s")
                let text = "\(remain)s"
                btn.byTitle(text, for: .normal)
            }
            // 完成回调：标题改成“重新开始”，提示文案刷新
            .onCountdownFinish { [weak self] btn, kind in
                guard let self else { return }
                print("✅ [\(kind.jobs_displayName)] 倒计时完成")
                // 计时内部会先 stopTimer() 并把标题设为「重新获取」
                // 这里异步再改回「重新开始」，覆盖内部默认文案
                DispatchQueue.main.async { [weak self, weak btn] in
                    guard let self, let btn else { return }
                    btn.byTitle("重新开始".tr, for: .normal)
                    self.hintLabel.byText("倒计时完成，点击可重新开始 \(self.defaultTotalSeconds)s".tr)
                }
            }
            // 点按：根据当前状态 => 开始 / 暂停 / 继续 / 重新开始
            .onJobsTap { [weak self] (btn: UIButton) in
                self?.handleCountdownButtonTap(btn)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.hintLabel.snp.bottom).offset(30)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(50)
            }
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor(.systemBackground)
        jobsSetupGKNav(title: "JobsTimer 按钮倒计时 Demo")
        hintLabel.byVisible(YES)
        countdownButton.byVisible(YES)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 离开页面时把倒计时停掉
        countdownButton.stopTimer()
    }
    // MARK: - 业务逻辑
    /// 统一处理按钮点击：根据当前状态切换行为
    private func handleCountdownButtonTap(_ btn: UIButton) {
        switch btn.timerState {
        case .idle, .stopped:
            // 处于空闲 / 完成状态：重新开始一轮
            let total = defaultTotalSeconds
            remainingSeconds = total
            hintLabel.byText("倒计时进行中，点击可以暂停".tr)
            btn.startTimer(
                total: total,
                interval: 1.0,
                kind: .gcd
            ).byFuseCountdown(duration: TimeInterval(total))
        case .running:
            // 正在倒计时：暂停
            btn.pauseTimer()
            let remain = remainingSeconds > 0 ? remainingSeconds : defaultTotalSeconds
            hintLabel.byText("已暂停，点击继续（还剩 \(remain)s）".tr)
        case .paused:
            // 暂停中：继续
            btn.resumeTimer()
            hintLabel.byText("倒计时进行中，点击可以暂停".tr)
        }
    }
}
