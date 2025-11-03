//
//  Demo@BMPlayer.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/28/25.
//

import UIKit
import SnapKit

final class BMPlayerDemoVC: BaseVC,
                            UITableViewDataSource,
                            UITableViewDelegate {

    private enum Row: Int, CaseIterable {
        case local, remote, feed
        var title: String {
            switch self {
            case .local:  return "本地视频：welcome_video.mp4（单独播放）"
            case .remote: return "网络视频：BigBuckBunny（单独播放）"
            case .feed:   return "抖音风：列表预览 → 详情页独立播放"
            }
        }
    }

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UITableViewCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()
            .byAddTo(view) {[unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "BMPlayer"
        )
        tableView.byVisible(YES)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { Row.allCases.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.py_dequeueReusableCell(withType: UITableViewCell.self, for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        cfg.text = Row(rawValue: indexPath.row)!.title
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Row(rawValue: indexPath.row)! {
        case .local:  PlayerLocalVC().byPush(self)     // 你项目里已有 .byPush
        case .remote: PlayerRemoteVC().byPush(self)
        case .feed:   FeedListVC().byPush(self)
        }
    }
}
