//
//  JobsCountdownProgressDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

import UIKit
import SnapKit
/// 演示：纯逻辑的 JobsCountdownProcess + 简单 UI
final class JobsCountdownProgressDemoVC: BaseVC {
    let horizontalInset: CGFloat = 40
    /// 当前正在运行的倒计时过程
    private var countdownProcess: JobsCountdownProcess?
    /// 可选时长（秒）—— 唯一真相源
    private lazy var durationOptions: [Int] = [5, 10, 20]
    /// SegmentedControl 展示文案
    private lazy var durationSegmentTitles: [String] = {
        durationOptions.map { "\($0) 秒".tr }
    }()
    /// 选中的倒计时总时长（基于 durationOptions + 当前选中的 index）
    private var selectedDuration: TimeInterval {
        let index = durationSegment.selectedSegmentIndex
        if durationOptions.indices.contains(index) {
            return TimeInterval(durationOptions[index])
        }
        // fallback：默认用数组中的第二个（10 秒）
        return durationOptions.count > 1
            ? TimeInterval(durationOptions[1])
            : TimeInterval(durationOptions.first ?? 10)
    }
    // MARK: - UI
    /// 显示剩余时间
    private lazy var timeLabel: UILabel = {
        UILabel()
            .byText("剩余：-- 秒".tr)
            .byFont(.monospacedDigitSystemFont(ofSize: 18, weight: .medium))
            .byTextAlignment(.center)
            .byAddTo(view) { [unowned self] make in
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().inset(20)
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(30)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                }
            }
    }()
    /// 进度条（显示剩余比例）
    private lazy var progressView: UIProgressView = {
        UIProgressView(progressViewStyle: .default)
            .byProgress(0)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.timeLabel.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                // 高度 UIProgressView 自己决定，一般不用约束
            }
    }()
    /// 倒计时时长选择
    private lazy var durationSegment: UISegmentedControl = {
        UISegmentedControl(items: durationSegmentTitles)
            .bySelectedSegmentIndex(1) // 默认选中 10 秒
            .onJobsChange { [weak self] (seg : UISegmentedControl) in
                guard let self else { return }
                // 启用“开始倒计时”按钮（你自己实现这个方法）
                self.setStartButton(true)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.progressView.snp.bottom).offset(40.h)
                make.centerX.equalToSuperview()
                make.width.equalTo(260.w)
            }
    }()
    /// 开始按钮
    private lazy var startButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("开始倒计时".tr, for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.boldSystemFont(ofSize: 16))
            .byCornerRadius(8)
            /// 普通@点按事件触发
            .onTap { [weak self] _ in
                guard let self else { return }
                // 先停掉旧的，支持重投
                if let process = self.countdownProcess {
                    process.cancel()
                    self.countdownProcess = nil
                }

                let duration = self.selectedDuration

                // UI 初始化：剩余满格
                self.progressView.setProgress(1.0, animated: false)
                self.timeLabel.byText(String(format: "剩余：%.1f 秒", duration))

                let process = JobsCountdownProcess(
                    duration: duration,
                    kind: .displayLink,          // CADisplayLink 内核，更顺滑
                    tickInterval: 1.0 / 60.0,    // 60fps
                    tolerance: 0,
                    queue: .main
                )

                // 倒计时进行中，禁用“开始倒计时”按钮
                self.setStartButton(false)

                // 每次 tick 更新进度和时间
                process.onProgress = { [weak self] snap in
                    guard let self else { return }

                    let remainingRatio = Float(1.0 - snap.progress)
                    self.progressView.setProgress(remainingRatio, animated: true)
                    self.timeLabel.byText(String(format: "剩余：%.1f 秒", snap.remaining))
                }

                // 走到 100% 的回调
                process.onFinished = { [weak self] snap in
                    guard let self else { return }
                    self.progressView.setProgress(0, animated: true)
                    self.timeLabel.byText("倒计时完成 ✅（总 \(Int(snap.total)) 秒）")
                    self.countdownProcess = nil
                    self.setStartButton(true)
                }

                self.countdownProcess = process
                process.start()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.durationSegment.snp.bottom).offset(40.h)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(44.h)
            }
    }()
    /// 取消按钮
    private lazy var cancelButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGray, for: .normal)
            .byTitle("取消".tr, for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16))
            .byCornerRadius(8)
            /// 普通@点按事件触发
            .onTap { [weak self] _ in
                guard let self else { return }
                self.countdownProcess?.cancel()
                self.countdownProcess = nil
                self.progressView.setProgress(0, animated: true)
                self.updateTimeLabelForIdle()
                self.setStartButton(true)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.startButton.snp.bottom).offset(16.h)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(44.h)
            }
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor(.systemBackground)
        jobsSetupGKNav(
            title: "JobsTimer 倒计时 Demo"
        )

        timeLabel.byVisible(YES)
        progressView.byVisible(YES)
        durationSegment.byVisible(YES)
        startButton.byVisible(YES)
        cancelButton.byVisible(YES)

        updateTimeLabelForIdle()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 离开页面时把 timer 停掉
        countdownProcess?.cancel()
        countdownProcess = nil
        setStartButton(true)
    }
    // MARK: - Helper
    /// 空闲状态下，根据当前选中的时长更新文案
    private func updateTimeLabelForIdle() {
        timeLabel.byText(String(format: "准备开始：%.0f 秒", selectedDuration))
    }
    /// 统一控制“开始倒计时”按钮的可用状态和样式
    private func setStartButton(_ enabled: Bool) {
        startButton.isEnabled = enabled
        startButton.alpha = enabled ? 1.0 : 0.5
    }
}
