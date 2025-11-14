//
//  PhotoPermissionAlertView.swift
//  JobsSwiftBaseConfigDemo
//
// 「要允许“AC”访问此设备的照片和视频吗？」弹框 View

import UIKit
import SnapKit

final class PhotoPermissionAlertView: UIView {
    // MARK: - Callbacks Storage
    private var limitedHandler: (() -> Void)?
    private var fullHandler: (() -> Void)?
    private var denyHandler: (() -> Void)?

    // MARK: - 链式配置回调（点语法）
    @discardableResult
    func onLimited(_ handler: @escaping () -> Void) -> Self {
        limitedHandler = handler
        return self
    }

    @discardableResult
    func onFull(_ handler: @escaping () -> Void) -> Self {
        fullHandler = handler
        return self
    }

    @discardableResult
    func onDeny(_ handler: @escaping () -> Void) -> Self {
        denyHandler = handler
        return self
    }
    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("要允许“AC”访问此设备的照片和视频吗?")
            .byTextColor(.init(r: 0.039, g: 0.063, b: 0.059))
            .byFont(.init(regular: 16)!)
            .byNumberOfLines(0)
            .byTextAlignment(.center)
            .byAddTo(self) { make in
                make.top.equalToSuperview()
                make.height.equalTo(60.h)
                make.left.right.equalToSuperview().inset(16)
            }
    }()

    private lazy var buttonsStack: UIStackView = {
        UIStackView()
            .byAxis(.vertical)
            .byAlignment(.fill)
            .byDistribution(.fillEqually)   // 改成等分
            .bySpacing(0)
            .addArrangedSubviews(limitedButton)
            .addArrangedSubviews(fullButton)
            .addArrangedSubviews(denyButton)
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(self.titleLabel.snp.bottom)
                make.height.equalTo(156)
                make.left.right.bottom.equalToSuperview()
            }
    }()

    private lazy var limitedButton: UIButton = {
        makeActionButton("允许有限访问")
            .byNormalBgColor(.white)
            .onTap { [weak self] _ in
                self?.limitedHandler?()
            }
    }()

    private lazy var fullButton: UIButton = {
        makeActionButton("全部允许")
            .byNormalBgColor(.white)
            .onTap { [weak self] _ in
                self?.fullHandler?()
            }
    }()

    private lazy var denyButton: UIButton = {
        makeActionButton("不允许")
            .byNormalBgColor(.white)
            .onTap { [weak self] _ in
                self?.denyHandler?()
            }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
// MARK: - Private
private extension PhotoPermissionAlertView {
    func setupUI() {
        byBgColor(.systemBackground)
            .byCornerRadius(12)
            .byClipsToBounds(true)

        titleLabel.byVisible(YES)
        makeSeparator(below: titleLabel).byVisible(YES)
        buttonsStack.byVisible(YES)
    }

    func makeActionButton(_ title: String) -> UIButton {
        UIButton.sys()
            .byTitle(title, for: .normal)
            .byTitleColor("#2CB4EF".cor, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16))
            .byBackgroundColor(.clear, for: .normal)
            .byContentEdgeInsets(.init(top: 11, left: 0, bottom: 11, right: 0))
    }
}
