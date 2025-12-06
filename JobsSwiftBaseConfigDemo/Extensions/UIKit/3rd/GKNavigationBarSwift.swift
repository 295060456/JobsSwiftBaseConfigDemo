//
//  GKNavigationBarSwift.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import Foundation
#if os(OSX)
    import AppKit
#endif
#if os(iOS) || os(tvOS)
    import UIKit
#endif

#if canImport(SDWebImage)
import GKNavigationBarSwift
public extension GKNavigationBarConfigure {
    // MARK: - 顶层 DSL 入口（全局一次性配置 & 后续增量更新）
    /// 外部入口：应用启动时调用一次
    /// 用法：GKConfigure.setupDefault()
    @discardableResult
    static func bySetupDefault() -> GKNavigationBarConfigure {
        let cfg = GKNavigationBarConfigure.shared
        // 这里直接调用你已“DSL 化”的实例方法，避免在外部重复写默认值
        cfg.setupDefault()
        return cfg
    }
    /// App 启动时一次性全局配置（内部会先 reset 到 setupDefault）
    /// 用法：
    /// GKNavigationBarConfigure.setup { cfg in
    ///     cfg.byBackground(color: .white)
    ///        .byTitle(color: .black, font: .boldSystemFont(ofSize: 17))
    ///        .byBack(style: .black)
    ///        .byFixSpace(left: 0, right: 0)
    ///        .byCommit()
    /// }
    @discardableResult
    static func setup(_ block: (GKNavigationBarConfigure) -> Void) -> GKNavigationBarConfigure {
        let cfg = GKNavigationBarConfigure.shared
        cfg.setupCustom { _ in } // reset 到默认并做一次内部 mirror
        block(cfg)
        // 这里不强制 commit，交由调用方决定；如需立即 mirror，可链式 .byCommit()
        return cfg
    }
    /// 运行期热更新（不会 reset 到默认）
    /// 用法：
    /// GKNavigationBarConfigure.update { $0.byStatusBar(style: .lightContent).byCommit() }
    @discardableResult
    static func update(_ block: (GKNavigationBarConfigure) -> Void) -> GKNavigationBarConfigure {
        let cfg = GKNavigationBarConfigure.shared
        cfg.update { _ in } // 走一遍原生 update 回调（保持行为一致）
        block(cfg)
        return cfg
    }
    // MARK: - 通用链式辅助
    /// 简单闭包链式语法糖
    @discardableResult
    func dsl(_ block: (GKNavigationBarConfigure) -> Void) -> Self {
        block(self); return self
    }
    /// 调用原生 awake（只做一次“唤醒”）
    @discardableResult
    func byAwake() -> Self { self.awake(); return self }
    /// mirror 一次“外部配置”到“内部参数”
    /// 等价于原类 `setupCustom` 结尾那段：
    ///     disableFixSpace = gk_disableFixSpace
    ///     navItemLeftSpace = gk_navItemLeftSpace
    ///     navItemRightSpace = gk_navItemRightSpace
    @discardableResult
    func byCommit() -> Self {
        self.disableFixSpace  = self.gk_disableFixSpace
        self.navItemLeftSpace = self.gk_navItemLeftSpace
        self.navItemRightSpace = self.gk_navItemRightSpace
        return self
    }
    // MARK: - 背景 / 分割线
    @discardableResult
    func byBackground(_ color: UIColor?) -> Self {
        self.backgroundColor = color; return self
    }
    /// 同时设置浅色/深色模式的背景图（可选）
    @discardableResult
    func byBackground(image: UIImage?, dark: UIImage? = nil) -> Self {
        self.backgroundImage = image
        self.darkBackgroundImage = dark
        return self
    }

    @discardableResult
    func byLine(color: UIColor?) -> Self {
        self.lineColor = color; return self
    }
    /// 组合设置分割线：图片优先于颜色；可附带隐藏开关
    @discardableResult
    func byLine(image: UIImage?, dark: UIImage? = nil, color: UIColor? = nil, hidden: Bool? = nil) -> Self {
        self.lineImage = image
        self.darkLineImage = dark
        if let color { self.lineColor = color }
        if let hidden { self.lineHidden = hidden }
        return self
    }

    @discardableResult
    func byLineHidden(_ hidden: Bool) -> Self {
        self.lineHidden = hidden; return self
    }
    // MARK: - 标题
    @discardableResult
    func byTitleCor(_ color: UIColor?) -> Self {
        self.titleColor = color; return self
    }

    @discardableResult
    func byTitleFont(_ font: UIFont?) -> Self {
        self.titleFont = font; return self
    }
    /// 一次性设置标题颜色 + 字体
    @discardableResult
    func byTitle(color: UIColor?, font: UIFont?) -> Self {
        self.titleColor = color
        self.titleFont = font
        return self
    }
    // MARK: - 返回按钮
    @discardableResult
    func byBack(image: UIImage?) -> Self {
        self.backImage = image; return self
    }

    @discardableResult
    func byBack(darkImage: UIImage?) -> Self {
        self.darkBackImage = darkImage; return self
    }

    @discardableResult
    func byBack(blackImage: UIImage?, whiteImage: UIImage?) -> Self {
        self.blackBackImage = blackImage
        self.whiteBackImage = whiteImage
        return self
    }

    @discardableResult
    func byBack(style: GKNavigationBarBackStyle) -> Self {
        self.backStyle = style; return self
    }
    /// 组合式：一次性把所有 Back 相关塞进去（什么有就配什么）
    @discardableResult
    func byBack(image: UIImage? = nil,
                dark: UIImage? = nil,
                black: UIImage? = nil,
                white: UIImage? = nil,
                style: GKNavigationBarBackStyle? = nil) -> Self {
        if let image { self.backImage = image }
        if let dark { self.darkBackImage = dark }
        if let black { self.blackBackImage = black }
        if let white { self.whiteBackImage = white }
        if let style { self.backStyle = style }
        return self
    }
    // MARK: - Item 间距修复
    /// 开关 + 左右间距（外部配置位）
    @discardableResult
    func byFixSpace(disable: Bool? = nil,
                    openSystemFixSpace: Bool? = nil,
                    left: CGFloat? = nil,
                    right: CGFloat? = nil) -> Self {
        if let disable { self.gk_disableFixSpace = disable }
        if let openSystemFixSpace { self.gk_openSystemFixSpace = openSystemFixSpace }
        if let left { self.gk_navItemLeftSpace = left }
        if let right { self.gk_navItemRightSpace = right }
        return self
    }
    /// 仅设置左右间距（外部配置位）
    @discardableResult
    func byNavItemSpacing(left: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let left { self.gk_navItemLeftSpace = left }
        if let right { self.gk_navItemRightSpace = right }
        return self
    }
    // MARK: - 状态栏
    @discardableResult
    func byStatusBar(hidden: Bool) -> Self {
        self.statusBarHidden = hidden; return self
    }

    @discardableResult
    func byStatusBar(style: UIStatusBarStyle) -> Self {
        self.statusBarStyle = style; return self
    }
    // MARK: - 还原系统导航栏 / TabBar 行为
    @discardableResult
    func byRestoreSystemNavBar(_ restore: Bool) -> Self {
        self.gk_restoreSystemNavBar = restore; return self
    }

    @discardableResult
    func byHidesBottomBarWhenPushed(_ hide: Bool) -> Self {
        self.gk_hidesBottomBarWhenPushed = hide; return self
    }
    // MARK: - 手势相关
    /// 设置需要屏蔽手势的 VC 列表（支持 UIViewController / String）
    @discardableResult
    func byShieldGestureVCs(_ v: [Any]?) -> Self {
        self.shiledGuestureVCs = v; return self
    }
    /// 全局开启 UIScrollView 手势处理
    @discardableResult
    func byOpenScrollViewGestureHandle(_ on: Bool) -> Self {
        self.gk_openScrollViewGestureHandle = on; return self
    }
    // MARK: - 交互参数（滑动临界、缩放、灵敏度）
    /// 快速滑动灵敏度（0~1，越大越“敏”）
    @discardableResult
    func bySnapSensitivity(_ val: CGFloat) -> Self {
        self.gk_snapMovementSensitivity = val; return self
    }
    /// push / pop 过渡临界值
    @discardableResult
    func byTransitionCritical(push: CGFloat? = nil, pop: CGFloat? = nil) -> Self {
        if let push { self.gk_pushTransitionCriticalValue = push }
        if let pop { self.gk_popTransitionCriticalValue = pop }
        return self
    }
    /// x/y 轴缩放（转场时）
    @discardableResult
    func byScale(x: CGFloat? = nil, y: CGFloat? = nil) -> Self {
        if let x { self.gk_scaleX = x }
        if let y { self.gk_scaleY = y }
        return self
    }
    // MARK: - 便捷组合（背景 + 标题 + 返回）
    /// 一把梭：背景（图/色）、标题（色/字重）、返回（图/样式）
    @discardableResult
    func byPreset(backgroundColor: UIColor? = nil,
                  backgroundImage: UIImage? = nil,
                  darkBackgroundImage: UIImage? = nil,
                  titleColor: UIColor? = nil,
                  titleFont: UIFont? = nil,
                  backStyle: GKNavigationBarBackStyle? = nil) -> Self {
        if let backgroundColor { self.backgroundColor = backgroundColor }
        if let backgroundImage { self.backgroundImage = backgroundImage }
        if let darkBackgroundImage { self.darkBackgroundImage = darkBackgroundImage }
        if let titleColor { self.titleColor = titleColor }
        if let titleFont { self.titleFont = titleFont }
        if let backStyle { self.backStyle = backStyle }
        return self
    }
}
#endif


