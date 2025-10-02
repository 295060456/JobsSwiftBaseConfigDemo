//
//  JobsCountdownDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/9/30.
//

import UIKit
import SnapKit

final class JobsCountdownDemoVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(
            title: "Countdown 按钮 Demo"
        )
        view.backgroundColor = .systemBackground

        if #available(iOS 15.0, *) {
            setupUI_iOS15()
        } else {
            UILabel()
                .byText("需要 iOS 15+ 的 UIButton.Configuration")
                .byTextColor(.secondaryLabel)
                .byTextAlignment(.center)
                .byAddTo(view) { make in
                    make.center.equalToSuperview()
                }
        }
    }
    // MARK: - iOS15+ Demo
    @available(iOS 15.0, *)
    private func setupUI_iOS15() {
        // ✅ Scroll 容器（防止内容过多）
        let scroll = UIScrollView()
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 14
        content.alignment = .fill

        view.addSubview(scroll)

        scroll.snp.makeConstraints {
            $0.top.equalTo(gk_navigationBar.snp.bottom).offset(10.h)
            $0.left.bottom.right.equalTo(view.safeAreaLayoutGuide)
        }

        scroll.addSubview(content)
        content.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(scroll.snp.width).offset(-40)
        }

        // MARK: - 辅助函数
        func addTitle(_ text: String) {
            let lab = UILabel()
            lab.text = text
            lab.font = .systemFont(ofSize: 13, weight: .semibold)
            lab.textColor = .secondaryLabel
            content.addArrangedSubview(lab)
        }

        func makeFilled(_ title: String, _ bg: UIColor) -> UIButton {
            let btn = UIButton(type: .system)
            var cfg = UIButton.Configuration.filled()
            cfg.title = title
            cfg.baseBackgroundColor = bg
            cfg.baseForegroundColor = .white
            cfg.cornerStyle = .capsule
            cfg.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
            btn.configuration = cfg
            btn.snp.makeConstraints { $0.height.equalTo(46) }
            return btn
        }

        // ========================================
        // 1️⃣ 基础倒计时（控制台打印）
        // ========================================
        addTitle("1️⃣ 基础 60s（控制台打印）")
        let b1 = makeFilled("获取验证码", .systemBlue)
        b1.byCountdown { cfg in
            cfg.mode = .down(from: 60)
            cfg.renderConfiguration = { sec, base in
                var c = base
                c.title = "重新发送(\(sec)s)"
                return c
            }
            cfg.onTick = { _, _, sec in
                print("🕒 倒计时运行中: \(sec)s")
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b1)

        // ========================================
        // 2️⃣ 每秒闪烁（背景交替颜色）
        // ========================================
        addTitle("2️⃣ 每秒换色闪烁")
        let b2 = makeFilled("开始闪烁倒计时", .systemTeal)
        b2.byCountdown { cfg in
            cfg.mode = .down(from: 20)
            cfg.renderConfiguration = { sec, base in
                var c = base
                c.title = "闪烁 \(sec)s"
                // ✅ 交替颜色
                c.baseBackgroundColor = (sec % 2 == 0) ? .systemTeal : .systemBlue
                return c
            }
            cfg.onTick = { _, _, sec in
                print("💡 闪烁中：\(sec)")
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b2)

        // ========================================
        // 3️⃣ 0.5s 间隔上数
        // ========================================
        addTitle("3️⃣ 上数到 10（0.5s 间隔）")
        let b3 = makeFilled("0.5s 起步", .systemGreen)
        b3.byCountdown { cfg in
            cfg.mode = .up(to: 10)
            cfg.interval = 0.5
            cfg.renderConfiguration = { sec, base in
                var c = base
                c.title = "进度 \(sec)/10"
                return c
            }
            cfg.onTick = { _, _, sec in
                print("⚡️ 进度: \(sec)/10")
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b3)

        // ========================================
        // 4️⃣ renderOnInit
        // ========================================
        addTitle("4️⃣ 进入即渲染（renderOnInit）")
        let b4 = makeFilled("进入已显示", .systemIndigo)
        b4.byCountdown { cfg in
            cfg.mode = .down(from: 10)
            cfg.renderOnInit = true
            cfg.renderConfiguration = { sec, base in
                var c = base
                c.title = "剩余 \(sec)s"
                return c
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b4)

        // ========================================
        // 5️⃣ 富文本标题（JobsRichText）
        // ========================================
        addTitle("5️⃣ 富文本标题（JobsRichText）")
        let b5 = makeFilled("富文本倒计时", .systemPurple)
        b5.byCountdown { cfg in
            cfg.mode = .down(from: 15)
            cfg.renderConfiguration = { sec, base in
                var c = base

                // 段落样式
                let ps = jobsMakeParagraphStyle {
                    $0.alignment = .center
                    $0.lineSpacing = 1.5
                }

                // 富文本片段
                let runs: [JobsRichRun] = [
                    JobsRichRun(.text("剩余 "))
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .color(.systemBlue),

                    JobsRichRun(.text("\(sec)"))
                        .font(.monospacedDigitSystemFont(ofSize: 16, weight: .bold))
                        .color(.systemBlue)
                        .underline(.single, color: .systemBlue),

                    JobsRichRun(.text(" s"))
                        .font(.systemFont(ofSize: 16))
                        .color(.systemBlue)
                ]

                let ns = JobsRichText.make(runs, paragraphStyle: ps)
                c.title = nil
                c.attributedTitle = AttributedString(ns)
                return c
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b5)

        // ========================================
        // 6️⃣ 图标附件 + 文本富文本
        // ========================================
        addTitle("6️⃣ 附件 + 文本富文本")
        let b6 = makeFilled("附件说明", .systemPink)
        b6.byCountdown { cfg in
            cfg.mode = .down(from: 8)
            cfg.renderConfiguration = { sec, base in
                var c = base
                let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
                let image = UIImage(systemName: "paperclip", withConfiguration: config)!
                let att = jobsMakeTextAttachment { $0.image = image }

                let runs: [JobsRichRun] = [
                    JobsRichRun(.attachment(att, CGSize(width: 14, height: 14))),
                    JobsRichRun(.text(" 附件 \(sec)s"))
                        .font(.systemFont(ofSize: 14))
                        .color(.white)
                ]

                let ps = jobsMakeParagraphStyle { $0.alignment = .center }
                let ns = JobsRichText.make(runs, paragraphStyle: ps)

                c.title = nil
                c.attributedTitle = AttributedString(ns)
                return c
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b6)

        // ========================================
        // 7️⃣ 运行中允许点击（弹 Toast）
        // ========================================
        addTitle("7️⃣ 运行中允许点击（弹 Toast 提示）")
        let b7 = makeFilled("运行可点", .systemOrange)
        b7.byCountdown { cfg in
            cfg.mode = .down(from: 12)
            cfg.clickableWhileRunning = true // ✅ 允许点击
            cfg.onTapWhileRunning = { btn, _ in
                // ✅ 弹 Toast
                let alert = UIAlertController(title: nil,
                                              message: "运行中被点击！",
                                              preferredStyle: .alert)
                btn.jobsNearestVC()?.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    alert.dismiss(animated: true)
                }
            }
            cfg.renderConfiguration = { sec, base in
                var c = base
                c.title = "可点 \(sec)s"
                return c
            }
        }.byCountdownOnTapAuto()
        content.addArrangedSubview(b7)
    }
}
