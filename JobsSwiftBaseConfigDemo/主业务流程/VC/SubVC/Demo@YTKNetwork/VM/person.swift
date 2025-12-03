// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let person = try Person(json)

import Foundation
// MARK: - 根对象
struct Person: Codable {
    let headers: Headers
}
// MARK: - headers
struct Headers: Codable {
    let accept: String
    let acceptEncoding: String
    let acceptLanguage: String
    let host: String
    let priority: String
    let userAgent: String
    let xAmznTraceID: String

    enum CodingKeys: String, CodingKey {
        case accept          = "Accept"
        case acceptEncoding  = "Accept-Encoding"
        case acceptLanguage  = "Accept-Language"
        case host            = "Host"
        case priority        = "Priority"
        case userAgent       = "User-Agent"
        case xAmznTraceID    = "X-Amzn-Trace-Id"
    }
}
