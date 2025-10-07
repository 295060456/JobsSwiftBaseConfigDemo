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

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byDataSource(self)
            .byDelegate(self)
            .bySeparatorStyle(.none)
            .byRowHeight(UITableView.automaticDimension)
            .byEstimatedRowHeight(120)
            .byScrollEnabled(false)
            .registerCellByID(CellCls: LinkCell.self, ID: LinkCell.reuseID)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10.h)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "富文本演示（Delegate & RAC）"
        )
        tableView.byAlpha(1)
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
        // 主文案：两个可点击片段
        // ① “专属客服” → 用 .link，走系统默认蓝色
        // ② “电话”     → 不用 .link；先按红字+蓝线渲染，稍后在 cell 内打 .jobsAction 标记
        cell.configure(
            title: (mode == .delegate)
            ? "Delegate 方案（专属客服默认样式 + 电话红字蓝线）"
            : "RAC 方案（专属客服默认样式 + 电话红字蓝线）",
            runs: [
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
            ],
            paragraphStyle: jobsMakeParagraphStyle { $0.alignment = .center; $0.lineSpacing = 4 },
            // “电话”的自定义点击与样式将在 cell 内补充（.jobsAction）
            phoneText: phoneText,
            phoneURL: phoneURL,
            // 附件示例
            attachmentRuns: [
                JobsRichRun(.attachment(NSTextAttachment().byImage(UIImage(systemName: "paperclip",
                                                                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!),
                                        CGSize(width: 16, height: 16))),
                JobsRichRun(.text("  附件说明"))
                    .font(.systemFont(ofSize: 15))
                    .color(.secondaryLabel)
            ],
            attachmentParagraphStyle: jobsMakeParagraphStyle { $0.alignment = .center; $0.lineSpacing = 2 },
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

    // ============================== UI（懒加载：内部完成 add + 约束） ==============================
    private lazy var titleLabel: UILabel = { [unowned self] in
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .medium))
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(1)
            .byAddTo(self.contentView) { make in
                make.top.equalToSuperview().offset(12)
                make.left.equalToSuperview().offset(16)
                make.right.lessThanOrEqualToSuperview().offset(-16)
            }
    }()

    private lazy var cardView: UIView = { [unowned self] in
        UIView()
            .byBgColor(.systemGray6)
            .byCornerRadius(10)
            .byClipsToBounds(true)
            .byAddTo(self.contentView) { make in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-12)
            }
    }()

    private lazy var textView: UITextView = { [unowned self] in
        UITextView()
            .byEditable(false)
            .bySelectable(true)               // 最终由 configure 调整
            .byTextAlignment(.center)
            .byBgColor(.clear)
            .byTextContainerInset(UIEdgeInsets(top: 14, left: 12, bottom: 6, right: 12))
            .byAddTo(self.cardView) { make in
                make.top.left.right.equalToSuperview()
            }
    }()

    private lazy var attachmentLabel: UILabel = { [unowned self] in
        UILabel()
            .byTextAlignment(.center)
            .byNumberOfLines(1)
            .byAddTo(self.cardView) { make in
                make.top.equalTo(self.textView.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(12)
                make.bottom.equalToSuperview().inset(12)
            }
    }()

    // ============================== Init ==============================
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.byBgColor(.clear)
        // 唤起懒加载（不改变视觉状态）
        titleLabel.byAlpha(1)
        cardView.byAlpha(1)
        textView.byAlpha(1)
        attachmentLabel.byAlpha(1)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    // ============================== 配置入口 ==============================
    func configure(title: String,
                   runs: [JobsRichRun],
                   paragraphStyle: NSMutableParagraphStyle,
                   phoneText: String,
                   phoneURL: String,
                   attachmentRuns: [JobsRichRun],
                   attachmentParagraphStyle: NSMutableParagraphStyle,
                   mode: Mode,
                   vc: RichTextDemoVC) {

        // 懒加载可能尚未唤起，保险再“点”一次
        titleLabel.byAlpha(1); cardView.byAlpha(1); textView.byAlpha(1); attachmentLabel.byAlpha(1)

        titleLabel.byText(title)

        // 复用安全：清理旧状态
        textView.byDelegate(nil)
            .byDataDetectorTypes([])
            .bySelectable(mode == .delegate)

        // 主富文本
        textView.richTextBy(runs, paragraphStyle: paragraphStyle)

        // 给“电话”片段打 .jobsAction + 颜色/下划线
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
                textView.byAttributedText(ms)
            }
        }

        // 附件文案
        attachmentLabel.richTextBy(attachmentRuns, paragraphStyle: attachmentParagraphStyle)

        // 手势：先清旧，再加新
        textView.gestureRecognizers?.forEach { textView.removeGestureRecognizer($0) }

        // ✅ 使用的手势 DSL：byConfig / byCancelsTouchesInView / byTaps / byTouches …
        let tap = textView.jobs_addGesture(UITapGestureRecognizer
            .byConfig { gr in
                print("Tap 触发 on: \(String(describing: gr.view))")
            }
            .byCancelsTouchesInView(false)
            .byTaps(1)
            .byTouches(1))

        switch mode {
        case .delegate:
            // 仅处理自定义“电话”；系统 link（专属客服）交给 UITextViewDelegate
            tap!.event
                .subscribe(onNext: { [weak self, weak vc] (gr: UITapGestureRecognizer) in   // 👈 显式标注类型
                    guard let self, let vc else { return }
                    if let url = self.urlAtTap(in: self.textView, gesture: gr, preferJobsAction: true) {
                        self.handle(url: url, on: vc)
                    }
                })
                .disposed(by: disposeBag)
            textView.byDelegate(vc)
        case .rac:
            // 自管“专属客服”+“电话”
            tap!.event
                .subscribe(onNext: { [weak self, weak vc] (gr: UITapGestureRecognizer) in   // 👈 显式标注类型
                    guard let self, let vc else { return }
                    guard let url = self.urlAtTap(in: self.textView, gesture: gr, preferJobsAction: true) else { return }
                    self.handle(url: url, on: vc, racCustomerAlert: true)
                })
                .disposed(by: disposeBag)
        }

    }
    // ============================== 命中算法（优先 .jobsAction） ==============================
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

        var usedRect = lm.lineFragmentUsedRect(forGlyphAt: glyph, effectiveRange: nil, withoutAdditionalLayout: true)
        usedRect.origin.x += textView.textContainerInset.left
        usedRect.origin.y += textView.textContainerInset.top
        guard usedRect.contains(gesture.location(in: textView)) else { return nil }

        let char = lm.characterIndexForGlyph(at: glyph)
        guard char < textView.attributedText.length else { return nil }

        let attrs = textView.attributedText.attributes(at: char, effectiveRange: nil)

        if preferJobsAction,
           let action = attrs[.jobsAction] as? String,
           let url = URL(string: action) { return url }

        if let v = attrs[.link] as? URL { return v }
        if let s = attrs[.link] as? String, let url = URL(string: s) { return url }
        return nil
    }
    // ============================== URL 处理 ==============================
    private func handle(url: URL,
                        on vc: UIViewController,
                        racCustomerAlert: Bool = false) {
        if url.scheme == "click", url.host == "customer" {
            if racCustomerAlert {
                let ac = UIAlertController(title: "RAC 点击", message: "点了：专属客服", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "确定", style: .default))
                vc.present(ac, animated: true)
            }
            return
        }

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
}
