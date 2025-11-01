//
//  AppDelegate.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/4.
//

import UIKit
import GKNavigationBarSwift
import LiveChat
// zzza
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GK配置()
        删除键监听()
        全局比例尺()
        安全Push和Present()
        启动检测()
        日志打印()
        LiveChat配置()
        多语言化()
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

extension AppDelegate {
    func GK配置(){
        GKNavigationBarConfigure
            .bySetupDefault()
            .byAwake()
            .byBackground(.systemBackground)
            .byTitleCor(.label)
            .byTitleFont(.systemFont(ofSize: 18, weight: .semibold))
    }

    func 删除键监听(){
        // ✅ 启用 UITextField 的 deleteBackward 广播（与 UITextView 互不影响）
        UITextField.enableDeleteBackwardBroadcast()
        // ✅ 启用 UITextView 的 deleteBackward 广播（与 UITextField 互不影响）
        UITextView.enableDeleteBackwardBroadcast()
    }

    func 全局比例尺(){
        JXScale.setup(designWidth: 375, designHeight: 812, useSafeArea: false)
    }

    func 安全Push和Present(){
        JobsSafePushSwizzler.enable()      // 只拦 push
        JobsSafePresentSwizzler.enable()   // 只拦 present
    }

    func 启动检测(){
        AppLaunchManager.handleLaunch(
            firstInstall: {
                log("🚀 新用户引导 / 初始化配置")
            },
            firstToday: {
                log("☀️ 每日签到弹窗 / 刷新缓存")
            },
            normal: {
                log("➡️ 正常启动 / 常规逻辑")
            }
        )
    }

    func 日志打印(){
        #if DEBUG
        JobsLog.enabled = true
        #else
        JobsLog.enabled = false    // Release 关闭日志
        #endif
        JobsLog.showThread = true
    }

    func LiveChat配置(){
        // 你的 LiveChat 许可证 ID（到 LiveChat 后台可查看）
        LiveChat.licenseId = AppKeys.liveChatKey      // 必填
        // 可选：减少预聊天表单输入
        LiveChat.name  = "Jobs"
        LiveChat.email = "jobs@example.com"
        // 可选：把用户归到指定客服分组（注意：groupId 必须有效，否则可能加载不出来）
        LiveChat.groupId = "77"
        // 可选：自定义变量（用于上下文）
        LiveChat.setVariable(withKey: "userId", value: "123456")
    }

    func 多语言化(){
        TRLang.bindBundleProvider { LanguageManager.shared.localizedBundle }
//        Bundle.jobs_enableLanguageHook() // 下面第2步的 swizzle，仅需一次
    }
}
