//
//  TraitChangeDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 10/16/25.
//

import UIKit
import SnapKit
import QuartzCore
// MARK: - Demo VC（iOS 17+ 使用 UITraitChangeObservable + 内置调试按钮）
final class TraitChangeDemoVC: BaseVC {
    // MARK: UI（全部懒加载，byAddTo + SnapKit）
    private lazy var titleLabel : UILabel = {
        UILabel().byText("UITraitChangeObservable · Demo")
            .byFont(.boldSystemFont(ofSize: 18))
            .byTextAlignment(.natural)              // ✅ 新增
            .byTextColor(.label)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(16)
            }
    }()

    private lazy var infoLabel :UILabel = {
        UILabel()
            .byNumberOfLines(0)
            .byTextColor(.secondaryLabel)
            .byFont(.systemFont(ofSize: 13))
            .byTextAlignment(.natural)              // ✅ 新增
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
                make.leading.trailing.equalToSuperview().inset(16)
            }
    }()

    private lazy var swatch : UIView = {
        UIView()
            .byCornerRadius(12)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.infoLabel.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(120)
            }
    }()
    /// 演示“不会自动随外观变化”的资源：Layer 需要手动刷新 CGColor
    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint   = CGPoint(x: 1, y: 0.5)
        return g
    }()
    /// 尺寸类切换时改变轴向
    private lazy var stack : UIStackView = {
        UIStackView()
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.swatch.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
            }
    }()

    private lazy var leftBox : UIView = {
        UIView()
            .byCornerRadius(10)
            .byAddTo(stack) { _ in }
    }()

    private lazy var rightBox : UIView = {
        UIView()
            .byCornerRadius(10)
            .byAddTo(stack) { _ in }
    }()

    private lazy var dynamicText :UILabel = {
        UILabel()
            .byText("Dynamic Type 预览")
            .byTextColor(.label)
            .byTextAlignment(.natural)              // ✅ 新增
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.stack.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16)
            }
    }()
    // MARK: - 调试状态
    private var forceDark = false
    private var forceRTL  = false
    // MARK: - Tokens（可选：若需要在对象存活时手动停止监听）
    @available(iOS 17.0, *)
    private var traitTokens: [UITraitChangeRegistration] = []

    @available(iOS 17.0, *)
    @discardableResult
    private func store(_ reg: UITraitChangeRegistration) -> UITraitChangeRegistration {
        traitTokens.append(reg)
        return reg
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "Traits (iOS 17+)",
            rightButtons: [
                UIButton(type: .system)
                    /// 按钮图片@图文关系
                    .byImage("moon.circle.fill".sysImg, for: .normal)
                    .byImage("moon.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        self.forceDark.toggle()
                        // 触发外观相关 trait 变化 —— 注意前缀 self.
                        self.overrideUserInterfaceStyle = self.forceDark ? .dark : .unspecified
                        // 保底刷新（即使 trait 回调还没到）
                        self.updateColors()
                    }
            ]
        )
        // 组装 UI
        swatch.layer.addSublayer(gradientLayer)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        leftBox.snp.makeConstraints { make in make.height.equalTo(80) }
        rightBox.snp.makeConstraints { make in make.height.equalTo(80) }
        // 初次同步
        configureForCurrentTraits()
        // iOS 17+：注册式监听（按需精确注册，避免全量刷新）
        if #available(iOS 17.0, *) {
            store(registerForTraitChanges([UITraitUserInterfaceStyle.self, UITraitUserInterfaceLevel.self]) { (self: Self, _) in
                self.updateColors()
            })
            store(registerForTraitChanges([UITraitHorizontalSizeClass.self, UITraitVerticalSizeClass.self]) { (self: Self, _) in
                self.reflowForSizeClass()
            })
            store(registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _) in
                self.applyDynamicType()
            })
            store(registerForTraitChanges([UITraitLayoutDirection.self]) { (self: Self, _) in
                self.updateForLayoutDirection()
            })
            // 可选：如果有位图/缩放缓存
            store(registerForTraitChanges([UITraitDisplayScale.self, UITraitDisplayGamut.self]) { (self: Self, _) in
                self.rerenderRasterizedStuff()
            })
        }

        // 唤起（显式渲染）—— Jobs 链式 DSL 约定
        titleLabel.byAlpha(1)
        infoLabel.byAlpha(1)
        swatch.byAlpha(1)
        leftBox.byAlpha(1)
        rightBox.byAlpha(1)
        dynamicText.byAlpha(1)
        stack.byAlpha(1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .dark
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = swatch.bounds // 旋转/分屏后需更新
    }

    // MARK: - 初始与按模块更新
    private func configureForCurrentTraits() {
        updateColors()
        reflowForSizeClass()
        applyDynamicType()
        updateForLayoutDirection()
        rerenderRasterizedStuff()
    }

    private func updateColors() {
        let style = traitCollection.userInterfaceStyle
        view.backgroundColor = (style == .dark) ? .secondarySystemBackground : .systemBackground

        // 手动刷新不会自动变化的 CGColor（Layer）
        let c1: UIColor
        let c2: UIColor
        if style == .dark {
            c1 = UIColor(white: 1, alpha: 0.12)
            c2 = UIColor(white: 1, alpha: 0.28)
            leftBox.backgroundColor  = .tertiarySystemFill
            rightBox.backgroundColor = .quaternarySystemFill
        } else {
            c1 = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
            c2 = UIColor(red: 0.85, green: 0.90, blue: 1.0, alpha: 1.0)
            leftBox.backgroundColor  = .systemFill
            rightBox.backgroundColor = .secondarySystemFill
        }
        gradientLayer.colors = [c1.cgColor, c2.cgColor]

        infoLabel.byText("""
        Style: \(style == .dark ? "Dark" : "Light")
        Scale: \(Int(traitCollection.displayScale))x
        Gamut: \(gamutString(traitCollection.displayGamut))
        """)
    }

    private func reflowForSizeClass() {
        let h = traitCollection.horizontalSizeClass
        stack.axis = (h == .compact) ? .vertical : .horizontal
    }

    private func applyDynamicType() {
        titleLabel
            .byFont(.preferredFont(forTextStyle: .title2))
            .byAdjustsFontForContentSizeCategory(true)

        infoLabel
            .byFont(.preferredFont(forTextStyle: .footnote))
            .byAdjustsFontForContentSizeCategory(true)

        dynamicText
            .byFont(.preferredFont(forTextStyle: .body))
            .byAdjustsFontForContentSizeCategory(true)
    }

    private func updateForLayoutDirection() {
        let attr: UISemanticContentAttribute = forceRTL ? .forceRightToLeft : .unspecified
        // 根视图 & 关键容器
        view.semanticContentAttribute  = attr
        stack.semanticContentAttribute = attr
        swatch.semanticContentAttribute = attr
        // 如需更明显效果，强制让 stack 在演示时用横向（见下面注释）
        // stack.axis = .horizontal
    }

    private func rerenderRasterizedStuff() {
        // 若你有按 scale/gamut 缓存的位图资源，这里重建
        // 示例：按当前 traits 取图（如果 Asset 配置了外观/Size Class 变体）
        // imageView.image = UIImage(named: "card_bg", in: nil, compatibleWith: traitCollection)
    }

    // MARK: - Helpers
    private func gamutString(_ g: UIDisplayGamut) -> String {
        switch g {
        case .P3:   return "P3"
        case .SRGB: return "sRGB"
        default:    return "Unspecified"
        }
    }
}
