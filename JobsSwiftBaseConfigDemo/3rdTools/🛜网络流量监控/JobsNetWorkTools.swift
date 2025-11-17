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
// MARK: - 监听当前网络是否可用
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
// MARK: - 只关心蜂窝网络是否被限制
final class CellularPermissionMonitor {
    private let cellularData = CTCellularData()

    var onChanged: ((CTCellularDataRestrictedState) -> Void)?

    init() {
        cellularData.cellularDataRestrictionDidUpdateNotifier = { [weak self] state in
            DispatchQueue.main.async {
                self?.onChanged?(state)
            }
        }
    }
}
// MARK: - 获取当前总上传/下载字节
struct NetworkBytes {
    let received: UInt64   // 下行总字节数
    let sent: UInt64       // 上行总字节数
}

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
                totalIn += UInt64(data.ifi_ibytes)
                totalOut += UInt64(data.ifi_obytes)
            }
        }

        ptr = ifa.ifa_next
    }

    freeifaddrs(addrs)

    return NetworkBytes(received: totalIn, sent: totalOut)
}
// MARK: - 用定时器算“当前网速”
final class NetworkSpeedMonitor {

    private var timer: DispatchSourceTimer?
    private var lastBytes: NetworkBytes?

    /// 回调：上/下行速度（单位：Bytes/s）
    var onUpdate: ((Double, Double) -> Void)?

    func start(interval: TimeInterval = 1.0) {
        stop()

        lastBytes = currentNetworkBytes()

        let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        t.schedule(deadline: .now() + interval, repeating: interval)
        t.setEventHandler { [weak self] in
            guard let self else { return }
            let now = currentNetworkBytes()

            if let last = self.lastBytes {
                let deltaIn = Double(now.received &- last.received)
                let deltaOut = Double(now.sent &- last.sent)

                let downSpeed = deltaIn / interval   // Bytes/s
                let upSpeed   = deltaOut / interval  // Bytes/s

                DispatchQueue.main.async {
                    self.onUpdate?(upSpeed, downSpeed)
                }
            }

            self.lastBytes = now
        }
        t.resume()
        self.timer = t
    }

    func stop() {
        timer?.cancel()
        timer = nil
        lastBytes = nil
    }
}
