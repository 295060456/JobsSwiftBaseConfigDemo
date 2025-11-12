//
//  SafeCodableDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/16/25.
//

import UIKit
import Foundation
import SnapKit
// MARK: - Demo VC
final class SafeCodableDemoVC: BaseVC {
    // MARK: - Reporter：把宽松转换/默认值上报到 UI
    private final class UIReporter: SafeCodableReporting {
        private weak var owner: SafeCodableDemoVC?
        init(owner: SafeCodableDemoVC) { self.owner = owner }
        func report(_ event: SafeCodableEvent) {
            DispatchQueue.main.async {
                guard let o = self.owner else { return }
                switch event {
                case let .coerced(from, to, path, raw):
                    o.appendLog("➡️ coerced \(path.joined(separator: ".")) \(from) -> \(to) raw=\(raw ?? "nil")")
                case let .defaulted(expected, path, reason):
                    o.appendLog("⚠️ defaulted \(path.joined(separator: ".")) to \(expected) because \(reason)")
                case let .failed(expected, path, reason):
                    o.appendLog("❌ failed \(path.joined(separator: ".")) expected \(expected): \(reason)")
                }
            }
        }
    }
    // MARK: - Model
    private struct User: Codable {
        @SafeCodable var id: Int
        @SafeCodable var name: String
        @SafeCodable var vip: Bool
        @SafeCodable var score: Double
        @SafeCodable var createdAt: Date
        @SafeCodable var homepage: URL
        @SafeCodableOptional var avatarURL: URL?
    }
    // MARK: - Lazy UI（全部懒加载，byAddTo + SnapKit）
    private lazy var jsonTitleLabel: UILabel = {
        UILabel()
            .byText("JSON（可编辑）")
            .byFont(.boldSystemFont(ofSize: 14))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(16)
                make.right.lessThanOrEqualToSuperview().inset(16)
            }
    }()

    private lazy var jsonTextView: UITextView = {
        UITextView()
            .byFont(.monospacedSystemFont(ofSize: 13, weight: .regular))
            .byBgColor(UIColor.secondarySystemBackground)
            .byCornerRadius(8)
            .byTextColor(.label)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.jsonTitleLabel.snp.bottom).offset(6)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(160)
            }
    }()

    private lazy var decodeDirtyButton: UIButton = {
        UIButton(type: .system)
            .byTitle("解码：脏数据", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemBlue, for: .normal)
            .byCornerRadius(8)
            .onTap { [weak self] _ in self?.useDirtyJSONAndDecode() }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.jsonTextView.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(16)
                make.height.equalTo(44)
            }
    }()

    private lazy var decodeCleanButton: UIButton = {
        UIButton(type: .system)
            .byTitle("解码：规范数据", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemGreen, for: .normal)
            .byCornerRadius(8)
            .onTap { [weak self] _ in self?.useCleanJSONAndDecode() }
            .byAddTo(view) { [unowned self] make in
                make.left.equalTo(self.decodeDirtyButton.snp.right).offset(12)
                make.right.equalToSuperview().inset(16)
                make.centerY.equalTo(self.decodeDirtyButton)
                make.width.equalTo(self.decodeDirtyButton)
                make.height.equalTo(44)
            }
    }()

    private lazy var valuesTitleLabel: UILabel = {
        UILabel()
            .byText("解析结果")
            .byFont(.boldSystemFont(ofSize: 14))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.decodeDirtyButton.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(16)
                make.right.lessThanOrEqualToSuperview().inset(16)
            }
    }()

    private lazy var idLabel: UILabel        = makeValueLabel(baseline: nil)
    private lazy var nameLabel: UILabel      = makeValueLabel(baseline: idLabel)
    private lazy var vipLabel: UILabel       = makeValueLabel(baseline: nameLabel)
    private lazy var scoreLabel: UILabel     = makeValueLabel(baseline: vipLabel)
    private lazy var createdAtLabel: UILabel = makeValueLabel(baseline: scoreLabel)
    private lazy var homepageLabel: UILabel  = makeValueLabel(baseline: createdAtLabel)
    private lazy var avatarURLLabel: UILabel = makeValueLabel(baseline: homepageLabel)

    private func makeValueLabel(baseline: UILabel?) -> UILabel {
        UILabel()
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.label)
            .byNumberOfLines(0)
            .byAddTo(view) { [unowned self] make in
                if let base = baseline {
                    make.top.equalTo(base.snp.bottom).offset(6)
                } else {
                    make.top.equalTo(self.valuesTitleLabel.snp.bottom).offset(6)
                }
                make.left.right.equalToSuperview().inset(16)
            }
    }

    private lazy var logTitleLabel: UILabel = {
        UILabel()
            .byText("解码日志")
            .byFont(.boldSystemFont(ofSize: 14))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.avatarURLLabel.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(16)
                make.right.lessThanOrEqualToSuperview().inset(16)
            }
    }()

    private lazy var logTextView: UITextView = {
        UITextView()
            .byFont(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .byBgColor(UIColor.secondarySystemBackground)
            .byCornerRadius(8)
            .byTextColor(.label)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.logTitleLabel.snp.bottom).offset(6)
                make.left.right.equalToSuperview().inset(16)
                make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16)
                make.height.greaterThanOrEqualTo(120)
            }
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "数据解析")
        /// SafeCodable 全局配置
        bootstrapSafeCodable()
        jsonTitleLabel.byAlpha(1)
        jsonTextView.byAlpha(1)
        decodeDirtyButton.byAlpha(1)
        decodeCleanButton.byAlpha(1)
        valuesTitleLabel.byAlpha(1)
        idLabel.byAlpha(1)
        nameLabel.byAlpha(1)
        vipLabel.byAlpha(1)
        scoreLabel.byAlpha(1)
        createdAtLabel.byAlpha(1)
        homepageLabel.byAlpha(1)
        avatarURLLabel.byAlpha(1)
        logTitleLabel.byAlpha(1)
        logTextView.byAlpha(1)
        /// 默认展示“脏数据”
        useDirtyJSONAndDecode()
    }
    // MARK: - SafeCodable 引导
    private func bootstrapSafeCodable() {
        SafeCodableConfig.shared.customDateFormatters = [DateFormatter()
            .byLocale(Locale(identifier: "en_US_POSIX"))
            .byTimeZone(TimeZone(secondsFromGMT: 0)!)
            .byDateFormat("yyyy-MM-dd HH:mm:ss")]
        SafeCodableConfig.shared.treatEmptyStringAsNilForURL = true
        SafeCodableReportCenter.shared = UIReporter(owner: self)
    }
    // MARK: - Actions
    private func useDirtyJSONAndDecode() {
        jsonTextView.text = dirtyJSONString
        decodeCurrentJSON()
    }

    private func useCleanJSONAndDecode() {
        jsonTextView.text = cleanJSONString
        decodeCurrentJSON()
    }

    private func decodeCurrentJSON() {
        clearValues()
        clearLog()

        guard let data = jsonTextView.text.data(using: .utf8) else {
            appendLog("❌ 无法转成 Data")
            return
        }

        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            render(user)
            appendLog("✅ 解码成功")
        } catch {
            appendLog("❌ 解码失败：\(error)")
        }
    }
    // MARK: - Render
    private func render(_ u: User) {
        idLabel.byText("id: \(u.id)")
        nameLabel.byText("name: \(u.name)")
        vipLabel.byText("vip: \(u.vip)")
        scoreLabel.byText("score: \(u.score)")
        createdAtLabel.byText("createdAt: " + DateFormatter()
            .byLocale(Locale(identifier: "en_US_POSIX"))
            .byTimeZone(TimeZone(secondsFromGMT: 0)!)
            .byDateFormat("yyyy-MM-dd HH:mm:ss 'UTC'").string(from: u.createdAt))
        homepageLabel.byText("homepage: \(u.homepage.absoluteString)")
        avatarURLLabel.byText("avatarURL: \(u.avatarURL?.absoluteString ?? "nil")")
    }

    private func clearValues() {
        [idLabel,
         nameLabel,
         vipLabel,
         scoreLabel,
         createdAtLabel,
         homepageLabel,
         avatarURLLabel].forEach { $0.text = "" }
    }

    private func appendLog(_ line: String) {
        let prefix = logTextView.text?.isEmpty == false ? "\n" : ""
        logTextView.byText((logTextView.text ?? "") + prefix + line)
        logTextView.scrollRangeToVisible(NSRange(location: max(0, logTextView.text.count - 1), length: 1))
    }

    private func clearLog() { logTextView.text = "" }
    // MARK: - Sample JSON
    private let dirtyJSONString = #"""
    {
      "id": "42",
      "name": 777,
      "vip": "true",
      "score": "3.14",
      "createdAt": "2024-08-20 10:00:00",
      "homepage": "",
      "avatarURL": "https://a.b/c.png"
    }
    """#

    private let cleanJSONString = #"""
    {
      "id": 42,
      "name": "Jobs",
      "vip": true,
      "score": 3.14,
      "createdAt": 1724148000,
      "homepage": "https://example.com",
      "avatarURL": null
    }
    """#
}
