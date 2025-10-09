//
//  PicLoadDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

import UIKit
import SnapKit
import Kingfisher
import SDWebImage   // 用到 UIButton 的 SDWebImage 扩展

final class PicLoadDemoVC: BaseVC {
    // MARK: - ScrollView（懒加载 + 点语法）
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
            .byShowsIndicators(vertical: true, horizontal: false)
            .byAlwaysBounceVertical(true)
            .byContentInset(.init(top: 0, left: 0, bottom: 24, right: 0))
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10) // 占满
                make.left.right.bottom.equalTo(view) // 占满
            }
        // iOS 11+：别自动调整 inset（按你项目风格自行取舍）
        if #available(iOS 11.0, *) {
            _ = sv.byContentInsetAdjustmentBehavior(.never)
        }
        return sv
    }()
    // MARK: - 顶部本地图片
    private lazy var localImgView: UIImageView = {
        UIImageView()
            .byImage("Ani".img)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .byAddTo(scrollView) { [unowned self] make in
                // 垂直锚到 contentLayoutGuide
                make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(10.h)
                // 水平锚到 frameLayoutGuide，保证宽度跟随可视宽度
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
    }()
    // MARK: - async/await 网络图
    private lazy var asyncImgView: UIImageView = {
        let imageView = UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(localImgView.snp.bottom).offset(20)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
        Task {
            do {
                imageView.byImage(try await "https://picsum.photos/200/300".kfLoadImage())
                print("✅ 加载成功 (async)")
            } catch {
                print("❌ 加载失败 (async)：\(error)")
            }
        }
        return imageView
    }()
    // MARK: - 包装封装的 setImage(from:)
    private lazy var wrapperImgView: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .setImage(from: "https://picsum.photos/200", placeholder: "Ani".img)
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(asyncImgView.snp.bottom).offset(20)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
    }()
    // MARK: - 按钮（懒加载 + 直接触发加载）
    /// 背景图按钮：背景图（bgNormalLoad）
    private lazy var btnBG: UIButton = {
        let b = UIButton(type: .system)
            .byCornerRadius(12)
            .byClipsToBounds(true)
            .imageURL("https://picsum.photos/300/200")
            .placeholderImage(nil)
            .options([.scaleDownLargeImages, .retryFailed])
            .bgNormalLoad()
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(wrapperImgView.snp.bottom).offset(24)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(64)
            }
        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("背景图：Base64 / URL")
                    .byBaseForegroundCor(.white)
                    .byContentInsets(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .byCornerStyle(.large)
                    .byImagePlacement(.trailing)
                    .byImagePadding(8)
            }
        } else {
            b.byTitle("背景图：Base64 / URL", for: .normal)
                .byTitleColor(.white, for: .normal)
                .byContentEdgeInsets(.init(top: 16, left: 16, bottom: 16, right: 16))
                .byBgColor(.systemBlue)
        }
        return b
    }()
    /// 前景图按钮：按钮自身 image（normalLoad）
    private lazy var btnImage: UIButton = {
        let b = UIButton(type: .system)
            .byCornerRadius(12)
            .byBorderWidth(1)
            .byBorderColor(UIColor.systemGray3)
            .byClipsToBounds(true)
            .imageURL("https://i.pinimg.com/736x/26/5b/ef/265bef0c9ee367b30847a85ba0075f14.jpg")
            .placeholderImage(nil)
            .options([.retryFailed, .highPriority, .scaleDownLargeImages])
            .normalLoad()
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnBG.snp.bottom).offset(16)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.greaterThanOrEqualTo(56)
            }
            .byAlpha(1)

        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("前景图：Button Image")
                    .byBaseForegroundCor(.label)
                    .byContentInsets(.init(top: 14, leading: 16, bottom: 14, trailing: 16))
                    .byCornerStyle(.large)
                    .byImagePlacement(.leading)
                    .byImagePadding(10)
            }
        } else {
            b.byTitle("前景图：Button Image", for: .normal)
                .byTitleColor(.label, for: .normal)
                .byContentEdgeInsets(.init(top: 14, left: 16, bottom: 14, right: 16))
        }
        return b
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "PicLoad Demo")

        scrollView.byAlpha(1)
        localImgView.byAlpha(1)         // UIImageView@本地图片
        asyncImgView.byAlpha(1)         // UIImageView@Kingfisher 网络图 kfLoadImage
        wrapperImgView.byAlpha(1)       // UIImageView@Kingfisher 网络图 setImage(from:placeholder:fade:)
        btnBG.byAlpha(1)                // UIButton@SDWebImage 背景图
        btnImage.byAlpha(1)             // UIButton@SDWebImage 前景图

        // 结束滚动内容：把最后一个控件的 bottom 贴到 contentLayoutGuide.bottom
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.bottom.equalTo(btnImage.snp.bottom).offset(24)
        }
    }
}
