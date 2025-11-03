//
//  MoyaProvider+Async.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import Foundation
import Moya

#if compiler(>=5.5) && canImport(_Concurrency)
public extension MoyaProvider {
    func request(_ target: Target,
                 callbackQueue: DispatchQueue? = nil,
                 progress: ProgressBlock? = nil) async throws -> Response {
        try await withCheckedThrowingContinuation { cont in
            self.request(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let resp): cont.resume(returning: resp)
                case .failure(let err):  cont.resume(throwing: err)
                }
            }
        }
    }
}
#endif
