//
//  LanguageManager.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import Foundation

public final class LanguageManager {
    public static let shared = LanguageManager()
    private init() {}

    private enum Key { static let userLang = "app.user.language.code" }
    /// 当前语言码（如 zh-Hans / en / en-GB），持久化到 UserDefaults
    public var currentLanguageCode: String? {
        get { UserDefaults.standard.string(forKey: Key.userLang) }
        set {
            let norm = newValue.flatMap { LanguageManager.normalize($0) }
            if let norm {
                UserDefaults.standard.set(norm, forKey: Key.userLang)
            } else {
                UserDefaults.standard.removeObject(forKey: Key.userLang)
            }
        }
    }
    /// 当前语言的 Bundle（默认 main）
    public var localizedBundle: Bundle {
        let code = currentLanguageCode ?? Locale.preferredLanguages.first ?? "en"
        let norm = LanguageManager.normalize(code)
        if let path = Bundle.main.path(forResource: norm, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        };return .main
    }
    /// 切换语言（会广播刷新）
    public func switchTo(_ code: String) {
        self.currentLanguageCode = code
        NotificationCenter.default.post(name: .TRLanguageDidChange, object: nil) // ✅
    }
    /// 规范化成 .lproj 目录名
    private static func normalize(_ raw: String) -> String {
        // 常见别名修正
        let lower = raw.lowercased()
        if lower.hasPrefix("zh") {
            if lower.contains("hant") || lower.contains("tw") || lower.contains("hk") {
                return "zh-Hant"
            } else {
                return "zh-Hans"
            }
        }
        // 标准化 en-GB / fr-CA 这类
        let comps = raw.replacingOccurrences(of: "_", with: "-")
                        .split(separator: "-")
        if comps.count >= 2 {
            let lang = comps[0].lowercased()
            let region = comps[1].uppercased()
            return "\(lang)-\(region)"
        } else {
            return comps.first.map(String.init) ?? "en"
        }
    }
}
