//
//  ConfirmToastView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

// ============================== 自定义“需确认”中心 Toast 视图 ==============================
final class ConfirmToastView: UIView {

    private lazy var titleLabel: UILabel = {
        UILabel()
            .byText("需要确认")
            .byFont(.boldSystemFont(ofSize: 18))
            .byTextColor(.label)
            .byTextAlignment(.center)
            .byAddTo(self) { make in
                make.top.equalToSuperview().inset(16)
                make.left.right.equalToSuperview().inset(16)
            }
    }()

    private lazy var descLabel: UILabel = {
        UILabel()
            .byText("这是一个中心弹出的自定义 View。只有点击下方“我知道了”后才会关闭。")
            .byFont(.systemFont(ofSize: 14))
            .byTextColor(.secondaryLabel)
            .byNumberOfLines(0)
            .byTextAlignment(.center)
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(16)
            }
    }()

    private lazy var confirmBtn: UIButton = {
        UIButton.sys()
            .byTitle("我知道了")
            .onTap { [weak self] (_: UIButton) in
                self?.confirmHandler?()   // ✅ 仅按钮触发关闭
            }
            .byAddTo(self) { [unowned self] make in
                make.top.equalTo(descLabel.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(40)
                make.bottom.equalToSuperview().inset(16)
            }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // 外观统一交给 EKAttributes（背景/圆角/阴影）
        titleLabel.byVisible(YES)
        descLabel.byVisible(YES)
        confirmBtn.byVisible(YES)
    }
    required init?(coder: NSCoder) { fatalError() }
}
