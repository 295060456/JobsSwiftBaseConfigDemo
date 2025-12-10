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
    private var count : Int = 0;
    private lazy var rainView: RedPacketRainView = {
        RedPacketRainView
            .dsl(
                config: RedPacketRainConfig(
                    spawnInterval: 0.2,
                    minFallDuration: 5.5,
                    maxFallDuration: 8.0,
                    packetSize: CGSize(width: 44, height: 54),
                    maxConcurrentCount: 80,
                    spawnInsets: .init(top: 0, left: 10, bottom: 0, right: 10),
                    tapEnabled: true,
                    packetImage: nil
                ),
                timerKind: .gcd)
            .onPacketTap { [weak self] _, count in
                self?.countLabel.byText("已抢到：\(count) 个")
            }
            .byAddTo(view) { [unowned self] make in
                make.edges.equalToSuperview()
            }
    }()

    private lazy var countLabel: UILabel = {
        UILabel()
            .byTextColor(.black)
            .byFont(.boldSystemFont(ofSize: 18))
            .byTextAlignment(.center)
            .byText("已抢到".tr + ":" + String(count) + "个".tr)
            .byBgCor(.black.withAlphaComponent(0.4))
            .byCornerRadius(8)
            .byAddTo(view) { [unowned self] make in
                make.centerX.equalToSuperview()
                make.height.equalTo(32.h)
                make.width.greaterThanOrEqualTo(160.w)
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(12.h)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                }
            }
    }()

    private lazy var toggleButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemRed, for: .normal)
            .byTitle("开始红包雨".tr, for: .normal)
            .byTitle("停止红包雨".tr, for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 18, weight: .bold))
            .byContentEdgeInsets(.init(top: 8, left: 16, bottom: 8, right: 16))
            .onTap { [weak self] _ in
                guard let self else { return }
                isRaining.toggle()
                if isRaining {
                    rainView.start()
                    toggleButton.setTitle("停止红包雨".tr, for: .normal)
                } else {
                    // 停止但不立即清屏，保留已经在下落的红包
                    rainView.stop(clear: false)
                    toggleButton.setTitle("开始红包雨".tr, for: .normal)
                }
            }
            .byCornerRadius(22)
            .byAddTo(view) { [unowned self] make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
                make.width.equalTo(160)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "JobsTimer@红包雨 Demo")
        rainView.byVisible(YES)
        countLabel.byVisible(YES)
        toggleButton.byVisible(YES)
    }
}
