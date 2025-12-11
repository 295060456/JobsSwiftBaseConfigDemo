//
//  Demo@系统导航栏.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/25/25.
//

import UIKit
import RxSwift
import RxCocoa

final class JobsNavigationDemoVC: BaseVC {
    deinit {
        print("JobsNavigationDemoVC deinit")
    }
    // MARK: - 左侧：自定义返回按钮（用你的按钮 DSL）
    private lazy var backButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.clear, for: .normal)
            .byTitle("返回".tr, for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 12, weight: .bold))
            .byImage("chevron.backward".sysImg, for: .normal)
            .byContentEdgeInsets(.init(top: 0, left: 10, bottom: 0, right: 10))
            .byTitleEdgeInsets(.init(top: 0, left: 4, bottom: 0, right: -4))
            .onTap { [weak self] _ in
                guard let self else { return }
                print("👉 点击了左侧『返回』按钮")
                goBack(nil)
            }
            .onLongPress(minimumPressDuration: 0.6) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                    print("返回按钮长按开始")
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                    print("返回按钮长按结束")
                }
            }
    }()
    // MARK: - 右侧：铃铛按钮（用你的按钮 DSL，带红点 + NEW 角标）
    private lazy var bellButton: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.clear, for: .normal)
            .byTitle("铃".tr, for: .normal)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleFont(.systemFont(ofSize: 12, weight: .bold))
            .byImage("bell".sysImg, for: .normal)
            .byContentEdgeInsets(.init(top: 0, left: 10, bottom: 0, right: 10))
            .byTitleEdgeInsets(.init(top: 0, left: 4, bottom: 0, right: -4))
            .byTapSound("Sound.wav") // 如果你项目里有这个声音资源
            .onTap { [weak self] _ in
                guard let self else { return }
                print("👉 点击了右侧『铃铛』按钮")
                "点击了右侧『铃铛』按钮".toast
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                if gr.state == .began {
                    btn.alpha = 0.6
                    print("铃铛长按开始")
                    "铃铛长按开始".toast
                } else if gr.state == .ended || gr.state == .cancelled {
                    btn.alpha = 1.0
                    print("铃铛长按结束")
                    "铃铛长按结束".toast
                }
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        // MARK: - 外观：背景图、底色、tintColor 等
        configureNavigationBarAppearance()
        self.title = "系统导航栏 Demo" // 普通文本的优先级低于富文本。title的优先级低于navigationItem.titleView
        // MARK: - 标题：富文本（JobsRichRun）
        navigationItem.titleView = UILabel()
            .byTextAlignment(.center)
            .byBgCor(.clear)
            .byNumberOfLines(1)
            .richTextBy([
                JobsRichRun(.text("合理".tr))
                    .font(.systemFont(ofSize: 12, weight: .regular))
                    .color(.systemBlue),
                JobsRichRun(.text("的".tr))
                    .font(.systemFont(ofSize: 13, weight: .semibold))
                    .color(.white),
                JobsRichRun(.text("语法糖".tr))
                    .font(.systemFont(ofSize: 14, weight: .ultraLight))
                    .color(.red)
            ], paragraphStyle: jobsMakeParagraphStyle {
                $0.alignment = .center
                $0.lineSpacing = 0
        }).bySizeToFit()
        navigationItem.hidesBackButton = true
        // MARK: - 左边：按钮 DSL 嵌进导航栏
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        // 如果有需求，也可以：
        // navigationController?.interactivePopGestureRecognizer?.delegate = self
        // MARK: - 右边：一个系统 hi + 一个按钮 DSL 铃铛
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem
                .make(title: "hi")
                .onTap { [weak self] (item:UIBarButtonItem) in
                    guard let self else { return }
                    print("👉 点击了右侧『hi』按钮")
                    "点击了右侧\(item.title!)按钮".toast
                },
            UIBarButtonItem(customView: bellButton)]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        UINavigationBar.appearance().isHidden = false
    }
    // MARK: - 导航栏外观
    private func configureNavigationBarAppearance() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.byTintColor(.black)
        let bgImage = "导航栏背景图".img
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
                .byLargeTitleAttributes([
                    .foregroundColor: UIColor.cyan,
                    .font: UIFont.boldSystemFont(ofSize: 30)
                ])
                .byTitleAttributes([
                    .foregroundColor: UIColor.red,
                    .font: UIFont.boldSystemFont(ofSize: 18)
                ])
                .byOpaqueBackground()
                .byBackgroundImage(bgImage)
                .byBackgroundColor(.yellow)
                .byShadowColor(.clear)

            navBar
                .byStandardAppearance(appearance)
                .byScrollEdgeAppearance(appearance)
                .byCompactAppearance(appearance)

            if #available(iOS 15.0, *) {
                navBar.byCompactScrollEdgeAppearance(appearance)
            }
        } else {
            navBar
                .byBackgroundImage(bgImage, for: .default)
                .byBarTintColor(.yellow)
                .byTranslucent(NO)
                .byShadowImage(UIImage())
                .byTitleTextAttributes([
                    .foregroundColor: UIColor.red,
                    .font: UIFont.boldSystemFont(ofSize: 18)
                ])
        }
    }
    // MARK: - 状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
