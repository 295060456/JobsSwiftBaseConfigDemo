//
//  EmptyView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/10.
//

import UIKit
import SnapKit

class EmptyView: UIView {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        label.text = "暂无数据，点击重试"
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        addSubview(label)

        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    var onTapRetry: (() -> Void)?

    @objc private func onTap() {
        onTapRetry?()
    }
}
