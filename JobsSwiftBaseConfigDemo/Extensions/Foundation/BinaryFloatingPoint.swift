//
//  BinaryFloatingPoint.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/27/25.
//

import Foundation

extension BinaryFloatingPoint {
    /// 浮点数专用：指定保留几位小数
    func toString(_ fractionDigits: Int) -> String {
        String(format: "%.\(fractionDigits)f", Double(self))
    }
}
