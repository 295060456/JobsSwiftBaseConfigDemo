//
//  VC2.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/10.
//

import UIKit
import SnapKit

class VC2: BaseVC {

    var collectionView: UICollectionView!
    var data: [String] = []

    let refreshControl = UIRefreshControl()
    var isLoadingMore = false
    let emptyView = EmptyView()
    
    func printSomething() {
            print("Hello from MyObject")
    }

    func startTask() {
        let task = jobs_weakify(self, VC2.printSomething)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            task() // ✅ 没有?也可以了
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        jobsSetupGKNav(
            title: "UITextField 全量演示"
        )

        doAsync(after: 2.0) { strongSelf in
            strongSelf.view.backgroundColor = .blue
        }
        
        setupCollectionView()
        setupEmptyView()
        loadInitialData()
        
    }

    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
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

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func loadInitialData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.data = (1...10).map { "图片 \($0)" }
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            self.checkEmptyState()
        }
    }

    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.data = (1...Int.random(in: 0...8)).map { "刷新 \($0)" }
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            self.checkEmptyState()
        }
    }

    private func loadMoreData() {
        guard !isLoadingMore else { return }
        isLoadingMore = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newItems = (self.data.count+1...self.data.count+6).map { "加载 \($0)" }
            self.data.append(contentsOf: newItems)
            self.collectionView.reloadData()
            self.isLoadingMore = false
        }
    }

    private func checkEmptyState() {
        emptyView.isHidden = !data.isEmpty
        collectionView.isHidden = data.isEmpty
    }
}

// MARK: - Delegate
extension VC2: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.config(title: data[indexPath.item], image: "photo".sysImg)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - height - 100 {
            loadMoreData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = data[indexPath.item]
        print("点击 item：\(name)")
    }
}
