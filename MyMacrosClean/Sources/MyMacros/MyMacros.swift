// The Swift Programming Language
// https://docs.swift.org/swift-book
// 只负责把宏“暴露”出来
// 生成两个成员：== 与 hash(into:)
// 并声明扩展会添加 Equatable/Hashable 遵循（无需你额外生成代码）

// 放宽成员覆盖声明，兼容 Swift 6 的覆盖检查
@attached(member, names: arbitrary)
@attached(extension, conformances: Equatable, Hashable)
public macro EquatableBy(_ key: String = "id") = #externalMacro(
    module: "MyMacrosMacros",
    type: "EquatableByMacro"
)

