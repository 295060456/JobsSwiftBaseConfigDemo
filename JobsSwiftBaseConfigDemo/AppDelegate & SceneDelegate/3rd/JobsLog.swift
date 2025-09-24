//
//  JobsLog.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/23/25.
//

import Foundation

//✅ 统一格式，自动带上文件名、行号、函数名
//✅ 区分 print / debugPrint 使用场景
//✅ 可以加开关（isDebugEnabled / #if DEBUG）来控制是否输出
//✅ 日志等级清晰（info / warning / error / debug）

enum LogLevel: String {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case debug = "🐞 DEBUG"
}

struct JobsLogger {
    // 是否开启调试模式
    static var isDebugEnabled: Bool = true

    /// 普通日志（print）
    static func log(_ items: Any..., level: LogLevel = .info,
                    file: String = #file, line: Int = #line, function: String = #function) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let message = items.map { "\($0)" }.joined(separator: " ")
        Swift.print("[\(level.rawValue)] \(fileName):\(line) \(function) → \(message)")
        #endif
    }

    /// 调试日志（debugPrint）
    static func debug(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        #if DEBUG
        guard isDebugEnabled else { return }
        let fileName = (file as NSString).lastPathComponent
        Swift.debugPrint("[\(LogLevel.debug.rawValue)] \(fileName):\(line) \(function) →", terminator: " ")
        for item in items {
            Swift.debugPrint(item, terminator: " ")
        }
        Swift.debugPrint("") // 换行
        #endif
    }
}

/**

 struct User: CustomStringConvertible, CustomDebugStringConvertible {
     let name: String
     var description: String { "👤 用户名: \(name)" }
     var debugDescription: String { "User(name: \(name))" }
 }

 let u = User(name: "Jobs")

 JobsLogger.log("应用启动成功")
 // [ℹ️ INFO] AppDelegate.swift:23 application(_:didFinishLaunchingWithOptions:) → 应用启动成功

 JobsLogger.log("网络超时", level: .warning)
 // [⚠️ WARNING] NetworkManager.swift:87 request() → 网络超时

 JobsLogger.debug(u)
 // [🐞 DEBUG] ViewController.swift:45 viewDidLoad() → User(name: Jobs)

 */
