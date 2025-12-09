//
//  PostJsonRequest.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import YTKNetwork
/// POST /post => 回显你发出去的 JSON
final class PostJsonRequest: YTKRequest {
    private let payload: [String: Any]
    init(payload: [String: Any]) {
        self.payload = payload
        super.init()
    }

    override func requestUrl() -> String {
        return "/post"
    }

    override func requestMethod() -> YTKRequestMethod {
        return .POST
    }
    /// 用 JSON 序列化请求体
    override func requestSerializerType() -> YTKRequestSerializerType {
        return .JSON
    }

    override func responseSerializerType() -> YTKResponseSerializerType {
        return .JSON
    }

    override func requestArgument() -> Any? {
        return payload
    }
    /// 回显字段中我们自己的 JSON
    var echoedJSON: [String: Any]? {
        (responseJSONObject as? [String: Any])?["json"] as? [String: Any]
    }
}
