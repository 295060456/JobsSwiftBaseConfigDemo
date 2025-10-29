//
//  Demo@LiveChat.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/29/25.
//

import UIKit
import SnapKit
import LiveChat

final class LiveChatDemoVC: UIViewController, LiveChatDelegate {

    private lazy var btnDefault: UIButton = { [unowned self] in
        let b = UIButton.sys()
            .byTitle("默认展示（presentChat）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byBgColor(.systemBlue) // ≈ Configuration.filled 的视觉
            .onTap { [weak self] _ in
                self?.onDefault()    // ✅ 保留你原有触发逻辑
            }
            .byAddTo(self.view) { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
        // 可选：如果你已有 byConfiguration DSL，这里用系统样式做精细化
        if #available(iOS 15.0, *) {
            _ = b.byConfiguration { c in
                // 这里不强依赖你是否有 “byFilled()” 之类方法，
                // 只做通用属性设置，避免破坏现有实现
                c.byTitle("默认展示（presentChat）")
                 .byBaseForegroundColor(.white)
                 .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                 .byCornerStyle(.large)
            }
        }
        return b
    }()

    private lazy var btnCustom: UIButton = { [unowned self] in
        let b = UIButton.sys()
            .byTitle("自定义展示（半屏）", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byBgColor(.secondarySystemBackground) // ≈ Configuration.gray 的视觉
            .onTap { [weak self] _ in
                self?.onCustom()     // ✅ 保留你原有触发逻辑
            }
            .byAddTo(self.view) { make in
                make.top.equalTo(self.btnDefault.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }

        // 可选：iOS 15+ 用你的 byConfiguration 进行细化
        if #available(iOS 15.0, *) {
            _ = b.byConfiguration { c in
                c.byTitle("自定义展示（半屏）")
                 .byBaseForegroundColor(.label)
                 .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                 .byCornerStyle(.large)
                 .byImagePlacement(.trailing)
                 .byImagePadding(8)
            }
        }
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "LiveChat Demo")
        view.backgroundColor = .systemBackground

        view.addSubview(btnDefault)
        view.addSubview(btnCustom)

        btnDefault.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.greaterThanOrEqualTo(260)
        }
        btnCustom.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(btnDefault.snp.bottom).offset(16)
            make.width.equalTo(btnDefault)
        }
    }

    // MARK: - 默认方式（SDK 自带展示）
    @objc private func onDefault() {
        LiveChat.presentChat() // 一句到位
        // 如果你要监听打开/关闭等事件，可同时设置 delegate = self
        LiveChat.delegate = self
    }

    // MARK: - 自定义方式（你来决定怎么展示）
    @objc private func onCustom() {
        LiveChat.delegate = self
        LiveChat.customPresentationStyleEnabled = true

        guard let chatVC = LiveChat.chatViewController else {
            assertionFailure("chatViewController == nil，确认已设置 customPresentationStyleEnabled = true")
            return
        }

        // 例：以半屏 Sheet 展示（iOS 15+）
        chatVC.modalPresentationStyle = .pageSheet
        if let sheet = chatVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            } else {
                sheet.detents = [.medium(), .large()]
            }
        }
        present(chatVC, animated: true, completion: nil)
    }

    // MARK: - LiveChatDelegate（可选）
    func chatPresented() {
        print("✅ LiveChat 打开")
    }

    func chatDismissed() {
        print("🌓 LiveChat 关闭")
        // 如果是自定义展示，可以主动收起（默认展示不需要）
        if LiveChat.customPresentationStyleEnabled {
            LiveChat.chatViewController?.dismiss(animated: true, completion: nil)
        }
    }

    // 收到新消息（可用于角标/本地通知等）
    func received(message: LiveChatMessage) {
        print("📩 收到消息：\(message.text)")
    }

    // 统一接管聊天里的 URL（默认会走 Safari）
    func handle(URL: URL) {
        print("🔗 用户点击了链接：\(URL.absoluteString)")
        // 你可以在这里自行处理，比如用 SFSafariViewController 打开
    }

    // 加载失败（排障抓日志）
    func loadingDidFail(with errror: Error) {
        print("❌ LiveChat 加载失败：\(errror)")
    }
}
