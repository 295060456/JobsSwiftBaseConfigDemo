//
//  JobsNetworkTrafficMonitor.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/17/25.
//

import Foundation
import Network
import Darwin
// MARK: - 数据源类型
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
// MARK: - 字节统计
private struct JobsNetworkBytes {
    let received: UInt64   // 下行总字节
    let sent: UInt64       // 上行总字节
}
/// 读取当前所有网络接口的总上下行字节（Wi-Fi + 蜂窝）
private func jobs_currentNetworkBytes() -> JobsNetworkBytes {
    var addrs: UnsafeMutablePointer<ifaddrs>?
    var totalIn: UInt64 = 0
    var totalOut: UInt64 = 0

    guard getifaddrs(&addrs) == 0, let firstAddr = addrs else {
        return JobsNetworkBytes(received: 0, sent: 0)
    }

    var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr

    while let ifa = ptr?.pointee {
        let flags = Int32(ifa.ifa_flags)
        // 只处理已启用的接口
        guard (flags & IFF_UP) == IFF_UP else {
            ptr = ifa.ifa_next
            continue
        }

        let name = String(cString: ifa.ifa_name)

        // en0 / en1... 通常是 Wi-Fi；pdp_ip0... 通常是蜂窝
        if name.hasPrefix("en") || name.hasPrefix("pdp_ip") {
            if let data = ifa.ifa_data?
                .assumingMemoryBound(to: if_data.self)
                .pointee {
                totalIn  += UInt64(data.ifi_ibytes)
                totalOut += UInt64(data.ifi_obytes)
            }
        }

        ptr = ifa.ifa_next
    }

    freeifaddrs(addrs)

    return JobsNetworkBytes(received: totalIn, sent: totalOut)
}
// MARK: - 监控类
final class JobsNetworkTrafficMonitor {
    static let shared = JobsNetworkTrafficMonitor()
    /// interval 秒内的上/下行速度（Bytes/s）
    var onUpdate: ((JobsNetworkSource, Double, Double) -> Void)?

    private let pathMonitor = NWPathMonitor()
    private let pathQueue = DispatchQueue(label: "jobs.network.path")
    private var timer: DispatchSourceTimer?
    private var lastBytes: JobsNetworkBytes?
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

    func start(interval: TimeInterval = 1.0) {
        stop()

        lastBytes = jobs_currentNetworkBytes()

        let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        t.schedule(deadline: .now() + interval, repeating: interval)

        t.setEventHandler { [weak self] in
            guard let self else { return }

            let now = jobs_currentNetworkBytes()

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

    func stop() {
        timer?.cancel()
        timer = nil
        lastBytes = nil
    }
}

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
// MARK: - 单位格式化
func jobs_formatSpeed(_ bytesPerSec: Double) -> String {
    if bytesPerSec < 1024 {
        return String(format: "%.0f B/s", bytesPerSec)
    } else if bytesPerSec < 1024 * 1024 {
        return String(format: "%.1f KB/s", bytesPerSec / 1024)
    } else {
        return String(format: "%.2f MB/s", bytesPerSec / 1024 / 1024)
    }
}
