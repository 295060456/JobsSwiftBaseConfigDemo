//
//  JobsTimer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

import Foundation
import QuartzCore // CADisplayLink
import UIKit      // 为了 Demo 中 UI 用途；纯框架层不依赖 UIKit 也可
import QuartzCore

// ================================== 配置体 ==================================
public struct JobsTimerConfig {
    /// 🔁 每次触发的时间间隔（秒）
    public var interval: TimeInterval
    /// ♻️ 是否重复执行。若为 `false`，触发一次后即自动销毁
    public var repeats: Bool
    /// ⚙️ 允许系统在此范围内微调触发时间，以提升能效与系统同步性
    public var tolerance: TimeInterval
    /// 🧵 执行回调的目标队列
    /// - 通常为 `.main`（UI 更新）
    /// - 也可使用自定义队列执行后台任务
    public var queue: DispatchQueue
    /// 初始化配置
    ///
    /// - Parameters:
    ///   - interval: 每次触发的间隔秒数（默认 1.0）
    ///   - repeats: 是否重复执行（默认 true）
    ///   - tolerance: 允许系统延迟的容忍度（默认 0.01）
    ///   - queue: 执行回调的队列（默认 .main）
    public init(interval: TimeInterval = 1.0,
                repeats: Bool = true,
                tolerance: TimeInterval = 0.01,
                queue: DispatchQueue = .main) {
        self.interval = interval
        self.repeats = repeats
        self.tolerance = tolerance
        self.queue = queue
    }
}
// ================================== 协议 ==================================
public protocol JobsTimer: AnyObject {
    func start()
    func pause()
    func resume()
    func stop()
    func fire()
    var isRunning: Bool { get }
    var isPaused: Bool  { get }
}

public extension JobsTimer {
    /// fireOnce：立即触发一次回调并终止定时器
    func fireOnce() {
        stop()
        fire()
    }
}
// ================================== 工厂 & 类型 ==================================
public enum JobsTimerKind: String, CaseIterable {
    case foundation     // Foundation.Timer
    case gcd            // DispatchSourceTimer
    case displayLink    // CADisplayLink
    case runLoopCore    // CFRunLoopTimer
}
// MARK: 显示名
public extension JobsTimerKind {
    var jobs_displayName: String {
        switch self {
        case .foundation:   return "NSTimer"
        case .gcd:          return "GCD"
        case .displayLink:  return "DisplayLink"
        case .runLoopCore:  return "RunLoop"
        }
    }
}

final class JobsFoundationTimer: JobsTimerProtocol {
    private var timer: Timer?
    private let config: JobsTimerConfig
    private var handler: () -> Void
    private var tickBlock: (() -> Void)?
    private var finishBlock: (() -> Void)?
    private(set) var isRunning = false

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.handler = handler
    }

    func start() {
        stop()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: config.interval,
                                     repeats: config.repeats) { [weak self] _ in
            guard let self else { return }
            self.handler()
            self.tickBlock?()
        }
        timer?.tolerance = config.tolerance
        RunLoop.current.add(timer!, forMode: .common)
    }

    func pause() {
        guard let timer else { return }
        timer.fireDate = .distantFuture
        isRunning = false
    }

    func resume() {
        guard let timer else { return }
        timer.fireDate = .distantPast
        isRunning = true
    }

    func fireOnce() {
        handler()
        tickBlock?()
        stop()
        finishBlock?()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    @discardableResult
    func onTick(_ block: @escaping () -> Void) -> Self {
        tickBlock = block
        return self
    }

    @discardableResult
    func onFinish(_ block: @escaping () -> Void) -> Self {
        finishBlock = block
        return self
    }
}
// MARK: - GCD (DispatchSourceTimer)
final class JobsGCDTimer: JobsTimerProtocol {
    // ==== config & state ====
    private let config: JobsTimerConfig
    private var source: DispatchSourceTimer?
    private var suspended = false
    private(set) var isRunning: Bool = false

    // ==== callbacks ====
    private var tickHandlers: [() -> Void] = []
    private var finishHandlers: [() -> Void] = []

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.tickHandlers.append(handler)
    }

    // MARK: JobsTimerProtocol
    func start() {
        stop() // 清旧
        isRunning = true

        let q = config.queue
        let s = DispatchSource.makeTimerSource(queue: q)
        let ivNs = UInt64(max(0.0001, config.interval) * 1_000_000_000)

        s.schedule(
            deadline: .now() + .nanoseconds(Int(ivNs)),
            repeating: .nanoseconds(Int(ivNs)),
            leeway: .nanoseconds(Int(max(0, config.tolerance) * 1_000_000_000))
        )
        s.setEventHandler { [weak self] in
            guard let self, self.isRunning else { return }
            self.tickHandlers.forEach { $0() }
            if !self.config.repeats {
                self.finishHandlers.forEach { $0() }
                self.stop()
            }
        }
        s.resume()
        source = s
        suspended = false
    }

    func pause() {
        guard let s = source, !suspended else { return }
        isRunning = false
        s.suspend()
        suspended = true
    }

    func resume() {
        guard let s = source, suspended else { return }
        isRunning = true
        s.resume()
        suspended = false
    }

    func fireOnce() {
        tickHandlers.forEach { $0() }
        finishHandlers.forEach { $0() }
        stop()
    }

    func stop() {
        isRunning = false
        guard let s = source else { return }
        if suspended { s.resume() } // cancel 前需 resumed
        s.cancel()
        source = nil
        suspended = false
    }

    @discardableResult
    func onTick(_ block: @escaping () -> Void) -> Self {
        tickHandlers.append(block); return self
    }

    @discardableResult
    func onFinish(_ block: @escaping () -> Void) -> Self {
        finishHandlers.append(block); return self
    }
}
// MARK: - CADisplayLink
final class JobsDisplayLinkTimer: JobsTimerProtocol {
    private let config: JobsTimerConfig
    private var link: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var accumulator: CFTimeInterval = 0
    private(set) var isRunning: Bool = false

    private var tickHandlers: [() -> Void] = []
    private var finishHandlers: [() -> Void] = []

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.tickHandlers.append(handler)
    }

    func start() {
        stop()
        isRunning = true
        accumulator = 0
        lastTimestamp = 0

        let l = CADisplayLink(target: self, selector: #selector(onTickInternal(_:)))
        if #available(iOS 15.0, *), config.interval > 0 {
            let fpsInt = max(1, min(120, Int(round(1.0 / config.interval))))
            l.preferredFrameRateRange = CAFrameRateRange(
                minimum:  Float(1),
                maximum:  Float(120),
                preferred: Float(fpsInt)
            )
        } else if l.responds(to: #selector(getter: CADisplayLink.preferredFramesPerSecond)),
                  config.interval > 0 {
            l.preferredFramesPerSecond = max(1, min(120, Int(round(1.0 / config.interval))))
        }
        l.add(to: .main, forMode: .common)
        link = l
    }

    func pause() {
        isRunning = false
        link?.isPaused = true
    }

    func resume() {
        isRunning = true
        link?.isPaused = false
        lastTimestamp = 0
        accumulator = 0
    }

    func fireOnce() {
        tickHandlers.forEach { $0() }
        finishHandlers.forEach { $0() }
        stop()
    }

    func stop() {
        isRunning = false
        link?.invalidate()
        link = nil
        accumulator = 0
        lastTimestamp = 0
    }

    @discardableResult
    func onTick(_ block: @escaping () -> Void) -> Self {
        tickHandlers.append(block); return self
    }

    @discardableResult
    func onFinish(_ block: @escaping () -> Void) -> Self {
        finishHandlers.append(block); return self
    }

    @objc private func onTickInternal(_ l: CADisplayLink) {
        guard isRunning else { return }
        if lastTimestamp == 0 { lastTimestamp = l.timestamp; return }
        let dt = l.timestamp - lastTimestamp
        lastTimestamp = l.timestamp
        accumulator += dt

        let iv = max(0.0001, config.interval)
        if accumulator + 1e-6 >= iv {
            accumulator = config.repeats ? (accumulator - iv) : 0
            tickHandlers.forEach { $0() }
            if !config.repeats {
                finishHandlers.forEach { $0() }
                stop()
            }
        }
    }
}
// MARK: - CFRunLoopTimer
final class JobsRunLoopTimer: JobsTimerProtocol {
    private let config: JobsTimerConfig
    private var rlTimer: CFRunLoopTimer?
    private(set) var isRunning: Bool = false

    private var tickHandlers: [() -> Void] = []
    private var finishHandlers: [() -> Void] = []

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.tickHandlers.append(handler)
    }

    func start() {
        stop()
        isRunning = true

        let interval = max(0.0001, config.interval)
        let timer = CFRunLoopTimerCreateWithHandler(
            kCFAllocatorDefault,
            CFAbsoluteTimeGetCurrent() + interval,
            config.repeats ? interval : 0,
            0, 0
        ) { [weak self] _ in
            guard let self, self.isRunning else { return }
            self.config.queue.async {
                self.tickHandlers.forEach { $0() }
                if !self.config.repeats {
                    self.finishHandlers.forEach { $0() }
                    self.stop()
                }
            }
        }
        CFRunLoopTimerSetTolerance(timer, max(0, config.tolerance))
        CFRunLoopAddTimer(CFRunLoopGetMain(), timer, .commonModes)
        rlTimer = timer
    }

    func pause() {
        guard let t = rlTimer else { return }
        isRunning = false
        CFRunLoopTimerSetNextFireDate(t, .infinity)
    }

    func resume() {
        guard let t = rlTimer else { return }
        isRunning = true
        CFRunLoopTimerSetNextFireDate(t, CFAbsoluteTimeGetCurrent() + max(0.0001, config.interval))
    }

    func fireOnce() {
        tickHandlers.forEach { $0() }
        finishHandlers.forEach { $0() }
        stop()
    }

    func stop() {
        isRunning = false
        if let t = rlTimer {
            CFRunLoopTimerInvalidate(t)
            rlTimer = nil
        }
    }

    @discardableResult
    func onTick(_ block: @escaping () -> Void) -> Self {
        tickHandlers.append(block); return self
    }

    @discardableResult
    func onFinish(_ block: @escaping () -> Void) -> Self {
        finishHandlers.append(block); return self
    }
}

public enum JobsTimerFactory {
    public static func make(kind: JobsTimerKind,
                            config: JobsTimerConfig,
                            handler: @escaping () -> Void) -> any JobsTimerProtocol {
        switch kind {
        case .foundation:   return JobsFoundationTimer(config: config, handler: handler)
        case .gcd:          return JobsGCDTimer(config: config, handler: handler)
        case .displayLink:  return JobsDisplayLinkTimer(config: config, handler: handler)
        case .runLoopCore:  return JobsRunLoopTimer(config: config, handler: handler)
        }
    }
}
// ================================== 共享状态机基类 ==================================
fileprivate class BaseTimerState {
    enum State { case idle, running, paused, stopped }
    private let lock = DispatchQueue(label: "jobs.timer.state.lock", qos: .utility)
    private var _state: State = .idle

    var state: State {
        get { lock.sync { _state } }
        set { lock.sync { _state = newValue } }
    }
    var isRunning: Bool { state == .running }
    var isPaused:  Bool { state == .paused  }
    var isStopped: Bool { state == .stopped }
}
// MARK: - 实现一：Foundation.Timer
fileprivate final class FoundationTimerBox: BaseTimerState, JobsTimer {
    private let config: JobsTimerConfig
    private let handler: () -> Void
    private weak var runLoop: RunLoop?
    private var timer: Timer?

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.handler = handler
        self.runLoop = .main
        super.init()
    }

    deinit { stop() }

    func start() {
        guard !isRunning else { return }
        makeTimerIfNeeded()
        guard let timer else { return }
        timer.tolerance = config.tolerance
        runLoop?.add(timer, forMode: .common)
        state = .running
    }

    func pause() {
        guard isRunning, let timer else { return }
        timer.fireDate = .distantFuture
        state = .paused
    }

    func resume() {
        guard isPaused, let timer else { return }
        timer.fireDate = Date().addingTimeInterval(config.interval)
        state = .running
    }

    func stop() {
        guard !isStopped else { return }
        timer?.invalidate()
        timer = nil
        state = .stopped
    }

    func fire() {
        config.queue.async { [handler] in handler() }
    }

    private func makeTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer(timeInterval: config.interval, repeats: config.repeats) { [weak self] _ in
            guard let self else { return }
            self.config.queue.async { self.handler() }
            if !self.config.repeats { self.stop() }
        }
    }
}
// MARK: - 实现二：DispatchSourceTimer (GCD)
fileprivate final class GCDTimerBox: BaseTimerState, JobsTimer {
    private let config: JobsTimerConfig
    private let handler: () -> Void

    private var source: DispatchSourceTimer?
    private var suspended = false
    private let lock = DispatchQueue(label: "jobs.timer.gcd.lock", qos: .utility)

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.handler = handler
        super.init()
    }

    deinit { stop() }

    func start() {
        guard !isRunning else { return }
        makeSourceIfNeeded()
        guard let source else { return }

        let ms = max(1, Int(config.interval * 1000))
        let repeating: DispatchTimeInterval = config.repeats ? .milliseconds(ms) : .never
        let deadline: DispatchTime = .now() + .milliseconds(ms)
        let leeway: DispatchTimeInterval = .nanoseconds(Int(max(config.tolerance, 0) * 1_000_000_000))

        source.schedule(deadline: deadline, repeating: repeating, leeway: leeway)

        // ✅ 必须先恢复，否则不会触发
        safeResume()
        state = .running
    }

    func pause() {
        guard isRunning else { return }
        safeSuspend()
        state = .paused
    }

    func resume() {
        guard isPaused else { return }
        safeResume()
        state = .running
    }

    func stop() {
        guard !isStopped else { return }
        lock.sync {
            guard let src = source else { state = .stopped; return }
            if suspended { src.resume(); suspended = false } // ✅ 取消前确保已恢复
            src.setEventHandler {}
            src.cancel()
            source = nil
            state = .stopped
        }
    }

    func fire() {
        config.queue.async { [handler] in handler() }
    }

    private func makeSourceIfNeeded() {
        guard source == nil else { return }
        let src = DispatchSource.makeTimerSource(queue: config.queue)
        src.setEventHandler { [weak self] in
            guard let self else { return }
            self.handler()
            if !self.config.repeats { self.stop() }
        }
        source = src
        suspended = true // ✅ 新建即挂起
    }

    private func safeSuspend() {
        lock.sync {
            guard let src = source, !suspended else { return }
            src.suspend()
            suspended = true
        }
    }

    private func safeResume() {
        lock.sync {
            guard let src = source, suspended else { return }
            src.resume()
            suspended = false
        }
    }
}

// MARK: - 实现三：CADisplayLink (逐帧；可按 interval 节流)
fileprivate final class DisplayLinkTimerBox: BaseTimerState, JobsTimer {
    private let config: JobsTimerConfig
    private let handler: () -> Void

    private var link: CADisplayLink?
    private var acc: CFTimeInterval = 0

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.handler = handler
        super.init()
    }

    deinit { stop() }

    func start() {
        guard !isRunning else { return }
        if link == nil {
            let l = CADisplayLink(target: self, selector: #selector(tick))
            l.add(to: .main, forMode: .common)
            if #available(iOS 15.0, *) {
                // 不强制指定，交给系统；如需自定义示例：120Hz 机型优先 120fps
                // l.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
                l.preferredFrameRateRange = CAFrameRateRange(minimum: 0, maximum: 0, preferred: 0) // 使用系统默认
            } else {
                // iOS < 15 可用这个（0 表示跟随系统）
                l.preferredFramesPerSecond = 0
            }
            link = l
        }
        link?.isPaused = false
        state = .running
    }

    func pause() {
        guard isRunning else { return }
        link?.isPaused = true
        state = .paused
    }

    func resume() {
        guard isPaused else { return }
        link?.isPaused = false
        state = .running
    }

    func stop() {
        guard !isStopped else { return }
        link?.invalidate()
        link = nil
        acc = 0
        state = .stopped
    }

    func fire() {
        config.queue.async { [handler] in handler() }
    }

    @objc private func tick(_ dl: CADisplayLink) {
        if config.interval <= 0 {
            dispatchAndMaybeStop()
            return
        }
        acc += dl.duration
        if acc + config.tolerance >= config.interval {
            acc = 0
            dispatchAndMaybeStop()
        }
    }

    private func dispatchAndMaybeStop() {
        config.queue.async { [handler] in handler() }
        if !config.repeats { stop() }
    }
}

// MARK: - 实现四：CFRunLoopTimerRef (+ 可选 RunLoop Observer)
fileprivate final class RunLoopCoreTimerBox: BaseTimerState, JobsTimer {
    private let config: JobsTimerConfig
    private let handler: () -> Void

    private var timer: CFRunLoopTimer?
    private weak var runLoop: RunLoop? = .main
    private var observer: CFRunLoopObserver?

    init(config: JobsTimerConfig, handler: @escaping () -> Void) {
        self.config = config
        self.handler = handler
        super.init()
    }

    deinit { stop() }

    func start() {
        guard !isRunning else { return }
        if timer == nil { createTimer() }
        guard let t = timer else { return }
        CFRunLoopAddTimer(runLoop?.getCFRunLoop() ?? CFRunLoopGetMain(), t, CFRunLoopMode.commonModes)
        attachObserverIfNeeded()
        state = .running
    }

    func pause() {
        guard isRunning, let t = timer else { return }
        // ⚠️ CFAbsoluteTime 是 Double，不能用 .distantFuture
        CFRunLoopTimerSetNextFireDate(t, Double.greatestFiniteMagnitude)
        state = .paused
    }

    func resume() {
        guard isPaused, let t = timer else { return }
        // 下一次 = now + interval（做最小钳制，避免 0）
        let next = CFAbsoluteTimeGetCurrent() + max(config.interval, 0.001)
        CFRunLoopTimerSetNextFireDate(t, next)
        state = .running
    }

    func stop() {
        guard !isStopped else { return }
        if let t = timer {
            CFRunLoopTimerInvalidate(t)
            CFRunLoopRemoveTimer(runLoop?.getCFRunLoop() ?? CFRunLoopGetMain(), t, CFRunLoopMode.commonModes)
            timer = nil
        }
        if let obs = observer {
            CFRunLoopRemoveObserver(runLoop?.getCFRunLoop() ?? CFRunLoopGetMain(), obs, CFRunLoopMode.commonModes)
            observer = nil
        }
        state = .stopped
    }

    func fire() {
        config.queue.async { [handler] in handler() }
    }

    private func createTimer() {
        let iv = max(config.interval, 0.001)
        let start = CFAbsoluteTimeGetCurrent() + iv
        let info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let cb: CFRunLoopTimerCallBack = { _, ctx in
            guard let ctx else { return }
            let me = Unmanaged<RunLoopCoreTimerBox>.fromOpaque(ctx).takeUnretainedValue()
            me.config.queue.async { me.handler() }
            if !me.config.repeats { me.stop() }
        }

        var context = CFRunLoopTimerContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)

        let t = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                     start,
                                     config.repeats ? iv : 0,
                                     0, 0, cb, &context)
        CFRunLoopTimerSetTolerance(t, config.tolerance)
        timer = t
    }

    private func attachObserverIfNeeded() {
        guard observer == nil else { return }
        // 可根据需求更改观察阶段
        let activities: CFRunLoopActivity = [.beforeWaiting, .afterWaiting]
        let obs = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                     activities.rawValue,
                                                     true, 0) { _, _ in
            // 这里留空，必要时可做统计/自检，不要阻塞
        }
        CFRunLoopAddObserver(runLoop?.getCFRunLoop() ?? CFRunLoopGetMain(), obs, CFRunLoopMode.commonModes)
        observer = obs
    }
}
