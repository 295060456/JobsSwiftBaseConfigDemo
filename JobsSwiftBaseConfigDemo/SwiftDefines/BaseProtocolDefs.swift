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
// MARK: - 查找当前对象所在的控制器
protocol ViewControllerFindable {}
protocol _UISafeUnwrappedBan {}     // 标记“UI 禁用默认兜底”
// MARK: - 安全解包 Optional
protocol SafeUnwrappedInitializable { init() }
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
// MARK: - JobsTimerProtocol
public protocol JobsTimerProtocol: AnyObject {
    /// 当前是否运行中
    var isRunning: Bool { get }

    /// 启动计时器
    func start()

    /// 暂停计时器
    func pause()

    /// 恢复计时器
    func resume()

    /// 立即触发一次（fire）
    func fireOnce()

    /// 停止计时器（销毁）
    func stop()

    /// 注册回调（每 tick 执行一次）
    @discardableResult
    func onTick(_ block: @escaping () -> Void) -> Self

    /// 注册完成回调（用于一次性定时器或倒计时）
    @discardableResult
    func onFinish(_ block: @escaping () -> Void) -> Self
}
