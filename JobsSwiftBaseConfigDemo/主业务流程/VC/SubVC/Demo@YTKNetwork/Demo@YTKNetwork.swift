//
//  Demo@YTKNetwork.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import YTKNetwork
import SnapKit

final class YTKNetworkDemoVC: BaseVC, YTKChainRequestDelegate {
    private var currentChainRequest: YTKChainRequest?
    /// 输出日志
    private lazy var logTextView: UITextView = {
        UITextView()
            .byEditable(NO)
            .byFont(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .byBgColor(.secondarySystemBackground)
            .byTextColor(.label)
            .byAddTo(view) { [unowned self] make in
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalToSuperview().inset(26)
                make.height.equalTo(Screen.height / 2)
        }
    }()
    /// 单请求按钮：GET /ip
    private lazy var singleRequestButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("单请求：GET /ip", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .byTapSound("Sound.wav")
            .onTap { [weak self] _ in
                guard let self else { return }
                appendLog("👉 单请求：GET /ip")
                GetIpRequest()
                    .bySuccess({ [weak self] (request: YTKBaseRequest) in
                        guard let self = self,let r = request as? GetIpRequest else { return }

                        self.appendLog("✅ 成功：IP = \(r.ip ?? "nil")")
                        self.appendLog("响应 JSON = \(String(describing: r.responseJSONObject))")

                        request.clearCompletionBlock()
                    })
                    .byFailure({ [weak self] (request: YTKBaseRequest) in
                        self?.appendLog("❌ 失败：\(String(describing: request.error))")
                        request.clearCompletionBlock()
                }).start()
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.equalToSuperview().inset(24)
                    make.height.equalTo(44)
                } else {
                    make.edges.equalTo(view.safeAreaLayoutGuide).inset(16)
                }
            }
    }()
    /// 批量请求按钮：GET /ip + GET /headers
    private lazy var batchRequestButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemBlue, for: .normal)
            .byTitle("批量：IP + Headers", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .onTap { [weak self] _ in
                guard let self else { return }
                appendLog("👉 批量请求：GET /ip + GET /headers")
                YTKBatchRequest(request: [GetIpRequest(), GetHeadersRequest()])
                    .bySuccess({ [weak self] (batchRequest: YTKBatchRequest) in
                        guard let self = self else { return }
                        let array = batchRequest.requestArray
                        guard array.count == 2,
                              let ip      = array[0] as? GetIpRequest,
                              let headers = array[1] as? GetHeadersRequest
                        else {
                            self.appendLog("⚠️ 批量成功但解析 requestArray 失败")
                            return
                        }
                        self.appendLog("✅ 批量成功：IP = \(ip.ip ?? "nil")")
                        self.appendLog("Headers = \(headers.headers ?? [:])")
                        batchRequest.clearCompletionBlock()
                    })
                    .byFailure({ [weak self] (batchRequest: YTKBatchRequest) in
                        self?.appendLog("❌ 批量失败：\(String(describing: batchRequest.failedRequest?.error))")
                        batchRequest.clearCompletionBlock()
                }).start()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.singleRequestButton.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()
    /// 链式请求按钮：POST /post → GET /headers
    private lazy var chainRequestButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemOrange, for: .normal)
            .byTitle("链式：POST → GET", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .onTap { [weak self] _ in
                guard let self else { return }
                appendLog("👉 链式请求：POST /post → GET /headers")
                currentChainRequest = YTKChainRequest()
                    .byAdd(PostJsonRequest(payload: [
                        "user": "Jobs",
                        "role": "Developer",
                        "time": Date().timeIntervalSince1970
                    ])) { chainRequest, baseReq in
                        _ = baseReq as? PostJsonRequest
                        let headersReq = GetHeadersRequest()
                        chainRequest.add(headersReq, callback: nil)
                    }
                    .byDelegate(self)
                    .byStart()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.batchRequestButton.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()
    /// 上传头像按钮：Multipart POST /post
    private lazy var uploadButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemPurple, for: .normal)
            .byTitle("上传头像：Multipart", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 12, bottom: 10, right: 12))
            .onTap { [weak self] _ in
                guard let self else { return }
                appendLog("👉 上传头像：POST /post (Multipart)")
                // 造一张纯色图
                UploadAvatarRequest(image: UIGraphicsImageRenderer(size: CGSize(width: 80, height: 80))
                    .image { ctx in
                        UIColor.systemPink.setFill()
                        ctx.fill(CGRect(x: 0, y: 0, width: 80, height: 80))
                    })
                    .bySuccess({ [weak self] (request: YTKBaseRequest) in
                    guard let self = self else { return }
                    self.appendLog("✅ 上传成功")
                    self.appendLog("响应 JSON = \(String(describing: request.responseJSONObject))")
                    request.clearCompletionBlock()
                })
                .byFailure({ [weak self] (request: YTKBaseRequest) in
                    self?.appendLog("❌ 上传失败：\(String(describing: request.error))")
                    request.clearCompletionBlock()
                })
                .start()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.chainRequestButton.snp.bottom).offset(12)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupYTKNetworkBaseURL()
        jobsSetupGKNav(
            title: "YTKNetwork Swift Demo",
            rightButtons: [
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("moon.circle.fill".sysImg, for: .normal)
                    .byImage("moon.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        logTextView.text = "";
                    }
            ]
        )
        // 触发懒加载 & 约束
        singleRequestButton.byVisible(YES)
        batchRequestButton.byVisible(YES)
        chainRequestButton.byVisible(YES)
        uploadButton.byVisible(YES)
        logTextView.byVisible(YES)
    }

    private func appendLog(_ text: String) {
        let line = "[\(Date())] \(text)\n"
        logTextView.text.append(line)
        let location = max(0, logTextView.text.count - 1)
        let range = NSRange(location: location, length: 1)
        logTextView.scrollRangeToVisible(range)
        print(line)
    }
    // MARK: - YTKChainRequestDelegate
    func chainRequestFinished(_ chainRequest: YTKChainRequest) {
        guard let last = chainRequest.requestArray().last as? GetHeadersRequest else {
            appendLog("⚠️ 链式成功但取不到最后一个请求")
            return
        };appendLog("✅ 链式成功，最终 Headers = \(last.headers ?? [:])")
    }

    func chainRequestFailed(_ chainRequest: YTKChainRequest,
                            failedBaseRequest request: YTKBaseRequest) {
        appendLog("❌ 链式失败：\(String(describing: request.error))")
    }
}
