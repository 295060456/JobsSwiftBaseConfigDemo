//
//  AFRoute.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Alamofire

enum AFRoute: URLRequestConvertible {
    case ghZen
    case ghUser(username: String)
    case ghSearchUsers(q: String, page: Int?)

    case login(email: String, password: String)
    case createUser(CreateUserReq)
    case updateUser(id: Int, UpdateUserReq)
    case deleteUser(id: Int)

    case uploadAvatar(Data)
    case downloadPNG
    case downloadBytes(size: Int)

    // MARK: - Base / Path / Method
    var baseURL: URL {
        switch self {
        case .ghZen, .ghUser, .ghSearchUsers: return URL(string: "https://api.github.com")!
        case .login, .createUser, .updateUser, .deleteUser: return URL(string: "https://reqres.in")!
        case .uploadAvatar, .downloadPNG, .downloadBytes: return URL(string: "https://httpbin.org")!
        }
    }

    var path: String {
        switch self {
        case .ghZen: return "/zen"
        case let .ghUser(username): return "/users/\(username)"
        case .ghSearchUsers: return "/search/users"

        case .login: return "/api/login"
        case .createUser: return "/api/users"
        case let .updateUser(id, _): return "/api/users/\(id)"
        case let .deleteUser(id): return "/api/users/\(id)"

        case .uploadAvatar: return "/post"
        case .downloadPNG:  return "/image/png"
        case let .downloadBytes(n): return "/bytes/\(n)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .ghZen, .ghUser, .ghSearchUsers, .downloadPNG, .downloadBytes: return .get
        case .login, .createUser, .uploadAvatar: return .post
        case .updateUser: return .put
        case .deleteUser: return .delete
        }
    }

    var timeout: TimeInterval {
        switch self {
        case .uploadAvatar, .downloadPNG, .downloadBytes: return 60
        default: return 20
        }
    }

    // MARK: - Headers
    var headers: HTTPHeaders {
        var h: HTTPHeaders = ["Accept": "application/json"]
        if case .uploadAvatar = self {
            // multipart 自带 boundary Content-Type
        } else {
            h.add(name: "Content-Type", value: "application/json; charset=utf-8")
        }
        return h
    }

    // MARK: - Encoding / Body
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.method = method
        req.headers = headers
        req.timeoutInterval = timeout

        switch self {
        case .ghZen, .ghUser, .deleteUser, .downloadPNG, .downloadBytes, .uploadAvatar:
            // 这些要么无 body，要么交给 upload/download API
            return req

        case let .ghSearchUsers(q, page):
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            var items: [URLQueryItem] = [.init(name: "q", value: q)]
            if let p = page { items.append(.init(name: "page", value: "\(p)")) }
            comps.queryItems = items
            req.url = comps.url
            return req

        case let .login(email, password):
            let body = ["email": email, "password": password]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            return req

        case let .createUser(b):
            req.httpBody = try JSONEncoder().encode(b); return req

        case let .updateUser(_, b):
            req.httpBody = try JSONEncoder().encode(b); return req
        }
    }

    // MARK: - Download Destination
    var destination: DownloadRequest.Destination? {
        switch self {
        case .downloadPNG, .downloadBytes:
            return { _, _ in
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("Downloads", isDirectory: true)
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                let name: String = {
                    switch self {
                    case .downloadPNG: return "sample.png"
                    case let .downloadBytes(n): return "bytes_\(n).bin"
                    default: return "file.bin"
                    }
                }()
                let url = dir.appendingPathComponent(name)
                return (url, [.removePreviousFile, .createIntermediateDirectories])
            }
        default:
            return nil
        }
    }

    // MARK: - sampleData（给 Stub 用，内容与 Moya 版一致）
    var sampleData: Data {
        switch self {
        case .ghZen:
            return Data("Keep it logically awesome.".utf8)
        case .ghUser:
            return #"{"login":"apple","id":1,"avatar_url":"https://avatars.githubusercontent.com/u/1"}"#
                .data(using: .utf8)!
        case .ghSearchUsers:
            return #"{"total_count":1,"items":[{"login":"jobs","id":9527,"avatar_url":"https://example.com/a.png"}]}"#
                .data(using: .utf8)!
        case .login:
            return #"{"token":"QpwL5tke4Pnpja7X4"}"#.data(using: .utf8)!
        case .createUser:
            return #"{"id":"101","name":"New User","email":"new@example.com","createdAt":"2025-01-01T00:00:00Z"}"#
                .data(using: .utf8)!
        case .updateUser:
            return #"{"name":"Updated","email":"updated@example.com","updatedAt":"2025-01-01T00:00:00Z"}"#
                .data(using: .utf8)!
        case .deleteUser:
            return Data()
        case .uploadAvatar:
            return #"{"files":{"file":"data:image/jpeg;base64,..."},"form":{}}"#.data(using: .utf8)!
        case .downloadPNG, .downloadBytes:
            return Data()
        }
    }
}
