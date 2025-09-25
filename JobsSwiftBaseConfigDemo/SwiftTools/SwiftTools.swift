//
//  SwiftTools.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

// MARK: - 扩展 Int 与 JXAuthCode 的比较
public func ==(lhs: Int?, rhs: JXAuthCode) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs == Int(rhs.rawValue)
}

public func ==(lhs: Int, rhs: JXAuthCode) -> Bool {
    return lhs == Int(rhs.rawValue)
}

public func ==(lhs: JXAuthCode, rhs: Int?) -> Bool {
    guard let rhs = rhs else { return false }
    return Int(lhs.rawValue) == rhs
}

public func ==(lhs: JXAuthCode, rhs: Int) -> Bool {
    return Int(lhs.rawValue) == rhs
}
// MARK: - 扩展 Int 与 JXAuthCode 的不等于
public func !=(lhs: Int?, rhs: JXAuthCode) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: Int, rhs: JXAuthCode) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: JXAuthCode, rhs: Int?) -> Bool {
    !(lhs == rhs)
}

public func !=(lhs: JXAuthCode, rhs: Int) -> Bool {
    !(lhs == rhs)
}
