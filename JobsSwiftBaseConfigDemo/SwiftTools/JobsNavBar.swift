//
//  JobsNavBar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/20/25.
//

import UIKit
import SnapKit
import WebKit

public class JobsNavBar: UIView {
    // MARK: - Style
    public struct Style {
        public var usesSafeAreaTopInset: Bool = true
        public var contentHeight: CGFloat = 44
        public var backgroundColor: UIColor = .secondarySystemBackground
        public var hairlineColor: UIColor = UIColor.separator.withAlphaComponent(0.6)
        public var hairlineHidden: Bool = false
        public var titleAlignmentCenter: Bool = true
        public init() {}
    }
    // MARK: - Public API
    public typealias TitleProvider = () -> NSAttributedString?    // 返回 nil 隐藏
    public typealias BackButtonProvider = () -> UIButton?         // 返回 nil 隐藏
    public typealias BackHandler = () -> Void                     // 未配置 -> Debug Toast
    public typealias BackButtonLayout = (JobsNavBar, UIButton, ConstraintMaker) -> Void
    /// 外部可自定义返回键布局
    public var backButtonLayout: BackButtonLayout? {
        didSet {
            // 回调变更时，仅重排约束（不再重复 addSubview）
            if oldValue == nil, backButtonLayout == nil { return }
            rebuildBackButton()
        }
    }

    @MainActor
    public func showLoadingTitle(_ text: String = "加载中…") {
        // 给 titleProvider 一个默认实现；外部/后续 bind 会覆盖它
        self.titleProvider = { Self._jobsMakeTitleAttr(text) }
        refreshTitle()
    }

    public var style: Style {
        didSet {
            applyStyle()
            _leftContainerH?.update(offset: style.contentHeight) // 同步高度
            relayoutTitleConstraints()
            invalidateIntrinsicContentSize()
            rebuildBackButton()                                  // contentHeight 变更会影响按钮高度上限
        }
    }

    public var backButtonProvider: BackButtonProvider? {
        didSet {
            rebuildBackButton() // provider 变化 -> 可能换按钮；交给 rebuild 处理
        }
    }

    public var titleProvider: TitleProvider? {
        didSet { refreshTitle() }
    }

    public var onBack: BackHandler?

    // ===== 懒加载子视图（外部可直接链式修改，比如 navBar.hairline.byVisible(true））=====
    public private(set) lazy var backgroundView: UIView = {
        UIView()
            .byAddTo(self) { make in
                make.edges.equalToSuperview()
            }
    }()

    public private(set) lazy var hairline: UIView = {
        UIView()
            .byVisible(!style.hairlineHidden)
            .byBgColor(style.hairlineColor)
            .byAddTo(self) { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
    }()

    public private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .byNumberOfLines(1)
            .byTextAlignment(.center)
            .byAddTo(self) { [unowned self] _ in
                /// 具体约束在 relayoutTitleConstraints() 里统一处理
            }
    }()
    private var _leftContainerH: Constraint?
    public private(set) lazy var leftContainer: UIView = {
        UIView().byAddTo(self) { [unowned self] make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview() // 贴底
            _leftContainerH = make.height.equalTo(self.style.contentHeight).constraint // 固定“内容区”高
            make.width.greaterThanOrEqualTo(36)
        }
    }()

    public private(set) var leftButton: UIButton?
    // ===== 内部状态 =====
    private var kvoTitle: NSKeyValueObservation?
    /// 返回按钮约束是否已安装（用于首装 vs 变更时的 make/remake 切换）
    private var _backConstraintsInstalled = false
    // MARK: - Init
    public init(style: Style = .init()) {
        self.style = style
        super.init(frame: .zero)
        // 懒加载：这里只触发样式应用，不强制创建所有子视图
        applyStyle()
        relayoutTitleConstraints()
        if self.titleProvider == nil {
            showLoadingTitle()
        }
    }

    public required init?(coder: NSCoder) {
        self.style = .init()
        super.init(coder: coder)
        applyStyle()
        relayoutTitleConstraints()
        if self.titleProvider == nil {
            showLoadingTitle()
        }
    }

    deinit { kvoTitle?.invalidate() }
    // MARK: - Public helpers
    /// 主动刷新全部
    @MainActor
    public func jobsNavBarRefresh() {
        _ = backgroundView; _ = hairline; _ = titleLabel; _ = leftContainer
        rebuildBackButton()
        refreshTitle()
        setNeedsLayout()
    }
    /// 绑定 WebView 标题（你也可以自定义 titleProvider 覆盖）
    // 小工具：统一标题样式
    private static func _jobsMakeTitleAttr(_ text: String) -> NSAttributedString {
        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
    }
    public static var loadingTitle: String = "加载中..."
    @MainActor
    public func bind(
        webView: WKWebView,
        defaultTitle: String? = nil,
        preferHostWhenEmpty: Bool = true
    ) {
        let fallback = defaultTitle ?? Self.loadingTitle
        self.titleProvider = { [weak webView] in
            guard let wv = webView else {
                return Self._jobsMakeTitleAttr(fallback)
            }
            // 1) 页面标题
            if let t = wv.title?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty {
                return Self._jobsMakeTitleAttr(t)
            }
            // 2) 域名回退
            if preferHostWhenEmpty, let host = wv.url?.host, !host.isEmpty {
                return Self._jobsMakeTitleAttr(host)
            }
            // 3) 默认占位
            return Self._jobsMakeTitleAttr(fallback)
        }

        kvoTitle?.invalidate()
        kvoTitle = webView.observe(\.title, options: [.new]) { [weak self] _, _ in
            Task { @MainActor in self?.refreshTitle() }
        }
        refreshTitle()
    }
    // MARK: - Private
    @MainActor
    private func applyStyle() {
        // 访问懒属性以确保存在，然后再设值
        backgroundView.byBgColor(style.backgroundColor)
        hairline
            .byBgColor(style.hairlineColor)
            .byVisible(!style.hairlineHidden)
    }

    @MainActor
//    private func refreshTitle() {
//        titleLabel.byAttributedString(Self._jobsMakeTitleAttr(Self.loadingTitle))
//    }

    private func refreshTitle() {
        if let attr = titleProvider?() {
            titleLabel.byAttributedString(attr).byVisible(true)
        } else {
            titleLabel.byAttributedString(nil).byVisible(false)
        }
    }

    // ④ 标题改为参照 leftContainer 的“内容区”对齐（避免对整个 NavBar 对齐）
    @MainActor
    private func relayoutTitleConstraints() {
        titleLabel.snp.remakeConstraints { make in
            if style.titleAlignmentCenter {
                make.center.equalToSuperview()
                make.left.greaterThanOrEqualTo(leftContainer.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().inset(12)
            } else {
                make.left.equalTo(leftContainer.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().inset(12)
            }
        }
    }
    /// 只走一次 addSubview；其后仅改约束（首装 make / 变更 remake）
    @MainActor
    private func rebuildBackButton() {
        _ = leftContainer
        // 1) 拿到 provider 结果；nil = 隐藏并清理
        guard let providedBtn = backButtonProvider?() else {
            leftContainer.byVisible(false)
            leftButton?.removeFromSuperview()
            leftButton = nil
            return
        }
        leftContainer.byVisible(true)
        // 2) 如按钮实例变了 -> 替换并清安装标记（只在此处 addSubview，一次性）
        if leftButton !== providedBtn {
            leftButton?.removeFromSuperview()
            leftButton = providedBtn
            leftContainer.addSubview(providedBtn)
            // 基础属性（不涉及布局）
            providedBtn.contentVerticalAlignment = .center
            providedBtn.setContentHuggingPriority(.required, for: .vertical)
            providedBtn.setContentCompressionResistancePriority(.required, for: .vertical)
            // 事件（避免重复加 target：先移除旧引用已 removeFromSuperview，这里安全）
            providedBtn.onTap { [weak self] _ in self?.backTapped() }
        }
        guard let btn = leftButton else { return }
        // 3) 安装/更新约束：首次 make，之后 remake（不再使用 byAddTo，避免重复 add）
        let install: (_ make: ConstraintMaker) -> Void = { [unowned self] make in
            if let L = self.backButtonLayout {
                L(self, btn, make)
            } else {
                make.left.equalToSuperview().inset(0)
                make.top.equalToSuperview().inset(6)
                make.height.greaterThanOrEqualTo(36)
                make.height.lessThanOrEqualTo(self.style.contentHeight)
                make.right.lessThanOrEqualToSuperview().inset(8)
            }
        }

        if _backConstraintsInstalled {
            btn.snp.remakeConstraints(install)
        } else {
            btn.snp.makeConstraints(install)
            _backConstraintsInstalled = true
        }
    }

    @MainActor
    private func backTapped() {
        if let onBack {
            onBack()
        } else {
            debugOnly {  // 仅 Debug 执行
                JobsToast.show(
                    text: "Hello",
                    config: JobsToast.Config()
                        .byBgColor(.systemGreen.withAlphaComponent(0.9))
                        .byCornerRadius(12)
                )
            }
        }
    }
    // MARK: - Layout / Safe Area
    public override var intrinsicContentSize: CGSize {
        let top = style.usesSafeAreaTopInset ? safeAreaInsets.top : 0
        return .init(width: UIView.noIntrinsicMetric, height: top + style.contentHeight)
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        if style.usesSafeAreaTopInset { invalidateIntrinsicContentSize() }
    }
}
@MainActor
public extension JobsNavBar.Style {
    /// 是否占用宿主的 safeArea 顶部内边距
    @discardableResult
    func byUsesSafeAreaTopInset(_ on: Bool = true) -> Self {
        var c = self; c.usesSafeAreaTopInset = on; return c
    }
    /// 内容区高度（不含安全区）
    @discardableResult
    func byContentHeight(_ height: CGFloat) -> Self {
        var c = self; c.contentHeight = height; return c
    }
    /// 背景色
    @discardableResult
    func byBackgroundColor(_ color: UIColor) -> Self {
        var c = self; c.backgroundColor = color; return c
    }
    /// 发丝线颜色
    @discardableResult
    func byHairlineColor(_ color: UIColor) -> Self {
        var c = self; c.hairlineColor = color; return c
    }
    /// 是否隐藏发丝线
    @discardableResult
    func byHairlineHidden(_ hidden: Bool = true) -> Self {
        var c = self; c.hairlineHidden = hidden; return c
    }
    /// 标题是否居中
    @discardableResult
    func byTitleAlignmentCenter(_ centered: Bool = true) -> Self {
        var c = self; c.titleAlignmentCenter = centered; return c
    }
}
