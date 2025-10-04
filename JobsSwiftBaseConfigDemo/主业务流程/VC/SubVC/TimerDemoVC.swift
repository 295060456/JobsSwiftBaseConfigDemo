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
//  通过协议统一「启动 / 暂停 / 继续 / 停止 / Fire(一次)」的外部能力；UI 层用状态机驱动交互与配色。
//
//  设计原则
//  -----------------------------------------------------------------------------
//  • 全部懒加载；控件/布局均在 VC 内部，便于调试与解耦。
//  • 统一链式 API：byXX / onJobsXX / byAddTo，读写一致。
//  • 框架与 UI 解耦：Timer 只负责时间信号；VC 以状态机（idle/running/paused/stopped）驱动 UI。
//  • 低入侵：不在框架中混入视图逻辑；仅提供组合方法 fireOnce() = stop() + fire()。
//  • 安全切换：切换定时器类型前，始终 stop() + 置空，避免资源泄漏或崩溃。
//
//  交互与状态
//  -----------------------------------------------------------------------------
//  • Start：进入 running；计数从 0 开始；运行期间“开始按钮标题 = 当前计数”。
//  • Pause：进入 paused；计数保持不变（开始按钮继续显示当前计数）。
//  • Resume：回到 running；计数继续累加。
//  • Fire：fireOnce()，触发一次回调并销毁定时器；UI 回到 stopped。
//  • Stop：销毁定时器但不触发回调；UI 回到 stopped。
//  • Segmented：在 NSTimer / GCD / DisplayLink / RunLoop 之间切换；切换前先 stop 旧实例。
//
//  布局与样式
//  -----------------------------------------------------------------------------
//  • 顶部 UISegmentedControl；下方显示最近触发时间 Last。
//  • 两行按钮：第一行只放“开始”（大按钮）；第二行 暂停/继续/Fire/停止 四等分，并与第一行左右对齐。
//  • 所有布局使用 SnapKit；按钮启用通过 alpha 控制 + isUserInteractionEnabled。
//  • 运行时删除“独立计数 Label”，直接用“开始按钮标题”显示当前计数（你要求）。
//
//  依赖
//  -----------------------------------------------------------------------------
//  • SnapKit
//  • 你的链式扩展（UIButton / UILabel / UISegmentedControl 的 byXX/onJobsXX/byAddTo）
//  • 框架层：JobsTimer 协议 + JobsTimerFactory + 各实现（协议扩展有 fireOnce()）
//

import UIKit
import SnapKit

final class TimerDemoVC: UIViewController {

    // MARK: - 状态机
    private enum UIState { case idle, running, paused, stopped }
    private var uiState: UIState = .idle { didSet { updateButtonStates() } }

    // MARK: - 定时器
    private var timer: JobsTimer?
    private var currentKind: JobsTimerKind = .gcd
    private var count = 0

    // MARK: - Segmented
    private lazy var kindSelector = UISegmentedControl(items: ["NSTimer", "GCD", "DisplayLink", "RunLoop"])
        .bySelectedSegmentIndex(1)
        .onJobsChange { [weak self] (seg: UISegmentedControl) in
            guard let self else { return }
            let mapping: [JobsTimerKind] = [.foundation, .gcd, .displayLink, .runLoopCore]
            let idx = max(0, min(seg.selectedSegmentIndex, mapping.count - 1))
            self.recreateTimer(with: mapping[idx])
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
            make.top.equalTo(self.kindSelector.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

    // MARK: - 按钮工厂（除“开始”外的普通按钮字体）
    private func makeActionButton(_ title: String,
                                  _ color: UIColor,
                                  _ action: @escaping (UIButton) -> Void) -> UIButton {
        UIButton(type: .system)
            .byTitle(title, for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold)) // 普通按钮字体
            .byBgColor(color)
            .byCornerRadius(8)
            .byMasksToBounds(true)
            .onJobsTap(action)
    }

    // MARK: - 开始按钮（单独字体、单独创建）
    private lazy var startButton: UIButton = {
        let btn = UIButton(type: .system)
            .byTitle("开始", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemBlue)
            .byCornerRadius(10)
            .byMasksToBounds(true)
        // 与其它按钮不同的字体（你要求）
        btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        // 点击
        btn.onJobsTap { [weak self] _ in
            guard let self else { return }
            count = 0
            // 运行期间标题显示计数
            startButton.setTitle("\(count)", for: .normal)
            lastFireLabel.text = "Last: -"
            timer?.start()
            uiState = .running
        }
        return btn
    }()

    private lazy var pauseButton = makeActionButton("暂停", .systemBlue) { [weak self] _ in
        self?.timer?.pause()
        self?.uiState = .paused
    }

    private lazy var resumeButton = makeActionButton("继续", .systemBlue) { [weak self] _ in
        self?.timer?.resume()
        self?.uiState = .running
    }

    private lazy var fireButton = makeActionButton("Fire 一次", .systemTeal) { [weak self] _ in
        // 触发一次 + 销毁定时器
        self?.timer?.fireOnce()
        self?.uiState = .stopped
    }

    private lazy var stopButton = makeActionButton("停止", .systemRed) { [weak self] _ in
        // 静默终止（不触发回调），销毁定时器
        self?.timer?.stop()
        self?.uiState = .stopped
    }

    // MARK: - 布局：两排对齐（开始 = 第一排；其余 4 个 = 第二排）
    private func layoutButtons() {
        let horizontalInset: CGFloat = 40
        let spacing: CGFloat = 12
        let totalWidth = UIScreen.main.bounds.width - horizontalInset * 2
        let itemWidth = (totalWidth - spacing * 3) / 4.0

        // 第一排：开始（与第二排整体左右对齐）
        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.top.equalTo(lastFireLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(horizontalInset)
            make.right.equalToSuperview().inset(horizontalInset)
            make.height.equalTo(56)
        }

        // 第二排：暂停/继续/Fire/停止（四等分）
        let buttons = [pauseButton, resumeButton, fireButton, stopButton]
        for (i, btn) in buttons.enumerated() {
            view.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.equalTo(startButton.snp.bottom).offset(18)
                make.left.equalToSuperview().offset(horizontalInset + CGFloat(i) * (itemWidth + spacing))
                make.width.equalTo(itemWidth)
                make.height.equalTo(44)
            }
        }
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "Timer Demo")

        _ = kindSelector
        _ = lastFireLabel
        layoutButtons()

        recreateTimer(with: currentKind)
        uiState = .idle
    }

    deinit { timer?.stop() }

    // MARK: - 定时器重建
    private func recreateTimer(with kind: JobsTimerKind) {
        timer?.stop()
        timer = nil
        currentKind = kind

        count = 0
        startButton.setTitle("开始", for: .normal) // 回到初态
        lastFireLabel.text = "Last: -"
        uiState = .idle

        let cfg = JobsTimerConfig(interval: 1.0, repeats: true, tolerance: 0.01, queue: .main)
        timer = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            count += 1
            // 运行期间，把“计数”显示在“开始按钮标题”上（你要求）
            startButton.setTitle("\(count)", for: .normal)
            lastFireLabel.text = "Last: " + Self.fmt(Date())
        }
    }

    // MARK: - 状态驱动（alpha + isUserInteractionEnabled）
    private func updateButtonStates() {
        func set(_ btn: UIButton, enabled: Bool, color: UIColor) {
            btn.alpha = enabled ? 1.0 : 0.5           // 你要求：外界用 alpha 唤起
            btn.isUserInteractionEnabled = enabled
            btn.backgroundColor = color
        }

        switch uiState {
        case .idle, .stopped:
            // 停止/初态：开始按钮标题恢复“开始”
            startButton.setTitle("开始", for: .normal)
            set(startButton,  enabled: true,  color: .systemBlue)
            set(pauseButton,  enabled: false, color: .systemGray3)
            set(resumeButton, enabled: false, color: .systemGray3)
            set(fireButton,   enabled: false, color: .systemGray3)
            set(stopButton,   enabled: false, color: .systemGray3)

        case .running:
            // running：开始按钮禁用，但标题持续显示“当前计数”
            set(startButton,  enabled: false, color: .systemGray3)
            set(pauseButton,  enabled: true,  color: .systemBlue)
            set(resumeButton, enabled: false, color: .systemGray3)
            set(fireButton,   enabled: true,  color: .systemTeal)
            set(stopButton,   enabled: true,  color: .systemRed)

        case .paused:
            // paused：开始按钮仍禁用，标题保持当前计数
            set(startButton,  enabled: false, color: .systemGray3)
            set(pauseButton,  enabled: false, color: .systemGray3)
            set(resumeButton, enabled: true,  color: .systemBlue)
            set(fireButton,   enabled: true,  color: .systemTeal)
            set(stopButton,   enabled: true,  color: .systemRed)
        }
    }

    private static func fmt(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: d)
    }
}
