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
            .byAllowedHosts([])                     // 例：["example.com"]，空=不限制
            .byOpenBlankInPlace(true)               // target=_blank 在当前 Web 打开
            .byDisableSelectionAndCallout(false)    // 是否禁用选中/长按菜单
            .byInjectDarkStylePatch(false)          // 简单深色补丁（按需 true）
            .byCustomUserAgentSuffix("JobsApp/1.0")
            .byAddTo(view) {[unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10) // 占满
                make.left.right.bottom.equalToSuperview()
            }
        // 注册 JS→Native 方法
        installHandlers(on: w)
        // Native → JS：页面就绪广播
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
        jobsSetupGKNav(title: "BaseWebView · 用法示例")
        // ① 加载线上 URL（任选其一）
//         web.loadBy(URL(string: "https://sina.cn/")!)
        // ② 加载内置 HTML（包含 JS↔︎Native 验证按钮）
//        web.loadHTMLBy(Self.demoHTML, baseURL: nil)

        print("Bundle:", Bundle.main.bundlePath)
        let all = Bundle.main.urls(forResourcesWithExtension: "html", subdirectory: nil) ?? []
        print("SomeThing in bundle:", all.map { $0.lastPathComponent })
        web.loadBundleHTMLBy(named: "BaseWebViewDemo")
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
}
// MARK: - 验证用 HTML（按钮覆盖 ping / alert / selection / _blank / 外链 / 下载）
extension BaseWebViewDemoVC {
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
