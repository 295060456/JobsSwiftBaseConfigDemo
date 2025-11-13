//
//  ToastDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

import UIKit
import SnapKit

final class ToastDemoVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "Toast Demo"
        )
        setupButtons()
    }

    // MARK: - UI
    private func setupButtons() {
        // 统一样式
        let btnHeight: CGFloat = 44
        let sideInset: CGFloat = 24
        let vSpacing: CGFloat = 12

        var last: UIView?

        @discardableResult
        func addButton(_ title: String, action: @escaping () -> Void) -> UIButton {
            let btn = UIButton(type: .system)
                .byTitle(title, for: .normal)
                .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
                .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
                .onTap { _ in action() }
                .byAddTo(view) { [unowned self] make in
                    if let last {
                        make.top.equalTo(last.snp.bottom).offset(vSpacing)
                    } else {
                        make.top.equalTo(gk_navigationBar.snp.bottom).offset(10) // 占满
                    }
                    make.left.right.equalToSuperview().inset(sideInset)
                    make.height.equalTo(btnHeight)
                }
            last = btn
            return btn
        }

        // 1) 默认：1s、底部偏移120
        addButton("默认 Toast（“谢谢光临”）") {
            toastBy("谢谢光临")
        }

        // 2) 自定义时长/位置（链式 Config）
        addButton("时长2.5s / 底部偏移80") {
            toastBy("操作成功")
        }

        // 3) 自定义样式：绿色背景 + 圆角12
        addButton("绿色圆角 Toast") {
            toastBy("保存成功")
        }

        // 4) 可点击（按钮作为内容，tap 回调）
        addButton("可点击 Toast（撤销）") {
            toastBy("点我撤销")
        }

        // 5) 大内边距（更宽的背景气泡）
        addButton("大 padding Toast") {
            toastBy("大 padding")
        }

        // 6) 手动提前关闭（先弹再 1s 后主动 dismiss）
        addButton("手动提前关闭") {
            let t = JobsToast.show(
                text: "3秒后本该消失，但我会 1 秒提前关闭",
                config: JobsToast.Config().byDuration(3)
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                t.dismiss()
            }
        }
    }
}
