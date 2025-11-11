//
//  Demo@自定义注解.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//

import UIKit
import SnapKit
import MyMacros   // ⬅️ 导入你本地包导出的宏（模块名即导出层 target）

@EquatableBy("id")
struct User {
    let id: Int
    var name: String
}

final class 自定义注解Demo: BaseVC {   // ⬅️ 与后面扩展保持一致

    private enum Section { case main }

    // MARK: - State
    private var users: [User] = [
        .init(id: 1, name: "Alice"),
        .init(id: 2, name: "Bob"),
        .init(id: 3, name: "Cindy")
    ]
    private var rows: Int = 3 { didSet { rows = max(0, rows) } }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self) // 先占位，后续会被 diffable 覆盖
            .byDelegate(self)
            .registerCell(UITableViewCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()
            .jobs_emptyButtonProvider { [unowned self] in
                UIButton(type: .system)
                    .byTitle("暂无数据", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("tray".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onTap { [weak self] _ in
                        guard let self else { return }
                        self.users = (1...10).map { User(id: $0, name: "User \($0)") }
                        self.rows = self.users.count
                        self.applySnapshot(animated: true)
                    }
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }
            .configRefreshHeader(
                component: JobsDefaultHeader(),
                container: self,
                trigger: 66
            ) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    self.rows = 20
                    self.users = (1...self.rows).map { User(id: $0, name: "User \($0)") }
                    self.applySnapshot(animated: true)
                    self.tableView.switchRefreshHeader(to: .normal)
                    self.tableView.switchRefreshFooter(to: .normal)
                }
            }
            .configRefreshFooter(
                component: JobsDefaultFooter(),
                container: self,
                trigger: 66
            ) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if self.rows < 60 {
                        let start = self.rows + 1
                        self.rows += 20
                        let more = (start...self.rows).map { User(id: $0, name: "User \($0)") }
                        self.users.append(contentsOf: more)
                        self.applySnapshot(animated: true)
                        self.tableView.switchRefreshFooter(to: .normal)
                    } else {
                        self.tableView.switchRefreshFooter(to: .noMoreData)
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()

    private lazy var renameButton: UIButton = {
        UIButton.sys()
            .byTitle("① 改 #2 的 name（id 不变）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byBgColor(.systemBlue)
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .onTap { [weak self] _ in self?.renameSameID() }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
                make.left.equalToSuperview().inset(16)
            }
    }()

    private lazy var replaceButton: UIButton = {
        UIButton.sys()
            .byTitle("② 替换 #2（id → 99）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byBgColor(.systemOrange)
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .onTap { [weak self] _ in self?.replaceWithNewID() }
            .byAddTo(view) { [unowned self] make in
                make.centerY.equalTo(self.renameButton)
                make.left.equalTo(self.renameButton.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().inset(16)
            }
    }()

    // MARK: - Diffable DataSource
    private var dataSource: UITableViewDiffableDataSource<Section, User>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "@EquatableBy(\"id\") × Jobs DSL"
        view.backgroundColor = .systemBackground
        _ = tableView; _ = renameButton; _ = replaceButton

        // Diffable：真正的数据源
        dataSource = UITableViewDiffableDataSource<Section, User>(tableView: tableView) { tableView, indexPath, item in
            tableView
                .dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
                .byText("ID=\(item.id)")
                .bySecondaryText(item.name)
                .bySelectionStyle(.none)
                .byAccessoryType(.disclosureIndicator)
        }

        // 覆盖掉 .byDataSource(self) 设置的 dataSource
        tableView.dataSource = dataSource

        applySnapshot(animated: false)
    }

    // MARK: - Snapshot
    private func applySnapshot(animated: Bool = true, reload: [User] = []) {
        var snap = NSDiffableDataSourceSnapshot<Section, User>()
        snap.appendSections([.main])
        let display = Array(users.prefix(rows))
        snap.appendItems(display, toSection: .main)
        if !reload.isEmpty { snap.reloadItems(reload) } // 同 id 只重载
        dataSource.apply(snap, animatingDifferences: animated)
    }

    // MARK: - Actions
    private func renameSameID() {
        guard let idx = users.firstIndex(where: { $0.id == 2 }) else { return }
        users[idx].name = "Bob \(Int.random(in: 100...999))"
        applySnapshot(reload: [users[idx]])     // 同 id：Diffable 识别为同一 item → 局部刷新
    }

    private func replaceWithNewID() {
        guard let idx = users.firstIndex(where: { $0.id == 2 }) else { return }
        let new = User(id: 99, name: "Bob(NewID)")
        users[idx] = new                         // id 变了：Diffable 识别为新 item → 插入/删除动画
        applySnapshot(animated: true)
    }
}
// MARK: - 协议占位实现（满足你的 DSL 链式要求）
extension 自定义注解Demo: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 实际不会走到（由 diffable 提供 cell），但为满足 .byDataSource(self) 保持最小实现
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        let display = Array(users.prefix(rows))
        if indexPath.row < display.count {
            let u = display[indexPath.row]
            cell.byText("ID=\(u.id)").bySecondaryText(u.name).bySelectionStyle(.none)
        }
        return cell
    }
}

extension 自定义注解Demo: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let display = Array(users.prefix(rows))
        guard indexPath.row < display.count else { return }
        let u = display[indexPath.row]
        print("👉 tap user id=\(u.id), name=\(u.name)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
