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
//  通过协议统一「启动 / 暂停 / 继续 / 停止 / Fire」；UI 用状态机驱动按钮可用与配色。
//  你要求：全部懒加载；链式 API（byXX / onJobsXX / byAddTo）；两排按钮；开始按钮在运行时显示当前计数；
//  可输入“步长”（interval），修改后立刻生效（重建定时器）；Fire 与 Stop 文案区分清楚。
//

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
//  通过协议统一「启动 / 暂停 / 继续 / 停止 / Fire」；UI 用状态机驱动按钮可用与配色。
//  你要求：全部懒加载；链式 API（byXX / onJobsXX / byAddTo）；两排按钮；开始按钮在运行时显示当前计数；
//  可输入“步长”（interval），修改后立刻生效（重建定时器）；Fire 与 Stop 文案区分清楚。
//  ✅ 新增：倒计时峰值输入框 + 倒计时演示按钮（Jobs风格）
//

import UIKit
import SnapKit

final class TimerDemoVC: UIViewController {
    let horizontalInset: CGFloat = 40
    let spacing: CGFloat = 12
    // MARK: - UI 状态机
    private enum UIState { case idle, running, paused, stopped }
    private var uiState: UIState = .idle { didSet { updateButtonStates() } }
    // MARK: - 定时器 & 配置
    // 属性
    private var timer: (any JobsTimerProtocol)?
    private var currentKind: JobsTimerKind = .gcd
    private var count = 0
    private var intervalSec: TimeInterval = 1.0   // 步长（秒），可在输入框修改
    // MARK: - Segmented（定时器实现选择）
    private lazy var kindSelector = UISegmentedControl(items: ["NSTimer", "GCD", "DisplayLink", "RunLoop"])
        .bySelectedSegmentIndex(1)
        .onJobsChange { [weak self] (seg: UISegmentedControl) in
            guard let self else { return }
            let mapping: [JobsTimerKind] = [.foundation, .gcd, .displayLink, .runLoopCore]
            let idx = max(0, min(seg.selectedSegmentIndex, mapping.count - 1))
            self.recreateTimer(with: mapping[idx])     // 切换实现 = 先停旧再建新
        }
        .byAddTo(view) { [unowned self] make in
            make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(40)
            make.height.equalTo(36)
        }
    // MARK: - 最近触发时间
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
        // 结束编辑后重建定时器（立刻生效）
        .onJobsEvent(.editingDidEnd) { [weak self] (tf: UITextField) in
            self?.applyIntervalFromField(tf, commit: true)
        }
    // MARK: - 倒计时峰值输入框（只允许输入数字）
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
    // MARK: - 按钮工厂（除“开始”外的其余四个）
    private func makeActionButton(
        title: String,
        titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        titleColor: UIColor,                              // 作为背景色使用
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
    // MARK: - 开始按钮
    private lazy var startButton: UIButton = {
        UIButton(type: .system)
            .byTitle("开始", for: .normal)
            .byTitleFont(.systemFont(ofSize: 22, weight: .bold))
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemBlue, for: .normal)
            .byCornerRadius(10)
            .byMasksToBounds(true)
            .onTap { [weak self] _ in
                guard let self else { return }
                self.recreateTimer(with: self.currentKind)
                count = 0
                startButton.setTitle("\(count)", for: .normal)
                lastFireLabel.text = "Last: -"
                timer?.start()
                uiState = .running
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(countdownField.snp.bottom).offset(14)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(56)
            }
    }()

    private lazy var pauseButton = makeActionButton(
        title: "暂停",
        titleFont: .systemFont(ofSize: 16, weight: .semibold),
        titleColor: .systemBlue,
        subtitle: "悬空"
    ) { [weak self] _ in
        self?.timer?.pause()
        self?.uiState = .paused
    }

    private lazy var resumeButton = makeActionButton(
        title: "继续",
        titleFont: .systemFont(ofSize: 16, weight: .semibold),
        titleColor: .systemBlue,
        subtitle: "恢复计时"
    ) { [weak self] _ in
        self?.timer?.resume()
        self?.uiState = .running
    }

    private lazy var fireButton = makeActionButton(
        title: "Fire",
        titleFont: .systemFont(ofSize: 16, weight: .semibold),
        titleColor: .systemTeal,
        subtitle: "触发并销毁"
    ) { [weak self] _ in
        self?.timer?.fireOnce()
        self?.uiState = .stopped
    }

    private lazy var stopButton = makeActionButton(
        title: "停止",
        titleFont: .systemFont(ofSize: 16, weight: .semibold),
        titleColor: .systemRed,
        subtitle: "销毁(无回调)"
    ) { [weak self] _ in
        self?.timer?.stop()
        self?.uiState = .stopped
    }
    // MARK: - 说明 Fire 与 Stop 的区别
    private lazy var hintLabel : UILabel = {
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
    // MARK: - 倒计时演示按钮
    private lazy var countdownButton: UIButton = {
        UIButton(type: .system)
            .byTitle("获取验证码", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemGreen, for: .normal)
            .onCountdownTick { btn, remain, total, kind in
                 log("⏱️ [\(kind.jobs_displayName)] \(remain)/\(total)")
             }
             .onCountdownFinish { btn, kind in
                 log("✅ [\(kind.jobs_displayName)] 倒计时完成")
             }
            .onTap { [weak self] btn in
                guard let self else { return }
                let total = self.parseCountdownTotal()   // 来自 countdownField
                let step  = self.intervalSec             // 来自 intervalField（你已有逻辑维护）
                let kind  = self.currentKind             // 来自 segmented
                btn.startJobsCountdown(total: total,
                                       interval: step,
                                       kind: kind)
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
        startButton.byAlpha(1)
        for (i, btn) in [pauseButton, resumeButton, fireButton, stopButton].enumerated() {
            btn.byAddTo(view) { [unowned self] make in
                make.top.equalTo(startButton.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(horizontalInset + CGFloat(i) * (itemWidth + spacing))
                make.width.equalTo(itemWidth)
                make.height.greaterThanOrEqualTo(52)
            }
        }
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
        recreateTimer(with: currentKind)
        uiState = .idle
    }
    deinit { timer?.stop() }
    // MARK: - 解析并应用“步长”输入
    private func applyIntervalFromField(_ t: UITextField, commit: Bool) {
        let v = (t.text ?? "").trimmingCharacters(in: .whitespaces)
        if let x = Double(v), x > 0 {
            intervalSec = x
        } else {
            intervalSec = 1.0
            t.text = "1.0"
        }
        if commit { recreateTimer(with: currentKind) }
    }
    // MARK: - 定时器重建（统一入口）
    private func recreateTimer(with kind: JobsTimerKind) {
        timer?.stop(); timer = nil; currentKind = kind
        count = 0
        startButton.setTitle("开始", for: .normal)
        lastFireLabel.text = "Last: -"
        uiState = .idle

        let cfg = JobsTimerConfig(interval: intervalSec, repeats: true, tolerance: 0.01, queue: .main)
        timer = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            count += 1
            startButton.setTitle("\(count)", for: .normal)
            lastFireLabel.text = "Last: " + Self.fmt(Date())
        }
    }
    // MARK: - 状态驱动按钮
    private func updateButtonStates() {
        func set(_ btn: UIButton, enabled: Bool, color: UIColor) {
            btn.byAlpha(enabled ? 1.0 : 0.5)
                .byUserInteractionEnabled(enabled)
                .byBackgroundColor(color, for: .normal)
                .bySetNeedsUpdateConfiguration()
        }
        switch uiState {
        case .idle, .stopped:
            startButton.setTitle("开始", for: .normal)
            set(startButton,  enabled: true,  color: .systemBlue)
            set(pauseButton,  enabled: false, color: .systemGray3)
            set(resumeButton, enabled: false, color: .systemGray3)
            set(fireButton,   enabled: false, color: .systemGray3)
            set(stopButton,   enabled: false, color: .systemGray3)
        case .running:
            set(startButton,  enabled: false, color: .systemGray3)
            set(pauseButton,  enabled: true,  color: .systemBlue)
            set(resumeButton, enabled: false, color: .systemGray3)
            set(fireButton,   enabled: true,  color: .systemTeal)
            set(stopButton,   enabled: true,  color: .systemRed)
        case .paused:
            set(startButton,  enabled: false, color: .systemGray3)
            set(pauseButton,  enabled: false, color: .systemGray3)
            set(resumeButton, enabled: true,  color: .systemBlue)
            set(fireButton,   enabled: true,  color: .systemTeal)
            set(stopButton,   enabled: true,  color: .systemRed)
        }
    }
    // MARK: - 工具
    /// 时间格式
    private static func fmt(_ d: Date) -> String {
        DateFormatter().byDateFormat("HH:mm:ss.SSS").string(from: d)
    }
    /// 解析倒计时峰值（只数字）
    private func parseCountdownTotal() -> Int {
        let v = (countdownField.text ?? "").trimmingCharacters(in: .whitespaces)
        let n = Int(v) ?? 0
        return max(1, n)           // 至少 1 秒
    }

}
