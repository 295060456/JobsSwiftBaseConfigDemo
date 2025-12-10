//
//  JobsSysProgressDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import SnapKit

final class JobsSysProgressDemoVC: BaseVC {
    let horizontalInset: CGFloat = 40
    /// 当前正在运行的倒计时过程
    private var countdownProcess: JobsCountdownProcess?
    /// 进度展示模式：0 → 100 / 100 → 0
    /// - `.countUp`   : 进度条从 0% 涨到 100%（已完成比例）
    /// - `.countDown` : 进度条从 100% 掉到 0%（剩余比例）
    /// 默认用“累积”语义：0 → 100
    private var progressMode: JobsCountdownProcess.ProgressMode = .countUp
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
    /// 进度条（显示剩余/已完成比例，取决于 progressMode）
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
    /// 模式切换按钮：0%→100% / 100%→0%
    private lazy var modeButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemOrange, for: .normal)
            .byTitle(modeButtonTitle(), for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .byCornerRadius(16)
            .onTap { [weak self] _ in
                guard let self else { return }
                // 切换模式本身
                switch progressMode {
                case .countUp:
                    progressMode = .countDown
                case .countDown:
                    progressMode = .countUp
                }
                // 切模式时，如果在跑，就先停掉
                countdownProcess?.cancel()
                countdownProcess = nil
                // 刷新按钮标题 + 进度初值 + 开始按钮状态
                modeButton.byTitle(modeButtonTitle(), for: .normal)
                updateTimeLabelForIdle()
                setStartButton(true)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.progressView.snp.bottom).offset(16.h)
                make.centerX.equalToSuperview()
                make.height.equalTo(32.h)
                make.width.greaterThanOrEqualTo(160.w)
            }
    }()
    /// 倒计时时长选择
    private lazy var durationSegment: UISegmentedControl = {
        UISegmentedControl(items: durationSegmentTitles)
            .bySelectedSegmentIndex(1) // 默认选中 10 秒
            .onJobsChange { [weak self] (_: UISegmentedControl) in
                guard let self else { return }
                // 切换时长时，如果有在跑的倒计时，先停掉
                countdownProcess?.cancel()
                countdownProcess = nil
                // 重新回到“准备开始”状态
                updateTimeLabelForIdle()
                setStartButton(true)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.modeButton.snp.bottom).offset(24.h)
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
            /// 点按 = 开始一次新的倒计时
            .onTap { [weak self] _ in
                guard let self else { return }
                // 先停掉旧的，支持重投
                if let process = self.countdownProcess {
                    process.cancel()
                    self.countdownProcess = nil
                }
                let duration = self.selectedDuration
                // 根据进度模式设置起点
                let initialRatio: Float = {
                    switch self.progressMode {
                    case .countUp:   return 0.0   // 0 → 100，从 0 开始
                    case .countDown: return 1.0   // 100 → 0，从满格开始
                    }
                }()

                self.progressView.setProgress(initialRatio, animated: false)
                self.timeLabel.byText(String(format: "剩余：%.1f 秒", duration))
                self.setStartButton(false) // 倒计时进行中，禁用“开始倒计时”按钮

                self.countdownProcess = JobsCountdownProcess(
                    duration: duration,
                    kind: .displayLink,          // CADisplayLink 内核，更顺滑
                    tickInterval: 1.0 / 60.0,    // 60fps
                    tolerance: 0,
                    queue: .main
                )
                .byProgress { [weak self] snap in
                    guard let self else { return }
                    // 按模式取进度：0→1 或 1→0
                    let ratio = Float(snap.progress(for: self.progressMode))
                    print("mode=\(self.progressMode) elapsed=\(snap.elapsedRatio) remaining=\(snap.remainingRatio) ratio=\(ratio)")
                    self.progressView.setProgress(ratio, animated: true)
                    self.timeLabel.byText(String(format: "剩余：%.1f 秒", snap.remaining))
                }
                .byFinished { [weak self] snap in
                    guard let self else { return }

                    // 根据模式给一个最终值
                    let finalRatio: Float = {
                        switch self.progressMode {
                        case .countUp:   return 1.0    // 结束时满格
                        case .countDown: return 0.0    // 结束时清空
                        }
                    }()

                    self.progressView.setProgress(finalRatio, animated: true)
                    self.timeLabel.byText("倒计时完成 ✅（总 \(Int(snap.total)) 秒）")
                    self.countdownProcess = nil
                    self.setStartButton(true)
                }
                .byStartRunning()
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
                countdownProcess?.cancel()
                countdownProcess = nil
                updateTimeLabelForIdle()
                setStartButton(true)
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
        modeButton.byVisible(YES)
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
    /// 空闲状态下，根据当前选中的时长更新文案 + 进度初始值
    private func updateTimeLabelForIdle() {
        let duration = selectedDuration
        timeLabel.byText(String(format: "准备开始：%.0f 秒", duration))

        let initialRatio: Float = {
            switch progressMode {
            case .countUp:   return 0.0
            case .countDown: return 1.0
            }
        }()

        progressView.setProgress(initialRatio, animated: false)
        modeButton.byTitle(modeButtonTitle(), for: .normal)
    }
    /// 统一控制“开始倒计时”按钮的可用状态和样式
    private func setStartButton(_ enabled: Bool) {
        startButton.isEnabled = enabled
        startButton.alpha = enabled ? 1.0 : 0.5
    }
    /// 模式按钮标题
    private func modeButtonTitle() -> String {
        switch progressMode {
        case .countUp:
            return "模式：0% → 100%".tr
        case .countDown:
            return "模式：100% → 0%".tr
        }
    }
}
