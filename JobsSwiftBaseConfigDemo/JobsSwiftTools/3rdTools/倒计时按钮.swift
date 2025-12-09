//
//  倒计时按钮.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import ObjectiveC
// MARK: - 公共配置体
@available(iOS 15.0, *)
public struct JobsCountdownButtonConfig {
    public enum Mode {
        /// 60 -> 59 -> ... -> 0
        case down(from: Int)
        /// 0 -> 1 -> ... -> to
        case up(to: Int)
    }
    /// 计时模式（默认 60s 倒计时）
    public var mode: Mode = .down(from: 60)
    /// 定时器间隔（秒），默认 1s
    public var interval: TimeInterval = 1.0
    /// 使用哪种 JobsTimer 内核，默认 GCD
    public var timerKind: JobsTimerKind = .gcd
    /// 容忍误差，直接透传给 JobsTimerConfig
    public var tolerance: TimeInterval = 0.01
    /// 是否在 `start()` 时先渲染一次初始值（例如：立刻显示 “60s”）
    public var renderOnInit: Bool = true
    /// 计时过程中是否允许点击
    public var clickableWhileRunning: Bool = false
    /// 渲染 UIButton.Configuration
    /// - 参数 sec: 当前秒数（向下时是“剩余秒数”，向上时是“已经走过的 step 数”）
    /// - 参数 base: 启动计时前的基础 configuration（已 copy）
    public var renderConfiguration: ((Int, UIButton.Configuration) -> UIButton.Configuration)?
    /// 每 tick 回调
    public var onTick: ((_ button: UIButton,
                         _ config: JobsCountdownButtonConfig,
                         _ sec: Int) -> Void)?
    /// 计时结束回调（已经自动复原 configuration & isEnabled）
    public var onFinish: ((_ button: UIButton,
                           _ config: JobsCountdownButtonConfig) -> Void)?

    /// 运行中被点击（仅当 clickableWhileRunning = true 时才会触发）
    public var onTapWhileRunning: ((_ button: UIButton,
                                    _ config: JobsCountdownButtonConfig) -> Void)?
    public init() { }
}
// MARK: - 内部控制器
@available(iOS 15.0, *)
final class JobsCountdownBtnCtrl {

    weak var button: UIButton?
    var config: JobsCountdownButtonConfig

    private var timer: JobsTimerProtocol?
    private(set) var isRunning: Bool = false

    private var current: Int = 0       // up 模式下：已走步数；down 模式下：剩余秒数
    private let baseConfiguration: UIButton.Configuration

    init(button: UIButton, config: JobsCountdownButtonConfig) {
        self.button = button
        self.config = config
        self.baseConfiguration = button.configuration ?? .plain()

        // 只是初始化，不自动开跑
        if config.renderOnInit {
            current = initialValue()
            applyRender(sec: current)
        }
    }

    deinit {
        timer?.stop()
        timer = nil
    }
    // MARK: - 对外控制
    func start() {
        guard let btn = button else { return }
        // 先停掉旧的
        stop(resetUI: false)

        current = initialValue()
        if config.renderOnInit {
            applyRender(sec: current)
        }

        // 不允许点击就直接禁用按钮
        if !config.clickableWhileRunning {
            btn.isEnabled = false
        }

        let tConfig = JobsTimerConfig(
            interval: config.interval,
            repeats: true,
            tolerance: config.tolerance,
            queue: .main
        )
        // 基于 JobsTimerFactory 统一出定时器内核
        timer = JobsTimerFactory.make(
            kind: config.timerKind,
            config: tConfig,
            handler: { [weak self] in
                self?.onTick()
            }
        )
        timer?.start()
        isRunning = true
    }

    func stop(resetUI: Bool = true) {
        isRunning = false
        timer?.stop()
        timer = nil

        guard let btn = button else { return }
        btn.isEnabled = true
        if resetUI {
            btn.configuration = baseConfiguration
        }
    }
    // MARK: - 内部流程
    private func initialValue() -> Int {
        switch config.mode {
        case .down(let from): return from
        case .up:             return 0
        }
    }

    private func onTick() {
        guard let btn = button else {
            stop(resetUI: false)
            return
        }

        switch config.mode {
        case .down:
            current -= 1
            let sec = max(0, current)
            applyRender(sec: sec)
            config.onTick?(btn, config, sec)

            if sec <= 0 {
                finish()
            }

        case .up(let to):
            current += 1
            let sec = min(to, current)
            applyRender(sec: sec)
            config.onTick?(btn, config, sec)

            if sec >= to {
                finish()
            }
        }
    }

    private func applyRender(sec: Int) {
        guard let btn = button else { return }
        var cfg = btn.configuration ?? baseConfiguration
        if let renderer = config.renderConfiguration {
            cfg = renderer(sec, cfg)
        }
        btn.configuration = cfg
    }

    private func finish() {
        guard let btn = button else {
            stop(resetUI: false)
            return
        }

        stop(resetUI: true)
        config.onFinish?(btn, config)
    }
}
// MARK: - UIButton 关联对象 & DSL
@available(iOS 15.0, *)
private var jobsCountdownControllerKey: UInt8 = 0
@available(iOS 15.0, *)
private extension UIButton {
    var jobsCountdownController: JobsCountdownBtnCtrl? {
        get {
            objc_getAssociatedObject(self, &jobsCountdownControllerKey) as? JobsCountdownBtnCtrl
        }
        set {
            objc_setAssociatedObject(self,
                                     &jobsCountdownControllerKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
@available(iOS 15.0, *)
public extension UIButton {
    typealias JobsCountdownConfigBuilder = (inout JobsCountdownButtonConfig) -> Void
    /// 配置倒计时（不会立刻绑定点击行为，也不会自动 start）
    @discardableResult
    func byCountdown(_ builder: JobsCountdownConfigBuilder) -> Self {
        var cfg = JobsCountdownButtonConfig()
        builder(&cfg)
        // 覆盖旧 controller
        let controller = JobsCountdownBtnCtrl(button: self, config: cfg)
        self.jobsCountdownController = controller
        return self
    }
    /// 把「点击按钮」和「启动倒计时」自动绑定起来
    @discardableResult
    func byCountdownOnTapAuto() -> Self {
        let action = UIAction { [weak self] _ in
            guard let self = self,
                  let ctrl = self.jobsCountdownController
            else { return }

            if ctrl.isRunning {
                // 正在跑
                if ctrl.config.clickableWhileRunning {
                    ctrl.config.onTapWhileRunning?(self, ctrl.config)
                } else {
                    // 不可点就直接吞掉点击
                }
            } else {
                // 未运行 -> 开始
                ctrl.start()
            }
        }
        self.addAction(action, for: .touchUpInside)
        return self
    }
    /// 手动停止并复原 UI
    func jobsStopCountdown() {
        jobsCountdownController?.stop(resetUI: true)
    }
}
