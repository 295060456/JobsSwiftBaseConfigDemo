//
//  PicLoadDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

import UIKit
import SnapKit

#if canImport(Kingfisher)
import Kingfisher
#endif

#if canImport(SDWebImage)
import SDWebImage
#endif

final class PicLoadDemoVC: BaseVC {
    private lazy var scrollView: UIScrollView = {
        UIScrollView()
            .byShowsIndicators(vertical: true, horizontal: false)
            .byAlwaysBounceVertical(true)
            .byContentInset(.init(top: 0, left: 0, bottom: 24, right: 0))
            .byContentInsetAdjustmentBehavior(.never)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10) // 占满
                make.left.right.bottom.equalTo(view) // 占满
            }
    }()
    // MARK: - UIImageView
    /// UIImageView@字符串本地图
    private lazy var localImgView: UIImageView = {
        UIImageView()
            .byImage("Ani".img)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(10.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
    }()
    /// UIImageView字符串网络图@Kingfisher
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
                print("✅ 加载成功 (KF async)")
            } catch {
                print("❌ 加载失败 (KF async)：\(error)")
            }
        }
        return imageView
    }()
    /// UIImageView字符串网络图@SDWebImage
    private lazy var asyncImgViewSD: UIImageView = {
        let imageView = UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(asyncImgView.snp.bottom).offset(20)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
        Task {
            do {
                imageView.byImage(try await "https://picsum.photos/400/300".sdLoadImage())
                print("✅ 加载成功 (SD async)")
            } catch {
                print("❌ 加载失败 (SD async)：\(error)")
            }
        }
        return imageView
    }()
    /// UIImageView网络图（失败兜底图）@Kingfisher
    private lazy var wrapperImgView: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .kf_setImage(from: "https://picsum.photos/200", placeholder: "Ani".img)
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(asyncImgViewSD.snp.bottom).offset(20)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
    }()
    /// UIImageView网络图（失败兜底图）@SDWebImage
    private lazy var wrapperImgViewSD: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .sd_setImage(from: "https://picsum.photos/200", placeholder: "Ani".img)
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(wrapperImgView.snp.bottom).offset(20)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(180)
            }
    }()
    // MARK: - UIButton
    /// 按钮网络背景图@SDWebImage
    private lazy var btnBG: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byClipsToBounds(true)
            .byTitle("我是主标题@SDWebImage")
            .bySubTitle("我是副标题@SDWebImage")
            .sd_imageURL("https://picsum.photos/3000/2000")
            .sd_placeholderImage(nil)
            .sd_options([.scaleDownLargeImages, .retryFailed])
            .sd_bgNormalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(wrapperImgViewSD.snp.bottom).offset(24)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(64)
            }
    }()
    /// 按钮网络前景图@SDWebImage
    private lazy var btnImage: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byBorderWidth(1)
            .byBorderColor(UIColor.systemGray3)
            .byClipsToBounds(true)
            .byTitle("我是主标题@SDWebImage")
            .bySubTitle("我是副标题@SDWebImage")
            .sd_imageURL("https://picsum.photos/200")
            .sd_placeholderImage(nil)
            .sd_options([.retryFailed, .highPriority, .scaleDownLargeImages])
            .sd_normalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnBG.snp.bottom).offset(16)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.greaterThanOrEqualTo(56)
            }
    }()
    /// 按钮网络背景图@Kingfisher
    private lazy var btnBG_KF: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byClipsToBounds(true)
            .byTitle("我是主标题@Kingfisher")
            .bySubTitle("我是副标题@Kingfisher")
            .kf_imageURL("https://picsum.photos/300/200")
            .kf_placeholderImage(nil)
            .kf_options([
                .processor(DownsamplingImageProcessor(size: CGSize(width: 500, height: 200))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.25)),
                .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
            ])
            .kf_bgNormalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnImage.snp.bottom).offset(24)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(64)
            }
    }()
    /// 按钮网络前景图@Kingfisher
    private lazy var btnImage_KF: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byBorderWidth(1)
            .byBorderColor(UIColor.systemGray3)
            .byClipsToBounds(true)
            .byTitle("我是主标题@Kingfisher")
            .bySubTitle("我是副标题@Kingfisher")
            .kf_imageURL("https://picsum.photos/200")
            .kf_placeholderImage(nil)
            .kf_options([
                .processor(DownsamplingImageProcessor(size: CGSize(width: 64, height: 64))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.25)),
                .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
            ])
            .kf_normalLoad() // 之前是配置项，这里才是真正决定渲染背景图/前景图
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnBG_KF.snp.bottom).offset(16)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20)
                make.height.equalTo(64)
            }
    }()
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "图片加载 UIImageView/UIButton")

        scrollView.byAlpha(1)

        localImgView.byAlpha(1)      // UIImageView@字符串本地图
        asyncImgView.byAlpha(1)      // UIImageView字符串网络图@Kingfisher
        asyncImgViewSD.byAlpha(1)    // UIImageView字符串网络图@SDWebImage
        wrapperImgView.byAlpha(1)    // UIImageView网络图（失败兜底图）@Kingfisher
        wrapperImgViewSD.byAlpha(1)  // UIImageView网络图（失败兜底图）@SDWebImage

        btnBG.byAlpha(1)             // 按钮网络背景图@SDWebImage
        btnImage.byAlpha(1)          // 按钮网络前景图@SDWebImage
        btnBG_KF.byAlpha(1)          // 按钮网络背景图@Kingfisher
        btnImage_KF.byAlpha(1)       // 按钮网络前景图@Kingfisher
        // 结束滚动内容
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.bottom.equalTo(btnImage_KF.snp.bottom).offset(24)
        }
    }
}
