//
//  LiveCommentDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//

import UIKit
import SnapKit

final class LiveCommentDemoVC: BaseVC {
    // Data
    private var data: [LiveMsg] = [
        .init(text: "欢迎来到直播间～"),
        .init(text: "礼貌发言，气氛更好 😄")
    ]

    // inputAccessoryView
    private lazy var accessory: LiveInputBar = {
        var a = LiveInputBar()
        a.sendBtn.onTap { [weak self] _ in self?.sendFromInput() }
        a.tf.byDelegate(self)
        return a
    }()
    override var canBecomeFirstResponder: Bool { true }
    override var inputAccessoryView: UIView? { accessory }

    // Table（添加与约束都在懒加载里）
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(LiveMsgCell.self)
            .bySeparatorStyle(.none)
            .byKeyboardDismissMode(.interactive)
            .byNoContentInsetAdjustment()
            .byBgColor(.clear)
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
            .jobs_addGestureRetView(
                UITapGestureRecognizer
                    .byConfig {[weak self] gr in
                        guard let self else { return }
                        view.endEditing(true)
                        gr.cancelsTouchesInView = false
                    }
                    .byTaps(2)                       // 双击
                    .byTouches(1)                    // 单指
                    .byCancelsTouchesInView(true)
                    .byEnabled(true)
                    .byName("customTap")
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        byTitle("直播间留言")
        view.byBgColor(.systemBackground)
        tableView.byVisible(YES)
        DispatchQueue.main.async { [weak self] in self?.scrollToBottom(false) }
    }

    private func sendFromInput() {
        let raw = accessory.tf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty else { return }
        accessory.tf.text = nil
        appendMessage(raw)
    }

    private func appendMessage(_ text: String) {
        let new = LiveMsg(text: text)
        let newRow = data.count
        data.append(new)

        tableView.performBatchUpdates({
            tableView.insertRows(at: [IndexPath(row: newRow, section: 0)], with: .none)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.scrollToBottom(false)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: newRow, section: 0)) as? LiveMsgCell {
                cell.playAppearAnimation()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    guard let self,
                          let c = self.tableView.cellForRow(at: IndexPath(row: newRow, section: 0)) as? LiveMsgCell else { return }
                    c.playAppearAnimation()
                }
            }
        })
    }

    private func scrollToBottom(_ animated: Bool) {
        guard !data.isEmpty else { return }
        let ip = IndexPath(row: data.count - 1, section: 0)
        tableView.scrollToRow(at: ip, at: .bottom, animated: animated)
    }
}
// ============================== Delegates ==============================
extension LiveCommentDemoVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        (tableView.dequeueReusableCell(withIdentifier: LiveMsgCell.className,for: indexPath) as! LiveMsgCell).configure(data[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { view.endEditing(true) }
}

extension LiveCommentDemoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendFromInput()
        return true
    }
}
