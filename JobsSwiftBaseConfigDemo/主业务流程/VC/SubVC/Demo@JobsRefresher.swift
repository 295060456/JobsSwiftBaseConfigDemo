//
//  JobsRefresherDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit
import SnapKit
/// 上：横向侧拉（Left/Right）
/// 下：纵向下拉/上拉（Header/Footer）
final class JobsRefresherDemoVC: BaseVC {
    private let topHeight: CGFloat = 180
    private var hItems = 18          // 顶部横向卡片数量
    private var rows = 20            // 底部纵向行数

    private lazy var hLayout: UICollectionViewFlowLayout = {
        UICollectionViewFlowLayout()
            .byScrollDirection(.horizontal)
            .byMinimumLineSpacing(12)
            .byMinimumInteritemSpacing(12)
            .bySectionInset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
            .byItemSize(CGSize(width: 120, height: 156))
    }()

    private lazy var topCollection: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: hLayout)
           .byDataSource(self)
           .byDelegate(self)
           .registerCell(HCell.self)
           .byBackgroundView(nil)
           .byShowsHorizontalScrollIndicator(false)
           .byAlwaysBounceHorizontal(true)// 即使不满一屏也允许左右拉
           .byAddTo(view) { [unowned self] make in
               make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
               make.left.right.equalToSuperview()
               make.height.equalTo(topHeight)
           }
           // 左侧拉：比如“上一页/回退”
           .configSideRefresh(with: JobsDefaultLeft(),
                              container: self,
                              at: .left,
                              trigger: 70) { [weak self] in
               guard let self else { return }
               Task { @MainActor in
                   try? await Task.sleep(nanoseconds: 900_000_000)
                   // 模拟“刷新完成”：减少一个 item 并刷新
                   self.hItems = max(8, self.hItems - 1)
                   self.topCollection.byReloadData()
                   self.topCollection.switchSideRefresh(.left, to: .normal)
               }
           }
           // 右侧拉：比如“下一页/加载更多卡片”
           .configSideRefresh(with: JobsDefaultRight(),
                                           container: self,
                                           at: .right,
                                           trigger: 70) { [weak self] in
               guard let self else { return }
               Task { @MainActor in
                   try? await Task.sleep(nanoseconds: 900_000_000)
                   self.hItems += 3
                   self.topCollection.byReloadData()
                   self.topCollection.switchSideRefresh(.right, to: .normal)
               }
           }
    }()

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byRowHeight(52)
            .byTableFooterView(UIView())
            .byDataSource(self)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(topCollection.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            // 下拉刷新 Header
            .configRefreshHeader(component: JobsDefaultHeader(),
                                 container: self,
                                 trigger: 66) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    self.rows = 20
                    self.tableView.byReloadData()
                    self.tableView.switchRefreshHeader(to: .normal)
                    self.tableView.switchRefreshFooter(to: .normal) // 复位“无更多”
                }
            }
            // 上拉加载 Footer
            .configRefreshFooter(component: JobsDefaultFooter(),
                                          container: self,
                                          trigger: 66) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if self.rows < 60 {
                        self.rows += 20
                        self.tableView.byReloadData()
                        self.tableView.switchRefreshFooter(to: .normal)
                    } else {
                        self.tableView.switchRefreshFooter(to: .noMoreData)
                    }
                }
            }
    }()
}
// MARK: - Life Cycle
extension JobsRefresherDemoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        topCollection.byVisible(YES)
        tableView.byVisible(YES)
    }
}
// MARK: - UITableViewDataSource
extension JobsRefresherDemoVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                UITableViewCell(style: .default, reuseIdentifier: "cell")
        var cfg = c.defaultContentConfiguration()
        cfg.text = "Row \(indexPath.row)"
        c.contentConfiguration = cfg
        return c
    }
}
// MARK: - UICollectionViewDataSource
extension JobsRefresherDemoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { hItems }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HCell = collectionView.dequeueCell(HCell.self, for: indexPath)
        cell.configure(index: indexPath.item)
        return cell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout (可选扩展)
extension JobsRefresherDemoVC: UICollectionViewDelegateFlowLayout { }
// MARK: - Cell
private final class HCell: UICollectionViewCell {
    static let reuseId = "HCell"
    private lazy var label: UILabel = {
        UILabel()
            .byFont(.systemFont(ofSize: 16, weight: .semibold))
            .byTextAlignment(.center)
            .byTextColor(.label)
            .byAddTo(contentView) { [unowned self] make in
                make.edges.equalToSuperview()
            }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.byBgColor(.secondarySystemBackground)
            .byCornerRadius(12)
            .byMasksToBounds(YES)
        label.byVisible(YES)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(index: Int) {
        label.byText("Card \(index)")
    }
}
