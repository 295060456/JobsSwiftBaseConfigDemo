//
//  JobsProtocol.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/15.
//
/// 是更安全、更明确的做法，适合用于类专用的逻辑（如使用关联对象、继承 NSObject、引用语义等）——它覆盖了你需要的 100% 的实际情况。
/// AnyObject
/// 这个协议只能被类（class）实现；
/// 不能被结构体（struct）或枚举（enum）实现；
/// 可以安全使用 weak、unowned 修饰；
/// 可以用 objc_get/setAssociatedObject 等 Objective-C runtime 功能。
protocol MyProtocol: AnyObject {
    var name: String { get set }
    func greet()
}
/// 不写AnyObject ：✅ 可以被 类（class）、结构体（struct）、枚举（enum） 实现。❌struct 不支持
/// 所以这更灵活，但也表示你不能假设这个协议是引用类型。
protocol JobsProtocol {
    var name: String { get set }
    func greet()
}
