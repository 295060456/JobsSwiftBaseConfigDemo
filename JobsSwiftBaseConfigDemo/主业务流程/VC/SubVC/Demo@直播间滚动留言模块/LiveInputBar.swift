//
//  LiveInputBar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/11/25.
//
import UIKit
import SnapKit
// ============================== InputBar（inputAccessoryView） ==============================
final class LiveInputBar: UIView {
    lazy var tf: UITextField = {
        UITextField()
            .byBorderStyle(.roundedRect)
            .byPlaceholder("说点什么…")
            .byReturnKeyType(.send)
            .byAddTo(self) { make in
                make.leading.equalToSuperview().offset(12)
                make.centerY.equalToSuperview()
                make.height.equalTo(36)
            }
    }()
    lazy var sendBtn: UIButton = {
        UIButton.sys()
            .byTitle("发送", for: .normal)
            .byTitleFont(.boldSystemFont(ofSize: 16))
            .byAddTo(self) { [unowned self] make in
                make.leading.equalTo(tf.snp.trailing).offset(8)
                make.trailing.equalToSuperview().inset(12)
                make.centerY.equalToSuperview()
                make.width.greaterThanOrEqualTo(56)
            }
    }()
    private lazy var topLine: UIView = {
        UIView()
            .byBgColor(.separator)
            .byAddTo(self) { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5)
            }
    }()

    override var intrinsicContentSize: CGSize { .init(width: UIView.noIntrinsicMetric, height: 52) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        byBgColor(.systemBackground)
        topLine.byVisible(YES)
        tf.byVisible(YES)
        sendBtn.byVisible(YES)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
