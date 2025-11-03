//
//  TimerDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//
//  概要
//  -----------------------------------------------------------------------------
//  一个统一演示定时器实现差异与一致 API 的示例控制器。
//  支持四种实现：Foundation.Timer / DispatchSourceTimer(GCD) / CADisplayLink / CFRunLoopTimer。
//  通过统一 API：「start / pause / resume / fireOnce / stop」，计时器挂在 UIButton 内部；
//  UI 用状态机驱动按钮可用与配色；
//  全部懒加载；链式 API（byXX / onXX / byAddTo）；两排按钮；开始按钮在运行时显示当前计数；
//  可输入“步长”（interval），修改后立刻生效（重建定时器）；Fire 与 Stop 文案区分清楚；
//  Segmented 指定计时器内核，更改后会“先停旧再用新内核重建并继续”。
// -----------------------------------------------------------------------------

import UIKit
import SnapKit

final class TimerDemoVC: BaseVC {
    // MARK: - Layout 常量
    let horizontalInset: CGFloat = 40
    let spacing: CGFloat = 12
    // MARK: - 计时器配置（由 UI 驱动）
    private var currentKind: JobsTimerKind = .gcd
    private var intervalSec: TimeInterval = 1.0   // 步长（秒），由输入框维护
    // MARK: - Segmented（选择计时器内核）
    private lazy var kindSelector = UISegmentedControl(items: ["NSTimer", "GCD", "DisplayLink", "RunLoop"])
        .bySelectedSegmentIndex(1) // 默认 GCD
        .onJobsChange { [weak self] (seg: UISegmentedControl) in
            guard let self else { return }
            let mapping: [JobsTimerKind] = [.foundation, .gcd, .displayLink, .runLoopCore]
            let idx = max(0, min(seg.selectedSegmentIndex, mapping.count - 1))
            self.currentKind = mapping[idx]
            self.rebuildActiveTimersForNewKind() // 切换实现：停旧 -> 按原模式用新内核重建
        }
        .byAddTo(view) { [unowned self] make in
            make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(40)
            make.height.equalTo(36)
        }
    // MARK: - 最近一次触发时间
    private lazy var lastFireLabel = UILabel()
        .byText("Last: -")
        .byFont(.monospacedDigitSystemFont(ofSize: 14, weight: .regular))
        .byTextColor(.secondaryLabel)
        .byTextAlignment(.center)
        .byAddTo(view) { [unowned self] make in
            make.top.equalTo(self.kindSelector.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
    // MARK: - 步长输入框（修改 interval）
    private lazy var intervalField = UITextField()
        .byText("1.0")
        .byKeyboardType(.decimalPad)
        .byBorderStyle(.roundedRect)
        .byTextAlignment(.center)
        .byFont(.systemFont(ofSize: 16))
        .byAddTo(view) { [unowned self] make in
            make.top.equalTo(self.lastFireLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
        // 输入时仅更新内存值，不重建（避免频繁抖动）
        .onJobsEvent(.editingChanged) { [weak self] (tf: UITextField) in
            self?.applyIntervalFromField(tf, commit: false)
        }
        // 结束编辑后：若有正在运行/暂停的计时器，立即“停旧并用新步长重启”（重建）
        .onJobsEvent(.editingDidEnd) { [weak self] (tf: UITextField) in
            self?.applyIntervalFromField(tf, commit: true)
        }
    // MARK: - 倒计时峰值输入框（只允许数字）
    private lazy var countdownField = UITextField()
        .byText("10")
        .byKeyboardType(.numberPad)
        .byBorderStyle(.roundedRect)
        .byTextAlignment(.center)
        .byFont(.systemFont(ofSize: 16))
        .byAddTo(view) { [unowned self] make in
            make.top.equalTo(self.intervalField.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().inset(40)
            make.height.equalTo(40)
        }
    // MARK: - 开始按钮（正计时：不传 total；按钮标题自动显示 elapsed）
    private lazy var startButton: UIButton = {
        UIButton(type: .system)
            .byTitle("开始", for: .normal)
            .byTitleFont(.systemFont(ofSize: 22, weight: .bold))
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemBlue, for: .normal)
            .byCornerRadius(10)
            .byMasksToBounds(true)
            // 每 tick：更新时间 & 最近触发时间
            .onTimerTick { [weak self] btn, elapsed, _, kind in
                guard let self else { return }
                // 正计时：elapsed（秒）已由按钮内部自动设置为标题，这里只补充 lastFireLabel
                self.lastFireLabel.text = "Last: " + fmt(Date())
            }
            // 状态变化：驱动控制键（暂停/继续/Fire/停止）的可用与配色
            .onTimerStateChange { [weak self] button, oldState, newState in
                self?.updateControlButtons(by: newState)
            }
            // 点击开始：不传 total => 正计时
            .onTap { [weak self] btn in
                guard let self else { return }
                self.lastFireLabel.text = "Last: -"
                btn.startTimer(
                    total: nil,                 // 不传 => 正计时
                    interval: self.intervalSec,
                    kind: self.currentKind
                )
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(countdownField.snp.bottom).offset(14)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(56)
            }
    }()

    // MARK: - 控制键：暂停 / 继续 / Fire / 停止（控制 startButton 的内部计时器）
    private lazy var pauseButton = makeActionButton(
        title: "暂停",
        titleColor: .systemBlue,
        subtitle: "悬空"
    ) { [weak self] _ in
        self?.startButton.pauseTimer()
        self?.countdownButton.pauseTimer()
    }

    private lazy var resumeButton = makeActionButton(
        title: "继续",
        titleColor: .systemBlue,
        subtitle: "恢复计时"
    ) { [weak self] _ in
        self?.startButton.resumeTimer()
        self?.countdownButton.resumeTimer()
    }

    private lazy var fireButton = makeActionButton(
        title: "Fire",
        titleColor: .systemTeal,
        subtitle: "触发并销毁"
    ) { [weak self] _ in
        self?.startButton.fireTimerOnce()
        self?.countdownButton.fireTimerOnce()
    }

    private lazy var stopButton = makeActionButton(
        title: "停止",
        titleColor: .systemRed,
        subtitle: "销毁(无回调)"
    ) { [weak self] _ in
        self?.startButton.stopTimer()
        self?.countdownButton.stopTimer()
    }
    // MARK: - 说明 Fire 与 Stop 的区别
    private lazy var hintLabel: UILabel = {
        UILabel()
            .byText("Fire：触发回调后销毁定时器；\n停止：销毁但不触发回调。")
            .byFont(.systemFont(ofSize: 12))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.left)
            .byNumberOfLines(0)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(stopButton.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
    }()
    // MARK: - 倒计时演示按钮（同一套 API：传 total => 倒计时）
    private lazy var countdownButton: UIButton = {
        UIButton(type: .system)
            .byTitle("获取验证码", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemGreen, for: .normal)
            .onCountdownTick { [weak self] btn, remain, total, kind in
                guard let self else { return }
                print("⏱️ [\(kind.jobs_displayName)] \(remain)/\(total)")
                self.lastFireLabel.text = "Last: " + fmt(Date())
                btn.byTitle("还剩 \(remain)s", for: .normal)
            }
            .onCountdownFinish { _, kind in
                print("✅ [\(kind.jobs_displayName)] 倒计时完成")
            }
            // ✅ 让控制按钮跟随倒计时按钮的状态启用/禁用
            .onTimerStateChange { [weak self] _, _, newState in
                self?.updateControlButtons(by: newState)
            }
            .onTap { [weak self] btn in
                guard let self else { return }
                let total = self.parseCountdownTotal(10)
                btn.startTimer(
                    total: total, // 传 total => 倒计时
                    interval: self.intervalSec,
                    kind: self.currentKind
                )
                // 关键：等 startTimer 把 "10s" 设好后再加前缀，避免被覆盖
                DispatchQueue.main.async {
                    let cur = btn.title(for: .normal) ?? "\(total)s"
                    if !cur.hasPrefix("还剩 ") {
                        btn.byTitle("还剩 \(cur)", for: .normal)
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.hintLabel.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(50)
            }
    }()
    // MARK: - 布局（两排：开始 / 暂停-继续-Fire-停止）
    private func layoutButtons() {
        let totalWidth = UIScreen.main.bounds.width - horizontalInset * 2
        let itemWidth = (totalWidth - spacing * 3) / 4.0
        // 第一排：开始
        startButton.byAlpha(1)
        // 第二排：暂停 / 继续 / Fire / 停止
        for (i, btn) in [pauseButton, resumeButton, fireButton, stopButton].enumerated() {
            btn.byAddTo(view) { [unowned self] make in
                make.top.equalTo(startButton.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(horizontalInset + CGFloat(i) * (itemWidth + spacing))
                make.width.equalTo(itemWidth)
                make.height.greaterThanOrEqualTo(52)
            }
        }
        // 说明文字 + 倒计时按钮
        hintLabel.byAlpha(1)
        _ = countdownButton
    }
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "Timer Demo")

        _ = kindSelector
        _ = lastFireLabel
        _ = intervalField
        _ = countdownField

        layoutButtons()
        // 初始：按 idle 态渲染控制键
        updateControlButtons(by: .idle)
    }
    // MARK: - 工具：构造次级按钮
    private func makeActionButton(
        title: String,
        titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        titleColor: UIColor,
        subtitle: String? = nil,
        subtitleFont: UIFont = .systemFont(ofSize: 11, weight: .regular),
        subtitleColor: UIColor = UIColor.white.withAlphaComponent(0.85),
        _ action: @escaping (UIButton) -> Void
    ) -> UIButton {
        UIButton(type: .system)
            .byTitle(title, for: .normal)
            .byTitleFont(titleFont)
            .byTitleColor(.white, for: .normal)
            .byAdoptConfigurationIfAvailable()
            .bySubTitle(subtitle, for: .normal)
            .bySubTitleFont(subtitleFont, for: .normal)
            .bySubTitleColor(subtitleColor, for: .normal)
            .byBackgroundColor(titleColor, for: .normal)
            .byCornerRadius(8)
            .byMasksToBounds(true)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
            .onTap(action)
            .byAddTo(view) { make in
                make.height.greaterThanOrEqualTo(52)
            }
    }
    // MARK: - 步长解析 & 应用（commit=true 时，重建并沿用“当前模式+新步长+当前内核”）
    private func applyIntervalFromField(_ t: UITextField, commit: Bool) {
        let v = (t.text ?? "").trimmingCharacters(in: .whitespaces)
        if let x = Double(v), x > 0 {
            intervalSec = x
        } else {
            intervalSec = 1.0
            t.text = "1.0"
        }
        guard commit else { return }
        // 若 startButton / countdownButton 有在跑或暂停，则“停旧并重启”
        rebuildActiveTimersForNewInterval()
    }
    // MARK: - 在切换内核时，如果有正在运行/暂停的计时器，则“停旧并用新内核重启”
    private func rebuildActiveTimersForNewKind() {
        rebuild(button: startButton, keepModeFrom: startButton, newKind: currentKind)
        rebuild(button: countdownButton, keepModeFrom: countdownButton, newKind: currentKind)
    }
    // MARK: - 在修改步长时，如有活动计时器则重建为新步长
    private func rebuildActiveTimersForNewInterval() {
        rebuild(button: startButton, keepModeFrom: startButton, newKind: currentKind)
        rebuild(button: countdownButton, keepModeFrom: countdownButton, newKind: currentKind)
    }
    /// 读取某个按钮的当前模式（正/倒计时），用同样模式+新参数重启
    private func rebuild(button target: UIButton,
                         keepModeFrom src: UIButton,
                         newKind: JobsTimerKind) {
        guard let core = src.timer else { return }
        let isActive = core.isRunning || (src.timerState == .paused)
        guard isActive else { return }

        // 判断是否倒计时：通过标题是否含 “s” 很脆弱；更好的方式是业务侧自行记忆。
        // 这里用一个保守策略：若当前标题以 “s” 结尾并且是数字+s，视为倒计时，否则视为正计时。
        var isCountdown = false
        if let text = src.title(for: .normal), text.hasSuffix("s") {
            let numPart = text.dropLast()
            isCountdown = Int(numPart) != nil
        }

        src.stopTimer()
        if isCountdown {
            // 重新读峰值（你 UI 里有输入框）
            target.startTimer(total: parseCountdownTotal(10), interval: intervalSec, kind: newKind)
        } else {
            target.startTimer(total: nil, interval: intervalSec, kind: newKind)
        }
    }
    // MARK: - 控制键 UI（由 startButton 的 timerState 驱动）
    private func updateControlButtons(by state: TimerState) {
        func set(_ btn: UIButton, _ enabled: Bool, _ color: UIColor) {
            btn.byAlpha(enabled ? 1.0 : 0.5)
                .byUserInteractionEnabled(enabled)
                .byBackgroundColor(color, for: .normal)
                .bySetNeedsUpdateConfiguration()
        }
        switch state {
        case .idle, .stopped:
            set(startButton,  true,  .systemBlue)
            set(pauseButton,  false, .systemGray3)
            set(resumeButton, false, .systemGray3)
            set(fireButton,   false, .systemGray3)
            set(stopButton,   false, .systemGray3)
        case .running:
            set(startButton,  false, .systemGray3)
            set(pauseButton,  true,  .systemBlue)
            set(resumeButton, false, .systemGray3)
            set(fireButton,   true,  .systemTeal)
            set(stopButton,   true,  .systemRed)
        case .paused:
            set(startButton,  false, .systemGray3)
            set(pauseButton,  false, .systemGray3)
            set(resumeButton, true,  .systemBlue)
            set(fireButton,   true,  .systemTeal)
            set(stopButton,   true,  .systemRed)
        }
    }
    // MARK: - 工具
    private func parseCountdownTotal(_ time : Int) -> Int {
        let v = (countdownField.text ?? "").trimmingCharacters(in: .whitespaces)
        return max(1, Int(v) ?? time)
    }
}
