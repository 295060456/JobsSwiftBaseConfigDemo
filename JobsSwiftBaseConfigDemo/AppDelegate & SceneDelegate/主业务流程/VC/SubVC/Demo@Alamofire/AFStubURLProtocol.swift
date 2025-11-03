//
//  AFStubURLProtocol.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation

final class AFStubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) -> (status: Int, headers: [String:String], data: Data)?)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let client = client, let url = request.url else { return }
        if let res = AFStubURLProtocol.handler?(request) {
            let resp = HTTPURLResponse(url: url, statusCode: res.status,
                                       httpVersion: "HTTP/1.1", headerFields: res.headers)!
            client.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: res.data)
            client.urlProtocolDidFinishLoading(self)
        } else {
            client.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
        }
    }
    override func stopLoading() {}
}
