//
//  JXScale.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/22/25.
//

import UIKit

// MARK: - 核心比例器
public enum JXScale {
    private static var designW: CGFloat = 375
    private static var designH: CGFloat = 812
    private static var useSafeArea: Bool = false
    
    public static func setup(designWidth: CGFloat, designHeight: CGFloat, useSafeArea: Bool = false) {
        self.designW = designWidth
        self.designH = designHeight
        self.useSafeArea = useSafeArea
    }
    
    private static var screenSize: CGSize {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return UIScreen.main.bounds.size
        }
        if useSafeArea {
            let insets = window.safeAreaInsets
            return CGSize(
                width: max(0, window.bounds.width - (insets.left + insets.right)),
                height: max(0, window.bounds.height - (insets.top + insets.bottom))
            )
        } else {
            return window.bounds.size
        }
    }
    
    public static var x: CGFloat { screenSize.width / designW }
    public static var y: CGFloat { screenSize.height / designH }
}

// MARK: - 扩展 Int / CGFloat
public extension BinaryInteger {
    var w: CGFloat { CGFloat(self) * JXScale.x }
    var h: CGFloat { CGFloat(self) * JXScale.y }
    var fz: CGFloat { CGFloat(self) * JXScale.x }   // 字体缩放，默认跟随 X
}

public extension BinaryFloatingPoint {
    var w: CGFloat { CGFloat(self) * JXScale.x }
    var h: CGFloat { CGFloat(self) * JXScale.y }
    var fz: CGFloat { CGFloat(self) * JXScale.x }
}

