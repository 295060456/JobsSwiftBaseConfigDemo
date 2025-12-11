//
//  RedPacketRainDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/12/10.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import SnapKit

final class RedPacketRainDemoVC: BaseVC {
    private var isRaining = false
    private var count = 0
    // MARK: - UI
    /// 红包雨视图
    private lazy var rainView: RedPacketRainView = {
          RedPacketRainView
              .dsl(
                  config: RedPacketRainConfig(
                      // 你可以改成 .default，或者继续用这套 Demo 配置
                      spawnInterval: 0.2,
                      minFallDuration: 5.5,
                      maxFallDuration: 8.0,
                      packetSize: CGSize(width: 44, height: 54),
                      maxConcurrentCount: 80,
                      spawnInsets: .init(top: 0, left: 10, bottom: 0, right: 10),
                      tapEnabled: true,
                      packetImage: nil
                  ),
                  timerKind: .gcd
              )
              .onPacketTap { [weak self] _, count in
                  guard let self else { return }
                  self.countLabel.byText("已抢到：\(count) 个")
              }
              .byAddTo(view) { [unowned self] make in
                  make.edges.equalToSuperview()
              }
      }()
    /// 显示累计点击次数
    private lazy var countLabel: UILabel = {
        UILabel()
            .byTextAlignment(.center)
            .byFont(.systemFont(ofSize: 18, weight: .medium))
            .byTextColor(.white)
            .byBgCor(.black.withAlphaComponent(0.4))
            .byCornerRadius(8)
            .byText("已抢到".tr + ":" + String(count) + "个".tr)
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                }
                make.centerX.equalToSuperview()
                make.height.equalTo(36)
                make.width.greaterThanOrEqualTo(180)
        }
    }()
    /// 开始 / 停止 红包雨
    private lazy var toggleButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("开始红包雨", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCornerRadius(8)
            .onTap { [weak self] _ in
                guard let self else { return }
                isRaining.toggle()
                if isRaining {
                    // 开始下红包雨
                    rainView.byStart()
                    toggleButton
                        .byTitle("停止红包雨", for: .normal)
                        .byBackgroundColor(.systemRed, for: .normal)
                } else {
                    // 停止继续生成，但保留屏幕上已有红包慢慢落完
                    rainView.byStop(clear: false)
                    toggleButton
                        .byTitle("开始红包雨", for: .normal)
                        .byBackgroundColor(.systemGreen, for: .normal)
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
                make.width.equalTo(160)
            }
    }()
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "JobsTimer@红包雨 Demo")
        rainView.byVisible(YES)
        countLabel.byVisible(YES)
        toggleButton.byVisible(YES)
    }
}
