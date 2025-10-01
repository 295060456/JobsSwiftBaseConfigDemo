//
//  AppDelegate.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/4.
//

import UIKit
import GKNavigationBarSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GKConfigure.setupDefault()
        GKConfigure.awake()
        GKConfigure.backgroundColor = .systemBackground
        GKConfigure.titleColor = .label
        GKConfigure.titleFont = .systemFont(ofSize: 18, weight: .semibold)
        // ✅ 启用 UITextField 的 deleteBackward 广播（与 UITextView 互不影响）
        UITextField.enableDeleteBackwardBroadcast()
        // ✅ 启用 UITextView 的 deleteBackward 广播（与 UITextField 互不影响）
        UITextView.enableDeleteBackwardBroadcast()
        // ✅ 全局比例尺
        JXScale.setup(designWidth: 375, designHeight: 812, useSafeArea: false)
        // ✅ 安全 push/present 页面
        JobsSafePushSwizzler.enable()      // 只拦 push
        JobsSafePresentSwizzler.enable()   // 只拦 present
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
