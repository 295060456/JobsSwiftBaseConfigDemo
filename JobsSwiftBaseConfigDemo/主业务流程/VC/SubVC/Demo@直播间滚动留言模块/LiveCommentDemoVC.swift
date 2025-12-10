//
//  LiveCommentDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift

final class LiveCommentDemoVC: BaseVC {
    // Data
    private var data: [LiveMsg] = [
        .init(text: "欢迎来到直播间～"),
        .init(text: "礼貌发言，气氛更好 😄")
    ]

    // 直接作为普通子视图，交给 IQKeyboardManager 顶起
    private lazy var accessory: LiveInputBar = {
        LiveInputBar()
            .onSend { [weak self] text in
                guard let self else { return }
                self.appendMessage(text)
            }
            .byAutoClearAfterSend(true)
            .byAutoResignAfterSend(false)   // 想发完继续输入就保持 false
    }()

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
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview()
                // ✅ 关键：列表底部贴输入条顶部，完全不用再算 inset
                make.bottom.equalTo(self.accessory.snp.top)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        jobsSetupGKNav(
            title: "直播间留言"
        )
        view.byBgColor(.systemBackground)

        setupAccessory()
        tableView.byVisible(YES)

        DispatchQueue.main.async { [weak self] in
            self?.scrollToBottom(false)
        }
    }

    // MARK: - UI
    private func setupAccessory() {
        view.addSubview(accessory)
        accessory.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    // MARK: - 发送逻辑
    private func sendFromInput() {
        let raw = accessory.tf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty else { return }
        appendMessage(raw)
        accessory.tf.text = nil
    }

    private func appendMessage(_ text: String) {
        let new = LiveMsg(text: text)
        let newRow = data.count
        data.append(new)

        tableView.performBatchUpdates({
            tableView.insertRows(at: [IndexPath(row: newRow, section: 0)], with: .none)
        }, completion: { [weak self] _ in
            guard let self else { return }

            self.tableView.layoutIfNeeded()
            self.scrollToBottom(false)

            let ip = IndexPath(row: newRow, section: 0)
            if let cell = self.tableView.cellForRow(at: ip) as? LiveMsgCell {
                cell.playAppearAnimation()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                    guard let self,
                          let c = self.tableView.cellForRow(at: ip) as? LiveMsgCell else { return }
                    c.playAppearAnimation()
                }
            }
        })
    }

    private func scrollToBottom(_ animated: Bool) {
        guard !data.isEmpty else { return }
        tableView.layoutIfNeeded()
        let ip = IndexPath(row: data.count - 1, section: 0)
        tableView.scrollToRow(at: ip, at: .bottom, animated: animated)
    }
}
// MARK: —— UITableViewDataSource & UITableViewDelegate & UITextFieldDelegate
extension LiveCommentDemoVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        (tableView.dequeueReusableCell(
            withIdentifier: LiveMsgCell.className,
            for: indexPath
        ) as! LiveMsgCell).configure(data[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

extension LiveCommentDemoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendFromInput()
        return true
    }
}
