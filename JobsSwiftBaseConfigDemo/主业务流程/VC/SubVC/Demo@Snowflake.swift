//
//  Demo@Snowflake.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/29/25.
//

import UIKit
import SnapKit

final class SnowflakeDemoVC: BaseVC {
    private let general = SnowflakeSwift(IDCID: 4, machineID: 30)
    // 结果展示
    private lazy var resultLabel: UILabel = {
        UILabel()
            .byText("未开始")
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(0)
            .byFont(.systemFont(ofSize: 14))
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview().offset(10)
                }
                make.left.right.equalToSuperview().inset(20)
            }
    }()

    // 生成按钮（用你的 API）
    private lazy var genButton: UIButton = {
        UIButton.sys()
            .byTitle("开始生成", for: .normal)
            .byTitle("生成中…", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byBgColor(.systemBlue)
            .byCornerRadius(12)
            .byMasksToBounds(YES)
            .byImage("bolt.fill".sysImg, for: .normal)
            .byImagePlacement(.leading)
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .byCornerBadgeText("NEW") { cfg in
                cfg.byOffset(.init(horizontal: -8, vertical: 8))
                    .byInset(.init(top: 2, left: 6, bottom: 2, right: 6))
                    .byBgColor(.systemRed)
                    .byFont(.systemFont(ofSize: 11, weight: .bold))
            }
            .onTap { [weak self] _ in
                self?.runBenchmark()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.resultLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(48)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "雪花算法")
        resultLabel.byVisible(YES)
        genButton.byVisible(YES)
    }

    // MARK: - 生成逻辑（放后台，避免卡 UI）
    private func runBenchmark() {
        guard !genButton.isSelected else { return } // 防抖
        genButton.isSelected = true
        genButton.isUserInteractionEnabled = false

        let total = 1_000_000
        let start = Date()
        let startTS = Date().timeIntervalSince1970

        // UI 先更新一次
        resultLabel.byText("开始：\(startTS)\n正在生成 \(total) 个 ID…")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            var lastID: UInt64 = 0
            var failCount = 0

            for _ in 0..<total {
                if let id = self.general.nextID() {
                    lastID = id
                    // 如需打印更多信息，可解注：
                    // _ = self.general.time(id: id)
                    // _ = self.general.IDC(id: id)
                    // _ = self.general.machine(id: id)
                } else {
                    failCount &+= 1
                }
            }

            let end = Date()
            let endTS = end.timeIntervalSince1970
            let elapsed = end.timeIntervalSince(start)

            DispatchQueue.main.async {
                self.genButton.isSelected = false
                self.genButton.isUserInteractionEnabled = true

                var text = ""
                text += "开始：\(startTS)\n结束：\(endTS)\n"
                text += String(format: "耗时：%.3f s\n", elapsed)
                text += "总数：\(total)\n失败：\(failCount)\n"
                text += "最后一个ID：\(lastID)"
                self.resultLabel.byText(text)
                print(text) // 控制台也打一份
            }
        }
    }
}
