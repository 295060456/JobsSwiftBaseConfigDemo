//
//  Demo@JobsText.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//

import UIKit
import SnapKit

/// 如果你项目有 BaseVC，则可改为继承 BaseVC
final class JobsTextDemoVC: UIViewController {

    // MARK: - 模型
    private var current: JobsText = "Hello, JobsText!"
    private var history: [JobsText] = []

    // MARK: - UI
    private let previewLabel = UILabel()
    private let rawLabel = UILabel()
    private let debugTextView = UITextView()

    private let sourceControl = UISegmentedControl(items: ["纯文本", "富文本样例"])
    private let boldBtn = UIButton(type: .system)
    private let redBtn = UIButton(type: .system)
    private let appendBtn = UIButton(type: .system)
    private let resetBtn = UIButton(type: .system)
    private let exportRTFBtn = UIButton(type: .system)
    private let importRTFBtn = UIButton(type: .system)

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "JobsText Demo"
//
//        setupUI()
//        setupActions()
//        refresh()

        let a: JobsText = "纯文本"                    // 字面量
        let b = JobsText(NSAttributedString(string: "富文本", attributes: [.kern: 1.2]))

        let joined = a + JobsText(" + ") + b

        let bolded = a.applying([.font: UIFont.boldSystemFont(ofSize: 16)]) // 纯文本→套属性
        let merged = b.applying([.foregroundColor: UIColor.systemRed])      // 富文本→覆盖冲突键

        let nsAttr = joined.asAttributedString()                             // 需要富文本时再取
        let plain  = joined.rawString                                        // 需要纯文本时取 string

        // 自定义映射：比如给每个字符加下划线
        let underlined = joined.mapAttributed { src in
            let m = NSMutableAttributedString(attributedString: src)
            m.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue],
                            range: NSRange(location: 0, length: m.length))
            return m
        }
        view.backgroundColor = .systemBackground
    }

    // MARK: - UI 构建
    private func setupUI() {
        // 顶部选择：纯/富文本
        sourceControl.selectedSegmentIndex = 0

        // 预览（富文本展示）
        previewLabel.numberOfLines = 0

        // 纯文本展示
        rawLabel.numberOfLines = 0
        rawLabel.font = .systemFont(ofSize: 13)
        rawLabel.textColor = .secondaryLabel

        // 调试输出
        debugTextView.isEditable = false
        debugTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        debugTextView.backgroundColor = UIColor.secondarySystemBackground
        debugTextView.layer.cornerRadius = 8

        // 按钮
        boldBtn.setTitle("加粗", for: .normal)
        redBtn.setTitle("红色", for: .normal)
        appendBtn.setTitle("拼接“ +World”", for: .normal)
        resetBtn.setTitle("还原", for: .normal)
        exportRTFBtn.setTitle("导出为 RTF", for: .normal)
        importRTFBtn.setTitle("从 RTF 导入", for: .normal)

        // 布局
        view.addSubview(sourceControl)
        view.addSubview(previewLabel)
        view.addSubview(rawLabel)
        view.addSubview(boldBtn)
        view.addSubview(redBtn)
        view.addSubview(appendBtn)
        view.addSubview(resetBtn)
        view.addSubview(exportRTFBtn)
        view.addSubview(importRTFBtn)
        view.addSubview(debugTextView)

        sourceControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(34)
        }

        previewLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceControl.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        rawLabel.snp.makeConstraints { make in
            make.top.equalTo(previewLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        boldBtn.snp.makeConstraints { make in
            make.top.equalTo(rawLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        redBtn.snp.makeConstraints { make in
            make.centerY.equalTo(boldBtn)
            make.left.equalTo(boldBtn.snp.right).offset(10)
            make.height.equalTo(36)
        }
        appendBtn.snp.makeConstraints { make in
            make.centerY.equalTo(boldBtn)
            make.left.equalTo(redBtn.snp.right).offset(10)
            make.height.equalTo(36)
        }
        resetBtn.snp.makeConstraints { make in
            make.centerY.equalTo(boldBtn)
            make.left.equalTo(appendBtn.snp.right).offset(10)
            make.height.equalTo(36)
        }

        exportRTFBtn.snp.makeConstraints { make in
            make.top.equalTo(boldBtn.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        importRTFBtn.snp.makeConstraints { make in
            make.centerY.equalTo(exportRTFBtn)
            make.left.equalTo(exportRTFBtn.snp.right).offset(10)
            make.height.equalTo(36)
        }

        debugTextView.snp.makeConstraints { make in
            make.top.equalTo(exportRTFBtn.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
        }
    }

    // MARK: - 事件
    private func setupActions() {
        sourceControl.addTarget(self, action: #selector(onSourceChanged), for: .valueChanged)
        boldBtn.addTarget(self, action: #selector(onBold), for: .touchUpInside)
        redBtn.addTarget(self, action: #selector(onRed), for: .touchUpInside)
        appendBtn.addTarget(self, action: #selector(onAppend), for: .touchUpInside)
        resetBtn.addTarget(self, action: #selector(onReset), for: .touchUpInside)
        exportRTFBtn.addTarget(self, action: #selector(onExportRTF), for: .touchUpInside)
        importRTFBtn.addTarget(self, action: #selector(onImportRTF), for: .touchUpInside)
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

    @objc private func onBold() {
        let font = UIFont.boldSystemFont(ofSize: 18)
        current = current.applying([.font: font])
        refresh()
    }

    @objc private func onRed() {
        current = current.applying([.foregroundColor: UIColor.systemRed])
        refresh()
    }

    @objc private func onAppend() {
        let suffix: JobsText = " + World"
        current = current + suffix
        refresh()
    }

    @objc private func onReset() {
        onSourceChanged()
    }

    @objc private func onExportRTF() {
        guard let data = current.rtfData() else {
            showTip("RTF 导出失败")
            return
        }
        // 这里只是演示大小与前缀
        showTip("RTF 导出成功（\(data.count) bytes）")
        // 生产环境：可写入文件、分享等
        history.append(current)
    }

    @objc private func onImportRTF() {
        // 演示：从刚才导出的 data 恢复（若没有就用内置富文本样例）
        if let last = history.last, let data = last.rtfData(),
           let restored = JobsText.from(data: data) {
            current = restored
            showTip("已从 RTF 恢复")
            refresh()
        } else {
            // 兜底：直接从一个 HTML 片段恢复
            let html = """
            <b><i>HTML</i> 导入</b> · <span style="color:#e53935">Red</span> + <span style="color:#1e88e5">Blue</span>
            """
            if let data = html.data(using: .utf8),
               let restored = JobsText.from(data: data, options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
               ]) {
                current = restored
                showTip("已从 HTML 恢复")
                refresh()
            } else {
                showTip("RTF/HTML 导入失败")
            }
        }
    }

    // MARK: - 渲染
    private func refresh() {
        // 1) 富文本预览
        previewLabel.attributedText = current.asAttributedString()

        // 2) 纯文本视图
        rawLabel.text = "rawString: \(current.rawString)"

        // 3) 调试信息：类型、长度、属性快照
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
            lines.append("  - range: \(range.location)..<\(range.location+range.length), attrs: \(attrs)")
        }
        return lines.joined(separator: "\n")
    }

    private func showTip(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak alert] in
            alert?.dismiss(animated: true, completion: nil)
        }
    }
}
