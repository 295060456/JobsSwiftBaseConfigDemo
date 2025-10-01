//
//  Optional.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

// MARK: - Optional String 安全解包
public extension Optional where Wrapped == String {
    func safelyUnwrapped(_ defaultValue: String = "") -> String {
        switch self {
        case .some(let value):
            return value
        case .none:
            return defaultValue
        }
    }
}
