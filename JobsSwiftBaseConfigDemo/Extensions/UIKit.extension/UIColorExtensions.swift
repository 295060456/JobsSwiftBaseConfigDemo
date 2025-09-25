//
//  UIColorExtensions.swift
//  PlayYes
//
//  Created by yihui on 2023/6/22.
//  扩展UIColor

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension UIColor {
    /// init method with RGB values from 0 to 255, instead of 0 to 1. With alpha(default:1)
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    /// init method with RGB values from 0 to 255, instead of 0 to 1. With alpha(default:1)
    public convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }

    /// init method with hex string and alpha(default: 1)
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
          let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
          let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
          let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
          self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }

    /// init method from Gray value and alpha(default:1)
    public convenience init(gray: CGFloat, alpha: CGFloat = 1) {
        self.init(red: gray/255, green: gray/255, blue: gray/255, alpha: alpha)
    }

    /// Red component of UIColor (get-only)
    public var redComponent: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }

    /// Green component of UIColor (get-only)
    public var greenComponent: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }

    /// blue component of UIColor (get-only)
    public var blueComponent: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }

    /// Alpha of UIColor (get-only)
    public var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
//    func withAlpha(_ alpha: CGFloat) -> UIColor {
//        return UIColor(red: self.cgColor.components!.first!,
//                       green: self.cgColor.components!.last!,
//                       blue: (self.cgColor.components!.count > 2 ? self.cgColor.components![2] : 0),
//                       alpha: alpha)
//    }
    /// Returns random UIColor with random alpha(default: false)
//    public static func random(randomAlpha: Bool = false) -> UIColor {
//        let randomRed = CGFloat.random()
//        let randomGreen = CGFloat.random()
//        let randomBlue = CGFloat.random()
//        let alpha = randomAlpha ? CGFloat.random() : 1.0
//        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
//    }

    /// 生成随机颜色
    static var random: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

