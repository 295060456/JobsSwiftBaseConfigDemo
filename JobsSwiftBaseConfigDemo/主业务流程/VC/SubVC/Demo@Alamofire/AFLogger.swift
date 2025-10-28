//
//  AFLogger.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Alamofire

/// 事件监控 + cURL 打印 + 回灌 UI
/// - Swift 6 说明:
///   1) EventMonitor 要求 queue 至少 internal；不能 private
///   2) 本类通过 @unchecked Sendable 声明手动承诺线程安全；并把 emit 包装成 @Sendable 闭包
final class AFLogger: EventMonitor {

    // 必须至少 internal，满足 EventMonitor 协议要求
    let queue = DispatchQueue(label: "af.logger.queue")

    // Swift 6: 闭包需要是 @Sendable；同时我们用一个 wrapper 进行桥接
    private let emit: (@Sendable (String) -> Void)?

    /// 注意：这里入参仍然允许你传普通闭包 (String)->Void
    /// 我们在内部包装成 @Sendable，避免调用点被 Swift 6 卡住
    init(emit: ((String) -> Void)?) {
        if let e = emit {
            self.emit = { text in e(text) }
        } else {
            self.emit = nil
        }
    }

    // MARK: - EventMonitor
    func requestDidResume(_ request: Request) {
        let head = "➡️ [AF] \(request.description)"
        let curl = request.cURLDescription()
        emit?([head, curl].joined(separator: "\n"))
    }

    func request(_ request: DataRequest,
                 didParseResponse response: DataResponse<Data?, AFError>) {
        var lines: [String] = []
        lines.append("AF Response: \(response.response?.statusCode ?? -1)")
        if let headers = response.response?.allHeaderFields as? [String: Any] {
            lines.append("Headers: \(headers)")
        }
        if let data = response.data, !data.isEmpty,
           let body = String(data: data, encoding: .utf8) {
            lines.append("Body: \(body)")
        }
        emit?(lines.joined(separator: "\n"))
    }

    func request(_ request: DownloadRequest, didFinishDownloadingTo url: URL) {
        emit?("⬇️ Download saved to: \(url.path)")
    }
}

// Swift 6：手动声明并发安全性（我们只在自建串行 queue 上触发 emit）
// 如果你更想“完全规避”，也可以把 AFLogger 改成 actor，并把 emit 标注为 nonisolated(unsafe)
extension AFLogger: @unchecked Sendable {}
