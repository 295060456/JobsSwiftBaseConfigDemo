//
//  BaseWebVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//

import UIKit
import SnapKit
import WebKit
/**
     BaseWebVC()
         .byData("https://www.baidu.com")
         .onResult { id in
             print("回来了 id=\(id)")
         }
         .byPush(self)           // 自带防重入，连点不重复
         .byCompletion{
             print("❤️结束❤️")
         }
 */
final class BaseWebVC: BaseVC {
    // MARK: - 懒加载 Web（全通用，无业务常量）
    private lazy var web: BaseWebView = { [unowned self] in
        return BaseWebView()
            .byBgColor(.clear)
            .byAllowedHosts([])                  // 不限域
            .byOpenBlankInPlace(true)
            .byDisableSelectionAndCallout(false)
            .byUserAgentSuffixProvider { _ in
                // 按请求动态追加 UA 后缀；nil = 使用系统默认 UA。
                // 需要区分页面时在此 return "YourApp/1.0"
                return nil
            }
//            .byNormalizeMToWWW(false)               // ❗️关闭 m→www
//            .byForceHTTPSUpgrade(false)             // ❗️关闭 http→https
//            .bySafariFallbackOnHTTP(false)          // ❗️关闭 Safari 兜底
//            .byInjectRedirectSanitizerJS(false)     // 可关，避免干涉 H5 自己跳转
            /// URL 重写策略（默认不重写；这里保持关闭）
            .byURLRewriter { _ in
                // 例如要做 http→https 升级：检测 url.scheme == "http" 再返回新 URL
                // 现在返回 nil 表示不改写
                return nil
            }
            /// Safari 兜底（默认不开）；返回 true 即交给 Safari 打开
            .bySafariFallbackRule { _ in
                return false
            }
            /// 一键开导航栏（默认标题=webView.title，默认有返回键）
            .byNavBarEnabled(true)
            .byNavBarStyle { s in
                s.byHairlineHidden(false)
                 .byBackgroundColor(.systemBackground)
                 .byTitleAlignmentCenter(true)
            }
            /// 自定义返回键（想隐藏就：.byNavBarBackButtonProvider { nil }）
            .byNavBarBackButtonProvider {
                UIButton(type: .system)
                    .byBackgroundColor(.clear)
                    .byImage("chevron.left".sysImg, for: .normal)
                    .byTitle("返回", for: .normal)
                    .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
                    .byTitleColor(.label, for: .normal)
                    .byContentEdgeInsets(.init(top: 6, left: 10, bottom: 6, right: 10))
                    .byTapSound("Sound.wav")
            }
            /// 返回行为：优先后退，否则关闭当前控制器
            .byNavBarOnBack { [weak self] in
                guard let self else { return }
                closeByResult("")
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
            /// 以下是依据前端暴露的自定义方法进行的JS交互
            .registerMobileAction("navigateToHome") { [weak self] dict in
                /// 跳转到首页
                self!.closeByResult("")
            }
            .registerMobileAction("getToken") { [weak self] dict in

            }
            .registerMobileAction("navigateToLogin") { [weak self] dict in
                /// 跳转到登录页
            }
            .registerMobileAction("navigateToDeposit") { [weak self] dict in
                /// 跳转到充值页
            }
            .registerMobileAction("closeWebView") { [weak self] dict in
                /// 关闭WebView
            }
            .registerMobileAction("navigateToSecurityCenter") { [weak self] dict in
                /// 跳转福利中心
            }
            .registerMobileAction("showToast") { [weak self] dict in
                /// 显示Toast
                JobsToast.show(
                    text: dict.stringValue(for: "message") ?? "",
                    config: JobsToast.Config()
                        .byBgColor(.systemGreen.withAlphaComponent(0.9))
                        .byCornerRadius(12)
                )
            }
    }()
    // MARK: - 生命周期
    // ✅ 缓存任意类型的入参
    private var input: Any?
    override func loadView() {
        super.loadView()
        // 读取并缓存（一次性拿 Any 即可）
        input = (inputData() as String?)
        if let any = input { print("收到任意数据:", any) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let s = input as? String, !s.isEmpty {
            web.loadBy(s)
        }
    }
}
