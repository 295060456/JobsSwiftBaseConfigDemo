//
//  LeftMenuView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

struct LeftMenuItem { let icon: String; let title: String }

final class LeftMenuView: UIView {

    private let items: [LeftMenuItem]
    private(set) var selectedIndex: Int
    var selectionChanged: ((Int) -> Void)?
    var currentTitle: String { items[selectedIndex].title }

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(LeftMenuCell.self)
            .bySeparatorStyle(.none)
            .byNoContentInsetAdjustment()
            .byAddTo(self) { make in make.edges.equalToSuperview() }
    }()

    init(items: [LeftMenuItem], defaultIndex: Int) {
        self.items = items
        self.selectedIndex = defaultIndex
        super.init(frame: .zero)
        backgroundColor = UIColor.systemGray6 // 灰底列
        // 右侧 0.5 分隔线
        UIView()
            .byBgColor(.separator)
            .byAddTo(self) { make in
                make.top.bottom.trailing.equalToSuperview()
                make.width.equalTo(0.5)
            }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.selectRow(at: IndexPath(row: defaultIndex, section: 0),
                                      animated: false, scrollPosition: .none)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension LeftMenuView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let m = items[indexPath.row]
        return (tableView.py_dequeueReusableCell(withType: LeftMenuCell.self, for: indexPath) as LeftMenuCell)
            .byMenu(icon: m.icon, title: m.title, selected: indexPath.row == selectedIndex)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        selectionChanged?(indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 64 }
}

extension LeftMenuView {
    /// 左侧菜单选中变化（链式）
    @discardableResult
    func onSelectionChanged(_ handler: @escaping (Int) -> Void) -> Self {
        self.selectionChanged = handler
        return self
    }
}
