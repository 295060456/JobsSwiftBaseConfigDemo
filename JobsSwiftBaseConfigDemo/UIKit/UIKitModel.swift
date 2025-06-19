//
//  UIKitModel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/18.
//

import Foundation

class BaseModel: NSObject, NSCoding, NSSecureCoding {
    // MARK: - NSSecureCoding 支持
    static var supportsSecureCoding: Bool {
        return true
    }
    // MARK: - NSCoding
    required init?(coder: NSCoder) {
        super.init()
        // 解码属性请在子类实现
    }

    func encode(with coder: NSCoder) {
        // 编码属性请在子类实现
    }

    // MARK: - MJExtension 对应方法
    class func mj_replacedKeyFromPropertyName() -> [String: Any] {
        return [:]
    }

    // MARK: - YYModel 对应方法
    class func modelCustomPropertyMapper() -> [String: Any] {
        return [:]
    }
}


class UIViewModel: BaseModel, UIViewModelProtocol, AppToolsProtocol {
    // 实现内容可在此补充
}
