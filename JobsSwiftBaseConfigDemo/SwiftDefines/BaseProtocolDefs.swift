//
//  BaseProtocolDefs.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/3/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
// MARK: - 安全解包 Optional
protocol SafeUnwrappedInitializable {
    init()
}
// MARK: - 强类型输入协议（可选实现）
protocol JobsDataReceivable {
    associatedtype InputData
    func receive(_ data: InputData)
}
// MARK: - 路由目的地等价（避免重名-前缀化）
/// 默认“同类型 = 同目的地”。需要区分同类不同参数时，在目标 VC 里 override `jobs_isSameDestination(as:)`
protocol JobsRouteComparable {
    func jobs_isSameDestination(as other: UIViewController) -> Bool
}
// MARK: - 少量便捷 then（可选）
public protocol Then {}
extension Then where Self: AnyObject {
    @discardableResult
    func then(_ block: (Self) -> Void) -> Self {
        block(self); return self
    }
}
// MARK: - 延迟执行
public protocol JobsAsyncable: AnyObject {}
public extension JobsAsyncable {
    /// 延迟执行，自动 weak self；默认主线程
    func doAsync(
        after delay: TimeInterval = 1.0,
        on queue: DispatchQueue = .main,
        _ block: @escaping (Self) -> Void
    ) -> Void {
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            block(self)     // ✅ 此处就是 Self，无需 as! 强转
        }
    }
}
