//
//  RichTextDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx          // 自动提供 disposeBag
import SnapKit              // 约束用 SnapKit

// 自定义可点击标记（给“电话”用：红字+蓝线，不走系统 link 样式）
private extension NSAttributedString.Key {
    static let jobsAction = NSAttributedString.Key("jobsAction")
}

// MARK: - 仅两个 cell：1) Delegate 方案  2) RAC 方案
//  - “专属客服”使用系统默认蓝色（.link）
//  - “400-123-4567” 可点击拨号，样式=红字+蓝色下划线（自定义）
//  - 在卡片里追加一个“图标附件”示例（回形针 + 文本）
final class RichTextDemoVC: UIViewController, HasDisposeBag {

    private let customerText = "专属客服"
    private let customerURL  = "click://customer"

    private let phoneText    = "400-123-4567"
    private let phoneURL     = "tel://4001234567"

    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "富文本演示（Delegate & RAC）"
        view.backgroundColor = .systemBackground
        setupTable()
    }

    private func setupTable() {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.isScrollEnabled = false

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        tableView.register(LinkCell.self, forCellReuseIdentifier: LinkCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
    }
}

// MARK: - DataSource / Delegate
extension RichTextDemoVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mode: LinkCell.Mode = (indexPath.row == 0) ? .delegate : .rac
        let cell = tableView.dequeueReusableCell(withIdentifier: LinkCell.reuseID,
                                                 for: indexPath) as! LinkCell

        let title = (mode == .delegate)
        ? "Delegate 方案（专属客服默认样式 + 电话红字蓝线）"
        : "RAC 方案（专属客服默认样式 + 电话红字蓝线）"

        // 主文案：两个可点击片段
        // ① “专属客服” → 用 .link，走系统默认蓝色
        // ② “电话”     → 不用 .link；先按红字+蓝线渲染，稍后在 cell 内打 .jobsAction 标记
        let ps = jobsMakeParagraphStyle { $0.alignment = .center; $0.lineSpacing = 4 }
        let runs: [JobsRichRun] = [
            JobsRichRun(.text("如需帮助，请联系 "))
                .font(.systemFont(ofSize: 16))
                .color(.label),

            JobsRichRun(.text(customerText))        // 系统默认蓝色
                .font(.systemFont(ofSize: 16))
                .link(customerURL),

            JobsRichRun(.text(" ")),                // 空格分隔

            JobsRichRun(.text(phoneText))           // 红字 + 蓝线（自定义动作，非系统 link）
                .font(.systemFont(ofSize: 16))
                .color(.red)
                .underline(.single, color: .blue)
        ]

        // 卡片里的“图标附件”示例：回形针 + “附件说明”
        let paperclipConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let paperclipImage  = UIImage(systemName: "paperclip", withConfiguration: paperclipConfig)!
        let att = NSTextAttachment(); att.image = paperclipImage

        let attachPS = jobsMakeParagraphStyle { $0.alignment = .center; $0.lineSpacing = 2 }
        let attachRuns: [JobsRichRun] = [
            JobsRichRun(.attachment(att, CGSize(width: 16, height: 16))),
            JobsRichRun(.text("  附件说明"))
                .font(.systemFont(ofSize: 15))
                .color(.secondaryLabel)
        ]

        cell.configure(
            title: title,
            runs: runs,
            paragraphStyle: ps,
            // “电话”的自定义点击与样式将在 cell 内补充（.jobsAction）
            phoneText: phoneText,
            phoneURL: phoneURL,
            // 附件示例
            attachmentRuns: attachRuns,
            attachmentParagraphStyle: attachPS,
            mode: mode,
            vc: self
        )
        return cell
    }
}

// MARK: - UITextViewDelegate（仅用于 Delegate 方案处理“专属客服”）
extension RichTextDemoVC: UITextViewDelegate {

    // iOS 17+
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView,
                  primaryActionFor textItem: UITextItem) -> UIAction? {
        if case let .link(url) = textItem.content {
            handleURL(url, source: "Delegate")
            return nil
        }
        return nil
    }

    // iOS 16 及以下
    @available(iOS, introduced: 10.0, deprecated: 17.0,
               message: "Use textView(_:primaryActionFor:) on iOS17+ instead")
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        handleURL(URL, source: "Delegate")
        return false
    }

    private func handleURL(_ url: URL, source: String) {
        if url.scheme == "click", url.host == "customer" {
            let ac = UIAlertController(title: "\(source) 点击",
                                       message: "点了：专属客服",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
        } else if url.scheme == "tel" || url.scheme == "telprompt" {
            #if targetEnvironment(simulator)
            let ac = UIAlertController(title: "提示",
                                       message: "模拟器不支持拨号：\(url.absoluteString)",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            present(ac, animated: true)
            #else
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            #endif
        }
    }
}

// MARK: - 单一 Cell（支持 Delegate / RAC）
final class LinkCell: UITableViewCell, HasDisposeBag {

    enum Mode { case delegate, rac }
    static let reuseID = "LinkCell"

    private let titleLabel      = UILabel()
    private let cardView        = UIView()
    private let textView        = UITextView()
    private let attachmentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }

        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 10
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }

        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 6, right: 12)
        // 不设置 linkTextAttributes，允许“专属客服”走系统默认、“电话”走自定义
        cardView.addSubview(textView)

        attachmentLabel.textAlignment = .center
        attachmentLabel.numberOfLines = 1
        cardView.addSubview(attachmentLabel)

        textView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        attachmentLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 统一配置
    func configure(title: String,
                   runs: [JobsRichRun],
                   paragraphStyle: NSMutableParagraphStyle,
                   phoneText: String,
                   phoneURL: String,
                   attachmentRuns: [JobsRichRun],
                   attachmentParagraphStyle: NSMutableParagraphStyle,
                   mode: Mode,
                   vc: RichTextDemoVC) {

        titleLabel.text = title
        textView.delegate = nil
        textView.dataDetectorTypes = []
        textView.isSelectable = (mode == .delegate)   // Delegate 用系统 link；RAC 关闭以避免冲突

        // 主富文本
        textView.richTextBy(runs, paragraphStyle: paragraphStyle)

        // 给“电话”片段打上自定义可点击标记 + 红字蓝线（保证样式）
        if let ms = textView.attributedText?.mutableCopy() as? NSMutableAttributedString {
            let full = ms.string as NSString
            let range = full.range(of: phoneText)
            if range.location != NSNotFound {
                ms.addAttributes([
                    .jobsAction: phoneURL,
                    .foregroundColor: UIColor.red,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.blue
                ], range: range)
                textView.attributedText = ms
            }
        }

        // 附件示例（回形针 + 文本）
        attachmentLabel.richTextBy(attachmentRuns, paragraphStyle: attachmentParagraphStyle)

        // 清理旧手势
        textView.gestureRecognizers?.forEach { textView.removeGestureRecognizer($0) }

        // 安装点击处理：Delegate 模式只补“电话”；RAC 模式同时管“专属客服”和“电话”
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false   // 允许系统 link（专属客服）继续工作
        // ⚠️ 不再设置 tap.delegate，彻底规避 UIGestureRecognizerDelegate 的冗余遵循问题
        textView.addGestureRecognizer(tap)

        if mode == .delegate {
            // 仅处理自定义动作（电话）；“专属客服”交给 UITextViewDelegate
            tap.rx.event
                .subscribe(onNext: { [weak self, weak vc] gr in
                    guard let self, let vc else { return }
                    if let url = self.urlAtTap(in: self.textView, gesture: gr, preferJobsAction: true) {
                        if url.scheme == "tel" || url.scheme == "telprompt" {
                            #if targetEnvironment(simulator)
                            let ac = UIAlertController(title: "提示",
                                                       message: "模拟器不支持拨号：\(url.absoluteString)",
                                                       preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "确定", style: .default))
                            vc.present(ac, animated: true)
                            #else
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            #endif
                        }
                    }
                })
                .disposed(by: disposeBag)

            textView.delegate = vc
        } else {
            // RAC：自管两种点击
            tap.rx.event
                .subscribe(onNext: { [weak self, weak vc] gr in
                    guard let self, let vc else { return }
                    guard let url = self.urlAtTap(in: self.textView, gesture: gr, preferJobsAction: true) else { return }
                    if url.scheme == "click", url.host == "customer" {
                        let ac = UIAlertController(title: "RAC 点击",
                                                   message: "点了：专属客服",
                                                   preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "确定", style: .default))
                        vc.present(ac, animated: true)
                    } else if url.scheme == "tel" || url.scheme == "telprompt" {
                        #if targetEnvironment(simulator)
                        let ac = UIAlertController(title: "提示",
                                                   message: "模拟器不支持拨号：\(url.absoluteString)",
                                                   preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "确定", style: .default))
                        vc.present(ac, animated: true)
                        #else
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        #endif
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    // 点击命中：优先匹配自定义 .jobsAction（电话），其次匹配系统 .link（专属客服）
    private func urlAtTap(in textView: UITextView,
                          gesture: UITapGestureRecognizer,
                          preferJobsAction: Bool) -> URL? {
        let lm = textView.layoutManager
        let tc = textView.textContainer
        var p  = gesture.location(in: textView)
        p.x -= textView.textContainerInset.left
        p.y -= textView.textContainerInset.top

        let glyph = lm.glyphIndex(for: p, in: tc)
        guard glyph < lm.numberOfGlyphs else { return nil }
        let char  = lm.characterIndexForGlyph(at: glyph)
        guard char < textView.attributedText.length else { return nil }

        let attrs = textView.attributedText.attributes(at: char, effectiveRange: nil)

        if preferJobsAction,
           let action = attrs[.jobsAction] as? String,
           let url = URL(string: action) {
            return url
        }
        if let v = attrs[.link] as? URL { return v }
        if let s = attrs[.link] as? String, let url = URL(string: s) { return url }
        return nil
    }
}
