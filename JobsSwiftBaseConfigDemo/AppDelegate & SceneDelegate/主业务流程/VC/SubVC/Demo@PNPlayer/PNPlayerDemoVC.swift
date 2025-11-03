//
//  PNPlayerDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/30/25.
//
//  https://github.com/linghugoogle/PNPlayer

import UIKit
import SnapKit
import MetalKit
import AVFoundation

class PNPlayerDemoVC: BaseVC {
    private lazy var renderer: MetalRenderer = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        return MetalRenderer(device: device)
            .byVideoTextureManagerDelegate(self)
    }()
    private lazy var metalView: MTKView = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        return MTKView(frame: .zero, device: device)
            .byClearColor(MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1))
            .byDepthStencilPixelFormat(.depth32Float)
            .byColorPixelFormat(.bgra8Unorm)
            .bySampleCount(4)
            .byPreferredFramesPerSecond(60)
            .byDelegate(renderer)
            .addPanAction { [weak self] gr in
                guard let self else { return }
                let p = (gr as! UIPanGestureRecognizer).translation(in: gr.view)
                print("拖拽中: \(p)")
                renderer.handlePan((gr as! UIPanGestureRecognizer), in: metalView)
                showControlsTemporarily()
            }
            .addTapAction { [weak self] gr in
                guard let self else { return }
                print("点击 \(gr.view!)")
                toggleControlsVisibility()
            }
            .byAddTo(view) { [unowned self] make in
                make.edges.equalToSuperview() // 全屏铺满
            }
    }()
    private lazy var controlsView: PlayerControlsView = {
        PlayerControlsView()
            .byDelegate(self)
            .byAddTo(view) { [unowned self] make in
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
                make.height.equalTo(68)
            }.byAlpha(0)
    }()
    private var controlsHideTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.byVisible(YES)
        controlsView.byVisible(YES)
        loadSampleVideo()
        configureAudioSession()
    }
    // MARK: - 加载示例视频
    private func loadSampleVideo() {
        guard let videoURL = Bundle.main.url(forResource: "pano_360", withExtension: "mp4") else {
            print("Sample video not found")
            return
        }
        renderer.loadVideo(url: videoURL)
    }
    // MARK: - 音频会话
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    // MARK: - 交互
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        renderer.handlePan(gesture, in: metalView)
        showControlsTemporarily()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        toggleControlsVisibility()
    }

    private func showControlsTemporarily() {
        controlsView.show()
        resetHideTimer()
    }

    private func toggleControlsVisibility() {
        if controlsView.alpha > 0 {
            controlsView.hide()
            controlsHideTimer?.invalidate()
        } else {
            showControlsTemporarily()
        }
    }

    private func resetHideTimer() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.controlsView.hide()
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
// MARK: - PlayerControlsDelegate
extension PNPlayerDemoVC: PlayerControlsDelegate {
    func didTapPlayPause() {
        renderer.togglePlayPause()
        resetHideTimer()
    }

    func didSeekToTime(_ time: TimeInterval) {
        renderer.bySeekToTime(time)
        resetHideTimer()
    }
}
// MARK: - VideoTextureManagerDelegate
extension PNPlayerDemoVC: VideoTextureManagerDelegate {
    func videoDidUpdateTime(currentTime: TimeInterval, duration: TimeInterval) {
        controlsView.updateProgress(currentTime: currentTime, duration: duration)
    }

    func videoPlaybackStateChanged(isPlaying: Bool) {
        controlsView.updatePlayPauseButton(isPlaying: isPlaying)
    }
}
