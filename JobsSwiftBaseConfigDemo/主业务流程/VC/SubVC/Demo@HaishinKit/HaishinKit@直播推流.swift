//
//  HaishinKit@直播推流.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/8/25.
//

import UIKit
import AVFoundation
import SnapKit
import HaishinKit      // HaishinKit / RTMPHaishinKit

final class HKLiveVC: BaseVC {
    deinit {
        JobsNetworkTrafficMonitorStop()  /// 停止网络实时监听
        JobsCancelWaitNetworkDataReady() /// 停止网络数据源监听
    }
    // MARK: - 推流配置（根据你的服务器改掉即可）
    /// RTMP 服务器地址，例如：
    /// - 本机 NMS/SRS: rtmp://192.168.65.91:1935/live
    /// - 云端:        rtmp://example.com/live
    private let rtmpURI = "rtmp://192.168.65.91:1935/live"      // TODO: 换成你的 RTMP 地址
    private let streamName = "jobs_test"                        // TODO: 换成你的 streamName / 推流 key
    // 实际完整推流 URL = rtmp://192.168.65.91:1935/live/jobs_test
    // MARK: - HaishinKit 管线（2.x 写法）
    /// 采集（摄像头 + 麦克风）都挂在这里
    private let mixer = MediaMixer()
    /// RTMP 连接（长链接）
    private let connection = RTMPConnection()
    /// RTMP 推流流对象
    private lazy var stream = RTMPStream(connection: connection)
    /// 当前摄像头朝向
    private var currentPosition: AVCaptureDevice.Position = .back
    /// 是否正在推流
    private var isStreaming = false
    // MARK: - UI（懒加载 + 你的链式 API + SnapKit）
    /// 预览视图：HaishinKit 提供的 Metal 预览
    private lazy var previewView: MTHKView = {
        let v = MTHKView(frame: .zero)
        v.videoGravity = .resizeAspectFill
        // 链式封装：添加到 self.view 并用 SnapKit 约束全屏
        v.byAddTo(view) { make in
            make.edges.equalToSuperview()   // 全屏铺满
        };return v
    }()
    /// 状态文案
    private lazy var statusLabel: UILabel = {
        UILabel()
            .byTextColor(.white)
            .byNumberOfLines(0)
            .byFont(.systemFont(ofSize: 14))
            .byTextAlignment(.center)
            .byText("准备就绪")
            .byAddTo(view) { [unowned self] make in
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalTo(recordButton.snp.top).offset(-12)
            }
    }()
    /// 开始/停止推流按钮（沿用原来的样式）
    private lazy var recordButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemRed, for: .normal)
            .byBackgroundColor(.systemGray, for: .disabled)
            .byTitle("开始推流", for: .normal)
            .byTitle("停止推流", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 20, bottom: 10, right: 20))
            .byCornerDot(diameter: 10, offset: .init(horizontal: -6, vertical: 6)) // 红点提示
            .onTap { [weak self] btn in
                self?.toggleStreaming(btn)
            }
            .byAddTo(view) { [unowned self] make in
                make.left.right.equalToSuperview().inset(24)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(32)
                make.height.equalTo(44)
            }
    }()
    /// 切换前后摄像头按钮
    private lazy var switchCameraButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(UIColor.black.withAlphaComponent(0.4), for: .normal)
            .byImage("camera.rotate".sysImg, for: .normal)
            .byCornerRadius(20)
            .onTap { [weak self] _ in
                guard let self else { return }
                /// 切换前后摄像头（2.x 写法，不再用 DeviceUtil）
                currentPosition = (currentPosition == .back) ? .front : .back
                Task { @MainActor in
                    guard let device = AVCaptureDevice.default(
                        .builtInWideAngleCamera,
                        for: .video,
                        position: self.currentPosition
                    ) else {
                        print("⚠️ 找不到对应方向摄像头：\(self.currentPosition)")
                        return
                    }

                    do {
                        try await self.mixer.attachVideo(device)
                        let posText = (self.currentPosition == .back) ? "后置" : "前置"
                        self.statusLabel.byText("📷 已切换到 \(posText) 摄像头")
                    } catch {
                        print("⚠️ 切换摄像头失败：\(error)")
                        self.statusLabel.byText("❌ 切换摄像头失败：\(error.localizedDescription)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
                make.right.equalToSuperview().inset(20)
                make.size.equalTo(CGSize(width: 40, height: 40))
            }
    }()
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        /// 开启屏幕常亮
        keepScreenOn()
        /// 流量监控@上行下载
        networkRichListenerBy(view)
        /// UI
        previewView.byVisible(YES)
        recordButton.byVisible(YES)
        switchCameraButton.byVisible(YES)
        statusLabel.byVisible(YES)
        /// 申请摄像头 + 麦克风权限（简单版）
        requestCameraAndMicrophoneAuthorization()
        /// 配置音频 Session（来自官方 README 的写法，2.x 推荐）
        setupAudioSession()
        /// 初始化 HaishinKit 采集管线
        Task { @MainActor in
            await setupCapturePipeline()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Task { [weak self] in
            guard let self else { return }
            await self.cleanup()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// 关闭屏幕常亮
        endScreenOn()
    }
    // MARK: - 权限
    /// 申请摄像头 + 麦克风权限（简单版）
    private func requestCameraAndMicrophoneAuthorization() {
        Task {
            _ = await AVCaptureDevice.requestAccess(for: .video)
            _ = await AVCaptureDevice.requestAccess(for: .audio)
        }
    }
    // MARK: - AVAudioSession
    /// 配置音频 Session（来自官方 README 的写法，2.x 推荐）
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .videoRecording,
                options: [.defaultToSpeaker, .allowBluetoothHFP]
            )
            try session.setActive(true)
        } catch {
            print("⚠️ 配置 AVAudioSession 失败：\(error)")
        }
    }
    // MARK: - HaishinKit 采集管线（2.x 正确写法）
    /// 初始化采集（绑定摄像头 + 麦克风，串起来 mixer -> stream -> previewView）
    @MainActor
    private func setupCapturePipeline() async {
        // 1. 准备采集设备
        guard
            let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: currentPosition
            ),
            let audioDevice = AVCaptureDevice.default(for: .audio)
        else {
            statusLabel.byText("❌ 找不到摄像头或麦克风")
            return
        }
        // 2. 把设备 attach 到 MediaMixer
        do {
            try await mixer.attachVideo(videoDevice)
        } catch {
            print("⚠️ attachVideo 失败：\(error)")
        }

        do {
            try await mixer.attachAudio(audioDevice)
        } catch {
            print("⚠️ attachAudio 失败：\(error)")
        }
        // 3. mixer 输出到 RTMPStream
        await mixer.addOutput(stream)
        // 4. RTMPStream 再输出到预览视图
        await stream.addOutput(previewView) // 预览
        statusLabel.byText("✅ 采集已就绪，点击“开始推流”")
    }
    /// 释放资源
    private func cleanup() async {
        if isStreaming {
            await stopStreaming()
        }
        await mixer.stopRunning()
    }
    // MARK: - 推流控制
    private func toggleStreaming(_ sender: UIButton) {
        Task { @MainActor in
            if isStreaming {
                await stopStreaming()
            } else {
                await startStreaming()
            }
        }
    }
    /// 开始推流：连接 RTMP 服务器 + publish
    @MainActor
    private func startStreaming() async {
        guard !isStreaming else { return }
        statusLabel.byText("🔌 正在连接服务器...")
        do {
            // 1. 建立 RTMP 连接（长链接）
            let connectResponse = try await connection.connect(rtmpURI)
            print("✅ RTMP connect: \(connectResponse)")
            statusLabel.byText("🚀 正在发起推流请求...")
            // 2. 开始推流
            let publishResponse = try await stream.publish(streamName)
            print("✅ RTMP publish: \(publishResponse)")

            isStreaming = true
            recordButton.isSelected = true
            statusLabel.byText("🟢 已开始推流")
        } catch RTMPConnection.Error.requestFailed(let response) {
            statusLabel.byText("❌ 连接失败：\(String(describing: response.status))")
            print("⚠️ RTMPConnection.Error.requestFailed: \(response)")
        } catch RTMPStream.Error.requestFailed(let response) {
            statusLabel.byText("❌ 推流失败：\(String(describing: response.status))")
            print("⚠️ RTMPStream.Error.requestFailed: \(response)")
        } catch {
            statusLabel.byText("❌ 推流异常：\(error.localizedDescription)")
            print("⚠️ startStreaming 失败：\(error)")
        }
    }
    /// 停止推流：关闭 RTMP 连接（服务器侧会自动 unpublish）
    @MainActor
    private func stopStreaming() async {
        guard isStreaming else { return }
        statusLabel.byText("⏹ 正在停止推流...")
        do {
            try await connection.close()
            isStreaming = false
            recordButton.isSelected = false
            statusLabel.byText("✅ 已停止推流")
        } catch {
            // close 失败一般问题不大，但还是打印一下
            statusLabel.byText("⚠️ 停止推流异常：\(error.localizedDescription)")
            print("⚠️ stopStreaming 失败：\(error)")
        }
    }
}
