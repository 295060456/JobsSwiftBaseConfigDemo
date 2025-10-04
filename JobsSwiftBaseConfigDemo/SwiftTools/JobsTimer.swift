//
//  JobsTimer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

import Foundation
import QuartzCore // CADisplayLink
import UIKit      // 为了 Demo 中 UI 用途；纯框架层不依赖 UIKit 也可

// ================================== 配置体 ==================================
public struct JobsTimerConfig {
    /// 周期（秒）。对 CADisplayLink：<=0 表示每帧触发；>0 表示逐帧节流到每 interval 触发一次
    public let interval: TimeInterval
    /// 是否重复（false = 单次）
    public let repeats: Bool
    /// 容差（Timer/CFRunLoopTimer 原生支持；GCD 用 leeway；DisplayLink 作为节流阈值）
    public let tolerance: TimeInterval
    /// 最终回调派发队列（统一行为，避免实现差异）
    public let queue: DispatchQueue

    public init(interval: TimeInterval,
                repeats: Bool = true,
                tolerance: TimeInterval = 0,
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
public enum JobsTimerKind {
    case foundation    // Foundation.Timer
    case gcd           // DispatchSourceTimer
    case displayLink   // CADisplayLink
    case runLoopCore   // CFRunLoopTimerRef
}

public enum JobsTimerFactory {
    public static func make(kind: JobsTimerKind,
                            config: JobsTimerConfig,
                            handler: @escaping () -> Void) -> JobsTimer {
        switch kind {
        case .foundation:
            return FoundationTimerBox(config: config, handler: handler)
        case .gcd:
            return GCDTimerBox(config: config, handler: handler)
        case .displayLink:
            return DisplayLinkTimerBox(config: config, handler: handler)
        case .runLoopCore:
            return RunLoopCoreTimerBox(config: config, handler: handler)
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
