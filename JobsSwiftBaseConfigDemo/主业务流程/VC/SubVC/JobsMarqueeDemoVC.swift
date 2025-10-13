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
            .byOnItemTap { idx, btn in
                print("TEXT tap idx=\(idx), title=\(btn.title(for: .normal) ?? "-")")
            }
            .setButtons([UIButton(type: .system)
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
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
                make.left.right.equalToSuperview()
                make.height.equalTo(64)
            }
    }()
    // ================================== 2) 文本（富文本：JobsRichText） ==================================
    private lazy var marqueeRich: JobsMarqueeView = {
        return JobsMarqueeView()
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
    // ================================== 3) 轮播图（本地图） ==================================
    private lazy var marqueeLocal: JobsMarqueeView = {
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
            .byItemSpacing(0)
            .byOnItemTap { idx, _ in
                print("LOCAL tap idx=\(idx)")
            }
            .setButtons([UIButton(type: .custom)
                .byContentEdgeInsets(.zero)
                .byClipsToBounds(true)
                .byBackgroundImage("唐老鸭".img)
                .byNormalBgColor(.tertiarySystemFill)
                .byTitle("本地封面").byTitleFont(.systemFont(ofSize: 12)).byTitleColor(.secondaryLabel)
                .byCornerRadius(0)
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeRich.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(96)
            }
    }()
    // ================================== 4) 轮播图（网络：SDWebImage） ==================================
    private lazy var marqueeRemoteSD: JobsMarqueeView = {
        return JobsMarqueeView()
            .byItemMainAxisLength(.fillViewport)
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
            .byItemSpacing(0)
            .setButtons([UIButton(type: .custom)
                .byContentEdgeInsets(.zero)
                .byClipsToBounds(true)
                .byNormalBgColor(.tertiarySystemFill)
                .byBackgroundImageContentMode(.scaleAspectFill)
                .byCornerRadius(0)
                .byTitle("网络封面 (SD)").byTitleFont(.systemFont(ofSize: 12)).byTitleColor(.secondaryLabel)
                .sd_imageURL("https://picsum.photos/760/320")
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
    // ================================== 5) 轮播图（网络：Kingfisher） ==================================
    private lazy var marqueeRemoteKF: JobsMarqueeView = {
        JobsMarqueeView()
            .byItemMainAxisLength(.fillViewport)
            .byDirection(.left)
            .byMode(.continuous(speed: 40))
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)//true
            .byGestureScrollEnabled(true)
            .byDirectionalLockEnabled(true)
//            .byAutoStartEnabled(false)// 不自动滚动
            .byHardAxisLock(true)
            .byDecelerationRate(.fast)
            .byPauseOnUserDrag(true)
            .byResumeAfterDragDelay(0.8)
            .byItemSpacing(0)
            .setButtons([
                UIButton(type: .system)
                    .byCornerRadius(12)
                    .byClipsToBounds(true)
                    .byTitle("我是主标题@Kingfisher").byTitleColor(.red)
                    .bySubTitle("我是副标题@Kingfisher").bySubTitleColor(.yellow)
                    .kf_imageURL("https://picsum.photos/300/200")
                    .kf_placeholderImage("唐老鸭".img)
                    .kf_options([
                        .processor(DownsamplingImageProcessor(size: CGSize(width: 500, height: 200))),
                        .scaleFactor(UIScreen.main.scale),
                        .cacheOriginalImage,
                        .transition(.fade(0.25)),
                        .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
                    ])
                    .kf_bgNormalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            ])
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.marqueeRemoteSD.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(120)
            }
            .refreshAfterConstraints()   // 约束/布局确定后触发重建
    }()
    // ================================== 控制按钮（直接在懒加载中布局） ==================================
    // 第一排：开始 / 暂停 / 继续 / 停止 / 一次
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
    /// 根据 started/paused/fireOnce 状态更新控制按钮可用性与视觉表现
    private func updateControlButtonStates() {
        // ✅ “开始”仅在停止时可用
        btnStart.isEnabled  = !started
        // ✅ “暂停”仅在运行中可用
        btnPause.isEnabled  = started && !paused
        // ✅ “继续”仅在暂停时可用
        btnResume.isEnabled = paused
        // ✅ “停止”在运行或暂停时可用
        btnStop.isEnabled   = started || paused
        // ✅ “一次”按钮状态与“停止”保持一致，只要能点停止，就能点一次
        btnFire.isEnabled   = btnStop.isEnabled
        // 颜色/透明度视觉区分
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
        // ✅ 单次执行
        marqueeText.fireOnce()
        marqueeRich.fireOnce()
        marqueeLocal.fireOnce()
        marqueeRemoteSD.fireOnce()
        marqueeRemoteKF.fireOnce()

        // ✅ 点击后视为“单次播放完毕 → 停止状态”，只保留“开始”按钮可用
        started = false
        paused = false
        fireOnceTriggered = true
        updateControlButtonStates()
    }
    // ================================== 生命周期 ==================================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "跑马灯/轮播图")
        // 触发懒加载（组件会自动 start）
        marqueeText.byAlpha(1)
        marqueeRich.byAlpha(1)
        marqueeLocal.byAlpha(1)
        marqueeRemoteSD.byAlpha(1)
        marqueeRemoteKF.byAlpha(1)

        btnStart.byAlpha(1)
        btnPause.byAlpha(1)
        btnResume.byAlpha(1)
        btnStop.byAlpha(1)
        btnFire.byAlpha(1)

        btnDirLeft.byAlpha(1)
        btnDirRight.byAlpha(1)
        btnDirUp.byAlpha(1)
        btnDirDown.byAlpha(1)

        btnModeContinuous.byAlpha(1)
        btnModeInterval.byAlpha(1)
        // ✅ 初始自动运行状态
        started = true
        paused = false
        fireOnceTriggered = true
        updateControlButtonStates()
    }
    // ================================== 私有方法：应用方向 & 模式 ==================================
    private func applyDirection(_ d: MarqueeDirection) {
        guard currentDirection != d else { return }
        currentDirection = d
        marqueeText.byDirection(d)
        marqueeRich.byDirection(d)
        marqueeLocal.byDirection(d)
        marqueeRemoteSD.byDirection(d)
        marqueeRemoteKF.byDirection(d)
    }

    private func applyMode(_ m: MarqueeMode) {
        // 切到同类型模式时，避免不必要重启；但若参数不同允许覆盖
        switch (currentMode, m) {
        case (.continuous(let s1), .continuous(let s2)) where s1 == s2: return
        case (.intervalOnce(let i1, let d1, let st1), .intervalOnce(let i2, let d2, let st2))
            where i1 == i2 && d1 == d2 && st1 == st2: return
        default: break
        }
        currentMode = m
        marqueeText.byMode(m)
        marqueeRich.byMode(m)
        marqueeLocal.byMode(m)
        marqueeRemoteSD.byMode(m)
        marqueeRemoteKF.byMode(m)
    }
}
