//
//  JobsCountdownDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/9/30.
//

import UIKit
import SnapKit

final class JobsCountdownDemoVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "倒计时按钮"
        )
        if #available(iOS 15.0, *) {
            title1Label.byVisible(YES)
            button1Basic.byVisible(YES)

            title2Label.byVisible(YES)
            button2Flash.byVisible(YES)

            title3Label.byVisible(YES)
            button3Up.byVisible(YES)

            title4Label.byVisible(YES)
            button4RenderOnInit.byVisible(YES)

            title5Label.byVisible(YES)
            button5RichText.byVisible(YES)

            title6Label.byVisible(YES)
            button6Attachment.byVisible(YES)

            title7Label.byVisible(YES)
            button7Tappable.byVisible(YES)
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
    /// 外层滚动视图
    private lazy var scrollView: UIScrollView = { [unowned self] in
        UIScrollView()
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10)
                make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            }
    }()
    /// 内容容器，用来放所有标题和按钮
    private lazy var contentView: UIView = { [unowned self] in
        UIView()
            .byAddTo(scrollView) { [unowned self] make in
                make.edges.equalToSuperview()
                make.width.equalTo(scrollView.snp.width)
            }
    }()
    // MARK: - 1️⃣ 基础 60s（控制台打印）
    @available(iOS 15.0, *)
    private lazy var title1Label: UILabel = { [unowned self] in
        UILabel().byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("1️⃣ 基础 60s（控制台打印）")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(contentView.snp.top).offset(20)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button1Basic: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemBlue, for: .normal)
            .byTitle("获取验证码", for: .normal)
            .byTitle("获取验证码", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
                cfg.mode = .down(from: 60)
                cfg.renderConfiguration = { sec, base in
                    var c = base
                    c.title = "重新发送(\(sec)s)"
                    return c
                }
                cfg.onTick = { _, _, sec in
                    print("🕒 倒计时运行中: \(sec)s")
                }
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title1Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
            }
    }()
    // MARK: - 2️⃣ 每秒闪烁（背景交替颜色）
    @available(iOS 15.0, *)
    private lazy var title2Label: UILabel = { [unowned self] in
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("2️⃣ 每秒换色闪烁")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(button1Basic.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button2Flash: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemTeal, for: .normal)
            .byTitle("开始闪烁倒计时", for: .normal)
            .byTitle("开始闪烁倒计时", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
                cfg.mode = .down(from: 20)
                cfg.renderConfiguration = { sec, base in
                    var c = base
                    c.title = "闪烁 \(sec)s"
                    c.baseBackgroundColor = (sec % 2 == 0) ? .systemTeal : .systemBlue
                    return c
                }
                cfg.onTick = { _, _, sec in
                    print("💡 闪烁中：\(sec)")
                }
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title2Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
            }
    }()
    // MARK: - 3️⃣ 0.5s 间隔上数
    @available(iOS 15.0, *)
    private lazy var title3Label: UILabel = { [unowned self] in
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("3️⃣ 上数到 10（0.5s 间隔）")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(button2Flash.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button3Up: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("0.5s 起步", for: .normal)
            .byTitle("0.5s 起步", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
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
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title3Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
            }
    }()
    // MARK: - 4️⃣ 进入即渲染（renderOnInit）
    @available(iOS 15.0, *)
    private lazy var title4Label: UILabel = { [unowned self] in
        UILabel().byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("4️⃣ 进入即渲染（renderOnInit）")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(button3Up.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button4RenderOnInit: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemIndigo, for: .normal)
            .byTitle("进入已显示", for: .normal)
            .byTitle("进入已显示", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
                cfg.mode = .down(from: 10)
                cfg.renderOnInit = true
                cfg.renderConfiguration = { sec, base in
                    var c = base
                    c.title = "剩余 \(sec)s"
                    return c
                }
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title4Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
            }
    }()
    // MARK: - 5️⃣ 富文本标题（JobsRichText）
    @available(iOS 15.0, *)
    private lazy var title5Label: UILabel = { [unowned self] in
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("5️⃣ 富文本标题（JobsRichText）")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(button4RenderOnInit.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button5RichText: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemPurple, for: .normal)
            .byTitle("富文本倒计时", for: .normal)
            .byTitle("富文本倒计时", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
                cfg.mode = .down(from: 15)
                cfg.renderConfiguration = { sec, base in
                    var c = base

                    let ps = jobsMakeParagraphStyle {
                        $0.alignment = .center
                        $0.lineSpacing = 1.5
                    }

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
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title5Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
            }
    }()
    // MARK: - 6️⃣ 图标附件 + 文本富文本
    @available(iOS 15.0, *)
    private lazy var title6Label: UILabel = { [unowned self] in
        UILabel()
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("6️⃣ 附件 + 文本富文本")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(button5RichText.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button6Attachment: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemPink, for: .normal)
            .byTitle("附件说明", for: .normal)
            .byTitle("附件说明", for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
                cfg.mode = .down(from: 8)
                cfg.renderConfiguration = { sec, base in
                    var c = base
                    let att = jobsMakeTextAttachment {
                        $0.image = "paperclip".sysImg(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
                    }

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
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title6Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
            }
    }()
    // MARK: - 7️⃣ 运行中允许点击（弹 Toast 提示）
    @available(iOS 15.0, *)
    private lazy var title7Label: UILabel = { [unowned self] in
        UILabel().byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byText("7️⃣ 运行中允许点击（弹 Toast 提示）")
            .byTextColor(.secondaryLabel)
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(button6Attachment.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(24)
            }
    }()

    @available(iOS 15.0, *)
    private lazy var button7Tappable: UIButton = { [unowned self] in
        UIButton.sys()
            .byBackgroundColor(.systemOrange, for: .normal)
            .byTitle("运行可点".tr, for: .normal)
            .byTitle("运行可点".tr, for: .selected)
            .byTitleColor(.white, for: .normal)
            .byTitleColor(.white, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byCountdown { cfg in
                cfg.mode = .down(from: 12)
                cfg.clickableWhileRunning = true
                cfg.onTapWhileRunning = { btn, _ in
                    "运行中被点击！".toast
                }
                cfg.renderConfiguration = { sec, base in
                    var c = base
                    c.title = "可点 \(sec)s"
                    return c
                }
            }
            .byCountdownOnTapAuto()
            .byAddTo(contentView) { [unowned self] make in
                make.top.equalTo(title7Label.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(46)
                // 最后一个顺便把 contentView 的 bottom 撑开，保证 Scroll 正常滚动
                make.bottom.equalTo(contentView.snp.bottom).offset(-24)
            }
    }()
}
