//
//  Plugins.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Moya

// MARK: - 把 cURL 也喂回 UI
public struct CurlLoggerPlugin: PluginType {
    private let emit: ((String) -> Void)?

    public init(emit: ((String) -> Void)? = nil) {
        self.emit = emit
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        guard let req = request.request else { return }
        let head = "➡️ [Moya] \(req.httpMethod ?? "") \(req.url?.absoluteString ?? "")"
        let curl = req.cURLDescription()
        if let emit { emit(head + "\n" + curl) }
        else { print(head); print(curl) }
    }
}

private extension URLRequest {
    func cURLDescription() -> String {
        var comps = ["curl -v"]
        if let method = httpMethod { comps.append("-X \(method)") }
        (allHTTPHeaderFields ?? [:]).forEach { k, v in comps.append("-H '\(k): \(v)'") }
        if let body = httpBody, let s = String(data: body, encoding: .utf8), !s.isEmpty {
            comps.append("--data '\(s)'")
        }
        comps.append("'\(url?.absoluteString ?? "")'")
        return comps.joined(separator: " \\\n  ")
    }
}

// MARK: - 每接口超时：在真正发起前改 URLRequest（仍保留）
public struct TimeoutPlugin: PluginType {
    public init() {}
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var r = request
        if let api = target as? DemoAPI { r.timeoutInterval = api.timeout }
        return r
    }
}

