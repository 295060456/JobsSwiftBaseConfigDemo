//
//  UIScrollView+Proxy.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit
import ObjectiveC

@MainActor
private struct JobsAssocKeys {
    // 用地址作为唯一键，避免 String 桥接 & 提高唯一性
    static var proxy: UInt8 = 0
}

@MainActor
extension UIScrollView {
    var mrk_proxy: JobsProxy {
        if let p = objc_getAssociatedObject(self, &JobsAssocKeys.proxy) as? JobsProxy {
            return p
        }
        let p = JobsProxy(scrollView: self)
        objc_setAssociatedObject(self, &JobsAssocKeys.proxy, p, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return p
    }
}
