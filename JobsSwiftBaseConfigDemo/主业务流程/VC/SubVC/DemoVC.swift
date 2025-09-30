//
//  DemoDetailVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/30/25.
//

import UIKit
import SnapKit
/// 示例模型，用于演示传参
struct DemoModel {
    let id: Int
    let title: String
}
// MARK: - 一个示例页面（用来被 push）
class DemoDetailVC: UIViewController {
    // ✅ 缓存任意类型的入参
    private var input: Any?
    override func loadView() {
        super.loadView()
        // 读取并缓存（一次性拿 Any 即可）
        input = (inputData() as Any?)
        // 需要的话再按类型分别打印
        if let id: Int = inputData() { print("收到 Int:", id) }
        if let info: [String: Any] = inputData() { print("收到 Dictionary:", info) }
        if let arr: [Int] = inputData() { print("收到 Array:", arr) }
        if let any = input { print("收到任意数据:", any) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detail"

        let close = UIButton(type: .system)
        close.setTitle("关闭", for: .normal)
        close.titleLabel?.font = .boldSystemFont(ofSize: 16)
        close.addTarget(self, action: #selector(onClose), for: .touchUpInside)

        view.addSubview(close)
        close.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func onClose() {
        closeByResult(input)
    }
}
// MARK: - 自定义半屏弹窗 VC（内容随便，这里示意）
class HalfSheetDemoVC: DemoDetailVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        let titleLbl = UILabel()
        titleLbl.text = "🍰 自定义高度 HalfSheet (320)"
        titleLbl.font = .boldSystemFont(ofSize: 18)
        titleLbl.textAlignment = .center
        view.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
