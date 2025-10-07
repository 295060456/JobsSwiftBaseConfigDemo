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
        jobsSetupGKNav(
            title: "🚦 Safety Push Demo"
        )
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
        stack.addArrangedSubview(UIButton(type: .system)
            .byTitle("Push Detail (快速连点试试)")
            .onTap { _ in
                DemoDetailVC()
                    .byData(["id": 7, "title": "详情", "price": 9.9])// 字典
                    .onResult { id in
                        print("回来了 id=\(id)")
                    }
                    .byPush(self)           // 自带防重入，连点不重复
                    .byCompletion{
                        print("❤️结束❤️")
                    }
            })
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
        stack.addArrangedSubview(UILabel()
            .byText("👆 点上面蓝色 View 看是否能推页面")
            .byTextColor(.secondaryLabel)
            .byFont(.systemFont(ofSize: 14)))
    }
}
// MARK: 一个自定义 View，内部点击时也能调用 pushVC
final class DemoInnerView: UIView {

    private lazy var label: UILabel = {
        return UILabel().byText("👉 Tap Here (View 内触发 Push)")
            .byTextAlignment(.center)
            .byFont(.systemFont(ofSize: 15, weight: .medium))
            .byTextColor(.systemBlue)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        isUserInteractionEnabled = true
        addGestureRecognizer(
            UITapGestureRecognizer
                .byConfig { gr in
                    DemoDetailVC()
                        .byData(DemoModel(id: 7, title: "详情"))
                        .onResult { id in
                            print("回来了 id=\(id)")
                        }
                        .byPush(self)           // 自带防重入，连点不重复
                        .byCompletion{
                            print("❤️结束❤️")
                        }
                }
        )

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
