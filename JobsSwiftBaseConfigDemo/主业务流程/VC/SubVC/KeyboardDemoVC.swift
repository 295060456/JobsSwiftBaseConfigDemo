//
//  KeyboardDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/09/30.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class KeyboardDemoVC: UIViewController {

    private let bag = DisposeBag()

    // 输入框
    private let textField = UITextField().then {
        $0.placeholder = "请输入文字，弹出键盘试试"
        $0.borderStyle = .roundedRect
    }

    // 底部工具栏（跟随键盘上移）
    private let bottomBar = UIView().then {
        $0.backgroundColor = .systemGray6
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard Height Demo"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // ✅ 核心：监听键盘高度
        view.keyboardHeight
            .subscribe(onNext: { [weak self] height in
                guard let self else { return }
                print("🧠 当前键盘高度: \(height)")
                // 更新底部 bar 位置
                self.bottomBar.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().inset(height)
                }
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: bag)
    }

    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(bottomBar)

        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        bottomBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalToSuperview() // 初始状态贴底
        }

        let label = UILabel()
        label.text = "我是底部栏，会跟随键盘上移"
        label.textColor = .darkGray
        label.textAlignment = .center
        bottomBar.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
