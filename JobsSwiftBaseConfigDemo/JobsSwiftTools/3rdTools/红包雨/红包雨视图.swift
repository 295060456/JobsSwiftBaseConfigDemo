//
//  红包雨视图.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import SnapKit
// MARK: —— 红包雨视图
public final class RedPacketRainView: UIView {
    deinit {
        spawnTimer?.stop()
    }
    // 对外配置 & 回调
    public var config: RedPacketRainConfig {
        didSet { /* 需要的话可以在这里做重置 */ }
    }
    /// 点中红包的回调（参数：红包雨视图，总共点中的数量）
    public var tapCallback: ((RedPacketRainView, Int) -> Void)?
    /// 当前是否正在“下红包雨”
    public private(set) var isRunning: Bool = false
    /// 累计点中红包的数量
    public private(set) var tappedCount: Int = 0
    // 使用哪种 JobsTimer 内核
    private let timerKind: JobsTimerKind
    // 内部状态
    private var spawnTimer: JobsTimerProtocol?
    /// 当前屏幕上的红包按钮
    private var activePackets: [UIButton] = []
    // MARK: - Init
    public init(
        frame: CGRect = .zero,
        config: RedPacketRainConfig = .default,
        timerKind: JobsTimerKind = .gcd
    ) {
        self.config = config
        self.timerKind = timerKind
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.config = .default
        self.timerKind = .gcd
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
    // MARK: - 对外控制
    public func start() {
        guard !isRunning else { return }
        buildTimerIfNeeded()
        spawnTimer?.start()
        isRunning = true
    }

    public func pause() {
        guard isRunning else { return }
        spawnTimer?.pause()
        isRunning = false
    }

    public func resume() {
        guard !isRunning else { return }
        spawnTimer?.resume()
        isRunning = true
    }
    /// 停止红包雨
    /// - Parameter clear: 是否把屏幕上现有红包也移除
    public func stop(clear: Bool = true) {
        isRunning = false
        spawnTimer?.stop()
        spawnTimer = nil
        if clear {
            clearAllPackets()
        }
    }
    /// 完全重置（停止 + 清空 + 计数清零）
    public func reset() {
        stop(clear: true)
        tappedCount = 0
    }
    // MARK: - Timer
    private func buildTimerIfNeeded() {
        guard spawnTimer == nil else { return }

        let cfg = JobsTimerConfig(
            interval: max(0.05, config.spawnInterval),
            repeats: true,
            tolerance: 0.01,
            queue: .main
        )

        spawnTimer = JobsTimerFactory.make(
            kind: timerKind,
            config: cfg
        ) { [weak self] in
            self?.spawnPacketIfNeeded()
        }
    }
    // MARK: - 红包生成逻辑（UIButton 版本）
    private func spawnPacketIfNeeded() {
        guard isRunning else { return }
        guard bounds.width > 0, bounds.height > 0 else { return }

        // 控制并发上限
        if activePackets.count >= config.maxConcurrentCount {
            return
        }
        let width = bounds.width - config.spawnInsets.left - config.spawnInsets.right
        guard width > 0 else { return }
        // 随机 X
        let maxX = max(0, width - config.packetSize.width)
        let randomX = config.spawnInsets.left + CGFloat.random(in: 0...maxX)
        let startFrame = CGRect(
            x: randomX,
            y: -config.packetSize.height,
            width: config.packetSize.width,
            height: config.packetSize.height
        )
        // 用 UIButton + DSL 创建单个红包
        let packet = UIButton.sys()
        packet.frame = startFrame
        packet.isUserInteractionEnabled = config.tapEnabled
        packet.clipsToBounds = true

        if let img = config.packetImage {
            // 有配置图片：直接用图片做背景
            packet.setBackgroundImage(img, for: .normal)
            packet.imageView?.contentMode = .scaleAspectFit
        } else {
            // 简单占位：红底 + 黄金边框 + 中间 ¥ 图标
            packet.backgroundColor = .systemRed
            packet.layer.cornerRadius = 6
            packet.layer.borderColor = UIColor.yellow.cgColor
            packet.layer.borderWidth = 1.5
            packet.layer.masksToBounds = true
            packet.byBackgroundImage(makeDefaultIconImage())
        }

        if config.tapEnabled {
            // MARK: - 点击红包（用你的 onTap DSL）
            packet.onTap { [weak self] sender in
                guard let self = self else { return }
                self.removePacket(sender)
                self.tappedCount += 1
                self.tapCallback?(self, self.tappedCount)

                // 点击后的简单反馈：轻微震动
                let feedback = UIImpactFeedbackGenerator(style: .light)
                feedback.impactOccurred()
            }
        }

        addSubview(packet)
        activePackets.append(packet)

        // 随机下落时间
        let duration = Double.random(
            in: min(config.minFallDuration, config.maxFallDuration)
            ... max(config.minFallDuration, config.maxFallDuration)
        )

        var endFrame = packet.frame
        endFrame.origin.y = bounds.height + config.packetSize.height

        // 稍微加一点水平漂移，视觉更自然一点
        let drift = CGFloat.random(in: -40...40)
        endFrame.origin.x = min(
            max(config.spawnInsets.left, endFrame.origin.x + drift),
            bounds.width - config.spawnInsets.right - config.packetSize.width
        )

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveLinear, .allowUserInteraction],
            animations: {
                packet.frame = endFrame
                // 轻微旋转
                let angle = CGFloat.random(in: -0.25...0.25)
                packet.transform = CGAffineTransform(rotationAngle: angle)
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.removePacket(packet)
            }
        )
    }

    private func clearAllPackets() {
        activePackets.forEach { $0.removeFromSuperview() }
        activePackets.removeAll()
    }

    private func removePacket(_ packet: UIButton) {
        if let idx = activePackets.firstIndex(where: { $0 === packet }) {
            activePackets.remove(at: idx)
        }
        packet.removeFromSuperview()
    }
    // MARK: - 简单生成一个默认图标（¥）
    private func makeDefaultIconImage() -> UIImage? {
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(ovalIn: rect)
        UIColor.red.setFill()
        path.fill()

        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.yellow
        ]
        let text = "$" as NSString
        let textSize = text.size(withAttributes: attr)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attr)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
// MARK: - DSL 扩展
public extension RedPacketRainView {
    /// 类似 UIButton.sys()：默认 config + 默认 timerKind
    static func dsl(
        config: RedPacketRainConfig = .default,
        timerKind: JobsTimerKind = .gcd
    ) -> RedPacketRainView {
        RedPacketRainView(config: config, timerKind: timerKind)
    }
    /// 链式配置整体 config
    @discardableResult
    func byConfig(_ config: RedPacketRainConfig) -> Self {
        self.config = config
        return self
    }
    /// 链式设置点击红包回调
    @discardableResult
    func onPacketTap(_ callback: @escaping (RedPacketRainView, Int) -> Void) -> Self {
        self.tapCallback = callback
        return self
    }
    /// 开始红包雨
    @discardableResult
    func byStart() -> Self {
        start()
        return self
    }
    /// 暂停红包雨
    @discardableResult
    func byPause() -> Self {
        pause()
        return self
    }
    /// 恢复红包雨
    @discardableResult
    func byResume() -> Self {
        resume()
        return self
    }
    /// 停止红包雨
    @discardableResult
    func byStop(clear: Bool = true) -> Self {
        stop(clear: clear)
        return self
    }
    /// 重置（停止 + 清空 + 计数清零）
    @discardableResult
    func byReset() -> Self {
        reset()
        return self
    }
}
