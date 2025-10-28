//
//  DemoAPI.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Moya
import Alamofire

public enum DemoAPI {
    // GitHub：公开 GET
    case ghZen
    case ghUser(username: String)
    case ghSearchUsers(q: String, page: Int?)

    // ReqRes：登录/CRUD
    case login(email: String, password: String)
    case createUser(CreateUserReq)
    case updateUser(id: Int, UpdateUserReq)
    case deleteUser(id: Int)

    // httpbin：上传/下载
    case uploadAvatar(imageData: Data)
    case downloadPNG
    case downloadBytes(size: Int)
}

extension DemoAPI: TargetType {

    public var baseURL: URL {
        switch self {
        case .ghZen, .ghUser, .ghSearchUsers:
            return URL(string: "https://api.github.com")!
        case .login, .createUser, .updateUser, .deleteUser:
            return URL(string: "https://reqres.in")!
        case .uploadAvatar, .downloadPNG, .downloadBytes:
            return URL(string: "https://httpbin.org")!
        }
    }

    public var path: String {
        switch self {
        case .ghZen: return "/zen"
        case let .ghUser(username): return "/users/\(username)"
        case .ghSearchUsers: return "/search/users"

        case .login: return "/api/login"
        case .createUser: return "/api/users"
        case let .updateUser(id, _): return "/api/users/\(id)"
        case let .deleteUser(id):    return "/api/users/\(id)"

        case .uploadAvatar: return "/post"
        case .downloadPNG:  return "/image/png"
        case let .downloadBytes(size): return "/bytes/\(size)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .ghZen, .ghUser, .ghSearchUsers, .downloadPNG, .downloadBytes: return .get
        case .login, .createUser, .uploadAvatar: return .post
        case .updateUser: return .put
        case .deleteUser: return .delete
        }
    }

    public var task: Task {
        switch self {
        // GitHub
        case .ghZen, .ghUser:
            return .requestPlain
        case let .ghSearchUsers(q, page):
            var params = ["q": q]
            if let p = page { params["page"] = "\(p)" }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        // ReqRes
        case let .login(email, password):
            return .requestParameters(parameters: ["email": email, "password": password],
                                      encoding: JSONEncoding.default)
        case let .createUser(body):
            return .requestJSONEncodable(body)
        case let .updateUser(_, body):
            return .requestJSONEncodable(body)
        case .deleteUser:
            return .requestPlain

        // httpbin 上传/下载
        case let .uploadAvatar(data):
            let form = MultipartFormData(provider: .data(data),
                                         name: "file",
                                         fileName: "avatar.jpg",
                                         mimeType: "image/jpeg")
            return .uploadMultipart([form])

        case .downloadPNG, .downloadBytes:
            let destination: DownloadDestination = { _, _ in
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
            return .downloadDestination(destination)
        }
    }

    public var headers: [String : String]? {
        var h = ["Accept": "application/json"]
        if case .uploadAvatar = self {
            // multipart 自带 boundary Content-Type
        } else {
            h["Content-Type"] = "application/json; charset=utf-8"
        }
        return h
    }

    public var sampleData: Data {
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

    public var validationType: ValidationType { .successCodes }

    public var timeout: TimeInterval {
        switch self {
        case .uploadAvatar, .downloadPNG, .downloadBytes: return 60
        default: return 20
        }
    }
}
