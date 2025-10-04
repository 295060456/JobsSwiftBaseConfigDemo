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
//  通过协议统一「启动 / 暂停 / 继续 / 停止 / Fire(一次)」；UI 用状态机驱动按钮可用与配色。
//  你要求：全部懒加载；链式 API（byXX / onJobsXX / byAddTo）；两排按钮；开始按钮在运行时显示当前计数；
//  可输入“步长”（interval），修改后立刻生效（重建定时器）；Fire 与 Stop 文案区分清楚。
//

import UIKit
import SnapKit

final class TimerDemoVC: UIViewController {

    // MARK: - UI 状态机
    private enum UIState { case idle, running, paused, stopped }
    private var uiState: UIState = .idle { didSet { updateButtonStates() } }

    // MARK: - 定时器 & 配置
    private var timer: JobsTimer?
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

    // MARK: - 按钮工厂（除“开始”外的其余四个）
    private func makeActionButton(
        title: String,
        titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        titleColor: UIColor,
        subtitle: String? = nil,
        subtitleFont: UIFont = .systemFont(ofSize: 11, weight: .regular),
        subtitleColor: UIColor = UIColor.white.withAlphaComponent(0.85),
        _ action: @escaping (UIButton) -> Void
    ) -> UIButton {
        let btn = UIButton(type: .system)
            .byTitle(title, for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(titleFont)
            // ✅ 确保进入 configuration 管线（subtitle/前景色/内边距才会完整生效）
            .byAdoptConfigurationIfAvailable()
            .bySubtitle(subtitle, color: subtitleColor, font: subtitleFont)
            .byBackgroundColor(titleColor, for: .normal)
            .byCornerRadius(8)
            .byMasksToBounds(true)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
            .onJobsTap(action)

        // 固定高度
        btn.snp.makeConstraints { $0.height.equalTo(44) }
        return btn
    }

    // MARK: - 开始按钮（独立大号字体 + 运行时显示计数）
    private lazy var startButton: UIButton = {
        let btn = UIButton(type: .system)
            .byTitle("开始", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemBlue, for: .normal)
            .byCornerRadius(10)
            .byMasksToBounds(true)
        btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)

        btn.onJobsTap { [weak self] _ in
            guard let self else { return }
            // 每次开始都以“当前步长 & 当前实现”重建，避免旧实例残留
            self.recreateTimer(with: self.currentKind)

            count = 0
            startButton.setTitle("\(count)", for: .normal)  // 运行时由按钮显示计数
            lastFireLabel.text = "Last: -"
            timer?.start()
            uiState = .running
        }
        return btn
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
        title: "Fire 一次",
        titleFont: .systemFont(ofSize: 16, weight: .semibold),
        titleColor: .systemTeal,
        subtitle: "触发并销毁"
    ) { [weak self] _ in
        self?.timer?.fireOnce()           // 触发一次 + 销毁
        self?.uiState = .stopped
    }

    private lazy var stopButton = makeActionButton(
        title: "停止",
        titleFont: .systemFont(ofSize: 16, weight: .semibold),
        titleColor: .systemRed,
        subtitle: "销毁(无回调)"
    ) { [weak self] _ in
        self?.timer?.stop()               // 静默销毁（不触发回调）
        self?.uiState = .stopped
    }

    // 说明 Fire 与 Stop 的区别
    private lazy var hintLabel = UILabel()
        .byText("Fire 一次：触发回调后销毁定时器；停止：销毁但不触发回调。")
        .byFont(.systemFont(ofSize: 12))
        .byTextColor(.secondaryLabel)
        .byTextAlignment(.center)

    // MARK: - 布局（两排：开始 / 暂停-继续-Fire-停止）
    private func layoutButtons() {
        let horizontalInset: CGFloat = 40
        let spacing: CGFloat = 12
        let totalWidth = UIScreen.main.bounds.width - horizontalInset * 2
        let itemWidth = (totalWidth - spacing * 3) / 4.0

        // 第一排：开始（左右与第二排整体对齐）
        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.top.equalTo(intervalField.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(horizontalInset)
            make.right.equalToSuperview().inset(horizontalInset)
            make.height.equalTo(56)
        }

        // 第二排：暂停 / 继续 / Fire / 停止（四等分）
        let buttons = [pauseButton, resumeButton, fireButton, stopButton]
        for (i, btn) in buttons.enumerated() {
            view.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.equalTo(startButton.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(horizontalInset + CGFloat(i) * (itemWidth + spacing))
                make.width.equalTo(itemWidth)
                make.height.equalTo(44)
            }
        }

        // 说明文字
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(stopButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "Timer Demo")

        _ = kindSelector
        _ = lastFireLabel
        _ = intervalField
        layoutButtons()

        recreateTimer(with: currentKind)  // 初次创建
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
        if commit {
            // ✅ 结束编辑后立即生效：重建定时器
            recreateTimer(with: currentKind)
        }
    }

    // MARK: - 定时器重建（统一入口）
    private func recreateTimer(with kind: JobsTimerKind) {
        timer?.stop()
        timer = nil
        currentKind = kind

        count = 0
        startButton.setTitle("开始", for: .normal)
        lastFireLabel.text = "Last: -"
        uiState = .idle

        let cfg = JobsTimerConfig(interval: intervalSec,
                                  repeats: true,
                                  tolerance: 0.01,
                                  queue: .main)
        timer = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            count += 1
            startButton.setTitle("\(count)", for: .normal)           // 运行时：开始按钮显示计数
            lastFireLabel.text = "Last: " + Self.fmt(Date())
        }
    }

    // MARK: - 状态驱动按钮
    private func updateButtonStates() {
        func set(_ btn: UIButton, enabled: Bool, color: UIColor) {
            btn.alpha = enabled ? 1.0 : 0.5     // 你要求：用 alpha 控制启用表现
            btn.isUserInteractionEnabled = enabled
            btn.backgroundColor = color
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
    private static func fmt(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: d)
    }
}
