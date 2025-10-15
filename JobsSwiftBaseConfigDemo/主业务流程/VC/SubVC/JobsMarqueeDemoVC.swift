//
//  JobsMarqueeDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/11.
//

import UIKit
import SnapKit
#if canImport(SDWebImage)
import SDWebImage
#endif
#if canImport(Kingfisher)
import Kingfisher
#endif

final class JobsMarqueeDemoVC: BaseVC {
    // ================================== 状态 ==================================
    private var currentDirection: MarqueeDirection = .left
    private var currentMode: MarqueeMode = .continuous(speed: 40)
    /// 由于 JobsMarqueeView 默认自动开始，这里 VC 侧用本地状态位来管理按钮可用性
    private var started: Bool = true   // 进入页面即视为已开启
    private var paused: Bool  = false  // 初始未暂停
    // ================================== 1) 文本（普通） ==================================
    private lazy var marqueeText: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.continuous(speed: 40))
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(true)
            .byDirectionalLockEnabled(true)
            .byHardAxisLock(true)
            .byDecelerationRate(.fast)
            .byPauseOnUserDrag(true)
            .byResumeAfterDragDelay(0.8)
            .byItemSpacing(8)
            .byItemMainAxisLength(.fillViewport)
            .byPreferredHeight(64)
            .byOnItemTap { idx, btn in
                print("TEXT tap idx=\(idx), title=\(btn.title(for: .normal) ?? "-")")
            }
            .setButtons([
                UIButton(type: .system)
                    .byTitle("跑马灯 · 主标题")
                    .byTitleFont(.systemFont(ofSize: 17, weight: .semibold))
                    .byTitleColor(.white)
                    .bySubTitle("副标题：普通文本")
                    .bySubTitleFont(.systemFont(ofSize: 11))
                    .bySubTitleColor(UIColor.white.withAlphaComponent(0.85))
                    .byNormalBgColor(.systemIndigo)
                    .byContentEdgeInsets(.init(top: 8, left: 12, bottom: 8, right: 12))
                    .byImagePlacement(.leading, padding: 8)
                    .byImage(UIImage(systemName: "bolt.horizontal.circle.fill"))
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10)
                make.left.right.equalToSuperview()
                make.height.equalTo(64)
            }
//            // ✅ UIView 层启动开关：父视图先布局 → 若是 Marquee 再重建 → 内部自动 start
            .byActivateAfterAdd()
            .refreshAfterConstraints()
    }()

    // ================================== 2) 文本（富文本：JobsRichText） ==================================
    private lazy var marqueeRich: JobsMarqueeView = {
        return JobsMarqueeView()
            .byDirection(.left)
            .byMode(.continuous(speed: 40))                // 跑马灯：连续模式 → 不显示 PageControl
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(true)
            .byDirectionalLockEnabled(true)
            .byHardAxisLock(true)
            .byDecelerationRate(.fast)
            .byPauseOnUserDrag(true)
            .byResumeAfterDragDelay(0.8)
            .byItemSpacing(8)
            .byOnItemTap { idx, _ in
                print("RICH tap idx=\(idx)")
            }
            .setButtons([UIButton(type: .system)
                .byRichTitle(JobsRichText.make([
                    JobsRichRun(.text("【富文本主标题】"))
                        .font(.systemFont(ofSize: 18, weight: .bold))
                        .color(.white)
                ]))
                .byRichSubTitle(JobsRichText.make([
                    JobsRichRun(.text("副标题 · Attributed  "))
                        .font(.systemFont(ofSize: 11)).color(.white.withAlphaComponent(0.85)),
                    JobsRichRun(.text("下划线")).underline(.single, color: .white),
                    JobsRichRun(.text("  ")),
                    JobsRichRun(.text("删除线")).strike(.single, color: .white.withAlphaComponent(0.9))
                ]))
                .byNormalBgColor(.systemTeal)
                .byContentEdgeInsets(.init(top: 8, left: 12, bottom: 8, right: 12))
                .byImagePlacement(.leading, padding: 8)
                .byImage("Ani".img)
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeText.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(64)
            }
    }()

    // ================================== 3) 轮播图（本地图，开启 PageControl：默认灰/白） ==================================
    private lazy var marqueeLocal: JobsMarqueeView = {
        JobsMarqueeView()
            .byItemMainAxisLength(.fillViewport)          // ✅ 轮播：每页=视口
            .byDirection(.left)                            // ✅ 横向
            .byMode(.intervalOnce(interval: 2.0, duration: 0.30, step: nil)) // ✅ 间隔模式（PageControl 允许出现）
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(true)
            .byDirectionalLockEnabled(true)
            .byHardAxisLock(true)
            .byDecelerationRate(.fast)
            .byPauseOnUserDrag(true)
            .byResumeAfterDragDelay(0.8)
            .byItemSpacing(0)
            .byPageControlEnabled(true)                   // ✅ 开启 PageControl
            // .byPageIndicatorAppearance(.init(            // 如需自定义为“图片”，解注释传图
            //     currentImage: UIImage(named: "dot_active"),
            //     inactiveImage: UIImage(named: "dot_inactive")
            // ))
            .byOnItemTap { idx, _ in
                print("LOCAL tap idx=\(idx)")
            }
            .setButtons([
                UIButton(type: .custom)
                    .byContentEdgeInsets(.zero)
                    .byClipsToBounds(true)
                    .byBackgroundImage("唐老鸭".img)
                    .byNormalBgColor(.tertiarySystemFill)
                    .byTitle("本地封面①").byTitleFont(.systemFont(ofSize: 12)).byTitleColor(.secondaryLabel)
                    .byCornerRadius(0),
                UIButton(type: .custom)
                    .byContentEdgeInsets(.zero)
                    .byClipsToBounds(true)
                    .byBackgroundImage("唐老鸭".img)
                    .byNormalBgColor(.tertiarySystemFill)
                    .byTitle("本地封面②").byTitleFont(.systemFont(ofSize: 12)).byTitleColor(.secondaryLabel)
                    .byCornerRadius(0)
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeRich.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(96)
            }
    }()

    // ================================== 4) 轮播图（网络：SDWebImage，开启 PageControl：自定义颜色） ==================================
    private lazy var marqueeRemoteSD: JobsMarqueeView = {
        return JobsMarqueeView()
            .byItemMainAxisLength(.fillViewport)
            .byDirection(.left)
            .byMode(.intervalOnce(interval: 2.5, duration: 0.30, step: nil)) // 改为间隔模式
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(true)
            .byDirectionalLockEnabled(true)
            .byHardAxisLock(true)
            .byDecelerationRate(.fast)
            .byPauseOnUserDrag(true)
            .byResumeAfterDragDelay(0.8)
            .byItemSpacing(0)
            .byPageControlEnabled(true)
            .byPageIndicatorAppearance(.init(
                currentColor: .white,
                inactiveColor: UIColor.white.withAlphaComponent(0.35)
            ))
            .setButtons([
                UIButton(type: .custom)
                    .byContentEdgeInsets(.zero)
                    .byClipsToBounds(true)
                    .byNormalBgColor(.tertiarySystemFill)
                    .byBackgroundImageContentMode(.scaleAspectFill)
                    .byCornerRadius(0)
                    .byTitle("网络封面 (SD) A").byTitleFont(.systemFont(ofSize: 12)).byTitleColor(.secondaryLabel)
                    .sd_imageURL("https://picsum.photos/760/320?random=101")
                    .sd_placeholderImage("唐老鸭".img)
                    .sd_options([.scaleDownLargeImages, .retryFailed])
                    .sd_context([.imageScaleFactor: UIScreen.main.scale])
                    .sd_bgNormalLoad(),
                UIButton(type: .custom)
                    .byContentEdgeInsets(.zero)
                    .byClipsToBounds(true)
                    .byNormalBgColor(.tertiarySystemFill)
                    .byBackgroundImageContentMode(.scaleAspectFill)
                    .byCornerRadius(0)
                    .byTitle("网络封面 (SD) B").byTitleFont(.systemFont(ofSize: 12)).byTitleColor(.secondaryLabel)
                    .sd_imageURL("https://picsum.photos/760/320?random=102")
                    .sd_placeholderImage("唐老鸭".img)
                    .sd_options([.scaleDownLargeImages, .retryFailed])
                    .sd_context([.imageScaleFactor: UIScreen.main.scale])
                    .sd_bgNormalLoad()
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeLocal.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(120)
            }
    }()

    // ================================== 5) 轮播图（网络：Kingfisher，开启 PageControl） ==================================
    private lazy var marqueeRemoteKF: JobsMarqueeView = {
        JobsMarqueeView()
            .byItemMainAxisLength(.fillViewport)
            .byDirection(.left)
            .byMode(.intervalOnce(interval: 2.2, duration: 0.30, step: nil)) // 改为间隔模式
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(true)
            .byDirectionalLockEnabled(true)
            .byHardAxisLock(true)
            .byDecelerationRate(.fast)
            .byPauseOnUserDrag(true)
            .byResumeAfterDragDelay(0.8)
            .byItemSpacing(0)
            .byPageControlEnabled(true)
            .setButtons([
                UIButton(type: .system)
                    .byCornerRadius(12)
                    .byClipsToBounds(true)
                    .byTitle("我是主标题@Kingfisher").byTitleColor(.red)
                    .bySubTitle("我是副标题@Kingfisher").bySubTitleColor(.yellow)
                    .kf_imageURL("https://picsum.photos/760/320?random=201")
                    .kf_placeholderImage("唐老鸭".img)
                    .kf_options([
                        .processor(DownsamplingImageProcessor(size: CGSize(width: 760, height: 320))),
                        .scaleFactor(UIScreen.main.scale),
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                        .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
                    ])
                    .kf_bgNormalLoad(),
                UIButton(type: .system)
                    .byCornerRadius(12)
                    .byClipsToBounds(true)
                    .byTitle("KF 第二页").byTitleColor(.white)
                    .bySubTitle("副标题").bySubTitleColor(.white)
                    .kf_imageURL("https://picsum.photos/760/320?random=202")
                    .kf_placeholderImage("唐老鸭".img)
                    .kf_options([
                        .processor(DownsamplingImageProcessor(size: CGSize(width: 760, height: 320))),
                        .scaleFactor(UIScreen.main.scale),
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                        .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
                    ])
                    .kf_bgNormalLoad()
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeRemoteSD.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(120)
            }
            .refreshAfterConstraints()   // 约束/布局确定后触发重建
    }()

    // ================================== 控制按钮（与原来一致） ==================================
    private lazy var btnStart: UIButton = {
        UIButton(type: .system)
            .byTitle("开始")
            .byTitleFont(.systemFont(ofSize: 14, weight: .semibold))
            .byTitleColor(.white)
            .byNormalBgColor(.systemBlue)
            .byCornerRadius(0)
            .onTap { [unowned self] _ in startAll() }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeRemoteKF.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(12)
                make.height.equalTo(36)
            }
    }()
    private lazy var btnPause: UIButton = {
        UIButton(type: .system)
            .byTitle("暂停")
            .byTitleFont(.systemFont(ofSize: 14, weight: .semibold))
            .byTitleColor(.white)
            .byNormalBgColor(.systemBlue)
            .byCornerRadius(0)
            .onTap { [unowned self] _ in pauseAll() }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnStart.snp.right).offset(8)
                make.centerY.equalTo(self.btnStart)
                make.height.equalTo(self.btnStart)
                make.width.equalTo(self.btnStart)
            }
    }()
    private lazy var btnResume: UIButton = {
        UIButton(type: .system)
            .byTitle("继续")
            .byTitleFont(.systemFont(ofSize: 14, weight: .semibold))
            .byTitleColor(.white)
            .byNormalBgColor(.systemBlue)
            .byCornerRadius(0)
            .onTap { [unowned self] _ in resumeAll() }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnPause.snp.right).offset(8)
                make.centerY.equalTo(self.btnStart)
                make.height.equalTo(self.btnStart)
                make.width.equalTo(self.btnStart)
            }
    }()
    private lazy var btnStop: UIButton = {
        UIButton(type: .system)
            .byTitle("停止")
            .byTitleFont(.systemFont(ofSize: 14, weight: .semibold))
            .byTitleColor(.white)
            .byNormalBgColor(.systemBlue)
            .byCornerRadius(0)
            .onTap { [unowned self] _ in stopAll() }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnResume.snp.right).offset(8)
                make.centerY.equalTo(self.btnStart)
                make.height.equalTo(self.btnStart)
                make.width.equalTo(self.btnStart)
            }
    }()
    private lazy var btnFire: UIButton = {
        UIButton(type: .system)
            .byTitle("一次")
            .byTitleFont(.systemFont(ofSize: 14, weight: .semibold))
            .byTitleColor(.white)
            .byNormalBgColor(.systemBlue)
            .byCornerRadius(0)
            .onTap { [unowned self] _ in fireOnceAll() }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnStop.snp.right).offset(8)
                make.right.equalToSuperview().inset(12)
                make.centerY.equalTo(self.btnStart)
                make.height.equalTo(self.btnStart)
                make.width.equalTo(self.btnStart)
            }
    }()

    // 第二排：方向（左/右/上/下）
    private lazy var btnDirLeft: UIButton = {
        UIButton(type: .system)
            .byTitle("← 左").byTitleFont(.systemFont(ofSize: 14, weight: .semibold)).byTitleColor(.white)
            .byNormalBgColor(.systemIndigo).byCornerRadius(0)
            .onTap { [unowned self] _ in applyDirection(.left) }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnStart.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(12)
                make.height.equalTo(36)
            }
    }()
    private lazy var btnDirRight: UIButton = {
        UIButton(type: .system)
            .byTitle("→ 右").byTitleFont(.systemFont(ofSize: 14, weight: .semibold)).byTitleColor(.white)
            .byNormalBgColor(.systemIndigo).byCornerRadius(0)
            .onTap { [unowned self] _ in applyDirection(.right) }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnDirLeft.snp.right).offset(8)
                make.centerY.equalTo(self.btnDirLeft)
                make.height.equalTo(self.btnDirLeft)
                make.width.equalTo(self.btnDirLeft)
            }
    }()
    private lazy var btnDirUp: UIButton = {
        UIButton(type: .system)
            .byTitle("↑ 上").byTitleFont(.systemFont(ofSize: 14, weight: .semibold)).byTitleColor(.white)
            .byNormalBgColor(.systemIndigo).byCornerRadius(0)
            .onTap { [unowned self] _ in applyDirection(.up) }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnDirRight.snp.right).offset(8)
                make.centerY.equalTo(self.btnDirLeft)
                make.height.equalTo(self.btnDirLeft)
                make.width.equalTo(self.btnDirLeft)
            }
    }()
    private lazy var btnDirDown: UIButton = {
        UIButton(type: .system)
            .byTitle("↓ 下").byTitleFont(.systemFont(ofSize: 14, weight: .semibold)).byTitleColor(.white)
            .byNormalBgColor(.systemIndigo).byCornerRadius(0)
            .onTap { [unowned self] _ in applyDirection(.down) }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnDirUp.snp.right).offset(8)
                make.right.equalToSuperview().inset(12)
                make.centerY.equalTo(self.btnDirLeft)
                make.height.equalTo(self.btnDirLeft)
                make.width.equalTo(self.btnDirLeft)
            }
    }()

    // 第三排：模式（连续 / 间隔）
    private lazy var btnModeContinuous: UIButton = {
        UIButton(type: .system)
            .byTitle("连续 continuous").byTitleFont(.systemFont(ofSize: 14, weight: .semibold)).byTitleColor(.white)
            .byNormalBgColor(.systemPurple).byCornerRadius(0)
            .onTap { [unowned self] _ in applyMode(.continuous(speed: 40)) }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnDirLeft.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(12)
                make.height.equalTo(36)
            }
    }()
    private lazy var btnModeInterval: UIButton = {
        UIButton(type: .system)
            .byTitle("间隔 interval").byTitleFont(.systemFont(ofSize: 14, weight: .semibold)).byTitleColor(.white)
            .byNormalBgColor(.systemPurple).byCornerRadius(0)
            .onTap { [unowned self] _ in applyMode(.intervalOnce(interval: 2.0, duration: 0.30, step: nil)) }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.btnModeContinuous.snp.right).offset(8)
                make.right.equalToSuperview().inset(12)
                make.centerY.equalTo(self.btnModeContinuous)
                make.height.equalTo(self.btnModeContinuous)
                make.width.equalTo(self.btnModeContinuous)
            }
    }()

    // ================================== 控制状态逻辑 ==================================
    private func updateControlButtonStates() {
        btnStart.isEnabled  = !started
        btnPause.isEnabled  = started && !paused
        btnResume.isEnabled = paused
        btnStop.isEnabled   = started || paused
        btnFire.isEnabled   = btnStop.isEnabled
        let active   = UIColor.systemBlue
        let inactive = UIColor.systemGray3
        [btnStart, btnPause, btnResume, btnStop, btnFire].forEach {
            $0.backgroundColor = $0.isEnabled ? active : inactive
            $0.alpha = $0.isEnabled ? 1.0 : 0.6
        }
    }

    // ================================== 控制状态字段 ==================================
    private var fireOnceTriggered = false

    // ================================== 统一控制封装 ==================================
    private func startAll() {
        guard !started else { return }
        marqueeText.start()
        marqueeRich.start()
        marqueeLocal.start()
        marqueeRemoteSD.start()
        marqueeRemoteKF.start()
        started = true
        paused = false
        fireOnceTriggered = false
        updateControlButtonStates()
    }

    private func pauseAll() {
        guard started, !paused else { return }
        marqueeText.pause()
        marqueeRich.pause()
        marqueeLocal.pause()
        marqueeRemoteSD.pause()
        marqueeRemoteKF.pause()
        paused = true
        updateControlButtonStates()
    }

    private func resumeAll() {
        guard started, paused else { return }
        marqueeText.resume()
        marqueeRich.resume()
        marqueeLocal.resume()
        marqueeRemoteSD.resume()
        marqueeRemoteKF.resume()
        paused = false
        updateControlButtonStates()
    }

    private func stopAll() {
        guard started || paused else { return }
        marqueeText.stop()
        marqueeRich.stop()
        marqueeLocal.stop()
        marqueeRemoteSD.stop()
        marqueeRemoteKF.stop()
        started = false
        paused = false
        fireOnceTriggered = false
        updateControlButtonStates()
    }

    private func fireOnceAll() {
        guard btnFire.isEnabled else { return }
        marqueeText.fireOnce()
        marqueeRich.fireOnce()
        marqueeLocal.fireOnce()
        marqueeRemoteSD.fireOnce()
        marqueeRemoteKF.fireOnce()
        started = false
        paused = false
        fireOnceTriggered = true
        updateControlButtonStates()
    }

    // ================================== 生命周期 ==================================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "跑马灯/轮播图 + PageControl")

        // 触发懒加载（组件会自动 start）
        [marqueeText, marqueeRich, marqueeLocal, marqueeRemoteSD, marqueeRemoteKF].forEach { _ = $0.byAlpha(1) }
        [btnStart, btnPause, btnResume, btnStop, btnFire,
         btnDirLeft, btnDirRight, btnDirUp, btnDirDown,
         btnModeContinuous, btnModeInterval].forEach { _ = $0.byAlpha(1) }

        started = true
        paused = false
        fireOnceTriggered = true
        updateControlButtonStates()
    }

    // ================================== 私有方法：应用方向 & 模式（同时影响 PageControl 是否可见） ==================================
    private func applyDirection(_ d: MarqueeDirection) {
        guard currentDirection != d else { return }
        currentDirection = d
        [marqueeText, marqueeRich, marqueeLocal, marqueeRemoteSD, marqueeRemoteKF].forEach { _ = $0.byDirection(d) }
    }

    private func applyMode(_ m: MarqueeMode) {
        switch (currentMode, m) {
        case (.continuous(let s1), .continuous(let s2)) where s1 == s2: return
        case (.intervalOnce(let i1, let d1, let st1), .intervalOnce(let i2, let d2, let st2))
            where i1 == i2 && d1 == d2 && st1 == st2: return
        default: break
        }
        currentMode = m
        [marqueeText, marqueeRich, marqueeLocal, marqueeRemoteSD, marqueeRemoteKF].forEach { _ = $0.byMode(m) }
    }
}
