//
//  QRCodeDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/18/25.
//

import UIKit
import SnapKit

final class QRCodeDemoVC: BaseVC {
    // 编码的内容（可自行替换）
    private let qrContent  = "https://jobs.dev/hello"
    private let barContent = "JOBS-2025-10-18"

    private lazy var imageViewQR: UIImageView = {
        UIImageView()
//            .byImage(qrContent.qrcodeImage(260))/* 由当前字符串生成二维码 UIImage（无插值放大，清晰）*/
            .byImage(
                "https://www.google.com".qrcodeImage(
                    260,
                    correction: "H",
                    centerLogo: "Ani".img,
                    logoRatio: 0.22,
                    logoCornerRadius: 10,
                    borderWidth: 6,
                    borderColor: .white
                )
            )/* 生成带中心 Logo 的二维码 */
            .byContentMode(.scaleAspectFit)
            .byClipsToBounds(true)
            .byBgColor(UIColor.secondarySystemBackground)
            .byCornerRadius(12)
            .byAddTo(view) { [unowned self] make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-90) // 上移一点给条码留位置
                make.width.height.equalTo(260) // 正方形
            }
    }()

    private lazy var imageViewBar: UIImageView = {
        UIImageView()
//            .byImage(barContent.code128BarcodeImage(size: CGSize(width: 260, height: 100)))
            .byImage(barContent.code128ByText(width: 260, barHeight: 100))
            .byContentMode(.scaleAspectFit)
            .byClipsToBounds(true)
            .byBgColor(.clear)
            .byCornerRadius(8)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(imageViewQR.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalTo(260)
                make.height.equalTo(100)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "二维码 + 条形码")
        view.byBgColor(.systemBackground)
        // 触发懒加载与展示
        imageViewQR.byAlpha(1)
        imageViewBar.byAlpha(1)
    }
}
