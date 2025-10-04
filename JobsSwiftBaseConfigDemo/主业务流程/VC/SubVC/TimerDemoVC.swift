
//
//  TimerDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  概要
//  -----------------------------------------------------------------------------
//  一个统一演示定时器实现差异与一致 API 的示例控制器。
//  支持四种实现：Foundation.Timer / DispatchSourceTimer(GCD) / CADisplayLink / CFRunLoopTimer。
//  通过协议统一「启动 / 暂停 / 继续 / 停止 / Fire(一次)」的外部能力；UI 层用状态机驱动交互与配色。
//
//  设计原则
//  -----------------------------------------------------------------------------
//  • 全部懒加载；控件/布局均在 VC 内部，便于调试与解耦。
//  • 统一链式 API：byXX / onJobsXX / byAddTo / UIStackView(byAxis/bySpacing/…)，可读性强。
//  • 框架与 UI 解耦：Timer 只负责时间信号；VC 以状态机（idle/running/paused/stopped）驱动 UI。
//  • 低入侵：不在框架中混入视图逻辑；仅提供组合方法 fireOnce() = stop() + fire()。
//  • 安全切换：切换定时器类型前，始终 stop() + 置空，避免资源泄漏或崩溃。
//
//  交互与状态
//  -----------------------------------------------------------------------------
//  • Start：进入 running；计数清零后从 0 开始累加。
//  • Pause：进入 paused；计数保持不变。
//  • Resume：回到 running；继续累加。
//  • Fire：调用 fireOnce()，仅触发一次回调并停止；UI 回到 stopped（与 Stop 语义区分）。
//  • Stop：停止并复位；计数与显示归零。
//  • Segmented：在 NSTimer / GCD / DisplayLink / RunLoop 之间切换；切换即销毁旧实例再创建新实例。
//
//  布局与样式
//  -----------------------------------------------------------------------------
//  • 顶部 UISegmentedControl（选择实现）。
//  • 信息区：计数 Label + 最近触发时间 Last。
//  • 操作区：按钮纵向排列（开始 / 暂停 / 继续 / Fire一次 / 停止），按钮采用圆角填充背景；
//    根据状态自动切换可点与配色（蓝=可操作，灰=禁用，红=终止，青=一次触发）。
//  • 所有布局使用 SnapKit；栈视图使用 UIStackView 扩展方法（byAxis/bySpacing/…）。
//
//  依赖
//  -----------------------------------------------------------------------------
//  • SnapKit（布局）
//  • 你的链式扩展：UIButton/UILabel/UISegmentedControl/UIStackView 等（byXX/onJobsXX）
//  • 框架层：JobsTimer 协议 + JobsTimerFactory + 各实现；协议扩展提供 fireOnce() 默认实现。
//

import UIKit
import SnapKit

final class TimerDemoVC: UIViewController {

    // MARK: - UI State
    private enum UIState { case idle, running, paused, stopped }
    private var uiState: UIState = .idle { didSet { updateButtonStates() } }

    private var timer: JobsTimer?
    private var currentKind: JobsTimerKind = .gcd
    private var count = 0

    // MARK: - Segmented
    private lazy var kindSelector: UISegmentedControl = {
        UISegmentedControl(items: ["NSTimer","GCD","DisplayLink","RunLoop"])
            .bySelectedSegmentIndex(1)
            .onJobsChange { [weak self] (seg: UISegmentedControl) in
                guard let self else { return }
                let kind: JobsTimerKind = {
                    switch seg.selectedSegmentIndex {
                    case 0: return .foundation
                    case 1: return .gcd
                    case 2: return .displayLink
                    default: return .runLoopCore
                    }
                }()
                self.recreateTimer(with: kind)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().inset(40)
                make.height.equalTo(36)
            }
    }()

    // MARK: - Labels
    private lazy var countLabel: UILabel = {
        UILabel()
            .byText("计数：0")
            .byFont(.systemFont(ofSize: 22, weight: .medium))
            .byTextAlignment(.center)
            .byTextColor(.systemBlue)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.kindSelector.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
            }
    }()

    private lazy var lastFireLabel: UILabel = {
        UILabel()
            .byText("Last: -")
            .byFont(.monospacedDigitSystemFont(ofSize: 14, weight: .regular))
            .byTextColor(.secondaryLabel)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.countLabel.snp.bottom).offset(6)
                make.centerX.equalToSuperview()
            }
    }()

    // MARK: - Buttons 工厂
    private func makeButton(_ title: String, _ color: UIColor) -> UIButton {
        let b = UIButton(type: .system)
            .byTitle(title, for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
        b.backgroundColor = color
        b.layer.cornerRadius = 8
        b.layer.masksToBounds = true
        b.snp.makeConstraints { $0.height.equalTo(44) }
        return b
    }

    // MARK: - Buttons
    private lazy var startButton = makeButton("开始", .systemBlue)
        .onJobsTap { [weak self] (_: UIButton) in
            guard let self else { return }
            self.count = 0
            self.countLabel.text = "计数：0"
            self.lastFireLabel.text = "Last: -"
            self.timer?.start()
            self.uiState = .running
        }

    private lazy var pauseButton = makeButton("暂停", .systemBlue)
        .onJobsTap { [weak self] (_: UIButton) in
            guard let self else { return }
            self.timer?.pause()
            self.uiState = .paused
        }

    private lazy var resumeButton = makeButton("继续", .systemBlue)
        .onJobsTap { [weak self] (_: UIButton) in
            guard let self else { return }
            self.timer?.resume()
            self.uiState = .running
        }

    private lazy var fireButton = makeButton("Fire 一次", .systemTeal)
        .onJobsTap { [weak self] (_: UIButton) in
            guard let self else { return }
            self.timer?.fireOnce()           // stop + fire
            self.uiState = .stopped
        }

    private lazy var stopButton = makeButton("停止", .systemRed)
        .onJobsTap { [weak self] (_: UIButton) in
            guard let self else { return }
            self.timer?.stop()
            self.uiState = .stopped
        }

    // MARK: - 两行按钮（StackView）
    private lazy var buttonStack1: UIStackView = {
        UIStackView()
            .byAxis(.horizontal)
            .byAlignment(.fill)
            .byDistribution(.fillEqually)
            .bySpacing(12)
            .addArrangedSubviews(startButton, pauseButton, resumeButton)
    }()

    private lazy var buttonStack2: UIStackView = {
        UIStackView()
            .byAxis(.horizontal)
            .byAlignment(.fill)
            .byDistribution(.fillEqually)
            .bySpacing(12)
            .addArrangedSubviews(fireButton, stopButton)
    }()

    // MARK: - Fire/Stop 说明（⚠️ 约束到 buttonStack2，而不是 stopButton）
    private lazy var hintLabel: UILabel = {
        UILabel()
            .byText("Fire 一次：立即执行一次回调并结束\n停止：终止计时并清零")
            .byFont(.systemFont(ofSize: 13, weight: .regular))
            .byTextColor(.secondaryLabel)
            .byTextAlignment(.center)
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "Toast Demo"
        )
        // 先确保 stack 被加入到同一层级
        _ = kindSelector; _ = countLabel; _ = lastFireLabel
        view.addSubview(buttonStack1)
        view.addSubview(buttonStack2)

        buttonStack1.snp.makeConstraints {
            $0.top.equalTo(lastFireLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(40)
        }
        buttonStack2.snp.makeConstraints {
            $0.top.equalTo(buttonStack1.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(80)
        }

        // 再把 hintLabel 加到 view，并锚定到 buttonStack2 底部（同一层级，避免崩溃）
        view.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(buttonStack2.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        recreateTimer(with: currentKind)
        uiState = .idle
    }

    deinit { timer?.stop() }

    // MARK: - Timer 重建
    private func recreateTimer(with kind: JobsTimerKind) {
        timer?.stop()
        timer = nil
        currentKind = kind

        count = 0
        countLabel.text = "计数：0"
        lastFireLabel.text = "Last: -"
        uiState = .idle

        let cfg = JobsTimerConfig(interval: 1.0, repeats: true, tolerance: 0.01, queue: .main)
        timer = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            self.count += 1
            self.countLabel.text = "计数：\(self.count)"
            self.lastFireLabel.text = "Last: " + Self.fmt(Date())
        }
    }

    // MARK: - 状态驱动按钮
    private func updateButtonStates() {
        func set(_ btn: UIButton, _ enabled: Bool, _ color: UIColor) {
            btn.isEnabled = enabled
            btn.backgroundColor = color
            btn.alpha = enabled ? 1 : 0.6
        }
        switch uiState {
        case .idle, .stopped:
            count = 0
            countLabel.text = "计数：0"
            set(startButton,  true,  .systemBlue)
            set(pauseButton,  false, .systemGray3)
            set(resumeButton, false, .systemGray3)
            set(fireButton,   false, .systemGray3)   // 未开始时禁用 Fire
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

    private static func fmt(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: d)
    }
}
