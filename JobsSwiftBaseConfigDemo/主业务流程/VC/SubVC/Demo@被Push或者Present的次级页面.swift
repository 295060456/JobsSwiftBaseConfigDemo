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
class DemoDetailVC: BaseVC {
    // ✅ 缓存任意类型的入参
    private var input: Any?
    override func loadView() {
        super.loadView()

        OCCls().string("q", image: "".img)

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
        jobsSetupGKNav(
            title: "🍰 自定义高度 HalfSheet (320)"
        )
        UIButton(type: .system)
            // 普通文字：未选中状态标题
            .byTitle("关闭", for: .normal)
            // 字体统一
            .byTitleFont(.boldSystemFont(ofSize: 16))
            // 点按事件（统一入口）
            .onTap { [weak self] sender in
                guard let self else { return }
                goBack(input)
            }
            .byAddTo(view) { make in
                make.center.equalToSuperview()
            }
    }
}
// MARK: - 自定义半屏弹窗 VC（内容随便，这里示意）
class HalfSheetDemoVC: DemoDetailVC{
    override func viewDidLoad() {
        super.viewDidLoad()

        view.byBgColor(.systemBackground)
            .byCornerRadius(16)
            .byClipsToBounds(true)

        UILabel()
            .byText("")
            .byFont(.boldSystemFont(ofSize: 18))
            .byTextAlignment(.center)
            .byAddTo(view) { make in
                make.top.equalToSuperview().offset(20)
                make.centerX.equalToSuperview()
            }
    }
}
