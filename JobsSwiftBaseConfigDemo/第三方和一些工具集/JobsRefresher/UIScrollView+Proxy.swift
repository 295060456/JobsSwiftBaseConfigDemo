//
//  UIScrollView+Proxy.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit
import ObjectiveC

@MainActor
private struct MRKAssocKeys {
    // 用地址作为唯一键，避免 String 桥接 & 提高唯一性
    static var proxy: UInt8 = 0
}

@MainActor
extension UIScrollView {
    var mrk_proxy: MRKProxy {
        if let p = objc_getAssociatedObject(self, &MRKAssocKeys.proxy) as? MRKProxy {
            return p
        }
        let p = MRKProxy(scrollView: self)
        objc_setAssociatedObject(self, &MRKAssocKeys.proxy, p, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return p
    }
}
