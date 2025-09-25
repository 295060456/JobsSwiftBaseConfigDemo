//
//  NSString.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//
import UIKit
// MARK: - 辅助
open extension CATextLayerAlignmentMode {
    static func fromNSTextAlignment(_ a: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch a {
        case .left: return .left
        case .right: return .right
        case .center: return .center
        case .justified: return .justified
        case .natural: return .natural
        @unknown default: return .natural
        }
    }
}
