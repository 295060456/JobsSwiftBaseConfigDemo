//
//  APIService.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Moya
import Alamofire

public final class APIService {
    public let provider: MoyaProvider<DemoAPI>
    public init(provider: MoyaProvider<DemoAPI>) { self.provider = provider }
}

// MARK: - 工厂：live / stubbed 都支持把日志回灌到 UI
public extension APIService {
    /// live：真实网络
    static func live(uiLog: ((String) -> Void)? = nil) -> APIService {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: config)

        let endpointClosure: (DemoAPI) -> Endpoint = { target in
            Endpoint(url: URL(target: target).absoluteString,
                     sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                     method: target.method,
                     task: target.task,
                     httpHeaderFields: target.headers)
        }

        // 注意：这里的参数是 Endpoint（不是 Target）
        let requestClosure: MoyaProvider<DemoAPI>.RequestClosure = { endpoint, done in
            do {
                let req = try endpoint.urlRequest()
                done(.success(req)) // 超时交给 TimeoutPlugin
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }

        // —— 日志重定向到 UI —— //
        let output: NetworkLoggerPlugin.Configuration.OutputType = { _, items in
            uiLog?(items.joined(separator: "\n"))
        }
        let logger = NetworkLoggerPlugin(
            configuration: .init(formatter: .init(),
                                 output: output,
                                 logOptions: .verbose) // 包含响应体
        )
        let curl = CurlLoggerPlugin(emit: uiLog)
        let token = AccessTokenPlugin { _ in TokenStore.shared.accessToken ?? "" }

        let provider = MoyaProvider<DemoAPI>(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: { _ in .never },
            session: session,
            plugins: [logger, curl, token, TimeoutPlugin()]
        )
        return APIService(provider: provider)
    }

    /// stubbed：本地桩
    static func stubbed(uiLog: ((String) -> Void)? = nil) -> APIService {
        let output: NetworkLoggerPlugin.Configuration.OutputType = { _, items in
            uiLog?(items.joined(separator: "\n"))
        }
        let logger = NetworkLoggerPlugin(
            configuration: .init(formatter: .init(),
                                 output: output,
                                 logOptions: .verbose)
        )
        let curl = CurlLoggerPlugin(emit: uiLog)

        let provider = MoyaProvider<DemoAPI>(
            stubClosure: { _ in .delayed(seconds: 0.3) },
            plugins: [logger, curl, TimeoutPlugin()]
        )
        return APIService(provider: provider)
    }
}

// MARK: - 401 -> 刷新 Token -> 重放一次
public extension APIService {
    func requestWithAutoRefresh(_ target: DemoAPI,
                                retryOnce: Bool = true,
                                completion: @escaping (Result<Response, MoyaError>) -> Void) {
        provider.request(target) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let resp) where resp.statusCode == 401 && retryOnce:
                self.refreshToken { ok in
                    if ok { self.provider.request(target, completion: completion) }
                    else  { completion(.success(resp)) }
                }
            default:
                completion(result)
            }
        }
    }

    private func refreshToken(_ done: @escaping (Bool) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            TokenStore.shared.accessToken = "NEW_TOKEN"
            done(true)
        }
    }
}
