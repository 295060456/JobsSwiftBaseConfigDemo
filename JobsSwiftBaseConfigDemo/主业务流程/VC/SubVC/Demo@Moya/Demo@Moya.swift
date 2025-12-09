//
//  MoyaDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  依赖：Moya、Alamofire、(可选) CombineMoya、SnapKit
//

import UIKit
import Moya
import Combine
import SnapKit
#if canImport(CombineMoya)
import CombineMoya
#endif

final class MoyaDemoVC: BaseVC {
    // ✅ 改为 lazy，并把 Moya 日志重定向到 UI
    private lazy var api: APIService = {
        APIService.live { [weak self] text in
            self?.appendRawLog(text ?? "")
        }
    }()

    private var bag = Set<AnyCancellable>()

    // =============== 回显区（懒加载 + 你的 byAddTo 就地约束） ===============
    private lazy var resultView: UITextView = {
        UITextView()
            .byEditable(false)
            .byAlwaysBounceVertical(true)
            .byShowsVerticalScrollIndicator(true)
            .byFont(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .byTextColor(.label)
            .byBgColor(UIColor.secondarySystemBackground)
            .byCornerRadius(8)
            .byMasksToBounds(true)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnClear.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
                make.height.greaterThanOrEqualTo(180)
            }
    }()

    // =============== 按钮们（懒加载 + 你的 DSL + 每个块内 byAddTo 约束） ===============
    private lazy var btnZen: UIButton = {
        UIButton.sys()
            .byTitle("GET /zen", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemBlue)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] sender in
                guard let self else { return }
                clear()
                show(title: "GET /zen → 请求中…")
                api.provider.request(.ghZen) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let resp):
                        let text = String(data: resp.data, encoding: .utf8) ?? ""
                        show(title: "GET /zen ✅", body: text)
                    case .failure(let e):
                        show(title: "GET /zen ❌", body: "\(e)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
                }
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnUser: UIButton = {
        UIButton.sys()
            .byTitle("GET /users/apple", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemIndigo)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                clear()
                show(title: "GET /users/apple → 请求中…")
                api.provider.request(.ghUser(username: "apple")) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let resp):
                        do {
                            let user = try JSONDecoder().decode(GHUser.self, from: resp.data)
                            show(title: "GET /users/apple ✅",
                                 body: "login=\(user.login), id=\(user.id)\navatar=\(user.avatar_url)")
                        } catch {
                            show(title: "解析失败 ❌", body: "\(error)")
                        }
                    case .failure(let e):
                        show(title: "GET /users/apple ❌", body: "\(e)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnZen.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnLogin: UIButton = {
        UIButton.sys()
            .byTitle("POST /login (ReqRes)", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemGreen)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                clear()
                show(title: "POST /api/login → 请求中…")
                api.requestWithAutoRefresh(.login(email: "eve.holt@reqres.in", password: "cityslicka")) { [weak self] res in
                    guard let self else { return }
                    switch res {
                    case .success(let resp):
                        show(title: "POST /login ✅", body: self.prettyJSON(resp.data))
                    case .failure(let e):
                        show(title: "POST /login ❌", body: "\(e)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnUser.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnUpload: UIButton = {
        UIButton.sys()
            .byTitle("UPLOAD /post (httpbin)", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemOrange)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                clear()
                show(title: "UPLOAD /post → 上传中…（看进度）")
                let fake = Data(repeating: 0xFF, count: 200_000)
                api.provider.request(.uploadAvatar(imageData: fake), progress: { [weak self] prog in
                    guard let self else { return }
                    self.show(title: "⬆️ 上传进度", body: String(format: "%.1f%%", prog.progress * 100))
                }, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let resp):
                        show(title: "UPLOAD ✅", body: self.prettyJSON(resp.data))
                    case .failure(let e):
                        show(title: "UPLOAD ❌", body: "\(e)")
                    }
                })
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnLogin.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnDownloadPNG: UIButton = {
        UIButton.sys()
            .byTitle("DOWNLOAD /image/png", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemPink)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                clear()
                show(title: "DOWNLOAD /image/png → 下载中…")
                api.provider.request(.downloadPNG, progress: { [weak self] prog in
                    guard let self else { return }
                    show(title: "⬇️ PNG 进度", body: String(format: "%.1f%%", prog.progress * 100))
                }) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let resp):
                        show(title: "DOWNLOAD PNG ✅",
                                  body: "保存至：\(resp.response?.url?.path ?? "-")")
                    case .failure(let e):
                        show(title: "DOWNLOAD PNG ❌", body: "\(e)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnUpload.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnDownloadBytes: UIButton = {
        UIButton.sys()
            .byTitle("DOWNLOAD /bytes/524288", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemTeal)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                show(title: "DOWNLOAD /bytes/524288 → 下载中…")
                api.provider.request(.downloadBytes(size: 524_288), progress: { [weak self] prog in
                    guard let self else { return }
                    show(title: "⬇️ BYTES 进度", body: String(format: "%.1f%%", prog.progress * 100))
                }) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let resp):
                        show(title: "DOWNLOAD BYTES ✅",
                                  body: "保存至：\(resp.response?.url?.path ?? "-")")
                    case .failure(let e):
                        show(title: "DOWNLOAD BYTES ❌", body: "\(e)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnDownloadPNG.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnCombineZen: UIButton = {
        UIButton.sys()
            .byTitle("Combine GET /zen", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemPurple)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                clear()
                #if canImport(CombineMoya)
                show(title: "Combine GET /zen → 请求中…")
                api.provider.requestPublisher(.ghZen)
                    .tryMap { response -> String in
                        guard (200..<300).contains(response.statusCode) else {
                            throw MoyaError.statusCode(response)
                        }
                        return String(data: response.data, encoding: .utf8) ?? ""
                    }
                    .sink { [weak self] jobsByVoidBlock in
                        guard let self else { return }
                        if case let .failure(err) = jobsByVoidBlock {
                            show(title: "Combine /zen ❌", body: "\(err)")
                        }
                    } receiveValue: { [weak self] text in
                        show(title: "Combine /zen ✅", body: text)
                    }
                    .store(in: &bag)
                #else
                show(title: "CombineMoya 未集成，跳过 Combine 示例")
                #endif
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnDownloadBytes.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var btnStub: UIButton = {
        UIButton.sys()
            .byTitle("Stub: sampleData", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.darkGray)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                clear()
                show(title: "Stub 示例 → 使用 sampleData")
                let stubAPI = APIService.stubbed { [weak self] text in
                    self?.appendRawLog(text ?? "")
                }
                stubAPI.provider.request(.ghZen) { [weak self] r in
                    switch r {
                    case .success(let resp):
                        self?.show(title: "Stub /zen ✅", body: String(data: resp.data, encoding: .utf8))
                    case .failure(let e):
                        self?.show(title: "Stub /zen ❌", body: "\(e)")
                    }
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnCombineZen.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    // 新增：清空输出按钮（就地约束，位于 resultView 之上右侧）
    private lazy var btnClear: UIButton = {
        UIButton.sys()
            .byTitle("清空输出", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byBgColor(.systemRed)
            .byContentEdgeInsets(.init(top: 8, left: 12, bottom: 8, right: 12))
            .onTap { [weak self] sender in
                guard let self else { return }
                clear()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.btnStub.snp.bottom).offset(8)
                make.right.equalToSuperview().inset(24)
                make.height.equalTo(36)
            }
    }()

    private func clear() {
        DispatchQueue.main.async { [weak self] in
            self?.resultView.text = ""
        }
    }

    // =============== 生命周期 ===============
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "Moya 全量用法 Demo")

        // 触发懒加载 + 就地布局（按顺序确保依赖关系）
        btnZen.byVisible(YES)
        btnUser.byVisible(YES)
        btnLogin.byVisible(YES)
        btnUpload.byVisible(YES)
        btnDownloadPNG.byVisible(YES)
        btnDownloadBytes.byVisible(YES)
        btnCombineZen.byVisible(YES)
        btnStub.byVisible(YES)
        btnClear.byVisible(YES)
        resultView.byVisible(YES)

        show(title: "准备就绪 ✅", body: "点上面的按钮触发网络示例，结果会回显到这里。")
    }

    // =============== 回显 & 工具 ===============
    private func show(title: String, body: String? = nil) {
        let header = "【\(title)】\n"
        // 强制回主线程，避免偶发回调不在 main 导致 UI 不刷新
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let b = body, !b.isEmpty {
                self.resultView.text = header + b + "\n\n" + (self.resultView.text ?? "")
            } else {
                self.resultView.text = header + (self.resultView.text ?? "")
            }
        }
    }

    /// 把 NetworkLoggerPlugin/CurlLoggerPlugin 的原始文本直接塞进 UI（不加标题）
    private func appendRawLog(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.resultView.text = text + "\n\n" + (self.resultView.text ?? "")
        }
    }

    private func prettyJSON(_ data: Data) -> String {
        guard
            let obj = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
            let s = String(data: pretty, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "(\(data.count) bytes)"
        }
        return s
    }

    // ===============（可选）async/await 示例：保留但不默认调用） ===============
    #if compiler(>=5.5) && canImport(_Concurrency)
    @available(iOS 13.0, *)
    private func demoAsyncAwaitStyle() async {
        do {
            let resp = try await api.provider.request(.ghSearchUsers(q: "jobs", page: 1))
            show(title: "async /search/users ✅", body: prettyJSON(resp.data))
        } catch {
            show(title: "async /search/users ❌", body: "\(error)")
        }
    }
    #endif
}
