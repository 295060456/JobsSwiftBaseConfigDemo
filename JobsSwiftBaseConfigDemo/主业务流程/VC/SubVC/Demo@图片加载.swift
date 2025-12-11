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
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10.h) // 占满
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
            .onTap { iv in
                "单击图片：\(iv)".toast
             }
            .onLongPress(minDuration: 0.8, movement: 12, touches: 1, name: "customLongPress") { iv, gr in
                switch gr.state {
                case .began:
                    "长按开始 on \(iv)".toast
                case .ended, .cancelled, .failed:
                    "长按结束 on \(iv)".toast
                default:
                    break
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(10.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(180.h)
            }
    }()
    /// UIImageView字符串网络图@Kingfisher
    private lazy var asyncImgView: UIImageView = {
        UIImageView()
            .byAsyncImageKF("https://picsum.photos/200/300", fallback: "唐老鸭".img)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .onTap { iv in
                "单击图片：\(iv)".toast
             }
            .onLongPress(minDuration: 0.8, movement: 12, touches: 1, name: "customLongPress") { iv, gr in
                switch gr.state {
                case .began:
                    "长按开始 on \(iv)".toast
                case .ended, .cancelled, .failed:
                    "长按结束 on \(iv)".toast
                default:
                    break
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(localImgView.snp.bottom).offset(20.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(180.h)
            }
    }()
    /// UIImageView字符串网络图@SDWebImage
    private lazy var asyncImgViewSD: UIImageView = {
        UIImageView()
            .byAsyncImageSD("https://picsum.photos/400/300", fallback: "唐老鸭".img)
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .onTap { iv in
                "单击图片：\(iv)".toast
             }
            .onLongPress(minDuration: 0.8, movement: 12, touches: 1, name: "customLongPress") { iv, gr in
                switch gr.state {
                case .began:
                    "长按开始 on \(iv)".toast
                case .ended, .cancelled, .failed:
                    "长按结束 on \(iv)".toast
                default:
                    break
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(asyncImgView.snp.bottom).offset(20.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(180.h)
            }
    }()
    /// UIImageView网络图（失败兜底图）@Kingfisher
    private lazy var wrapperImgView: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .kf_setImage(from: "https://picsum.photos/200", placeholder: "Ani".img)
            .onTap { iv in
                "单击图片：\(iv)".toast
             }
            .onLongPress(minDuration: 0.8, movement: 12, touches: 1, name: "customLongPress") { iv, gr in
                switch gr.state {
                case .began:
                    "长按开始 on \(iv)".toast
                case .ended, .cancelled, .failed:
                    "长按结束 on \(iv)".toast
                default:
                    break
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(asyncImgViewSD.snp.bottom).offset(20.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(180.h)
            }
    }()
    /// UIImageView网络图（失败兜底图）@SDWebImage
    private lazy var wrapperImgViewSD: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .sd_setImage(from: "https://picsum.photos/200", placeholder: "Ani".img)
            .onTap { iv in
                "单击图片：\(iv)".toast
             }
            .onLongPress(minDuration: 0.8, movement: 12, touches: 1, name: "customLongPress") { iv, gr in
                switch gr.state {
                case .began:
                    "长按开始 on \(iv)".toast
                case .ended, .cancelled, .failed:
                    "长按结束 on \(iv)".toast
                default:
                    break
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(wrapperImgView.snp.bottom).offset(20.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(180.h)
            }
    }()
    // MARK: - UIButton
    /// UIButton网络背景图@SDWebImage
    private lazy var btnBG: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byClipsToBounds(true)
            .byTitle("我是UIButton主标题@SDWebImage")
            .bySubTitle("我是UIButton副标题@SDWebImage")
            .sd_imageURL("https://picsum.photos/3000/2000")
            .sd_placeholderImage(nil)
            .sd_options([.scaleDownLargeImages, .retryFailed])
            .sd_bgNormalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            .onTap { sender in
                print("🔴 Kingfisher@背景图 2 tapped, selected=\(sender.isSelected)")
                "点击了UIButton网络背景图@SDWebImage".toast
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                    print("长按开始 on \(btn)")
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                    print("长按结束")
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(wrapperImgViewSD.snp.bottom).offset(24.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(64.h)
            }
    }()
    /// UIButton网络前景图@SDWebImage
    private lazy var btnImage: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byBorderWidth(1)
            .byBorderColor(UIColor.systemGray3)
            .byClipsToBounds(true)
            .byTitle("我是UIButton主标题@SDWebImage")
            .bySubTitle("我是UIButton副标题@SDWebImage")
            .sd_imageURL("https://picsum.photos/200")
            .sd_placeholderImage(nil)
            .sd_options([.retryFailed, .highPriority, .scaleDownLargeImages])
            .sd_normalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            .onTap { sender in
                print("🔴 Kingfisher@背景图 2 tapped, selected=\(sender.isSelected)")
                "UIButton网络前景图@SDWebImage".toast
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                    print("长按开始 on \(btn)")
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                    print("长按结束")
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnBG.snp.bottom).offset(16.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.greaterThanOrEqualTo(56.h)
            }
    }()
    /// UIButton网络背景图@Kingfisher
    private lazy var btnBG_KF: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byClipsToBounds(true)
            .byTitle("我是UIButton主标题@Kingfisher").byTitleColor(.red)
            .bySubTitle("我是UIButton副标题@Kingfisher").bySubTitleColor(.yellow)
            .kf_imageURL("https://picsum.photos/300/200")
            .kf_placeholderImage("唐老鸭".img)
            .kf_options([
                .processor(DownsamplingImageProcessor(size: CGSize(width: 500, height: 200))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.25)),
                .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
            ])
            .kf_bgNormalLoad()// 之前是配置项，这里才是真正决定渲染背景图/前景图
            .onTap { sender in
                print("🔴 Kingfisher@背景图 2 tapped, selected=\(sender.isSelected)")
                "UIButton网络背景图@Kingfisher".toast
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                    print("长按开始 on \(btn)")
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                    print("长按结束")
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnImage.snp.bottom).offset(24.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(64.h)
            }
    }()
    /// UIButton网络前景图@Kingfisher
    private lazy var btnImage_KF: UIButton = {
        UIButton(type: .system)
            .byCornerRadius(12)
            .byBorderWidth(1)
            .byBorderColor(UIColor.systemGray3)
            .byClipsToBounds(true)
            .byTitle("我是UIButton主标题@Kingfisher")
            .bySubTitle("我是UIButton副标题@Kingfisher")
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
            .onTap { sender in
                print("🔴 Kingfisher@背景图 2 tapped, selected=\(sender.isSelected)")
                "UIButton网络前景图@Kingfisher".toast
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                    print("长按开始 on \(btn)")
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                    print("长按结束")
                }
            }
            .byAddTo(scrollView) { [unowned self] make in
                make.top.equalTo(btnBG_KF.snp.bottom).offset(16.h)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left).offset(20.w)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right).inset(20.w)
                make.height.equalTo(64.h)
            }
    }()
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "图片加载 UIImageView/UIButton")

        scrollView.byVisible(YES)

        localImgView.byVisible(YES)     // UIImageView@字符串本地图
        asyncImgView.byVisible(YES)     // UIImageView字符串网络图@Kingfisher
        asyncImgViewSD.byVisible(YES)   // UIImageView字符串网络图@SDWebImage
        wrapperImgView.byVisible(YES)   // UIImageView网络图（失败兜底图）@Kingfisher
        wrapperImgViewSD.byVisible(YES) // UIImageView网络图（失败兜底图）@SDWebImage

        btnBG.byVisible(YES)            // UIButton网络背景图@SDWebImage
        btnImage.byVisible(YES)         // UIButton网络前景图@SDWebImage
        btnBG_KF.byVisible(YES)         // UIButton网络背景图@Kingfisher
        btnImage_KF.byVisible(YES)      // UIButton网络前景图@Kingfisher
        // 结束滚动内容
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.bottom.equalTo(btnImage_KF.snp.bottom).offset(24)
        }
    }
}
