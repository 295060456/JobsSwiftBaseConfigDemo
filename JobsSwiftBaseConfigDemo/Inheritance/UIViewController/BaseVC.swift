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
        Task { @MainActor in
            JobsToast.show(
                text: "当前控制器销毁成功",
                config: JobsToast.Config()
                    .byBgColor(.systemGreen.withAlphaComponent(0.9))
                    .byCornerRadius(12)
            )
        }
    }
}
