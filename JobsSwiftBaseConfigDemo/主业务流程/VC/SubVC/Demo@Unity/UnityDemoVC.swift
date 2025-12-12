//
//  UnityDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/11/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import SnapKit
/// 要看这个功能演示，必须执行 ./Unity/xcode_effectTest/Libraries 下的合并脚本
final class UnityDemoVC: BaseVC {
    // ===== 配置 =====
    /// 自动关闭 Unity 的秒数，对外可改。<= 0 表示不开自动关闭
    var unityAutoCloseSeconds: TimeInterval = 3
    /// Unity 自动关闭用的定时器（如果你想用 JobsTimer 自己关，可以用它；目前用的是 UnityManager 里自带的 autoClose）
    private var unityAutoCloseTimer: JobsTimerProtocol?
    /// 定时器内核用哪种，外面也可以改（目前没用到）
    private var unityTimerKind: JobsTimerKind = .gcd  // 或 .foundation / .displayLink / .runLoopCore
    // ===== UI =====
    /// 中间用来放 Unity 的容器（现在只是占位，如果你以后要全屏可以不用它）
    private lazy var unityContainerView: UIView = {
        UIView()
            .byBgColor(.clear)
            .byCornerRadius(8)
            .byAddTo(view) { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 300, height: 300))
            }
    }()
    /// 顶部提示：要先执行合并脚本
    private lazy var tipLabel: UILabel = {
        UILabel()
            .byText("要看这个功能演示，必须先执行 ./Unity/xcode_effectTest/Libraries 下的合并脚本")
            .byTextColor(.systemRed)
            .byFont(.systemFont(ofSize: 13))
            .byNumberOfLines(0)
            .byTextAlignment(.center)
            .byAddTo(view) { [unowned self] make in
                make.leading.trailing.equalToSuperview().inset(24)
                make.bottom.equalTo(closeTimeTextField.snp.top).offset(-8)
            }
    }()
    /// 输入自动关闭时间（秒）
    private lazy var closeTimeTextField: UITextField = {
        UITextField()
            .byBorderStyle(.roundedRect)
            .byKeyboardType(.decimalPad)
            .byTextAlignment(.center)
            .byPlaceholder("自动关闭时间（秒）默认 3")
            .byText("3")
            .byAddTo(view) { [unowned self] make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(startUnityButton.snp.top).offset(-16)
                make.width.equalTo(160)
                make.height.equalTo(36)
        }
    }()
    /// 开始 Unity
    private lazy var startUnityButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemRed, for: .normal)
            .byTitle("开始 Unity", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCornerRadius(8)
            .onTap { [weak self] _ in
                guard let self else { return }
                let dataPath = Bundle.main.bundlePath + "/Data/boot.config"
                print("Data boot.config exists:", FileManager.default.fileExists(atPath: dataPath))
                // 从输入框读取关闭时间
                if let text = self.closeTimeTextField.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                   let value = TimeInterval(text),
                   value > 0 {
                    self.unityAutoCloseSeconds = value
                } else {
                    // 输入非法就回退到默认 3 秒
                    self.unityAutoCloseSeconds = 3
                    self.closeTimeTextField.text = "3"
                }
                // 打开 Unity，按输入的时间自动关闭并卸载
                UnityManager.shared.showUnity(
                    from: self,
                    autoCloseAfter: self.unityAutoCloseSeconds,
                    unloadOnClose: true
                )
            }
            .byAddTo(view) { [unowned self] make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
                make.width.equalTo(160)
            }
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "Unity@Demo")
        unityContainerView.byVisible(YES)
        startUnityButton.byVisible(YES)
        closeTimeTextField.byVisible(YES)
        tipLabel.byVisible(YES)
    }
}
/// JobsTimer 自己关 Unity
private extension UnityDemoVC {
    /// 安排自动关闭 Unity 的定时器（目前没用到）
    func scheduleUnityAutoClose() {
        unityAutoCloseTimer?.stop()
        unityAutoCloseTimer = nil
        guard unityAutoCloseSeconds > 0 else { return }
        let config = JobsTimerConfig(
            interval: unityAutoCloseSeconds,
            repeats: false,          // 一次性定时器
            tolerance: 0.1,
            queue: .main
        )

        let timer = JobsTimerFactory.make(
            kind: unityTimerKind,
            config: config
        ) { [weak self] in
            self?.closeUnity()
        }

        unityAutoCloseTimer = timer
        timer.start()
    }
    /// 统一的 Unity 关闭逻辑（如果用 JobsTimer 自己关就走这里）
    func closeUnity() {
        unityAutoCloseTimer?.stop()
        unityAutoCloseTimer = nil
        // 把 Unity 从窗口里移除 / 卸载
        UnityManager.shared.detachUnity(from: self)
        // 或者：
        // UnityManager.shared.unloadUnity()
    }
}
