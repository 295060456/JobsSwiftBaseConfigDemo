//
//  UIView+JobsCountdownFuse.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import ObjectiveC
/// 导火索式倒计时：在任意 UIView 最外层画一圈可消耗的边框，随着时间递减
/// 导火索倒计时配置（按需可以继续扩）
/// 这里先做最小配置：线宽、颜色、内边距、结束后是否移除
public struct JobsFuseConfig {
    public var lineWidth: CGFloat
    public var color: UIColor
    public var inset: CGFloat
    public var removeOnFinish: Bool

    public init(lineWidth: CGFloat = 4,
                color: UIColor = .systemRed,
                inset: CGFloat = 0,
                removeOnFinish: Bool = true) {
        self.lineWidth = lineWidth
        self.color = color
        self.inset = inset
        self.removeOnFinish = removeOnFinish
    }
}

public extension UIView {
    // MARK: - Associated Keys
    private struct JobsFuseKeys {
        static var processKey: UInt8 = 0
        static var layerKey: UInt8 = 0
        static var configKey: UInt8 = 0
    }

    private var jobs_fuseProcess: JobsCountdownProcess? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.processKey) as? JobsCountdownProcess
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.processKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var jobs_fuseLayer: CAShapeLayer? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.layerKey) as? CAShapeLayer
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.layerKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var jobs_fuseConfig: JobsFuseConfig? {
        get {
            objc_getAssociatedObject(self, &JobsFuseKeys.configKey) as? JobsFuseConfig
        }
        set {
            objc_setAssociatedObject(self,
                                     &JobsFuseKeys.configKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // MARK: - 公共 API
    /// DSL 写法：在当前视图上挂一个导火索倒计时
    @discardableResult
    func byFuseCountdown(duration: TimeInterval,
                         config: JobsFuseConfig = JobsFuseConfig(),
                         finished: (() -> Void)? = nil) -> Self {
        jobs_startFuseCountdown(duration: duration,
                                config: config,
                                finished: finished)
        return self
    }
    /// 显式启动导火索倒计时
    ///
    /// - Parameters:
    ///   - duration: 总时长（秒）
    ///   - config: 外观配置（线宽、颜色、inset）
    ///   - finished: 结束时回调
    @discardableResult
    func jobs_startFuseCountdown(duration: TimeInterval,
                                 config: JobsFuseConfig = JobsFuseConfig(),
                                 finished: (() -> Void)? = nil) -> JobsCountdownProcess? {

        // 布局先稳定一下，避免 bounds 为 0
        layoutIfNeeded()

        guard bounds.width > 0, bounds.height > 0 else {
            // 尺寸为 0，直接不给你画，省心
            return nil
        }

        // 先停掉旧的
        jobs_fuseProcess?.cancel()
        jobs_fuseProcess = nil

        // 记录配置
        jobs_fuseConfig = config

        // 拿到 / 创建 Layer
        let fuseLayer: CAShapeLayer
        if let existing = jobs_fuseLayer {
            fuseLayer = existing
        } else {
            fuseLayer = CAShapeLayer()
            fuseLayer.fillColor = UIColor.clear.cgColor
            fuseLayer.lineCap = .round
            layer.addSublayer(fuseLayer)
            jobs_fuseLayer = fuseLayer
        }

        // 配置 Layer 几何与样式
        fuseLayer.frame = bounds

        let inset = config.inset + config.lineWidth / 2.0
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let cornerRadius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

        fuseLayer.path = path.cgPath
        fuseLayer.lineWidth = config.lineWidth
        fuseLayer.strokeColor = config.color.cgColor
        fuseLayer.strokeStart = 0
        fuseLayer.strokeEnd = 1       // 一开始满格

        // 创建内部倒计时过程（沿用你现在的 JobsCountdownProcess 语义）
        let process = JobsCountdownProcess(
            duration: duration,
            kind: .displayLink,
            tickInterval: 1.0 / 60.0,
            tolerance: 0,
            queue: .main
        )

        // 进度更新：strokeEnd 从 1 → 0，导火索被“烧掉”
        process.onProgress = { [weak self] snap in
            guard let self = self,
                  let fuseLayer = self.jobs_fuseLayer else { return }
            let remainRatio = CGFloat(1.0 - snap.progress)
            fuseLayer.strokeEnd = max(0, min(1, remainRatio))
        }

        // 结束：视图恢复干净 / 保留最后状态
        process.onFinished = { [weak self] _ in
            guard let self = self else { return }

            if config.removeOnFinish {
                self.jobs_removeFuseLayer()
            } else {
                self.jobs_fuseLayer?.strokeEnd = 0
            }

            self.jobs_fuseProcess = nil
            finished?()
        }

        jobs_fuseProcess = process
        process.start()

        return process
    }
    /// 取消导火索倒计时
    func jobs_cancelFuseCountdown(removeLayer: Bool = true) {
        jobs_fuseProcess?.cancel()
        jobs_fuseProcess = nil

        if removeLayer {
            jobs_removeFuseLayer()
        }
    }
    // MARK: - 手动刷新布局（如果你在动画中改变了 view 的大小，可选调用）
    /// 如果 view 的 bounds 发生改变，想让导火索跟着更新一圈，可以在外面的 layoutSubviews/动画回调里手动调一下
    func jobs_layoutFuseIfNeeded() {
        guard let fuseLayer = jobs_fuseLayer,
              let config = jobs_fuseConfig else { return }

        layoutIfNeeded()
        fuseLayer.frame = bounds
        
        let inset = config.inset + config.lineWidth / 2.0
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let cornerRadius = self.layer.cornerRadius
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        fuseLayer.path = path.cgPath
    }
    // MARK: - Private
    private func jobs_removeFuseLayer() {
        jobs_fuseLayer?.removeFromSuperlayer()
        jobs_fuseLayer = nil
    }
}
