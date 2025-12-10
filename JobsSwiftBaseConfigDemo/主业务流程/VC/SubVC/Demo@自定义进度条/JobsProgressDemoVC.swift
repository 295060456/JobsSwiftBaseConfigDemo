//
//  JobsProgressDemoVC.swift
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

final class JobsProgressDemoVC: BaseVC {
    deinit {
        timer?.stop()
    }
    // MARK: - 状态
    /// 使用 JobsTimerProtocol 替代原生 Timer
    private var timer: JobsTimerProtocol?
    private var currentProgress: CGFloat = 0
    // MARK: - UI 懒加载
    /// 标题
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("Directional Progress Demo")
            .byFont(.boldSystemFont(ofSize: 20))
            .byTextAlignment(.center)
            .byAddTo(view) { [unowned self] make in
                make.centerX.equalToSuperview()
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
                }
            }
    }()
    /// 方向切换 SegmentedControl
    ///
    /// 0: 左 -> 右
    /// 1: 右 -> 左
    /// 2: 下 -> 上
    /// 3: 上 -> 下
    private lazy var directionSegment: UISegmentedControl = {
        UISegmentedControl(items: ["→", "←", "↑", "↓"])
            .bySelectedSegmentIndex(0)
            .onJobsChange { [weak self] (seg: UISegmentedControl) in
                guard let self else { return }

                switch seg.selectedSegmentIndex {
                case 0:
                    progressView.direction = .leftToRight
                case 1:
                    progressView.direction = .rightToLeft
                case 2:
                    progressView.direction = .bottomToTop
                case 3:
                    progressView.direction = .topToBottom
                default:
                    break
                }
                // 换方向时重置进度 & 停掉当前 JobsTimer
                timer?.stop()
                currentProgress = 0
                progressView.setProgress(0, animated: false)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(titleLabel.snp.bottom).offset(24)
                make.centerX.equalToSuperview()
            }
    }()
    /// 自定义进度条
    private lazy var progressView: JobsProgressView = {
        JobsProgressView()
            .byDirection(.leftToRight)
            .byTrackColor(.systemGray5)
            .byLabelBackgroundColor(.secondarySystemBackground)
            .byLabelFont(.monospacedDigitSystemFont(ofSize: 12, weight: .medium))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(directionSegment.snp.bottom).offset(40.h)
                make.left.equalToSuperview().offset(40.w)
                make.right.equalToSuperview().inset(40.w)
                make.height.equalTo(80.h) /// 给点高度让上方 label 有空间移动
            }
    }()
    /// 开始按钮
    private lazy var startButton: UIButton = {
        UIButton.sys()
            /// 背景色
            .byBackgroundColor(.systemGreen, for: .normal)
            /// 普通字符串@设置主标题
            .byTitle("开始动画", for: .normal)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            /// 普通@点按事件触发
            .onTap { [weak self] sender in
                guard let self else { return }
                sender.isSelected.toggle()
                // 重置进度 & 停掉旧定时器
                timer?.stop()
                currentProgress = 0
                progressView.setProgress(0, animated: false)

                let step: CGFloat = 0.01
                let interval: TimeInterval = 0.03

                // 用 JobsTimerConfig + JobsTimerFactory 创建定时器
                let config = JobsTimerConfig(
                    interval: interval,
                    repeats: true,
                    tolerance: 0,          // 精准一点，进度更平滑
                    queue: .main           // UI 更新必须在主线程
                )

                // 这里用 GCD 版，也可以换成 .foundation / .displayLink / .runLoopCore
                let t = JobsTimerFactory.make(
                    kind: .gcd,
                    config: config
                ) { [weak self] in
                    guard let self else { return }

                    self.currentProgress += step
                    self.progressView.setProgress(self.currentProgress, animated: true)

                    if self.currentProgress >= 1 {
                        self.currentProgress = 1
                        self.timer?.stop()
                    }
                }

                self.timer = t
                t.start()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(progressView.snp.bottom).offset(32)
                make.centerX.equalToSuperview()
            }
    }()
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "自定义进度条")
        titleLabel.byVisible(YES)
        directionSegment.byVisible(YES)
        progressView.byVisible(YES)
        startButton.byVisible(YES)
    }
}
