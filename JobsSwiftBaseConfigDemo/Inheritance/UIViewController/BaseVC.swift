//
//  BaseVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/2/25.
//

import UIKit
import SnapKit

class BaseVC: UIViewController {
    deinit {
        // 清理资源
        print("deinit")
        debugOnly {  // 仅 Debug 执行
            JobsToast.show(
                text: "当前控制器销毁成功",
                config: JobsToast.Config()
                    .byBgColor(.systemGreen.withAlphaComponent(0.9))
                    .byCornerRadius(12)
            )
        }
    }
    /// 手势返回
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let nav = navigationController else { return }
        // 只有当栈深 > 1 时才允许侧滑
        let canPop = nav.viewControllers.count > 1
        // 关键：把手势的 delegate 置空，交还给系统默认的触发逻辑
        nav.interactivePopGestureRecognizer?.delegate = nil
        nav.interactivePopGestureRecognizer?.isEnabled = canPop
    }
}
