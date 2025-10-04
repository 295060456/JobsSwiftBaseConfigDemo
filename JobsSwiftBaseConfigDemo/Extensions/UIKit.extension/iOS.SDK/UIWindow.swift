//
//  UIWindow.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/4/25.
//

import UIKit

extension UIWindow {
    /// 返回一个“保证非空”的 UIWindow
    /// - 优先 jobsKeyWindow（真实窗口）
    /// - 取不到时兜底创建一个离屏窗口，避免 unwrap 报错
    static var wd: UIWindow {
        if let real = UIApplication.jobsKeyWindow() {
            return real
        } else {
            // ✅ 构造一个兜底 window（不会显示，只用于防止 nil）
            let dummy = UIWindow(frame: UIScreen.main.bounds)
            dummy.windowLevel = .alert + 1
            return dummy
        }
    }

    /// 实例访问也保持一致
    var wd: UIWindow { Self.wd }
}
