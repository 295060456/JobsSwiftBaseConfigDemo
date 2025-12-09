//
//  AFService.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Alamofire
import Combine

final class AFService {
    enum Mode { case live, stubbed }

    let session: Session
    private let logger: AFLogger
    private let interceptor: RequestInterceptor

    init(mode: Mode = .live, uiLog: ((String) -> Void)? = nil) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20

        // stubbed: 走 URLProtocol
        if mode == .stubbed {
            config.protocolClasses = [AFStubURLProtocol.self]
            AFStubURLProtocol.handler = { req in
                guard let url = req.url else { return nil }
                switch (url.host, url.path) {
                case ("api.github.com", "/zen"):
                    return (200, ["Content-Type":"text/plain; charset=utf-8"], AFRoute.ghZen.sampleData)
                case let ("api.github.com", p) where p.hasPrefix("/users/"):
                    return (200, ["Content-Type":"application/json"], AFRoute.ghUser(username: "").sampleData)
                case ("api.github.com", "/search/users"):
                    return (200, ["Content-Type":"application/json"], AFRoute.ghSearchUsers(q: "", page: nil).sampleData)
                case ("reqres.in", "/api/login"):
                    return (200, ["Content-Type":"application/json"], AFRoute.login(email: "", password: "").sampleData)
                case ("httpbin.org", "/post"):
                    return (200, ["Content-Type":"application/json"], AFRoute.uploadAvatar(Data()).sampleData)
                case ("httpbin.org", "/image/png"):
                    return (200, ["Content-Type":"image/png"], Data())
                default:
                    return (404, ["Content-Type":"application/json"],
                            #"{"message":"stub not found"}"#.data(using: .utf8)!)
                }
            }
        }

        // Token 注入 + 401 重试
        let tokenAdapter = TokenRetryInterceptor()
        self.interceptor = tokenAdapter

        self.logger = AFLogger(emit: uiLog)
        self.session = Session(configuration: config,
                               interceptor: tokenAdapter,
                               eventMonitors: [logger])
    }

    // MARK: - Data Request (闭包风格)
    func request(_ route: AFRoute, jobsByVoidBlock: @escaping (Result<Data, AFError>) -> Void) {
        session.request(route)
            .validate()
            .responseData { resp in jobsByVoidBlock(resp.result) }
    }

    // MARK: - Upload (multipart) + Progress
    func uploadAvatar(_ route: AFRoute, imageData: Data,
                      progress: ((Double) -> Void)?,
                      jobsByVoidBlock: @escaping (Result<Data, AFError>) -> Void) {
        session.upload(multipartFormData: { mfd in
            mfd.append(imageData, withName: "file",
                       fileName: "avatar.jpg",
                       mimeType: "image/jpeg")
        }, with: route)
        .uploadProgress { p in progress?(p.fractionCompleted) }
        .validate()
        .responseData { resp in jobsByVoidBlock(resp.result) }
    }

    // MARK: - Download + Progress
    func download(_ route: AFRoute,
                  progress: ((Double) -> Void)?,
                  jobsByVoidBlock: @escaping (Result<URL, AFError>) -> Void) {
        session.download(route, to: route.destination)
            .downloadProgress { p in progress?(p.fractionCompleted) }
            .validate()
            .responseURL { resp in
                switch resp.result {
                case .success(let url): jobsByVoidBlock(.success(url))
                case .failure(let err): jobsByVoidBlock(.failure(err))
                }
            }
    }

    // MARK: - Combine（可选）
    @available(iOS 13.0, *)
    func publisherString(_ route: AFRoute) -> AnyPublisher<String, AFError> {
        session.request(route)
            .validate()
            .publishString()
            .value()
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}

// MARK: - Token 注入 + 401 自动刷新重放
final class TokenRetryInterceptor: RequestInterceptor {
    private let lock = NSLock()
    private var isRefreshing = false
    private var waiters: [(Bool) -> Void] = []

    // 注入 Authorization
    func adapt(_ urlRequest: URLRequest, for session: Session, jobsByVoidBlock: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        if let token = TokenStore.shared.accessToken, !token.isEmpty {
            req.headers.add(.authorization(bearerToken: token))
        }
        jobsByVoidBlock(.success(req))
    }

    // 401 -> 刷新一次 -> 重放
    func retry(_ request: Request, for session: Session, dueTo error: Error,
               jobsByVoidBlock: @escaping (RetryResult) -> Void) {
        guard
            let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401
        else { jobsByVoidBlock(.doNotRetry); return }

        lock.lock()
        defer { lock.unlock() }

        waiters.append { ok in jobsByVoidBlock(ok ? .retry : .doNotRetry) }
        guard !isRefreshing else { return }

        isRefreshing = true
        // 这里模拟刷新；你可以换成真实刷新接口
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            TokenStore.shared.accessToken = "NEW_TOKEN"
            self.lock.lock()
            let pending = self.waiters
            self.waiters.removeAll()
            self.isRefreshing = false
            self.lock.unlock()
            pending.forEach { $0(true) }
        }
    }
}
