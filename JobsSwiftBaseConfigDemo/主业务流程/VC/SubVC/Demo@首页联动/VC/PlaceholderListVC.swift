//
//  PlaceholderListVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit
import JXSegmentedView

final class PlaceholderListVC: BaseVC, JXSegmentedListContainerViewListDelegate {

    private let titleText: String
    init(title: String) { self.titleText = title; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private lazy var tipLabel: UILabel = {
        UILabel()
            .byText("这里是「\(titleText)」示例页面")
            .byFont(.systemFont(ofSize: 16, weight: .medium))
            .byTextColor(.secondaryLabel)
            .byAddTo(view) { make in make.center.equalToSuperview() }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tipLabel.byVisible(YES)
    }

    func listView() -> UIView { view }
}
