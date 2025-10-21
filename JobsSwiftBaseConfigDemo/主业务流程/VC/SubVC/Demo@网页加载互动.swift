//
//  BaseWebViewDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/18/25.
//

import UIKit
import SnapKit
import WebKit
/// 用法示例：懒加载 + 你的链式 DSL + SnapKit 约束
final class BaseWebViewDemoVC: BaseVC {
    // MARK: - 懒加载 Web
    private lazy var web: BaseWebView = { [unowned self] in
        let w = BaseWebView()
            .byBgColor(.clear)
            .byAllowedHosts([])                  // 不限域
            .byOpenBlankInPlace(true)
            .byDisableSelectionAndCallout(false)
            .byUserAgentSuffixProvider { req in
    //          guard let host = req.url?.host?.lowercased() else { return nil }
    //          if host == "m.bwsit.cc" { return nil }               // 该域名走系统默认 UA（避免奇怪分流）
    //          if req.url?.absoluteString.contains("/activity/") == true { return "JobsApp/1.0" }
                return nil                                           // 其它页面默认 UA
            }
            .byNormalizeMToWWW(false)               // ❗️关闭 m→www
            .byForceHTTPSUpgrade(false)             // ❗️关闭 http→https
            .bySafariFallbackOnHTTP(false)          // ❗️关闭 Safari 兜底
            .byInjectRedirectSanitizerJS(false)     // 可关，避免干涉 H5 自己跳转

            // 🔽 一键开导航栏（默认标题=webView.title，默认有返回键）
            .byNavBarEnabled(true)
            .byNavBarStyle { s in
                s.byHairlineHidden(false)
                    .byBackgroundColor(.systemBackground)
                    .byTitleAlignmentCenter(true)
            }
            // 自定义返回键（想隐藏就：.byNavBarBackButtonProvider { nil }）
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
//            .byNavBarBackButtonLayout { bar, btn, make in
//                make.left.equalToSuperview().offset(0)
//                make.centerY.equalToSuperview()
//            }
            // 返回行为：优先后退，否则 pop
            .byNavBarOnBack { [weak self] in
                guard let self else { return }
                closeByResult("")
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10) // 若确信此时已存在，才去取
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
        /// 注册 JS→Native 方法
        installHandlers(on: w)
        /// Native → JS：页面就绪广播（延迟仅示例）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak w] in
            w?.emitEvent("nativeReady", payload: [
                "msg": "Native is ready ✔︎",
                "ts": Date().timeIntervalSince1970
            ])
        }
        return w
    }()
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor(.systemBackground)

//        jobsSetupGKNav(title: "BaseWebView · 用法示例")
        // 1️⃣ 加载线上 URL（任选其一）
//        web.loadBy("https://www.baidu.com")
         web.loadBy("https://www.bwsit.cc/activity/list/FIRST_DEPOSIT_V2/441138552531886080")
//        web.loadBy(URL(string: "https://www.bwsit.cc/activity/list/FIRST_DEPOSIT_V2/441138552531886080")!)
        // 2️⃣ 加载内置 HTML（包含 JS↔︎Native 验证按钮）
//        web.loadHTMLBy(Self.demoHTML, baseURL: nil)
        // 3️⃣ 加载本地HTML文件
//        print("Bundle:", Bundle.main.bundlePath)
//        let all = Bundle.main.urls(forResourcesWithExtension: "html", subdirectory: nil) ?? []
//        print("SomeThing in bundle:", all.map { $0.lastPathComponent })
//        web.loadBundleHTMLBy(named: "BaseWebViewDemo")
    }
    // MARK: - JS→Native 事件注册
    private func installHandlers(on web: BaseWebView) {
        // ping：回包设备信息（device 显式类型，避免 'name' 歧义）
        web.on("ping") { payload, reply in
            let device: [String: String] = [
                "name": UIDevice.current.name,
                "system": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
            ]
            reply([
                "ok": true,
                "echo": payload ?? NSNull(),
                "device": device,
                "ts": Date().timeIntervalSince1970
            ])
        }
        // openAlert：用你自家的 UIAlertController DSL
        web.on("openAlert") { payload, reply in
            let msg = (payload as? [String: Any])?["message"] as? String ?? "No message"
            let ac = UIAlertController
                .makeAlert("提示", msg)
                .byAddCancel { _ in reply(["shown": false]) }
                .byAddOK     { _ in reply(["shown": true]) }
            self.present(ac, animated: true)
        }
        // toggleSelection：切换是否禁用选中/长按
        web.on("toggleSelection") { payload, reply in
            let disabled = ((payload as? [String: Any])?["disabled"] as? Bool) ?? false
            web.setSelectionDisabled(disabled)
            reply(["disabled": disabled])
        }
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
