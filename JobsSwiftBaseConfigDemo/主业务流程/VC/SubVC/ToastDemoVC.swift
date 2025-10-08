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
                        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
                    }
                    make.left.right.equalToSuperview().inset(sideInset)
                    make.height.equalTo(btnHeight)
                }
            last = btn
            return btn
        }

        // 1) 默认：1s、底部偏移120
        addButton("默认 Toast（“谢谢光临”）") {
            JobsToast.show(text: "谢谢光临")
        }

        // 2) 自定义时长/位置（链式 Config）
        addButton("时长2.5s / 底部偏移80") {
            JobsToast.show(
                text: "操作成功",
                config: JobsToast.Config()
                    .byDuration(2.5)
                    .byBottomOffset(80)
            )
        }

        // 3) 自定义样式：绿色背景 + 圆角12
        addButton("绿色圆角 Toast") {
            JobsToast.show(
                text: "保存成功",
                config: JobsToast.Config()
                    .byBgColor(.systemGreen.withAlphaComponent(0.9))
                    .byCornerRadius(12)
            )
        }

        // 4) 可点击（按钮作为内容，tap 回调）
        addButton("可点击 Toast（撤销）") {
            JobsToast.show(
                text: "点我撤销",
                tap: { _ in
                    print("🫳 撤销一次")
                },
                completion: {
                    print("✅ 点击或超时后消失")
                }
            )
        }

        // 5) 大内边距（更宽的背景气泡）
        addButton("大 padding Toast") {
            JobsToast.show(
                text: "大 padding",
                config: JobsToast.Config()
                    .byHorizontalPadding(24)
                    .byVerticalPadding(14)
            )
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
