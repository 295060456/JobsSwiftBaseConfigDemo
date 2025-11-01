//
//  TRString.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import Foundation

/// 统一、唯一的本地化入口
public extension String {
    /// 只保留这一版：强制走 TRLang.bundleProvider
    var tr: String {
        let bundle = TRLang.bundleProvider()
        let s = NSLocalizedString(self,
                                  tableName: nil,
                                  bundle: bundle,
                                  value: self,
                                  comment: "")
        // 不再做兼容：你项目已存在 TRAutoRefresh 标记链，请直接走它
        return TRAutoRefresh.Marker.pack(translated: s, key: self, table: nil)
    }
}
