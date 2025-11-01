//
//  TRLang.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import Foundation

/// 语言上下文（唯一真相）
public enum TRLang {
    /// 返回当前“生效”的本地化 Bundle（必须绑定，默认 .main 仅用于极早期）
    public private(set) static var bundleProvider: () -> Bundle = { .main }

    /// App 启动时绑定：让 .tr 永远走“最新语言”的 Bundle
    @inline(__always)
    public static func bindBundleProvider(_ provider: @escaping () -> Bundle) {
        bundleProvider = provider
    }
}
