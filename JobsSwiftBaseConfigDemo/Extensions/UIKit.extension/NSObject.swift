//
//  NSObject.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/15.
//

import Foundation
import ObjectiveC.runtime
/// Swift 的 extension 是不能新增存储属性的，因此用关联对象 (objc_getAssociatedObject) 来模拟属性
/// 写法一
//extension NSObject: MyProtocol {
//    private struct AssociatedKeys {
////        static var nameKey = "nameKey"
//        static var nameKey = UnsafeRawPointer(bitPattern: "nameKey".hashValue)!
//    }
//
//    var name: String {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.nameKey) as? String ?? ""
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.nameKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//    }
//
//    func greet() {
//        print("👋 Hello, my name is \(name)")
//    }
//}
/// 写法二
/// ✅ 用 UInt8 就不会有警告
/// Swift 的 &nameKey 现在是 UnsafeRawPointer 类型的地址，但 nameKey 是个简单的整数（UInt8），不会暴露复杂类型（如 String、NSObject）的内部内存结构，因此不会触发 Swift 的类型安全警告。
/// 这是 Apple 官方推荐的方式之一。
private var nameKey: UInt8 = 0
extension NSObject: MyProtocol {
    var name: String {
        get {
            return objc_getAssociatedObject(self, &nameKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &nameKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    func greet() {
        print("👋 Hello, my name is \(name)")
    }
}

extension NSObject {
    /// weakify 支持有返回值
    func weakify<T: AnyObject, U>(_ owner: T, _ function: @escaping (T) -> () -> U) -> () -> U? {
        return { [weak owner] in
            guard let strongOwner = owner else { return nil }
            return function(strongOwner)()
        }
    }

    /// ✅ weakify 支持无返回值
    func weakify<T: AnyObject>(_ owner: T, _ function: @escaping (T) -> () -> Void) -> () -> Void {
        return { [weak owner] in
            guard let strongOwner = owner else { return }
            function(strongOwner)()
        }
    }

    /// 延迟执行 block，自动处理 weak self
    func doAsync(after delay: TimeInterval = 1.0, _ block: @escaping (Self) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let strongSelf = self else { return }
            block(strongSelf as! Self)
        }
    }
}

extension NSObject {
    /// 类名 -> 字符串
    public var className: String {
        return type(of: self).className
    }

    /// 枚举 -> 类名
    public static var className: String {
        return String(describing: self)
    }

    func py_description() -> String {
        var output = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            output = String(data: data, encoding: .utf8) ?? ""
            output = output.replacingOccurrences(of: "\\/", with: "/") // 处理\/转义字符
        } catch {

        }
        return output
    }
}
