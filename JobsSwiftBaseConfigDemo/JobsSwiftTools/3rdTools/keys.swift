//
//  keys.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/30/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public enum AppKeys {
    /// 网易易盾KEY（原：#ifndef 网易易盾KEY / #define 网易易盾KEY @""）
    public static let neteaseYidunKey: String = ""
    /// 极验验证码KEY（原：极验验证码KEY）
    public static let geetestKey: String = "4e91ed65a8ff92414edec055461845d4"
    /// LiveChatKEY（原：LiveChatKEY）
    public static let liveChatKey: String = "18866559"
    /// PicSalt（原：PicSalt）
    public static let picSalt: String = "RRU4JZTV5WZXPCVZ"
}
