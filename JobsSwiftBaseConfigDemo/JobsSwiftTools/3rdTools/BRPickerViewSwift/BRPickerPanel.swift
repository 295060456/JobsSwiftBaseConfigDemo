//
//  BRPickerPanel.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

public final class BRPickerPanel: UIView {

    public var style: BRPickerStyle
    public var onConfirm: (jobsByVoidBlock)?
    public var onCancel: (jobsByVoidBlock)?

    public let contentContainer = UIView()

    // ⚠️ 避免覆盖 UIView.maskView
    private let dimmingControl = UIControl()
    private let toolbar = UIView()
    private let titleLabel = UILabel()
    private let cancelBtn = UIButton(type: .system)
    private let doneBtn = UIButton(type: .system)
    private var bottomConstraint: Constraint?
    private weak var hostView: UIView?

    public init(style: BRPickerStyle) {
        self.style = style
        super.init(frame: .zero)
        isOpaque = false
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        // mask
        addSubview(dimmingControl)
        dimmingControl.backgroundColor = UIColor.black.withAlphaComponent(style.maskAlpha)
        dimmingControl.addTarget(self, action: #selector(maskTapped), for: .touchUpInside)
        dimmingControl.snp.makeConstraints { $0.edges.equalToSuperview() }

        // toolbar（圆角容器）
        toolbar.backgroundColor = style.toolbarBackgroundColor
        toolbar.layer.cornerRadius = style.cornerRadius
        toolbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        toolbar.clipsToBounds = true
        addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            bottomConstraint = make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(320).constraint
        }

        let topBar = UIView()
        topBar.backgroundColor = style.toolbarBackgroundColor
        titleLabel.text = style.title
        titleLabel.textAlignment = .center
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor

        cancelBtn.setTitle(style.cancelText, for: .normal)
        cancelBtn.titleLabel?.font = style.cancelFont
        cancelBtn.setTitleColor(style.cancelColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        doneBtn.setTitle(style.doneText, for: .normal)
        doneBtn.titleLabel?.font = style.doneFont
        doneBtn.setTitleColor(style.doneColor, for: .normal)
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        toolbar.addSubview(topBar)
        toolbar.addSubview(contentContainer)
        topBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        contentContainer.backgroundColor = style.pickerBackgroundColor
        contentContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
        }

        topBar.addSubview(titleLabel)
        topBar.addSubview(cancelBtn)
        topBar.addSubview(doneBtn)

        cancelBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        doneBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    @objc private func maskTapped() { if style.allowTouchToDismiss { dismiss(); onCancel?() } }
    @objc private func cancelTapped() { dismiss(); onCancel?() }
    @objc private func doneTapped() { dismiss(); onConfirm?() }

    public func present(in container: UIView? = nil) {
        guard let host = container ?? UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first else { return }
        hostView = host

        host.addSubview(self)
        self.snp.makeConstraints { $0.edges.equalToSuperview() }
        host.layoutIfNeeded()
        bottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.hostView?.layoutIfNeeded()
        }
    }

    public func dismiss() {
        bottomConstraint?.update(offset: 320)
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.dimmingControl.alpha = 0
            self?.hostView?.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
        })
    }
}
