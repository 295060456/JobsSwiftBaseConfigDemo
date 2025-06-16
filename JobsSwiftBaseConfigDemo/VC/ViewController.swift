//
//  ViewController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/4.
//

import UIKit
import SnapKit
//import JobsObj
//如果你真的想要 import JobsObj，你要这样做：
//你就得 把 JobsObj.swift 单独做成 module，方法如下：
//创建一个新 Framework Target（例如叫 JobsObj）；
//把 JobsObj.swift 拖进去；
//在主 App Target 中 import JobsObj；
//在主 Target 的 General > Frameworks, Libraries, and Embedded Content 中添加该 framework；
//编译。
class ViewController: UIViewController{
    fileprivate let tableView = UITableView()/// 默认internal。fileprivate本文件可访问
    private var data: [(title: String, subtitle: String)] = []
    private var isLoadingMore = false

    private let refreshControl = UIRefreshControl()
    private let emptyView = EmptyView()

    private var dataSource: UITableViewDiffableDataSource<Int, String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let obj = NSObject()
        obj.name = "Jobs"
        obj.greet() // 输出: 👋 Hello, my name is Jobs

        setupTableView()
        setupEmptyView()
        setupDataSource()

        loadInitialData()
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 封装成点语法的形式
        tableView
            .registerCell(CustomCell.self)
            .byDelegate(self)
            .byDataSource(self)
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.delegate = self

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupEmptyView() {
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.isHidden = true
        emptyView.onTapRetry = { [weak self] in
            self?.loadInitialData()
        }
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) {
            (tableView, indexPath, item) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell else {
                return UITableViewCell()
            }
            let value = self.data[indexPath.row]
            cell.config(title: value.title, subtitle: value.subtitle)
            return cell
        }
    }

    private func applySnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(data.map { $0.title })
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func loadInitialData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.data = (1...10).map { ("标题 \($0)", "副标题内容 \($0)") }
            self.applySnapshot()
            self.refreshControl.endRefreshing()
            self.checkEmptyState()
        }
    }

    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.data = (1...Int.random(in: 0...8)).map { ("刷新 \($0)", "副标题 \($0)") }
            self.applySnapshot()
            self.refreshControl.endRefreshing()
            self.checkEmptyState()
        }
    }

    private func loadMoreData() {
        guard !isLoadingMore else { return }
        isLoadingMore = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let more = (self.data.count + 1...self.data.count + 5).map {
                ("加载更多 \($0)", "副标题 \($0)")
            }
            self.data.append(contentsOf: more)
            self.applySnapshot()
            self.isLoadingMore = false
        }
    }

    private func checkEmptyState() {
        emptyView.isHidden = !data.isEmpty
        tableView.isHidden = data.isEmpty
    }
}
// MARK: - UIScrollViewDelegate 上拉加载更多
// Swift 不允许在 extension 的作用域里写“执行语句”。
// 只能写方法、计算属性、嵌套类型，不能写直接执行的代码（表达式/语句）
extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 100 {
            loadMoreData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = VC2()
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = "第 \(indexPath.row + 1) 行"
        return cell
    }
}
