//  JobsCountdownButton.swift
//  完整可复用的倒计时封装（含步长 interval）
//  ✅ 全面兼容 UIButton.Configuration 管线（不丢字、不丢色）

import UIKit

// ================================== 倒计时模型 ==================================
public enum JobsCountdownMode {
    case down(from: Int)
    case up(to: Int)

    var initialSecond: Int {
        switch self {
        case .down(let s): return s
        case .up: return 0
        }
    }

    func next(from cur: Int) -> (val: Int, finished: Bool) {
        switch self {
        case .down:
            let nv = max(cur - 1, 0)
            return (nv, nv == 0)
        case .up(let to):
            let nv = min(cur + 1, to)
            return (nv, nv == to)
        }
    }
}

// ================================== 文本输出（兼容老系统） ==================================
public enum JobsCountdownTitle {
    case plain(String)
    case rich(NSAttributedString)
}

@available(iOS 15.0, *)
fileprivate extension AttributedString {
    init(_ ns: NSAttributedString) { self = AttributedString(ns) }
}

// ================================== 计时内核（可插拔） ==================================
public protocol JobsTicker: AnyObject {
    var isRunning: Bool { get }
    func start(interval: TimeInterval, _ tick: @escaping () -> Void)
    func stop()
}

public final class DispatchTicker: JobsTicker {
    private var timer: DispatchSourceTimer?
    public private(set) var isRunning = false

    public init() {}

    public func start(interval: TimeInterval, _ tick: @escaping () -> Void) {
        stop()
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + interval, repeating: interval)
        t.setEventHandler(handler: tick)
        t.resume()
        timer = t
        isRunning = true
    }

    public func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }
}

public final class TimerTicker: JobsTicker {
    private var timer: Timer?
    public private(set) var isRunning = false

    public init() {}

    public func start(interval: TimeInterval, _ tick: @escaping () -> Void) {
        stop()
        let t = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        isRunning = true
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}

// ================================== 配置体 ==================================
public struct JobsCountdownConfig {
    public var mode: JobsCountdownMode = .down(from: 60)

    /// iOS15+：给你 “秒数 + 基线配置”，返回最终配置
    public var renderConfiguration: ((Int, UIButton.Configuration) -> UIButton.Configuration)?
    /// 老系统：返回字符串或富文本
    public var renderLegacy: ((Int) -> JobsCountdownTitle)?

    public var clickableWhileRunning: Bool = false
    public var affectEnabledProperty: Bool = true

    public var onTapWhileRunning: ((UIButton, JobsCountdownController) -> Void)?
    public var onStart:  ((UIButton, JobsCountdownController) -> Void)?
    public var onTick:   ((UIButton, JobsCountdownController, Int) -> Void)?
    public var onFinish: ((UIButton, JobsCountdownController) -> Void)?

    public var onPauseUI:  ((UIButton, JobsCountdownController, UIButton.Configuration) -> UIButton.Configuration)?
    public var onResumeUI: ((UIButton, JobsCountdownController, UIButton.Configuration) -> UIButton.Configuration)?

    public var tickerFactory: () -> JobsTicker = { DispatchTicker() }
    public var interval: TimeInterval = 1.0
    public var renderOnInit: Bool = false

    public init() {}
}

// ================================== 控制器 ==================================
public final class JobsCountdownController {
    private weak var button: UIButton?
    private var sec: Int
    private var cfg: JobsCountdownConfig
    private var ticker: JobsTicker!
    private var snapshot: UIButton.Configuration? // 保存初始样式

    public init(button: UIButton, config: JobsCountdownConfig) {
        self.button = button
        self.cfg = config
        self.sec = config.mode.initialSecond
        if #available(iOS 15.0, *) { self.snapshot = button.configuration }
        if cfg.renderOnInit { render(sec: sec) }
        applyEnabledPolicy(false)
    }

    public func start() {
        guard let btn = button else { return }
        cfg.onStart?(btn, self)
        render(sec: sec)
        ticker = cfg.tickerFactory()
        ticker.start(interval: cfg.interval) { [weak self] in
            guard let self else { return }
            let step = cfg.mode.next(from: self.sec)
            self.sec = step.val
            self.render(sec: self.sec)

            // ✅ 每次 Tick 打印
            print("🕒 倒计时运行中：sec = \(self.sec)")

            self.cfg.onTick?(btn, self, self.sec)
            if step.finished { self.stop(fireFinish: true) }
        }
        applyEnabledPolicy(true)
    }

    public func stop(fireFinish: Bool) {
        ticker?.stop()
        ticker = nil
        if fireFinish, let btn = button {
            cfg.onFinish?(btn, self)
        }
        applyEnabledPolicy(false)
    }

    public var isRunning: Bool { ticker?.isRunning ?? false }

    // MARK: - 状态控制
    private func applyEnabledPolicy(_ running: Bool) {
        guard let btn = button else { return }
        if cfg.clickableWhileRunning { return }
        if cfg.affectEnabledProperty {
            btn.isEnabled = !running
        } else {
            btn.isUserInteractionEnabled = !running
        }
    }

    // MARK: - UI 渲染
    fileprivate func render(sec: Int) {
        guard let btn = button else { return }

        if #available(iOS 15.0, *), let renderCfg = cfg.renderConfiguration {
            var base = btn.configuration ?? snapshot ?? .filled()
            // 🔒 保底：永远不丢文字 / 不丢颜色
            if base.baseForegroundColor == nil { base.baseForegroundColor = .white }
            if base.baseBackgroundColor == nil { base.baseBackgroundColor = .systemBlue }

            var newCfg = renderCfg(sec, base)

            let noTitle  = (newCfg.title?.isEmpty ?? true)
            let noAttr   = (newCfg.attributedTitle?.characters.isEmpty ?? true)
            if noTitle && noAttr { newCfg.title = "\(sec)s" }

            // 保证颜色仍存在
            if newCfg.baseForegroundColor == nil {
                newCfg.baseForegroundColor = base.baseForegroundColor ?? .white
            }

            btn.configuration = newCfg
            return
        }

        // 老系统 fallback
        if let make = cfg.renderLegacy {
            switch make(sec) {
            case .plain(let s): btn.setTitle(s, for: .normal)
            case .rich(let a):  btn.setAttributedTitle(a, for: .normal)
            }
        } else {
            btn.setTitle("\(sec)s", for: .normal)
        }
    }
}

// ================================== UIButton 接口 ==================================
private var kCountdownControllerKey: Void?

public extension UIButton {
    /// 配置倒计时控制器（一次性绑定）
    @discardableResult
    func byCountdown(_ build: (inout JobsCountdownConfig) -> Void) -> Self {
        var c = JobsCountdownConfig()
        build(&c)

        let ctl = JobsCountdownController(button: self, config: c)
        objc_setAssociatedObject(self, &kCountdownControllerKey, ctl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    /// 自动处理点击：未运行 → start；运行中 → stop 或自定义 onTapWhileRunning
    @discardableResult
    func byCountdownOnTapAuto() -> Self {
        addTarget(self, action: #selector(_jobs_countdownAutoTap), for: .touchUpInside)
        return self
    }

    @objc private func _jobs_countdownAutoTap() {
        guard let ctl = objc_getAssociatedObject(self, &kCountdownControllerKey) as? JobsCountdownController else { return }
        if ctl.isRunning {
            ctl.stop(fireFinish: false)
        } else {
            ctl.start()
        }
    }
}
