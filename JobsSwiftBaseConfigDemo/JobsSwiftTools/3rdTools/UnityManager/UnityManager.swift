//
//  UnityManager.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/11/25.
//

import UIKit
// ⚠️ UnityFramework 的头文件请放在 Bridging-Header 里：
// #import "UnityFramework/UnityFramework.h"
// 这里就不用 `import UnityFramework` 了

/// 统一管理 Unity 的加载 / 展示 / 关闭
final class UnityManager: NSObject {

    static let shared = UnityManager()

    /// 当前 UnityFramework 实例（运行中才有）
    private var ufw: UnityFramework?

    /// Unity 是否正在跑游戏循环
    private(set) var isRunning = false

    /// 宿主 App 的窗口（Unity 启动前的 keyWindow）
    private weak var hostWindow: UIWindow?

    /// Unity 自己的窗口（UnityAppController.window）
    private weak var unityWindow: UIWindow?

    /// 自动关闭用的定时器
    private var autoCloseTimer: JobsTimerProtocol?

    private override init() {
        super.init()
    }

    // MARK: - Window 辅助

    /// 当前 keyWindow
    private func currentKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    // MARK: - 内部：加载 & 启动 Unity

    /// 确保拿到一个可用的 UnityFramework 实例
    @discardableResult
    private func loadUnityFramework() -> UnityFramework? {
        // 已经有实例了就复用
        if let ufw = self.ufw {
            // 补一下 window 引用（防止外面先拿）
            if unityWindow == nil {
                unityWindow = ufw.appController()?.window
            }
            return ufw
        }

        // 记录 Unity 接管前的宿主窗口
        if hostWindow == nil {
            hostWindow = currentKeyWindow()
        }

        // 1. 找到 .app/Frameworks/UnityFramework.framework
        let frameworkPath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        guard let bundle = Bundle(path: frameworkPath) else {
            print("❌ 找不到 UnityFramework.framework，路径: \(frameworkPath)")
            return nil
        }

        if !bundle.isLoaded {
            bundle.load()
        }

        // 2. 拿主类实例
        guard
            let cls = bundle.principalClass as? UnityFramework.Type,
            let ufw = cls.getInstance()
        else {
            print("❌ 无法拿到 UnityFramework 实例")
            return nil
        }

        // 3. 首次启动 Unity Runtime
        if ufw.appController() == nil {
            // 用宿主 App 的 Data 目录
            if let bundleId = Bundle.main.bundleIdentifier {
                ufw.setDataBundleId(bundleId)
            }

            let argc = Int32(CommandLine.argc)
            let argv = CommandLine.unsafeArgv

            ufw.runEmbedded(
                withArgc: argc,
                argv: argv,
                appLaunchOpts: nil
            )
        }

        // 4. 注册监听 & 缓存
        ufw.register(self)
        self.ufw = ufw
        self.unityWindow = ufw.appController()?.window

        return ufw
    }

    // MARK: - 对外：显示 / 关闭 Unity（全屏）

    /// 启动 / 显示 Unity。
    /// - Parameters:
    ///   - autoCloseAfter: 多少秒之后自动关闭（nil 或 <=0 表示不自动关）
    ///   - unloadOnClose: 关闭时是否顺便卸载 Unity 引擎（一般 `true`）
    func showUnity(
        autoCloseAfter seconds: TimeInterval? = nil,
        unloadOnClose: Bool = true
    ) {
        guard let ufw = loadUnityFramework() else { return }

        if let uWindow = ufw.appController()?.window {
            unityWindow = uWindow
            uWindow.isHidden = false
            uWindow.makeKeyAndVisible()
        }

        isRunning = true

        setupAutoCloseTimer(after: seconds, unloadOnClose: unloadOnClose)
    }

    /// 方便保持你之前的调用写法：from 参数实际上可以忽略
    func showUnity(
        from _: UIViewController,
        autoCloseAfter seconds: TimeInterval? = nil,
        unloadOnClose: Bool = true
    ) {
        showUnity(autoCloseAfter: seconds, unloadOnClose: unloadOnClose)
    }

    /// 仅隐藏 Unity 的窗口，不卸载引擎（下次可以秒开）
    func hideUnity() {
        autoCloseTimer?.stop()
        autoCloseTimer = nil

        unityWindow?.isHidden = true
        hostWindow?.makeKeyAndVisible()

        isRunning = false
    }

    /// 触发 Unity 的卸载流程（真正释放在 `unityDidUnload` 里完成）
    func unloadUnity() {
        autoCloseTimer?.stop()
        autoCloseTimer = nil

        guard let ufw = ufw else { return }
        ufw.unloadApplication()  // 异步，结束后会回调 unityDidUnload
    }

    // MARK: - JobsTimer 自动关闭

    private func setupAutoCloseTimer(
        after seconds: TimeInterval?,
        unloadOnClose: Bool
    ) {
        autoCloseTimer?.stop()
        autoCloseTimer = nil

        guard let seconds, seconds > 0 else { return }

        let config = JobsTimerConfig(
            interval: seconds,
            repeats: false,
            tolerance: 0.01,
            queue: .main
        )

        // 你可以按需换成 .gcd / .displayLink / .runLoopCore
        let timer: JobsTimerProtocol = JobsFoundationTimer(
            config: config
        ) { [weak self] in
            guard let self else { return }
            if unloadOnClose {
                self.unloadUnity()
            } else {
                self.hideUnity()
            }
        }

        autoCloseTimer = timer
        timer.start()
    }

    // MARK: - 兼容你之前的 API（名字不改，内部用全屏）

    /// 以前的“嵌入容器”接口，现在其实就是全屏 Unity + 自动关闭
    func attachUnity(
        into _: UIView,
        from host: UIViewController,
        autoCloseAfter seconds: TimeInterval? = nil,
        unloadOnClose: Bool = true
    ) {
        showUnity(from: host, autoCloseAfter: seconds, unloadOnClose: unloadOnClose)
    }

    /// 以前的 detach 接口：根据需要选择只隐藏还是卸载
    func detachUnity(
        from _: UIViewController,
        unload: Bool = true
    ) {
        if unload {
            unloadUnity()
        } else {
            hideUnity()
        }
    }
}

// MARK: - UnityFrameworkListener

extension UnityManager: UnityFrameworkListener {

    /// Unity 调用了 unloadApplication 之后会回调这里
    func unityDidUnload(_ notification: Notification!) {
        print("✅ Unity did unload")

        autoCloseTimer?.stop()
        autoCloseTimer = nil

        if let ufw = ufw {
            ufw.unregisterFrameworkListener(self)
        }
        ufw = nil
        isRunning = false

        // 卸载完 Unity 后把宿主窗口顶回来
        hostWindow?.makeKeyAndVisible()
    }

    func unityDidQuit(_ notification: Notification!) {
        print("✅ Unity did quit")
    }
}
