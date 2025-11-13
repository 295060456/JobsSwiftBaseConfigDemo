//
//  Demo@JobsText.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//

import UIKit
import SnapKit
/// 如果你项目有 BaseVC，则可改为继承 BaseVC
final class JobsTextDemoVC: BaseVC {
    // MARK: - 模型
    private var current: JobsText = "Hello, JobsText!"
    private var history: [JobsText] = []
    // MARK: - UI（懒加载）
    private lazy var sourceControl: UISegmentedControl = { [unowned self] in
        UISegmentedControl(items: ["纯文本", "富文本样例"])
            .bySelectedSegmentIndex(0)
            .onJobsTap { [weak self] _ in
                guard let self else { return }
                onSourceChanged()
            }
            .byAddTo(view) {[unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
                }
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(34)
            }
    }()

    private lazy var previewLabel: UILabel = { [unowned self] in
        UILabel()
            .byNumberOfLines(0)
            .byAddTo(view) { make in
                make.top.equalTo(self.sourceControl.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
            }
    }()

    private lazy var rawLabel: UILabel = { [unowned self] in
        UILabel()
            .byNumberOfLines(0)
            .byFont(.systemFont(ofSize: 13))
            .byTextColor(.secondaryLabel)
            .byAddTo(view) { make in
                make.top.equalTo(self.previewLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(16)
            }
    }()

    private lazy var boldBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("加粗", for: .normal)
            .onTap(jobs_weakify(self) { me, _ in
                me.onBold()
            })
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.rawLabel.snp.bottom).offset(12)
                make.left.equalToSuperview().inset(16)
                make.height.equalTo(36)
            }
    }()

    private lazy var redBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("红色", for: .normal)
            .onTap { [weak self] _ in self?.onRed() }
            .byAddTo(view) { make in
                make.centerY.equalTo(self.boldBtn)
                make.left.equalTo(self.boldBtn.snp.right).offset(10)
                make.height.equalTo(36)
            }
    }()

    private lazy var appendBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("拼接“ +World”", for: .normal)
            .onTap { [weak self] _ in self?.onAppend() }
            .byAddTo(view) { make in
                make.centerY.equalTo(self.boldBtn)
                make.left.equalTo(self.redBtn.snp.right).offset(10)
                make.height.equalTo(36)
            }
    }()

    private lazy var resetBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("还原", for: .normal)
            .onTap { [weak self] _ in self?.onReset() }
            .byAddTo(view) { make in
                make.centerY.equalTo(self.boldBtn)
                make.left.equalTo(self.appendBtn.snp.right).offset(10)
                make.height.equalTo(36)
            }
    }()

    private lazy var exportRTFBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("导出为 RTF", for: .normal)
            .onTap { [weak self] _ in self?.onExportRTF() }
            .byAddTo(view) { make in
                make.top.equalTo(self.boldBtn.snp.bottom).offset(10)
                make.left.equalToSuperview().inset(16)
                make.height.equalTo(36)
            }
    }()

    private lazy var importRTFBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("从 RTF 导入", for: .normal)
            .onTap { [weak self] _ in self?.onImportRTF() }
            .byAddTo(view) { make in
                make.centerY.equalTo(self.exportRTFBtn)
                make.left.equalTo(self.exportRTFBtn.snp.right).offset(10)
                make.height.equalTo(36)
            }
    }()

    private lazy var debugTextView: UITextView = { [unowned self] in
        UITextView()
            .byEditable(false)
            .byFont(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .byBgColor(.secondarySystemBackground)
            .byCornerRadius(8)
            .byAddTo(view) {[unowned self] make in
                make.top.equalTo(self.exportRTFBtn.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
        }
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "JobsText Demo")
        sourceControl.byVisible(YES)
        previewLabel.byVisible(YES)
        rawLabel.byVisible(YES)
        boldBtn.byVisible(YES)
        redBtn.byVisible(YES)
        appendBtn.byVisible(YES)
        resetBtn.byVisible(YES)
        exportRTFBtn.byVisible(YES)
        importRTFBtn.byVisible(YES)
        debugTextView.byVisible(YES)

        refresh()
    }

    // MARK: - 回调
    @objc private func onSourceChanged() {
        switch sourceControl.selectedSegmentIndex {
        case 0:
            current = "Hello, JobsText!"
        default:
            current = makeSampleAttributed()
        }
        refresh()
    }

    private func onBold() {
        let font = UIFont.boldSystemFont(ofSize: 18)
        current = current.applying([.font: font])
        refresh()
    }

    private func onRed() {
        current = current.applying([.foregroundColor: UIColor.systemRed])
        refresh()
    }

    private func onAppend() {
        let suffix: JobsText = " + World"
        current = current + suffix
        refresh()
    }

    private func onReset() {
        onSourceChanged()
    }

    private func onExportRTF() {
        guard let data = current.rtfData() else {
            toastBy("RTF 导出失败")
            return
        }
        toastBy("RTF 导出成功（\(data.count) bytes）")
        history.append(current) // 简单留存，供“导入”演示
    }

    private func onImportRTF() {
        // 优先从最近导出的 RTF 恢复；否则用内置 HTML 示例
        if let last = history.last, let data = last.rtfData(),
           let restored = JobsText.from(data: data) {
            current = restored
            toastBy("已从 RTF 恢复")
            refresh()
        } else {
            let html = """
            <b><i>HTML</i> 导入</b> · <span style="color:#e53935">Red</span> + <span style="color:#1e88e5">Blue</span>
            """
            if let data = html.data(using: .utf8),
               let restored = JobsText.from(data: data, options: [
                   .documentType: NSAttributedString.DocumentType.html,
                   .characterEncoding: String.Encoding.utf8.rawValue
               ]) {
                current = restored
                toastBy("已从 HTML 恢复")
                refresh()
            } else {
                toastBy("RTF/HTML 导入失败")
            }
        }
    }
    // MARK: - 渲染
    private func refresh() {
        // 1) 富文本预览
        previewLabel.attributedText = current.asAttributedString()
        // 2) 纯文本视图
        rawLabel.byText("rawString: \(current.rawString)")
        // 3) 调试信息
        debugTextView.text = debugDump(current)
    }
    // MARK: - 辅助
    private func makeSampleAttributed() -> JobsText {
        let m = NSMutableAttributedString(string: "Hello, ")
        m.append(NSAttributedString(string: "Rich", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.systemBlue
        ]))
        m.append(NSAttributedString(string: "Text", attributes: [
            .font: UIFont.italicSystemFont(ofSize: 22),
            .foregroundColor: UIColor.systemPink
        ]))
        m.append(NSAttributedString(string: " ✨", attributes: [
            .baselineOffset: 2
        ]))
        return JobsText(m)
    }

    private func debugDump(_ rt: JobsText) -> String {
        let a = rt.asAttributedString()
        var lines: [String] = []
        lines.append("isPlain: \(rt.isPlain ? "true" : "false")")
        lines.append("length: \(a.length)")
        lines.append("string: \"\(a.string)\"")
        lines.append("attributes:")
        a.enumerateAttributes(in: NSRange(location: 0, length: a.length), options: []) { attrs, range, _ in
            lines.append("  - range: \(range.location)..<\(range.location + range.length), attrs: \(attrs)")
        }
        return lines.joined(separator: "\n")
    }
}
