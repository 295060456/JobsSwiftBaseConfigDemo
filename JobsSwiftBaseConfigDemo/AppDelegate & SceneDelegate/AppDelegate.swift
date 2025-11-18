//
//  AppDelegate.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/4.
//

import UIKit
import GKNavigationBarSwift
import LiveChat
/// https://github.com/apple/swift-collections#
#if canImport(Collections)
import Collections          // ✅ Pod 或 SPM 直接接 apple/swift-collections
#elseif canImport(OrderedCollections)
import OrderedCollections   // ✅ SPM 只接 OrderedCollections product 的情况
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        JSONDecoder解析字段对齐()
        JSONDecoder解析字段key不一致_CodingKeys()
        JSONDecoder解析字段key不一致_keyDecodingStrategy()
        JSONDecoder解析字段处理时间()
        JSONDecoder嵌套JSON数组解析()
        JSONDecoder嵌套对象()

        OrderedDictionary测试()

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
    func JSONDecoder解析字段对齐(){
        struct User: Codable {
            let id: Int
            let name: String
            let isVIP: Bool
        }

        let json = """
        {
            "id": 1,
            "name": "Jobs",
            "isVIP": true
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // 👈 这个开关可以直接全局打开
            let user = try decoder.decode(User.self, from: json)
            print(user.id, user.name, user.isVIP) // 1 Jobs true
        } catch {
            print("❌ 解析失败：\(error)")
        }
    }

    /// 结论：最好写 CodingKeys。keyDecodingStrategy不是万能的
    func JSONDecoder解析字段key不一致_CodingKeys(){

        struct User: Codable {
            let userId: Int
            let userName: String
            /// 模型名 = 服务器字段名
            enum CodingKeys: String, CodingKey { // 👈 关键
                case userId   = "user_id"
                case userName = "user_name"
            }
        }

        let json = """
        {
          "user_id": 1,
          "user_name": "Jobs"
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: json)
            print(user.userId, user.userName) // 1 Jobs true
        } catch {
            print("❌ 解析失败：\(error)")
        }
    }

    func JSONDecoder解析字段key不一致_keyDecodingStrategy(){

        struct User: Codable {
            let userId: Int
            let userName: String
        }

        let json = """
        {
          "user_id": 1,
          "user_name": "Jobs"
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // 👈 关键
            let user = try decoder.decode(User.self, from: json)
            print(user.userId, user.userName) // 1 Jobs true
        } catch {
            print("❌ 解析失败：\(error)")
        }
    }

    func JSONDecoder解析字段处理时间(){
        struct Post: Codable {
            let id: Int
            let createdAt: Date
        }

        let json = """
        {
          "id": 1,
          "created_at": "2025-11-18 16:39:00"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
            .bykeyDecodingStrategy(.convertFromSnakeCase)
            .byDateDecodingStrategy(
                .formatted(DateFormatter()
                .byDateFormat("yyyy-MM-dd HH:mm:ss")
                .byLocale(Locale(identifier: "en_US_POSIX"))))
        do {
            let post = try decoder.decode(Post.self, from: json)
            print(post.createdAt)
        } catch {
            print("❌ 解析失败：\(error)")
        }
    }

    func JSONDecoder嵌套JSON数组解析(){
        struct User: Codable {
            let id: Int
            let name: String
        }

        let json = """
        [
          { "id": 1, "name": "A" },
          { "id": 2, "name": "B" }
        ]
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let users = try decoder.decode([User].self, from: json)
            print(users.count) // 2
        } catch {
            print("❌ 解析失败：\(error)")
        }
    }

    func JSONDecoder嵌套对象(){

        struct APIResponse<T: Codable>: Codable {
            let code: Int
            let message: String
            let data: T
        }

        struct User: Codable {
            let id: Int
            let name: String
        }

        let json = """
        {
          "code": 0,
          "message": "ok",
          "data": {
            "id": 1,
            "name": "Jobs"
          }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let resp = try decoder.decode(APIResponse<User>.self, from: json)
            let user = resp.data
            print(user) // 2
        } catch {
            print("❌ 解析失败：\(error)")
        }
    }

    func OrderedDictionary测试(){
        let d1: [String: JSONValue] = [
            "sd": .int(1),
            "fg": .string("2"),
            "pi": .double(3.14159),
            "flag": .bool(true),
            "list": .array([.int(1), .int(2)]),
            "config": .object([
                "debug": .bool(false),
                "threshold": .double(0.75)
            ]),
            "nothing": .null
        ]

        let d2 = [1,2,3,4]
        let d3 = [
            "sd":"1",
            "ff":"2",
            "fff":"3",
            "fdf":"4"
        ]
        let d4: OrderedDictionary<String, String> = [
            "hi":  "1",
            "mo":  "2",
            "do": "3",
            "gg": "4"
        ]

        for (k, v) in d4 {
            // ✅ 一定是 sd, ff, fff, fdf
            print(k, v)
        }

        log(d1)
        log(d2)
        log(d3)

        for key in d3.keys.sorted() {
            print(key,d3[key] as Any);
        }

        print(type(of: d3))
        dump(d3)

        for (k, v) in d3 {
            print(k, v)
        }
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
        TRLang.bundleProvider = { LanguageManager.shared.localizedBundle }
        TRLang.localeCodeProvider = { LanguageManager.shared.currentLanguageCode }
    }
}
