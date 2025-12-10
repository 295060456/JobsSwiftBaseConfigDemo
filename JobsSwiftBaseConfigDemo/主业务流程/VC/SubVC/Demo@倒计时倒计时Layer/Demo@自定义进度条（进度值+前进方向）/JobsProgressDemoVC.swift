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
    /// 当前标准进度 [0, 1]
    private var currentProgress: CGFloat = 0
    // MARK: - UI 懒加载
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
                // 换方向时：停掉当前 JobsTimer & 进度归零
                timer?.stop()
                currentProgress = 0
                progressView.setProgress(0, animated: false)
            }
            .byAddTo(view) { [unowned self] make in
                make.centerX.equalToSuperview()
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(30)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
                }
            }
    }()
    /// 模式切换按钮：在 0→100 / 100→0 之间切换
    private lazy var modeToggleButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemOrange, for: .normal)
            .byTitle("模式：100→0", for: .normal)   // 初始和 progressView.byValueMode(.countDown) 对齐
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .byCornerRadius(16)
            .onTap { [weak self] sender in
                guard let self else { return }

                let newMode: JobsProgressView.ValueMode
                let newTitle: String

                switch self.progressView.valueMode {
                case .countUp:
                    // 切到 100→0
                    newMode = .countDown
                    newTitle = "模式：100→0"
                case .countDown:
                    // 切到 0→100
                    newMode = .countUp
                    newTitle = "模式：0→100"
                }

                // 切换数值模式
                self.progressView.byValueMode(newMode)
                sender.byTitle(newTitle, for: .normal)

                // 切模式时：停掉定时器 & 进度归零
                self.timer?.stop()
                self.currentProgress = 0
                self.progressView.setProgress(0, animated: false)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(directionSegment.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.height.equalTo(32)
                make.width.greaterThanOrEqualTo(140)
            }
    }()
    /// 自定义进度条
    private lazy var progressView: JobsProgressView = {
        JobsProgressView()
            .byDirection(.leftToRight)
            .byValueMode(.countDown)   // 初始：显示为 100→0
            .byTrackColor(.systemGray5)
            .byLabelBackgroundColor(.secondarySystemBackground)
            .byLabelFont(.monospacedDigitSystemFont(ofSize: 12, weight: .medium))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(modeToggleButton.snp.bottom).offset(24.h)
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
        jobsSetupGKNav(title: "自定义（进度值+前进方向）进度条")

        directionSegment.byVisible(YES)
        modeToggleButton.byVisible(YES)
        progressView.byVisible(YES)
        startButton.byVisible(YES)
    }
}
