//
//  TRString.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import Foundation

public extension String {
    /// 仅此一个 API：每次访问都按“当前语言”取值
    var tr: String {
        let b = TRLang.bundle()
        print("📍 strings path =", b.path(forResource: "Localizable", ofType: "strings") ?? "nil")
        // value: self → 当 key 未翻到时，回退 key 本身，便于你肉眼排查漏翻
        return NSLocalizedString(self, tableName: nil, bundle: b, value: self, comment: "")
    }

    /// 可选：带参数版本（String(format:)）
    func tr(_ args: CVarArg...) -> String {
        String(format: self.tr, arguments: args)
    }
}
