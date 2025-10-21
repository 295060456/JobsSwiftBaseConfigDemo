//
//  UIAlertDemo.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/13/25.
//

import UIKit
import SnapKit

final class UIAlertDemoVC: BaseVC {
    // MARK: 最简单的 Alert：主/副标题 + 取消_确定@按钮行为监听 + 中间弹出 + 点击空白区域不可取消
    private lazy var simpleAlertBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("① 简单 Alert")
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .onTap { [weak self] _ in
                guard let self else { return }
                UIAlertController
                    .makeAlert("提示", "这是一条简单提示")
                    .byAddCancel { _ in
                        print("Cancel")
                    }           // 一个回调，只给 action
                    .byAddOK { _ in
                        print("OK")
                    }
                    .byPresent(self)
            }
            .byAddTo(view) {[unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom).offset(10) // 占满
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }
    }()
    // MARK: 主/副标题 + 设置背景图（本地/网络）+ 输入框@监听（输入_删除）回调 + 取消_确定@按钮行为监听 + 中间弹出 + 点击空白区域不可取消
    private lazy var textFieldAlertBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("② 输入框 Alert（读取文本）")
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .onTap { [weak self] _ in
                guard let self else { return }

                UIAlertController
                    .makeAlert("重命名", "请输入新的名称")
//                    .bySDBgImageView("https://picsum.photos/800/600",
//                                     image: "唐老鸭".img,
//                                     hideSystemBackdrop: true)
//                    .byKFBgImageView("https://picsum.photos/800/600",
//                                     image: "唐老鸭".img,
//                                     hideSystemBackdrop: true)
                    .byBgImage("唐老鸭".img)                      // 本地图背景（同步阶段，无动画）
                    .byCardBorder(width: 1, color: .systemBlue)   // 外层卡片描边
                    .byAddTextField(placeholder: "新名称",
                                    borderWidth: nil,             // ← 不给 tf 自身描边
                                    borderColor: nil,
                                    cornerRadius: 8) { alert, tf, input, oldText, isDeleting in
                        let ok = alert.actions.first { $0.title == "确定" }
                        ok?.isEnabled = !(tf.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }
                    .byTextFieldOuterBorder(at: 0, width: 1, color: .systemBlue, cornerRadius: 10, insets: .init(top: 6, left: 12, bottom: 6, right: 12)) // ← 给灰色容器描边
                    .byAddCancel { _ in                          // ✅ 一个回调（只给 action）
                        print("Cancel tapped")
                    }
                    .byAddOK{ alert, _ in                 // 需要 alert + action 的回调
                        let name = alert.textField(at: 0)?.text ?? ""
                        print("new name =", name)
                    }
                    .byTintColor(.systemBlue)
                    .byPresent(self)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(simpleAlertBtn.snp.bottom).offset(12)
                make.left.right.height.equalTo(simpleAlertBtn)
            }
    }()
    // MARK: 主标题 + 相机_相册_取消@按钮行为监听 + 屏幕底部弹出 + 点击空白区域可取消
    private lazy var actionSheetAutoBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("③ ActionSheet（自动锚点）")
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .onTap { [weak self] _ in
                guard let self else { return }
                UIAlertController
                    .makeActionSheet("选择来源", nil)
                    .byAddAction(title: "相机") { _ in
                        print("camera")
                    }
                    .byAddAction(title: "相册") { _ in
                        print("photos")
                    }
                    .byAddCancel { _ in
                        print("Cancel tapped")
                    }
                    .byPresent(self)
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(textFieldAlertBtn.snp.bottom).offset(12)
                make.left.right.height.equalTo(textFieldAlertBtn)
            }
    }()
    // MARK: 主标题 + 删除_取消@按钮行为监听 + 从按钮自身位置（锚点）弹出 + 点击空白区域可取消
    private lazy var actionSheetFromButtonBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("④ 从当前按钮处弹出")
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .onTap { [weak self] sender in
                guard let self else { return }
                UIAlertController
                    .makeActionSheet("操作", nil)
                    .byAddDestructive("删除") { _ in
                        print("delete")
                    }
                    .byAddCancel { _ in
                        print("Cancel tapped")
                    }
                    .byPresent(self, anchor: .view(sender, sender.bounds)) // 指定锚点
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(actionSheetAutoBtn.snp.bottom).offset(12)
                make.left.right.height.equalTo(actionSheetAutoBtn)
            }
    }()
    /// 5) iOS16+ 严重程度 + 首选按钮
    private lazy var severityAlertBtn: UIButton = { [unowned self] in
        UIButton(type: .system)
            .byTitle("⑤ Critical Alert（iOS16+）")
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .onTap { [weak self] _ in
                guard let self else { return }
                if #available(iOS 16.0, *) {
                    UIAlertController
                        .makeAlert("危险操作", "此操作不可撤销")
                        .bySeverity(.critical)
                        .byAddDestructive("删库跑路") { _ in
                            print("boom")
                        }
                        .byAddCancel { _ in
                            print("Cancel tapped")
                        }
                        .byPresent(self)
                } else {
                    UIAlertController
                        .makeAlert("提示", "iOS16 以上才支持 severity")
                        .byAddOK()
                        .byPresent(self)
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(actionSheetFromButtonBtn.snp.bottom).offset(12)
                make.left.right.height.equalTo(actionSheetFromButtonBtn)
            }
    }()
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "系统的弹出框")
        // 触发懒加载（按你的习惯用 .byAlpha(1)）
        simpleAlertBtn.byAlpha(1)
        textFieldAlertBtn.byAlpha(1)
        actionSheetAutoBtn.byAlpha(1)
        actionSheetFromButtonBtn.byAlpha(1)
        severityAlertBtn.byAlpha(1)
    }
}
