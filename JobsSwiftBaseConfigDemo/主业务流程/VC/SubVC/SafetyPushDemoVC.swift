//
//  SafetyPushDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 2025/09/30.
//

import UIKit
import SnapKit

final class SafetyPushDemoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🚦 Safety Push Demo"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    // MARK: - UI
    private let stack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .center
    }

    private func setupUI() {
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        // 1️⃣ 普通按钮，测试重复点击防重 push
        let btn1 = UIButton(type: .system)
        btn1.setTitle("Push Detail (快速连点试试)", for: .normal)
        btn1.addTarget(self, action: #selector(onPushVC), for: .touchUpInside)
        stack.addArrangedSubview(btn1)
        // 2️⃣ 自定义 View，内部自己调用 pushSafely
        let customView = DemoInnerView()
        customView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        customView.layer.cornerRadius = 8
        customView.snp.makeConstraints { make in
            make.width.equalTo(250)
            make.height.equalTo(60)
        }
        stack.addArrangedSubview(customView)

        // label
        let tip = UILabel()
        tip.text = "👆 点上面蓝色 View 看是否能推页面"
        tip.textColor = .secondaryLabel
        tip.font = .systemFont(ofSize: 14)
        stack.addArrangedSubview(tip)
    }
    // MARK: - Action
    @objc private func onPushVC() {
        DemoDetailVC()
            .byData(["id": 7, "title": "详情", "price": 9.9])// 字典
            .onResult { id in
                print("回来了 id=\(id)")
            }
            .byPush(self)           // 自带防重入，连点不重复
    }
}
// MARK: 一个自定义 View，内部点击时也能调用 pushVC
final class DemoInnerView: UIView {

    private lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.text = "👉 Tap Here (View 内触发 Push)"
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = .systemBlue
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onTap() {
        DemoDetailVC()
            .byData(DemoModel(id: 7, title: "详情"))
            .onResult { id in
                print("回来了 id=\(id)")
            }
            .byPush(self)           // 自带防重入，连点不重复
    }
}
