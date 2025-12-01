//
//  VideoTextureManager.swift
//  PNPlayer
//
//  Created by linghugoogle on 2025/10/11.
//

import AVFoundation
import Metal
import CoreVideo

protocol VideoTextureManagerDelegate: AnyObject {
    func videoDidUpdateTime(currentTime: TimeInterval, duration: TimeInterval)
    func videoPlaybackStateChanged(isPlaying: Bool)
}

class VideoTextureManager: NSObject {
    private let device: MTLDevice
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private var textureCache: CVMetalTextureCache?
    private var timeObserver: Any?
    
    weak var delegate: VideoTextureManagerDelegate?
    var currentTexture: MTLTexture?
    
    var isPlaying: Bool {
        return player?.rate != 0
    }
    
    var duration: TimeInterval {
        guard let playerItem = playerItem else { return 0 }
        let duration = playerItem.duration
        let seconds = CMTimeGetSeconds(duration)
        return seconds.isFinite && !seconds.isNaN && seconds > 0 ? seconds : 0
    }
    
    var currentTime: TimeInterval {
        guard let player = player else { return 0 }
        let seconds = CMTimeGetSeconds(player.currentTime())
        return seconds.isFinite && !seconds.isNaN && seconds >= 0 ? seconds : 0
    }
    
    init(device: MTLDevice) {
        self.device = device
        super.init()
        
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
    }
    
    func loadVideo(url: URL) {
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        let outputSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:] as CFDictionary
        ] as [String : Any]
        
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: outputSettings)
        playerItem?.add(videoOutput!)
        
        setupDisplayLink()
        setupTimeObserver()
        setupNotifications()
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateTexture))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        displayLink?.preferredFramesPerSecond = 60
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            let duration = self.duration
            self.delegate?.videoDidUpdateTime(currentTime: currentTime, duration: duration)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    @objc private func playerItemDidReachEnd() {
        delegate?.videoPlaybackStateChanged(isPlaying: false)
    }
    
    @objc private func updateTexture() {
        guard let videoOutput = videoOutput,
              let playerItem = playerItem else { return }
        
        let currentTime = playerItem.currentTime()
        
        if videoOutput.hasNewPixelBuffer(forItemTime: currentTime) {
            guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else { return }
            
            createTexture(from: pixelBuffer)
        }
    }
    
    private func createTexture(from pixelBuffer: CVPixelBuffer) {
        guard let textureCache = textureCache else { return }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var metalTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &metalTexture
        )
        
        if status == kCVReturnSuccess, let metalTexture = metalTexture {
            currentTexture = CVMetalTextureGetTexture(metalTexture)
        }
    }
    
    func play() {
        player?.play()
        delegate?.videoPlaybackStateChanged(isPlaying: true)
    }
    
    func pause() {
        player?.pause()
        delegate?.videoPlaybackStateChanged(isPlaying: false)
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.videoDidUpdateTime(currentTime: self.currentTime, duration: self.duration)
        }
    }
    
    deinit {
        displayLink?.invalidate()
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
