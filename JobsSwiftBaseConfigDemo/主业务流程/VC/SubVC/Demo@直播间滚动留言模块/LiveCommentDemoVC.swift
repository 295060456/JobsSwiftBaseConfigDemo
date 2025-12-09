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
        LiveInputBar()
            .onSend { [weak self] text in
                guard let self else { return }
                // 你的发送流程：插入消息、滚到底、更新底部 inset
                self.appendMessage(text)
                self.updateBottomInsetForAccessory()
            }
            .byAutoClearAfterSend(true)
            .byAutoResignAfterSend(false)   // 如果你希望继续输入，就设为 false
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
                    make.left.right.bottom.equalToSuperview()     // ✅ 改：贴到底
                } else {
                    make.edges.equalToSuperview()
                }
            }
            // ====== B. 手势不要截断触摸 ======
            .jobs_addGestureRetView(
                UITapGestureRecognizer
                    .byConfig { [weak self] gr in
                        guard let self else { return }
                        jobsDismissKeyboard()
                        gr.cancelsTouchesInView = false          // ✅ 改：允许触摸继续向下传递
                    }
                    .byTaps(2)
                    .byTouches(1)
                    // .byCancelsTouchesInView(true)             // ❌ 删除这行（或保持为 false）
                    .byEnabled(true)
                    .byName("customTap")
            )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(
            title: "直播间留言"
        )
        view.byBgColor(.systemBackground)
        tableView.byVisible(YES)
        DispatchQueue.main.async { [weak self] in self?.scrollToBottom(false) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()                 // 你已有
        updateBottomInsetForAccessory()        // ✅ 出现后立刻修正 inset
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateBottomInsetForAccessory()        // ✅ 旋转/设备变化时更新
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBottomInsetForAccessory()        // ✅ 布局周期尾部兜底一次
    }

    private func sendFromInput() {
        let raw = accessory.tf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty else { return }
        appendMessage(raw)
        accessory.tf.text = nil
    }

    // MARK: - 让列表永远在键盘/输入条之上
    // 让列表内容 & 指示器永远在输入条之上
    private func updateBottomInsetForAccessory() {
        let bottom = accessory.intrinsicContentSize.height + view.safeAreaInsets.bottom

        // content inset
        if tableView.contentInset.bottom != bottom {
            var ci = tableView.contentInset
            ci.bottom = bottom
            tableView.contentInset = ci
        }

        // scroll indicator inset（新 API 优先）
        if #available(iOS 13.0, *) {
            var vi = tableView.verticalScrollIndicatorInsets
            if vi.bottom != bottom {
                vi.bottom = bottom
                tableView.verticalScrollIndicatorInsets = vi
            }
        } else {
            var si = tableView.scrollIndicatorInsets   // 仅 < iOS 13 使用旧 getter
            if si.bottom != bottom {
                si.bottom = bottom
                tableView.scrollIndicatorInsets = si
            }
        }
    }

    private func appendMessage(_ text: String) {
        let new = LiveMsg(text: text)
        let newRow = data.count
        data.append(new)
        // 插入前：先算一次底部 inset，避免插入瞬间被遮
        updateBottomInsetForAccessory()
        tableView.performBatchUpdates({
            tableView.insertRows(at: [IndexPath(row: newRow, section: 0)], with: .none)
        }, completion: { [weak self] _ in
            guard let self else { return }

            // 插入后：完成布局 → 再滚底 → 再兜底一次 inset
            self.tableView.layoutIfNeeded()
            self.scrollToBottom(false)
            self.updateBottomInsetForAccessory()

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
        tableView.layoutIfNeeded()                            // ✅ 先完成布局
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
