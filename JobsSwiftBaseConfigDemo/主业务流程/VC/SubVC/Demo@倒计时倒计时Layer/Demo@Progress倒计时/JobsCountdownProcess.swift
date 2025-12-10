//
//  JobsCountdownProcess.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

import Foundation
/// 纯逻辑倒计时过程，内部用 JobsTimer 驱动
public final class JobsCountdownProcess {
    /// 进度快照
    public struct Snapshot {
        /// 总倒计时（秒）
        public let total: TimeInterval
        /// 已经过去的时间（秒）
        public let elapsed: TimeInterval
        /// 剩余时间（秒）
        public var remaining: TimeInterval { max(0, total - elapsed) }
        /// 0.0 ~ 1.0 的进度值
        public var progress: Double {
            guard total > 0 else { return 1 }
            return min(1, max(0, elapsed / total))
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

    deinit {
        cancel()
    }

    // MARK: - 控制

    /// 开始倒计时（从 0 开始走一次）
    public func start() {
        // 防止重复开
        if state == .running { return }

        // 如果想重复使用同一个实例，可以每次 start 前重置
        resetInternal()

        guard snapshot.total > 0 else {
            // 特殊情况：总时长 <= 0 直接视作完成
            state = .finished
            onProgress?(snapshot)
            onFinished?(snapshot)
            return
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
            self?.handleTick()
        }

        timer?.stop()
        timer = t
        t.start()

        // 起步的时候先回调一次 0 进度
        onProgress?(snapshot)
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

    private func handleTick() {
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
}
