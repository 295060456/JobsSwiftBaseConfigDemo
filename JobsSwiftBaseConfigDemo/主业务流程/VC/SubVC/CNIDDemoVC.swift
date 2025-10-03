//
//  CNIDDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 2025/10/2.
//

import UIKit
import SnapKit

final class CNIDDemoVC: UIViewController {

    private lazy var textField: UITextField = {
        UITextField()
            .byPlaceholder("请输入身份证号码")
            .byBorderStyle(.roundedRect)
            .byClearButtonMode(.whileEditing)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10.h)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()

    private lazy var exampleButton: UIButton = {
        UIButton(type: .system)
            .byTitle("自动填入示例")
            .byTitleFont(.systemFont(ofSize: 15))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.textField.text = "510105199307315321"
                self.resultLabel.text = nil
            }.byAddTo(view) { [unowned self] make in
                make.top.equalTo(textField.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.height.equalTo(36)
            }
    }()

    private lazy var checkButton: UIButton = {
        UIButton(type: .system)
            .byTitle("开始校验")
            .byTitleFont(.boldSystemFont(ofSize: 16))
            .onTap { [weak self] _ in
                guard let self else { return }
                let input = textField.text ?? ""
                guard !input.isEmpty else {
                    updateResult("❌ 请输入身份证号码", success: false)
                    return
                }

                do {
                    let normalized = try CNID.validate(input)
                    updateResult("✅ 校验成功\n标准化结果：\(normalized)", success: true)
                } catch {
                    updateResult("❌ \(error)", success: false)
                }
            }.byAddTo(view) { [unowned self] make in
                make.top.equalTo(exampleButton.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
            }
    }()

    private lazy var resultLabel: UILabel = {
        UILabel()
            .byTextAlignment(.center)
            .byFont(.systemFont(ofSize: 16))
            .byNumberOfLines(0)
            .byTextColor(.secondaryLabel)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(checkButton.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "身份证校验 Demo"
        )
        printDemo()// 打印示例
        textField.alpha = 1;// 输入框
        exampleButton.alpha = 1;// 示例按钮（自动填充）
        checkButton.alpha = 1;// 校验按钮
        resultLabel.alpha = 1;// 结果标签
    }
    // MARK: - 更新显示结果
    private func updateResult(_ text: String, success: Bool) {
        resultLabel.text = text
        resultLabel.textColor = success ? .systemGreen : .systemRed
    }
    // MARK: - 打印示例
    private func printDemo() {
        // 1) 普通文本 / 参数混合
        log("你好，世界", 123, true)

        // 2) JSON：自动识别 String/Data/字典/数组（默认 pretty + 中文还原）
        log(#"{"key":"\u7231\u60c5"}"#)                 // String JSON
        log(["user": "张三", "tags": ["iOS","Swift"]])  // 字典/数组
        log(DataFromNetwork(
            statusCode: 200,
            message: "OK",
            url: URL(string: "https://api.example.com/users")!,
            headers: ["Content-Type": "application/json"],
            body: #"{"user":"\u5f20\u4e09","tags":["iOS","Swift"],"ok":true}"#.data(using: .utf8),
            receivedAt: Date(),
            retryable: false
        ))                            // Data

        // 3) 对象：自动反射为 JSON（防环、可控深度）
        struct User { let id: Int; let name: String }
        let u = User(id: 1, name: "张三")
        log(u)                      // .auto 下会转对象 JSON
        log(u, mode: .object)       // 强制对象模式（不走 stringify）

        // 4) 指定级别（仍是一个入口）
        log("启动完成", level: .info)
        log("接口慢",  level: .warn)
        log(["err": "timeout"], level: .error)
        log(["arr": ["\\u7231\\u60c5", 1]], level: .debug)
    }
}
// 网络返回模型（引用类型）
final class DataFromNetwork {
    var statusCode: Int
    var message: String
    var url: URL
    var headers: [String: String]
    var body: Data?          // 原始字节（通常是 JSON）
    var receivedAt: Date
    var retryable: Bool

    init(statusCode: Int,
         message: String,
         url: URL,
         headers: [String: String] = [:],
         body: Data? = nil,
         receivedAt: Date = Date(),
         retryable: Bool = false) {
        self.statusCode = statusCode
        self.message = message
        self.url = url
        self.headers = headers
        self.body = body
        self.receivedAt = receivedAt
        self.retryable = retryable
    }
}
