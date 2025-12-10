//
//  JobsTimerBySysProcess.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

import Foundation
/// JobsTimer@系统倒计时进度条
public final class JobsCountdownProcess {
    deinit {
        cancel()
    }
    /// 进度模式：0 → 100（正向）或 100 → 0（反向）
    ///
    /// - `countUp`   : 0% 慢慢涨到 100%，适合“进度条”语义
    /// - `countDown` : 100% 慢慢掉到 0%，适合“剩余进度”语义
    public typealias ProgressMode = Snapshot.Mode
    /// 进度快照
    public struct Snapshot {
        /// 进度模式
        public enum Mode {
            /// 从 0% 到 100%（elapsed / total）
            case countUp
            /// 从 100% 到 0%（remaining / total）
            case countDown
        }
        /// 总倒计时（秒）
        public let total: TimeInterval
        /// 已经过去的时间（秒）
        public let elapsed: TimeInterval
        /// 剩余时间（秒）
        public var remaining: TimeInterval {
            max(0, total - elapsed)
        }
        /// 0.0 ~ 1.0：已经过去的比例（从 0% → 100%）
        public var elapsedRatio: Double {
            guard total > 0 else { return 1 }
            let ratio = elapsed / total
            return min(1, max(0, ratio))
        }
        /// 0.0 ~ 1.0：剩余比例（从 100% → 0%）
        public var remainingRatio: Double {
            1 - elapsedRatio
        }
        /// 兼容旧 API：等价于 `elapsedRatio`（0 → 1）
        public var progress: Double {
            elapsedRatio
        }
        /// 按给定模式返回进度值
        ///
        /// - `.countUp`   返回 0 → 1（已完成比例）
        /// - `.countDown` 返回 1 → 0（剩余比例）
        public func progress(for mode: Mode) -> Double {
            switch mode {
            case .countUp:
                return elapsedRatio
            case .countDown:
                return remainingRatio
            }
        }
    }
    /// 状态
    public enum State {
        case idle       // 初始
        case running    // 进行中
        case finished   // 正常完成
        case cancelled  // 手动取消
    }
    // MARK: - Public
    /// 当前状态
    public private(set) var state: State = .idle
    /// 当前快照
    public private(set) var snapshot: Snapshot
    /// 进度回调（每次 tick）
    public var onProgress: ((Snapshot) -> Void)?
    /// 完成回调（走到 100%）
    public var onFinished: ((Snapshot) -> Void)?
    /// 所使用的 JobsTimer 内核
    public let kind: JobsTimerKind
    /// tick 间隔（秒），默认 1/60，适合做顺滑动画
    public let tickInterval: TimeInterval
    /// 容差
    public let tolerance: TimeInterval
    /// 回调所在队列（更新 UI 就 .main）
    public let queue: DispatchQueue
    // MARK: - Private
    private var timer: JobsTimerProtocol?
    private var startDate: Date?
    // MARK: - Init
    /// - Parameters:
    ///   - duration: 倒计时总时长（秒）
    ///   - kind: 使用哪种 JobsTimer 内核，默认 DisplayLink
    ///   - tickInterval: tick 间隔，默认 1/60 秒
    ///   - tolerance: 时间容差，默认 0
    ///   - queue: 回调队列，默认 .main
    public init(duration: TimeInterval,
                kind: JobsTimerKind = .displayLink,
                tickInterval: TimeInterval = 1.0 / 60.0,
                tolerance: TimeInterval = 0,
                queue: DispatchQueue = .main) {
        let total = max(0, duration)
        self.snapshot = Snapshot(total: total, elapsed: 0)
        self.kind = kind
        self.tickInterval = tickInterval
        self.tolerance = tolerance
        self.queue = queue
    }
    // MARK: - 控制
    /// 开始倒计时（从 0 开始走一次）
    @discardableResult
    public func start() -> JobsCountdownProcess{
        if state == .running { return self }
        /// 如果想重复使用同一个实例，可以每次 start 前重置
        resetInternal()
        guard snapshot.total > 0 else {
            /// 特殊情况：总时长 <= 0 直接视作完成
            state = .finished
            onProgress?(snapshot)
            onFinished?(snapshot)
            return self
        }

        startDate = Date()
        state = .running

        let config = JobsTimerConfig(
            interval: tickInterval,
            repeats: true,
            tolerance: tolerance,
            queue: queue
        )

        let t = JobsTimerFactory.make(kind: kind, config: config) { [weak self] in
            guard let self else { return }
            guard state == .running else { return }
            guard let start = startDate else { return }

            let elapsed = Date().timeIntervalSince(start)
            let clampedElapsed = min(elapsed, snapshot.total)

            snapshot = Snapshot(total: snapshot.total, elapsed: clampedElapsed)
            // 进度回调
            onProgress?(snapshot)
            // 到点了
            if clampedElapsed >= snapshot.total {
                timer?.stop()
                timer = nil
                state = .finished
                onFinished?(snapshot)
            }
        }

        timer?.stop()
        timer = t
        t.start()
        // 起步的时候先回调一次 0 进度
        onProgress?(snapshot)
        return self
    }
    /// 手动取消倒计时（不触发 onFinished）
    public func cancel() {
        timer?.stop()
        timer = nil
        if state == .running {
            state = .cancelled
        }
    }
    /// 重置为初始状态（不自动 start）
    public func reset() {
        cancel()
        resetInternal()
    }
    // MARK: - Private
    private func resetInternal() {
        snapshot = Snapshot(total: snapshot.total, elapsed: 0)
        startDate = nil
        state = .idle
    }
}
// MARK: - DSL
public extension JobsCountdownProcess {
    /// 链式设置进度回调
    @discardableResult
    func byProgress(_ handler: @escaping (Snapshot) -> Void) -> Self {
        self.onProgress = handler
        return self
    }
    /// 链式设置完成回调
    @discardableResult
    func byFinished(_ handler: @escaping (Snapshot) -> Void) -> Self {
        self.onFinished = handler
        return self
    }
    /// 链式启动：start() 并返回自身
    @discardableResult
    func byStartRunning() -> Self {
        start()
        return self
    }
    /// 工厂 + 自动 start 的快捷 DSL
    ///
    /// 用法：
    /// let process = JobsCountdownProcess.byStart(
    ///     duration: 10,
    ///     onProgress: { snap in ... },
    ///     onFinished: { snap in ... }
    /// )
    @discardableResult
    static func byStart(duration: TimeInterval,
                        kind: JobsTimerKind = .displayLink,
                        tickInterval: TimeInterval = 1.0 / 60.0,
                        tolerance: TimeInterval = 0,
                        queue: DispatchQueue = .main,
                        onProgress: ((Snapshot) -> Void)? = nil,
                        onFinished: ((Snapshot) -> Void)? = nil) -> JobsCountdownProcess {
        let process = JobsCountdownProcess(
            duration: duration,
            kind: kind,
            tickInterval: tickInterval,
            tolerance: tolerance,
            queue: queue
        )
        process.onProgress = onProgress
        process.onFinished = onFinished
        process.start()
        return process
    }
}
