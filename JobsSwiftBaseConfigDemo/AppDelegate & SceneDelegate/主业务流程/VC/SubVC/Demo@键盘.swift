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
import NSObject_Rx

final class KeyboardDemoVC: BaseVC {

    private let bag = DisposeBag()
    // 输入框
    private lazy var textField: UITextField = {
        UITextField()
            .byPlaceholder("请输入文字，弹出键盘试试")
            .byBorderStyle(.roundedRect)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(80.h)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(44)
            }
    }()
    // 底部工具栏（跟随键盘上移）
    private lazy var bottomBar: UIView = {
        UIView()
            .byBgColor(.systemGray6)
            .byAddTo(view) { [unowned self] make in
                make.left.right.equalToSuperview()
                make.height.equalTo(60)
                make.bottom.equalToSuperview() // 初始状态贴底
            }
    }()

    private lazy var label: UILabel = {
        UILabel()
            .byText("我是底部栏，会跟随键盘上移")
            .byTextColor(.darkGray)
            .byTextAlignment(.center)
            .byAddTo(bottomBar) { make in
                make.edges.equalToSuperview()
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "Keyboard Height Demo"
        )
        textField.byAlpha(1)
        bottomBar.byAlpha(1)
        label.byAlpha(1)
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
}
