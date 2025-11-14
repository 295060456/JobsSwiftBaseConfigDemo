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
                    // 有阴影就不要 masksToBounds = true，不然阴影会被裁掉
                    .byMasksToBounds(NO)
                    .byShadowCor(color: .black.withAlphaComponent(0.15))
                    .byShadowOffset(offset: CGSize(width: 0, height: 4))
                    .byShadowRadius(radius: 12)
                    .byShadowOpacity(opacity: 1)
            }
            .byAddTo(self) { make in               // ✅ 加到 self 上
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
    }()
    /// 主文案
    private lazy var messageLabel: UILabel = {
        UILabel()
            .byText("开启照片、视频权限，如果不允许\n您将无法选择相册里的照片进行上传")
            .byTextColor(.label)
            .byFont(.systemFont(ofSize: 14))
            .byNumberOfLines(0)
            .byTextAlignment(.center)
    }()
    /// 灰色小字
    private lazy var hintLabel: UILabel = {
        UILabel()
            .byText("设置-隐私安全-照片和视频")
            .byTextColor(.secondaryLabel)
            .byFont(.systemFont(ofSize: 12))
            .byNumberOfLines(0)
            .byTextAlignment(.center)
    }()
    /// 底部绿色按钮：去开启
    private lazy var confirmButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(
                UIColor(
                    red: 0/255,
                    green: 199/255,
                    blue: 140/255,
                    alpha: 1
                )
            )
            .byTitle("去开启", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.removeFromSuperview()
                self.confirmHandler?()
            }
            .byAddTo(cardView) { make in           // ✅ 加到 cardView 里
                make.height.equalTo(40)
            }
    }()

    private lazy var stack: UIStackView = {
        UIStackView(arrangedSubviews: [
            titleLabel,
            messageLabel,
            hintLabel,
            confirmButton
        ])
            .byAxis(.vertical)
            .bySpacing(14)
            .byAlignment(.fill)
            .byDistribution(.fill)
            .byAddTo(cardView) { make in              // ✅ 约束写在 cardView 里
                 make.edges.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 20, bottom: 16, right: 20))
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
        // 半透明黑色遮罩
//        byBgColor(.black.withAlphaComponent(0.35))
        // 触发 lazy 创建
        cardView.byVisible(YES)
        stack.byVisible(YES)
        cardView.makeSeparator(below: titleLabel, offset: 12)
    }
}

