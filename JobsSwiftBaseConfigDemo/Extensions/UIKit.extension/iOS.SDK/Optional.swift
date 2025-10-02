//
//  Optional.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

import Foundation
import UIKit
// MARK: - 安全解包 Optional
protocol SafeUnwrappedInitializable {
    init()
}

extension Optional where Wrapped: SafeUnwrappedInitializable {
    func safelyUnwrapped(defaultValue: Wrapped? = nil) -> Wrapped {
        guard let result = self else {
//            assertionFailure("instance of : \(String(describing:Wrapped.self)) is nil")
            return defaultValue ?? Wrapped()
        }
        return result
    }
}
extension String: SafeUnwrappedInitializable { }
extension UIColor: SafeUnwrappedInitializable { }
extension Double: SafeUnwrappedInitializable { }
extension Array: SafeUnwrappedInitializable { }
extension UIImage: SafeUnwrappedInitializable { }
