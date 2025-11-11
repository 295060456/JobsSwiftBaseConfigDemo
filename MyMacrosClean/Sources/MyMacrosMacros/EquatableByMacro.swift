import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// 同时实现 MemberMacro + ExtensionMacro
public struct EquatableByMacro: MemberMacro, ExtensionMacro {

    static func extractKey(from node: AttributeSyntax) -> String {
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let first = args.first
        else { return "id" }

        if let lit = first.expression.as(StringLiteralExprSyntax.self),
           let val = lit.representedLiteralValue {
            return val
        }
        if let ref = first.expression.as(DeclReferenceExprSyntax.self) {
            return ref.baseName.text
        }
        return "id"
    }

    // Swift 6.2：带 conformingTo 的签名
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        conformingTo: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        let key = extractKey(from: node)

        // 生成到类型内部的成员
        let eq: DeclSyntax =
        """
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.\(raw: key) == rhs.\(raw: key)
        }
        """

        let hs: DeclSyntax =
        """
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.\(raw: key))
        }
        """

        return [eq, hs]
    }

    // 这里真正“声明”协议遵循：extension Type: Equatable, Hashable {}
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo decl: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        let t = type.trimmed
        let ext: DeclSyntax =
        """
        extension \(t): Equatable, Hashable {}
        """
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}
