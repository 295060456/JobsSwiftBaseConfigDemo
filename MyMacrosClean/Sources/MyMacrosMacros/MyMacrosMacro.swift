import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EquatableByMacro.self   // ✅ 只注册这个
    ]
}
