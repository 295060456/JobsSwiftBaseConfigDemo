//
//  TipsGrantPermissionView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/14/25.
//

import UIKit
import SnapKit

final class TipsGrantPermissionView: UIView {
    /// 白色卡片
    private lazy var cardView: UIView = {
        UIView()
            .byBgColor(.white)
            .byLayer { layer in
                layer.byCornerRadius(14)
                    .byMasksToBounds(NO) // 有阴影就不要 masksToBounds = true，不然阴影会被裁掉
                    .byShadowColor(.black.withAlphaComponent(0.15))
                    .byShadowOffset(CGSize(width: 0, height: 4))
                    .byShadowRadius(12)
                    .byShadowOpacity(1)
            }
            .byAddTo(self) { make in
                make.edges.equalToSuperview()
            }
    }()
    /// 标题：温馨提示
    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("温馨提示")
            .byTextColor(.label)
            .byFont(.systemFont(ofSize: 17, weight: .semibold))
            .byTextAlignment(.center)
            .byAddTo(cardView) { make in
                make.top.equalToSuperview().inset(18)
                make.left.right.equalToSuperview().inset(20)
            }
    }()
    /// 主文案
    private lazy var messageLabel: UILabel = {
        UILabel()
            .byText("开启照片、视频权限，如果不允许\n您将无法选择相册里的照片进行上传")
            .byTextColor(.label)
            .byFont(.systemFont(ofSize: 14))
            .byNumberOfLines(0)
            .byTextAlignment(.center)
            .byAddTo(cardView) { [unowned self] make in
                make.top.equalTo(titleLabel.snp.bottom).offset(14)
                make.left.right.equalToSuperview().inset(20)
            }
    }()
    /// 灰色小字
    private lazy var hintLabel: UILabel = {
        UILabel()
            .byText("设置-隐私安全-照片和视频")
            .byTextColor(.secondaryLabel)
            .byFont(.systemFont(ofSize: 12))
            .byNumberOfLines(0)
            .byTextAlignment(.center)
            .byAddTo(cardView) { [unowned self] make in
                make.top.equalTo(messageLabel.snp.bottom).offset(14)
                make.left.right.equalToSuperview().inset(20)
            }
    }()
    /// 底部绿色按钮：去开启
    private lazy var confirmButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.init(r: 0/255, g: 199/255, b: 140/25, a: 1))
            .byTitle("去开启", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.removeFromSuperview()
                self.confirmHandler?()
            }
            .byAddTo(cardView) { [unowned self] make in
                make.top.equalTo(hintLabel.snp.bottom).offset(14)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(40)
                make.bottom.equalToSuperview().inset(16)
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

    private func setupUI() {
        // 半透明黑色遮罩（按需打开）
        // byBgColor(.black.withAlphaComponent(0.35))

        // 触发懒加载，顺带确保整个层级建好
        cardView.byVisible(YES)
        confirmButton.byVisible(YES)
        // 标题下方分割线
        cardView.makeBelowSeparatorBy(below: titleLabel, offset: 12)
    }
}
