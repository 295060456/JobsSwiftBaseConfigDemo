//
//  ScrollDecelerator.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/28/25.
//

import UIKit
/// 模拟 UIScrollView 的减速曲线
/// velocity：当前速度（可以是角速度 rad/s）
/// decelerationRate：UIScrollView.DecelerationRate.normal.rawValue 之类
struct ScrollDecelerator {
    var velocity: CGFloat              // 当前速度（比如角速度）
    let decelerationRate: CGFloat      // 例如 0.998（.normal）
    /// 每过 dt 秒，更新一次速度，并返回这一小段的“位移”（你这边就是 Δangle）
    mutating func step(dt: CGFloat) -> CGFloat {
        guard dt > 0 else { return 0 }

        // 每毫秒乘一次 rate -> dt 秒乘 pow(rate, dt * 1000)
        let factor = pow(decelerationRate, dt * 1000)

        let v0 = velocity
        let v1 = v0 * factor              // 衰减后的速度

        // 位移 ≈ (v0 + v1) / 2 * dt （匀变速近似）
        let displacement = (v0 + v1) * 0.5 * dt

        velocity = v1
        return displacement
    }

    /// 是否已经“几乎停了”
    func isStopped(threshold: CGFloat = 0.01) -> Bool {
        return abs(velocity) < threshold
    }
}
