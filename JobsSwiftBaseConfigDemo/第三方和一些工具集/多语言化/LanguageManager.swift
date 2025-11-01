//
//  LanguageManager.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import Foundation

public extension Notification.Name {
    /// 全局：语言切换完成
    static let JobsLanguageDidChange = Notification.Name("JobsLanguageDidChange")
}

public final class LanguageManager {
    public static let shared = LanguageManager()
    private init() {
        // 启动恢复（可按需持久化）
        if let saved = UserDefaults.standard.string(forKey: Self.udk) {
            currentLanguageCode = saved
        }
    }

    private static let udk = "jobs.currentLanguageCode"

    /// 当前语言码（与 .lproj 目录名一致，如 zh-Hans / en）
    public private(set) var currentLanguageCode: String = "zh-Hans" {
        didSet { UserDefaults.standard.set(currentLanguageCode, forKey: Self.udk) }
    }

    /// 计算属性：每次都据当前语言码“拿最新 Bundle”
    public var localizedBundle: Bundle {
        if let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
           let b = Bundle(path: path) {
            return b
        }
        return .main
    }

    /// 切换语言：更新语言码 → 广播通知（不重建 Root）
    public func switchTo(_ code: String) {
        guard code != currentLanguageCode else { return }
        currentLanguageCode = code
        NotificationCenter.default.post(name: .JobsLanguageDidChange, object: nil)
    }
}
