//
//  Demo@Lottie.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/3/25.
//

import UIKit
import SnapKit
import Lottie

final class LottieDemoVC: BaseVC {

    // MARK: - Config
    private let initialAnimationName   = "9squares_AlBoardman" // 主 Bundle 的 .json（不带扩展）
    private let alternateAnimationName = "LottieLogo1"         // 用于替换演示

    // MARK: - UI（lazy：只配置，不 add/约束）
    private lazy var containerView: UIView = {
        UIView()
            .byBgColor(.secondarySystemBackground)
            .byCornerRadius(12)
            .byAddTo(view) { [unowned self] make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-90)
                make.size.equalTo(CGSize(width: 240, height: 240))
            }
    }()

    private lazy var playBtn: UIButton = {
        UIButton.sys()
            .byTitle("▶︎ 播放")
            .onJobsTap { [weak self] (_: UIButton) in
                self?.containerView.lottiePlay()
            }
    }()

    private lazy var pauseBtn: UIButton = {
        UIButton.sys()
            .byTitle("❚❚ 暂停")
            .onJobsTap { [weak self] (_: UIButton) in
                self?.containerView.lottiePause()
            }
    }()

    private lazy var stopBtn: UIButton = {
        UIButton.sys()
            .byTitle("■ 停止")
            .onJobsTap { [weak self] (_: UIButton) in
                guard let self else { return }
                self.containerView.lottieStop(resetToBeginning: true)
                self.progressSlider.byValue(0)
            }
    }()

    private lazy var replaceBtn: UIButton = {
        UIButton.sys()
            .byTitle("⇄ 替换动画")
            .onJobsTap { [weak self] (_: UIButton) in
                guard let self else { return }
                if Bundle.main.path(forResource: self.alternateAnimationName, ofType: "json") != nil {
                    self.containerView.lottieReplace(name: self.alternateAnimationName, autoPlay: true)
                    self.progressSlider.byValue(0)
                } else if let anim = LottieAnimation.named(self.initialAnimationName) {
                    self.containerView.lottieRemove()
                    self.containerView.byLottieAnimation(
                        anim,
                        loop: self.resolvedLoopMode(),
                        speed: CGFloat(self.speedSlider.value),
                        contentMode: .scaleAspectFit,
                        autoPlay: true,
                        makeConstraints: { make in
                            make.edges.equalToSuperview().inset(12)
                        }
                    )
                    self.progressSlider.byValue(0)
                }
            }
    }()

    private lazy var loopSegment: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["once", "loop", "auto"])
        seg.selectedSegmentIndex = 1
        seg.onJobsChange { [weak self] (sender: UISegmentedControl) in
            guard let self else { return }
            let mode = self.resolvedLoopMode()
            self.containerView.jobs_lottieView?.loopMode = mode
            if mode == .playOnce {
                self.containerView.lottieStop(resetToBeginning: true)
                self.progressSlider.byValue(0)
            }
        };return seg
    }()

    private lazy var progressSlider: UISlider = {
        UISlider()
            .byMinimumValue(0)
            .byMaximumValue(1)
            .byValue(0)
            .onJobsChange { [weak self] (s: UISlider) in
                self?.containerView.lottieProgress(CGFloat(s.value))
            }
    }()

    private lazy var speedSlider: UISlider = {
        UISlider()
            .byMinimumValue(0.25)
            .byMaximumValue(3.0)
            .byValue(1.0)
            .onJobsChange { [weak self] (s: UISlider) in
                guard let self else { return }
                let speed = CGFloat(s.value)
                self.containerView.jobs_lottieView?.animationSpeed = speed
                self.speedLabel.byText(String(format: "%.2f×", speed))
            }
    }()

    private lazy var speedLabel: UILabel = {
        UILabel()
            .byText("1.00×")
            .byTextAlignment(.right)
            .byFont(.systemFont(ofSize: 14, weight: .medium))
    }()
    // 行：按钮（用你的 UIStackView DSL）
    private lazy var buttonsRow: UIStackView = {
        UIStackView()
            .byAxis(.horizontal)
            .byAlignment(.fill)
            .byDistribution(.fillEqually)
            .bySpacing(12)
            .addArrangedSubviews(playBtn, pauseBtn, stopBtn, replaceBtn)
    }()
    // 行：循环
    private lazy var loopRow: UIStackView = {
        makeRow(title: "循环", control: loopSegment)
    }()
    // 行：进度
    private lazy var progressRow: UIStackView = {
        makeRow(title: "进度", control: progressSlider)
    }()
    // 行：速度（右侧数值标签）
    private lazy var speedRow: UIStackView = {
        makeRow2(title: "速度", left: speedSlider, right: speedLabel)
    }()
    // 垂直面板：把各行组装好，也用你的 DSL
    private lazy var controlsPanel: UIStackView = { [unowned self] in
        UIStackView()
            .byAxis(.vertical)
            .byAlignment(.fill)
            .byDistribution(.fill)
            .bySpacing(12)
            .byLayoutMargins(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) // 开启 relative + 边距（按需改）
            .addArrangedSubviews(buttonsRow, loopRow, progressRow, speedRow)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(containerView.snp.bottom).offset(20)
                make.leading.trailing.equalTo(view.layoutMarginsGuide)
            }
    }()
    // 容器里的 Lottie 视图（通过 UIView 的 DSL 挂载）
    private lazy var lottieView: LottieAnimationView = { [unowned self] in
        containerView.byLottieAnimation(
            initialAnimationName,
            loop: .loop,
            speed: CGFloat(speedSlider.value),
            contentMode: .scaleAspectFit,
            autoPlay: true,
            makeConstraints: { make in
                make.edges.equalToSuperview().inset(12)
            }
        )
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "Lottie 动画")
        view.byBgColor(.systemBackground)

        containerView.byAlpha(1)
        controlsPanel.byAlpha(1)
        _ = lottieView
    }
    // MARK: - Helpers（行工厂，用 UIStackView DSL）
    private func makeRow(title: String, control: UIView) -> UIStackView {
        let label = UILabel().byText(title)
        return UIStackView()
            .byAxis(.horizontal)
            .byAlignment(.center)
            .byDistribution(.fill)
            .bySpacing(12)
            .addArrangedSubviews(label, control)
    }

    private func makeRow2(title: String, left: UIView, right: UIView) -> UIStackView {
        let label = UILabel().byText(title)
        return UIStackView()
            .byAxis(.horizontal)
            .byAlignment(.center)
            .byDistribution(.fill)
            .bySpacing(12)
            .addArrangedSubviews(label, left, right)
    }

    private func resolvedLoopMode() -> LottieLoopMode {
        switch loopSegment.selectedSegmentIndex {
        case 0: return .playOnce
        case 1: return .loop
        default: return .autoReverse
        }
    }
}
