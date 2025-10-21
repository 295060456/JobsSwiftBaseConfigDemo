//
//  BaseWebViewDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/18/25.
//

import UIKit
import SnapKit
import WebKit
/// 用法示例：懒加载 + 你的链式 DSL + SnapKit 约束（基于最新版 BaseWebView.swift）
final class BaseWebViewDemoVC: BaseVC {
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
                    .byImage(UIImage(systemName: "chevron.left"), for: .normal)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor(.systemBackground)
        /// 1️⃣ 加载线上 URL（任选其一）
        web.loadBy("https://www.bwsit.cc/activity/list/FIRST_DEPOSIT_V2/441138552531886080")
        // web.loadBy("https://www.baidu.com")
        /// 2️⃣ 加载内置 HTML（包含 JS↔︎Native 验证按钮）
        // web.loadHTMLBy(Self.demoHTML, baseURL: nil)
        /// 3️⃣ 加载本地 HTML 文件
        // web.loadBundleHTMLBy(named: "BaseWebViewDemo")
    }
    // MARK: - 验证用 HTML（按钮覆盖 ping / alert / selection / _blank / 外链 / 下载）
    static let demoHTML = """
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>BaseWebView Usage Demo</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html,body { margin:0; padding:0; font-family:-apple-system,Helvetica; }
    header { position:sticky; top:0; background:#111; color:#fff; padding:12px 16px; font-weight:600; }
    main { padding:16px; }
    button { padding:10px 14px; margin:6px 6px 6px 0; border-radius:8px; border:1px solid #ccc; background:#fafafa; }
    pre { background:#f6f8fa; padding:10px; border-radius:6px; white-space:pre-wrap; word-break:break-word; max-height:40vh; overflow:auto; }
    .row { display:flex; gap:8px; flex-wrap:wrap; }
    a { color:#0a84ff; }
  </style>
</head>
<body>
  <header>BaseWebView · JS ↔︎ Native</header>
  <main>
    <div class="row">
      <button id="btnPing">JS→Native ping()</button>
      <button id="btnAlert">JS→Native openAlert()</button>
      <button id="btnDisableSel">禁用选择 ON</button>
      <button id="btnEnableSel">禁用选择 OFF</button>
    </div>

    <p>外链/下载：</p>
    <div class="row">
      <a href="mailto:test@example.com">mailto</a>
      <a href="https://example.com" target="_blank">_blank 打开 example.com</a>
      <a href="data:text/plain,hello" download="hello.txt">下载 data: 文本</a>
    </div>

    <p>日志：</p>
    <pre id="log"></pre>
  </main>

  <script>
    const logEl = document.getElementById('log');
    function log(){ const line=[...arguments].map(a=>typeof a==='string'?a:JSON.stringify(a)).join(' ');
      console.log(line); logEl.textContent=(line+"\\n"+logEl.textContent).slice(0, 10000); }

    document.addEventListener('nativeReady', e => log('[event] nativeReady:', e.detail));

    document.getElementById('btnPing').addEventListener('click', async () => {
      const res = await Native.call('ping', { msg:'hello from JS', rnd: Math.random() });
      log('[reply] ping =>', res);
    });

    document.getElementById('btnAlert').addEventListener('click', async () => {
      const res = await Native.call('openAlert', { message:'JS 请求原生 Alert' });
      log('[reply] openAlert =>', res);
    });

    document.getElementById('btnDisableSel').addEventListener('click', async () => {
      const res = await Native.call('toggleSelection', { disabled:true });
      log('[reply] toggleSelection =>', res);
    });
    document.getElementById('btnEnableSel').addEventListener('click', async () => {
      const res = await Native.call('toggleSelection', { disabled:false });
      log('[reply] toggleSelection =>', res);
    });
  </script>
</body>
</html>
"""
}
