//
//  JobsNetWorkTools.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/17/25.
//

import Foundation
import Darwin
import Network
import CoreTelephony
/// 🛜网络流量监控
// MARK: - 数据源类型（当前网络来源）
enum JobsNetworkSource {
    case wifi
    case cellular
    case other
    case none

    var displayName: String {
        switch self {
        case .wifi:     return "Wi-Fi"
        case .cellular: return "蜂窝"
        case .other:    return "其他"
        case .none:     return "无网络"
        }
    }
}
// MARK: - 获取当前总上传/下载字节（Wi-Fi + 蜂窝）
/// 总字节数：下行 / 上行
struct NetworkBytes {
    let received: UInt64   // 下行总字节数
    let sent: UInt64       // 上行总字节数
}
/// 读取当前所有网络接口的总上下行字节（只统计 UP 状态的 Wi-Fi / 蜂窝）
func currentNetworkBytes() -> NetworkBytes {
    var addrs: UnsafeMutablePointer<ifaddrs>?
    var totalIn: UInt64 = 0
    var totalOut: UInt64 = 0

    guard getifaddrs(&addrs) == 0, let firstAddr = addrs else {
        return NetworkBytes(received: 0, sent: 0)
    }

    var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr

    while let ifa = ptr?.pointee {
        let flags = Int32(ifa.ifa_flags)
        // 只算 UP 的接口
        guard (flags & IFF_UP) == IFF_UP else {
            ptr = ifa.ifa_next
            continue
        }

        let name = String(cString: ifa.ifa_name)

        // en0 / en1... 一般是 Wi-Fi，pdp_ip0... 一般是蜂窝
        if name.hasPrefix("en") || name.hasPrefix("pdp_ip") {
            if let data = ifa.ifa_data?.assumingMemoryBound(to: if_data.self).pointee {
                totalIn  += UInt64(data.ifi_ibytes)
                totalOut += UInt64(data.ifi_obytes)
            }
        }

        ptr = ifa.ifa_next
    }
    freeifaddrs(addrs)
    return NetworkBytes(received: totalIn, sent: totalOut)
}
// MARK: - 网络流量监控（来源 + 上下行速度）
/// 统一的网络流量监控：
/// - 每 interval 秒回调一次当前网络来源 + 上/下行速度（Bytes/s）
/// - 内部用 NWPathMonitor + getifaddrs 统计总字节差值
final class JobsNetworkTrafficMonitor {
    static let shared = JobsNetworkTrafficMonitor()
    /// 回调：当前来源 + 上/下行速度（Bytes/s）
    /// - source: 当前网络来源（Wi-Fi / 蜂窝 / 其他 / 无）
    /// - up: 上行速度（Bytes/s）
    /// - down: 下行速度（Bytes/s）
    var onUpdate: ((JobsNetworkSource, Double, Double) -> Void)?

    private let pathMonitor = NWPathMonitor()
    private let pathQueue = DispatchQueue(label: "jobs.network.path")
    private var timer: DispatchSourceTimer?
    private var lastBytes: NetworkBytes?
    private var currentSource: JobsNetworkSource = .none

    private init() {
        // 监听当前网络类型
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let source: JobsNetworkSource
            if path.status != .satisfied {
                source = .none
            } else if path.usesInterfaceType(.wifi) {
                source = .wifi
            } else if path.usesInterfaceType(.cellular) {
                source = .cellular
            } else {
                source = .other
            }

            DispatchQueue.main.async {
                self.currentSource = source
            }
        }
        pathMonitor.start(queue: pathQueue)
    }
    /// 开始定时统计网速，默认 1s 一次
    func start(interval: TimeInterval = 1.0) {
        stop()
        lastBytes = currentNetworkBytes()

        let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        t.schedule(deadline: .now() + interval, repeating: interval)

        t.setEventHandler { [weak self] in
            guard let self else { return }

            let now = currentNetworkBytes()

            guard let last = self.lastBytes else {
                self.lastBytes = now
                return
            }

            let deltaIn  = Double(now.received &- last.received)
            let deltaOut = Double(now.sent &- last.sent)

            let downSpeed = deltaIn / interval   // Bytes/s
            let upSpeed   = deltaOut / interval  // Bytes/s
            let source    = self.currentSource

            self.lastBytes = now

            DispatchQueue.main.async {
                self.onUpdate?(source, upSpeed, downSpeed)
            }
        }

        t.resume()
        timer = t
    }
    /// 停止监控
    func stop() {
        timer?.cancel()
        timer = nil
        lastBytes = nil
    }
}
// MARK: - DSL 风格链式封装
extension JobsNetworkTrafficMonitor {
    @discardableResult
    func byOnUpdate(_ block: @escaping (JobsNetworkSource, Double, Double) -> Void) -> Self {
        self.onUpdate = block
        return self
    }
    @discardableResult
    func byStart(interval: TimeInterval = 1.0) -> Self {
        start(interval: interval)
        return self
    }
}
// MARK: - 单位格式化（B/s -> KB/s / MB/s）
func jobs_formatSpeed(_ bytesPerSec: Double) -> String {
    if bytesPerSec < 1024 {
        return String(format: "%.0f B/s", bytesPerSec)
    } else if bytesPerSec < 1024 * 1024 {
        return String(format: "%.1f KB/s", bytesPerSec / 1024)
    } else {
        return String(format: "%.2f MB/s", bytesPerSec / 1024 / 1024)
    }
}
// MARK: - 监听当前网络是否可用（系统层）
/// 只关心「是否可以访问网络」：
/// - Wi-Fi / 蜂窝 任意一条满足即可
final class NetworkPermissionMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "jobs.network.monitor")
    /// canUseNetwork: 当前是否还能正常访问网络（true = 能，false = 不能）
    var onChanged: ((Bool) -> Void)?
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let canUseNetwork = (path.status == .satisfied)
            DispatchQueue.main.async {
                self?.onChanged?(canUseNetwork)
            }
        }
        monitor.start(queue: queue)
    }
    func stop() {
        monitor.cancel()
    }
}
// MARK: - 只关心蜂窝网络是否被限制（系统设置开关）
/// 只关心蜂窝权限：
/// - 依赖 CTCellularData 的 restrictedState
final class CellularPermissionMonitor {
    private let cellularData = CTCellularData()
    /// 回调当前蜂窝限制状态
    var onChanged: ((CTCellularDataRestrictedState) -> Void)?
    init() {
        cellularData.cellularDataRestrictionDidUpdateNotifier = { [weak self] state in
            DispatchQueue.main.async {
                self?.onChanged?(state)
            }
        }
    }
}
// MARK: - 兼容：只要网速，不关心网络来源的简单监控（可选）
/// 如果你有地方只想要「上下行网速」而不关心来源，
/// 可以用这个包装器，内部仍然复用 JobsNetworkTrafficMonitor.shared。
final class NetworkSpeedMonitor {
    private var timerInterval: TimeInterval = 1.0
    private var isStarted = false
    /// 回调：上/下行速度（单位：Bytes/s）
    var onUpdate: ((Double, Double) -> Void)?

    func start(interval: TimeInterval = 1.0) {
        timerInterval = interval
        isStarted = true

        JobsNetworkTrafficMonitor.shared
            .byOnUpdate { [weak self] _, up, down in
                guard let self, self.isStarted else { return }
                self.onUpdate?(up, down)
            }
            .byStart(interval: interval)
    }

    func stop() {
        isStarted = false
        JobsNetworkTrafficMonitor.shared.stop()
    }
}
// MARK: - 一次性：等到“真的有流量”再回调（典型用在蜂窝数据授权场景）
/// 用法场景：
/// 1、触发了一个需要蜂窝数据的网络请求；
/// 2、系统可能弹出「是否允许使用蜂窝数据」；
//// 3、你不关心弹窗，只关心：什么时候真的有字节进来；
/// 4、第一次探测到有数据流动（上行/下行任意一边 > 0）时回调 block，然后停止轮询。
final class JobsCellularDataReadyMonitor {

    static let shared = JobsCellularDataReadyMonitor()

    private let queue = DispatchQueue(label: "jobs.cellular.ready")
    private var timer: DispatchSourceTimer?
    private var lastBytes: NetworkBytes?
    private var isWaiting: Bool = false

    private init() {}

    /// 等到“有数据流动”之后仅回调一次。
    ///
    /// - Parameters:
    ///   - interval: 轮询间隔（秒），建议 0.5 ~ 1.0 之间
    ///   - timeout: 超时时间（可选；为 nil 则一直等）
    ///   - onReady: 第一次探测到有数据流动时触发（主线程回调）
    ///   - onTimeout: 超时仍无数据时触发（主线程回调，可选）
    func waitOnce(
        interval: TimeInterval = 0.5,
        timeout: TimeInterval? = nil,
        onReady: @escaping () -> Void,
        onTimeout: (() -> Void)? = nil
    ) {
        queue.async { [weak self] in
            guard let self else { return }

            // 已经在等，不重复启动（简单版本：一个 VC 一个 wait 就够了）
            if self.isWaiting { return }

            self.isWaiting = true
            self.lastBytes = currentNetworkBytes()
            let startTime = CFAbsoluteTimeGetCurrent()

            let t = DispatchSource.makeTimerSource(queue: self.queue)
            t.schedule(deadline: .now() + interval, repeating: interval)

            t.setEventHandler { [weak self] in
                guard let self else { return }

                let now = currentNetworkBytes()
                guard let last = self.lastBytes else {
                    self.lastBytes = now
                    return
                }

                let deltaIn  = now.received &- last.received
                let deltaOut = now.sent &- last.sent
                self.lastBytes = now
                // ✅ 核心：只要有任意一方向的字节增长，就认为“数据通了”
                if deltaIn > 0 || deltaOut > 0 {
                    self.stopLocked()
                    DispatchQueue.main.async {
                        onReady()
                    }
                    return
                }
                // 可选：超时兜底
                if let timeout = timeout {
                    let nowTime = CFAbsoluteTimeGetCurrent()
                    if nowTime - startTime >= timeout {
                        self.stopLocked()
                        if let onTimeout {
                            DispatchQueue.main.async {
                                onTimeout()
                            }
                        }
                    }
                }
            }

            self.timer = t
            t.resume()
        }
    }
    /// 主动取消等待（比如 VC 要销毁了）
    func cancel() {
        queue.async { [weak self] in
            self?.stopLocked()
        }
    }
    // MARK: - 内部清理（在 queue 上调用）
    private func stopLocked() {
        timer?.cancel()
        timer = nil
        lastBytes = nil
        isWaiting = false
    }
}
// DSL 风格封装一下，方便链式调用
extension JobsCellularDataReadyMonitor {
    /// 链式版本
    @discardableResult
    func byWaitOnce(
        interval: TimeInterval = 0.5,
        timeout: TimeInterval? = nil,
        onReady: @escaping () -> Void,
        onTimeout: (() -> Void)? = nil
    ) -> Self {
        waitOnce(interval: interval, timeout: timeout, onReady: onReady, onTimeout: onTimeout)
        return self
    }
}
/// 等到“有蜂窝流量实际跑起来”再调用 block。
/// - 内部：interval=0.5s，timeout=10s，超时只打印一行日志。
/// deinit { JobsCellularDataReadyMonitor.shared.cancel() }
func jobsWaitCellularDataReady(_ onReady: @escaping () -> Void) {
    JobsCellularDataReadyMonitor.shared
        .byWaitOnce(interval: 0.5, timeout: 10) {
            onReady()
        } onTimeout: {
            #if DEBUG
            print("⚠️ jobs_waitCellularDataReady: 10 秒内没有探测到任何上下行字节，可能用户点了“不允许”或网络异常。")
            #endif
        }
}
