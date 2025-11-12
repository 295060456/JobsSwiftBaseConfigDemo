//
//  Demo@SkeletonView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit
import SkeletonView

// MARK: - 数据模型
struct User {
    let name: String
    let detail: String
    let color: UIColor
}
// MARK: - Demo VC
final class SkeletonViewDemoVC: BaseVC {
    // UI
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byBgColor(.systemGroupedBackground)
            .bySeparatorStyle(.none)
            .byRowHeight(UITableView.automaticDimension)
            .byEstimatedRowHeight(72)
            .registerCell(SkeletonUserCell.self)
            .byDataSource(self)
            .byDelegate(self)
            .bySkeletonable(YES)
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.edges.equalTo(view.safeAreaLayoutGuide)
                }
            }
    }()

    // 状态
    private var data: [User] = []
    private var isLoading = true
    private var useGradient = true

    // Skeleton 配置
    private let gradient = SkeletonGradient(baseColor: UIColor.systemGray5)
    private let solid     = SkeletonGradient(baseColor: UIColor.systemGray5) // 纯色也用 gradient 类型，动画不同
    private let slideAnim = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(
            title: "Demo@SkeletonView",
            rightButtons: [
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("moon.circle.fill".sysImg, for: .normal)
                    .byImage("moon.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        // 重新进入加载状态
                        startSkeleton()
                        simulateFetch()
                    },
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("globe".sysImg, for: .normal)
                    .byImage("globe".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        // 动画模式在渐变滑动 & 脉冲之间切换
                        useGradient.toggle()
                        if isLoading {
                            tableView.hideSkeleton()
                            startSkeleton()
                        }
                    }
            ]
        )

        view.backgroundColor = .systemBackground
        view.bySkeletonable(YES) // 容器也打标，避免传导问题
        startSkeleton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 模拟网络
        simulateFetch()
    }
    // MARK: - Skeleton 显隐
    private func startSkeleton() {
        isLoading = true
        if useGradient {
            // 渐变骨架：用 builder/sliding
            let anim = GradientDirection.leftRight.slidingAnimation()
            tableView.showAnimatedGradientSkeleton(
                usingGradient: gradient,
                animation: anim,
                transition: .crossDissolve(0.2)
            )
        } else {
            // 纯色骨架：直接用内置“脉冲”，不要 builder
            tableView.showAnimatedSkeleton(transition: .crossDissolve(0.2))
        }
    }

    private func stopSkeletonAndReload() {
        tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        isLoading = false
    }
    // MARK: - 模拟网络
    private func simulateFetch() {
        // 2 秒后给数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            self.data = Self.mockUsers(count: 20)
            self.stopSkeletonAndReload()
        }
    }

    private static func mockUsers(count: Int) -> [User] {
        let names = ["Alice", "Bob", "Cindy", "David", "Eva", "Frank", "Grace", "Henry", "Iris", "Jack", "Kate", "Leo", "Mia", "Nina", "Owen", "Paul", "Quinn", "Ruby", "Sam", "Tina"]
        let descs = [
            "这是一段较短的简介。",
            "这里是两行简介，展示骨架文本的多行效果。第二行用来填充视觉。",
            "偏长的描述，目的是让 subtitleLabel 在骨架时出现 2 行以上，从而看到 lastLineFillPercent。"
        ]
        func randColor() -> UIColor {
            let all: [UIColor] = [.systemBlue, .systemTeal, .systemPink, .systemOrange, .systemPurple, .systemGreen, .systemIndigo, .systemRed]
            return all.randomElement() ?? .systemGray
        }
        return (0..<count).map { i in
            .init(
                name: names[i % names.count],
                detail: descs[i % descs.count],
                color: randColor()
            )
        }
    }
}
// MARK: - UITableViewDataSource / UITableViewDelegate
extension SkeletonViewDemoVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.py_dequeueReusableCell(withType: SkeletonUserCell.self, for: indexPath)
        if !isLoading {
            c.configure(with: data[indexPath.row])
        };return c
    }
}
// MARK: - Skeleton 数据源（关键）
extension SkeletonViewDemoVC: SkeletonTableViewDataSource {
    // 骨架期的占位行数
    func numSections(in collectionSkeletonView: UITableView) -> Int { 1 }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        8
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        String(describing: SkeletonUserCell.self)
    }
}
