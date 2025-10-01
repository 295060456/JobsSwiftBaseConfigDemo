//
//  UIButtonDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/09/29.
//

import UIKit
import SnapKit

final class UIButtonDemoVC: UIViewController {

    // 用垂直栈统一承载所有演示按钮，便于扩展/复制
    private let stack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 12
        $0.distribution = .equalSpacing
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "UIButton 语法糖 Demo"

        setupLayout()
        buildDemos()
    }

    private func setupLayout() {
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    // MARK: - 构建所有示例（每个按钮都是局部变量，注释写清用途）
    private func buildDemos() {

        // 1) 基础链式：标题 / 颜色 / 字体 / 图片 / 背景图
        do {
            let btnBasic = UIButton(type: .system)
                .byTitle("1) 基础链式：Title / Color / Font / Image / BG")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemBlue)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { _ in print("基础链式 tapped") }

            // SF Symbol 示例（iOS 13+ 可按需设置符号大小）
            if #available(iOS 13.0, *) {
                let img = UIImage(systemName: "bolt.fill")
                _ = btnBasic.byImage(img, for: .normal)
                    .byTintColor(.white)
                    .for(.normal).preferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
            }

            stack.addArrangedSubview(btnBasic)
        }

        // 2) 按 state 的链式代理：for(.highlighted).title(...) / 背景色
        do {
            let btnState = UIButton(type: .system)
                .byTitle("2) StateProxy：Normal / Highlighted", for: .normal)
                .byTitleColor(.white, for: .normal)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemIndigo, for: .normal)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { _ in print("StateProxy tapped") }

            // 使用 StateProxy 配置 highlighted 的样式
            btnState
                .for(.highlighted).title("2) Highlighted 标题")
                .for(.highlighted).titleColor(.yellow)
                .for(.highlighted).backgroundColor(.systemPurple)

            stack.addArrangedSubview(btnState)
        }

        // 3) 背景色兜底：iOS15+ 走 configuration；其它/非 normal state 用 1×1 背景图
        do {
            let btnBG = UIButton(type: .system)
                .byTitle("3) 背景色兜底（Normal / Disabled）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemTeal, for: .normal)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { btn in
                    // 点击切换 enable，观察 .disabled 状态样式
                    btn.isEnabled.toggle()
                }

            // 非 normal 的 state 一律调用兜底方法
            btnBG.for(.disabled).backgroundColor(.systemGray)

            stack.addArrangedSubview(btnBG)
        }

        // 4) 内容内边距：byContentInsets / byContentEdgeInsets（兼容 iOS15-）
        do {
            let btnInsets = UIButton(type: .system)
                .byTitle("4) ContentInsets / EdgeInsets（左右 24）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemGreen)

            // iOS 15+ 优先 directionalInsets；否则回落到 UIEdgeInsets
            _ = btnInsets.byContentInsets(NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))

            stack.addArrangedSubview(btnInsets)
        }

        // 5) 图片与标题的相对位置：byImagePlacement(.leading/.trailing/.top/.bottom) + padding
        do {
            let btnPlacement = UIButton(type: .system)
                .byTitle("5) imagePlacement = .trailing, padding=8")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemOrange)
                .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))

            if #available(iOS 13.0, *) {
                _ = btnPlacement.byImage(UIImage(systemName: "arrow.right.circle.fill"), for: .normal)
                    .byTintColor(.white)
            }
            _ = btnPlacement.byImagePlacement(.trailing, padding: 8)

            stack.addArrangedSubview(btnPlacement)
        }

        // 6) 副标题（iOS15+）：bySubtitle；低版本退化为主标题换行
        do {
            let btnSubtitle = UIButton(type: .system)
                .byTitle("6) 主标题")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
                .byBackgroundColor(.systemPink)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .bySubtitle("副标题：iOS15+ 走 configuration.subtitle", color: .white, font: .systemFont(ofSize: 12))

            stack.addArrangedSubview(btnSubtitle)
        }

        // 7) 菜单（iOS14+）：byMenu + byShowsMenuAsPrimaryAction
        do {
            let btnMenu = UIButton(type: .system)
                .byTitle("7) 菜单作为主动作（点我弹出）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemBrown)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))

            if #available(iOS 14.0, *) {
                let items: [UIAction] = [
                    UIAction(title: "复制", image: UIImage(systemName: "doc.on.doc")) { _ in print("复制") },
                    UIAction(title: "分享", image: UIImage(systemName: "square.and.arrow.up")) { _ in print("分享") },
                    UIAction(title: "删除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in print("删除") }
                ]
                let menu = UIMenu(title: "操作", children: items)
                _ = btnMenu.byMenu(menu).byShowsMenuAsPrimaryAction(true)
            }

            stack.addArrangedSubview(btnMenu)
        }

        // 8) 指针交互（iOS13.4+）：byPointerInteractionEnabled
        do {
            let btnPointer = UIButton(type: .system)
                .byTitle("8) Pointer Interaction（iPad/悬停设备）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemCyan)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { _ in print("Pointer tapped") }

            if #available(iOS 13.4, *) {
                _ = btnPointer.byPointerInteractionEnabled(true)
            }

            stack.addArrangedSubview(btnPointer)
        }

        // 9) Role（iOS14+）：.destructive 等；演示 destructive 风格
        do {
            let btnRole = UIButton(type: .system)
                .byTitle("9) Role = .destructive（删除）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
                .byBackgroundColor(.systemRed)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { _ in print("Destructive tapped") }

            if #available(iOS 14.0, *) {
                _ = btnRole.byRole(.destructive)
            }

            stack.addArrangedSubview(btnRole)
        }

        // 10) 主动作切换 selected（iOS15+）：byChangesSelectionAsPrimaryAction
        do {
            let btnToggle = UIButton(type: .system)
                .byTitle("10) 点击切换 selected", for: .normal)
                .byTitleColor(.white, for: .normal)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemMint, for: .normal)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .for(.selected).title("10) ✅ 已选择")
                .for(.selected).backgroundColor(.systemGreen)

            if #available(iOS 15.0, *) {
                _ = btnToggle.byChangesSelectionAsPrimaryAction(true)
            } else {
                // 低版本手动切换
                _ = btnToggle.onTap { b in b.isSelected.toggle() }
            }

            stack.addArrangedSubview(btnToggle)
        }

        // 11) Configuration Update（iOS15+）：根据 state 动态更新样式
        do {
            let btnUpdate = UIButton(type: .system)
                .byTitle("11) configurationUpdateHandler：高亮时降透明")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemBlue)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))

            if #available(iOS 15.0, *) {
                _ = btnUpdate
                    .byAutomaticallyUpdatesConfiguration(true)
                    .byConfigurationUpdateHandler { btn in
                        let cfg = btn.configuration ?? .plain()
                        // 根据 state 动态变更（这里只是演示调 alpha）
                        btn.alpha = btn.isHighlighted ? 0.6 : 1.0
                        btn.configuration = cfg
                    }
            }

            stack.addArrangedSubview(btnUpdate)
        }

        // 12) 旋转动画：startRotating / stopRotating + 防连点
        do {
            let btnRotate = UIButton(type: .system)
                .byTitle("12) 旋转动画（点击切换）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemPurple)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { [weak self] b in
                    guard self != nil else { return }
                    // 防止频繁点击抖动
                    b.disableAfterClick(interval: 0.25)

                    if b.isRotating() {
                        _ = b.stopRotating(resetTransformOnStop: true)
                        print("停止旋转")
                    } else {
                        _ = b.startRotating(duration: 0.9, scope: .imageView, clockwise: true)
                        print("开始旋转")
                    }
                }

            if #available(iOS 13.0, *) {
                _ = btnRotate.byImage(UIImage(systemName: "arrow.2.circlepath.circle.fill"), for: .normal)
                    .byTintColor(.white)
            }

            stack.addArrangedSubview(btnRotate)
        }

        // 13) 长按事件：onLongPress(minimumPressDuration:)
        do {
            let btnLong = UIButton(type: .system)
                .byTitle("13) 长按 0.8s 触发（含手势对象回调）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemGray)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                    if gr.state == .began {
                        print("长按开始 on \(btn)")
                        btn.alpha = 0.7
                    } else if gr.state == .ended || gr.state == .cancelled {
                        btn.alpha = 1.0
                        print("长按结束")
                    }
                }

            stack.addArrangedSubview(btnLong)
        }

        // 14) UIAction（iOS14+）与低版本闭包回退：onTap 已封装优先 UIAction
        do {
            let btnAction = UIButton(type: .system)
                .byTitle("14) onTap：iOS14+走UIAction，低版本走 addAction 兜底")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemBlue)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
                .onTap { _ in
                    print("onTap 统一入口（内部已区分 iOS14+ / 低版本）")
                }

            stack.addArrangedSubview(btnAction)
        }

        // 15) iOS13+ 的 per-state Symbol 配置（preferredSymbolConfiguration）
        do {
            let btnSymbol = UIButton(type: .system)
                .byTitle("15) per-state Symbol 配置（Normal/Highlighted）")
                .byTitleColor(.white)
                .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
                .byBackgroundColor(.systemOrange)
                .byContentEdgeInsets(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))

            if #available(iOS 13.0, *) {
                _ = btnSymbol.byImage(UIImage(systemName: "star.fill"), for: .normal)
                    .byTintColor(.white)
                    .for(.normal).preferredSymbolConfiguration(.init(pointSize: 16, weight: .regular))
                    .for(.highlighted).preferredSymbolConfiguration(.init(pointSize: 20, weight: .bold))
            }
            stack.addArrangedSubview(btnSymbol)
        }
    }
}

