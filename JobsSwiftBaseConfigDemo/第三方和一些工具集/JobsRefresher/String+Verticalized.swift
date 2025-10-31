//
//  String+Verticalized.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import Foundation

extension String {
    /// 将字符串竖排化：每字符一行（Emoji/空格也原样拆分）
    var mrk_verticalized: String {
        guard !isEmpty else { return self }
        return self.map { String($0) }.joined(separator: "\n")
    }
}
