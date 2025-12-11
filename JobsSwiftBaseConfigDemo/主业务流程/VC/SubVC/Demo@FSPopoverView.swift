//
//  Demo@FSPopoverView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/11/12.
//

import UIKit
import SnapKit
import FSPopoverView
/// FSPopoverView Demo（链式 by-DSL 写法 + 约束写在懒加载里的 byAddTo）
/// - 展示：
///   1) 列表弹窗（FSPopoverListView）
///   2) 自定义内容（FSPopoverViewDataSource）
///   3) 从 UIBarButtonItem 与 任意 view 的 rect 弹出
final class FSPopoverDemoVC: BaseVC {
    // MARK: - UI（by-DSL + 约束在 byAddTo 内）
    private lazy var exampleButton: UIButton = {
        let b = UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("显示列表 ▶︎", for: .normal)
            .byTitle("隐藏", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byImage(UIImage(systemName: "list.bullet"), for: .normal)
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .onTap { [weak self] _ in
                self?.showListFromRect()
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(40)
                } else {
                    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
                }
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }

        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("从按钮处弹出列表")
                 .byBaseForegroundCor(.white)
                 .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                 .byCornerStyle(.large)
                 .byImagePlacement(.trailing)
                 .byImagePadding(8)
            }
        }
        return b
    }()

    private lazy var customButton: UIButton = {
        let b = UIButton.sys()
            .byBackgroundColor(.systemIndigo, for: .normal)
            .byTitle("从右上角弹出【自定义内容】 ▶︎", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
            .byImage(UIImage(systemName: "sparkles"), for: .normal)
            .byTitleEdgeInsets(.init(top: 0, left: 8, bottom: 0, right: -8))
            .onTap { [weak self] _ in
                self?.showCustomFromBarItem()
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.exampleButton.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(44)
            }

        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byBaseForegroundCor(.white)
                 .byImagePlacement(.trailing)
                 .byImagePadding(8)
            }
        };return b
    }()

    private lazy var btn: UIButton = {
        UIButton.sys()
            /// 按钮图片@图文关系
            .byImage("ellipsis.circle".sysImg, for: .normal)
            .byImage("moon.circle.fill".sysImg, for: .selected)
            /// 事件触发@点按
            .onTap { [weak self] sender in
                guard let self else { return }
                sender.isSelected.toggle()
                let listView = FSPopoverListView()
                listView.items = makeDemoItems()
                listView.present(fromView: btn)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(
            title: "Demo@FSPopoverView",
            rightButtons: [btn]
        )
        view.byBgColor(.systemBackground)
        // 全局外观（如不需要，可移除）
        let ap = FSPopoverView.fs_appearance()
        ap.showsArrow = true
        ap.showsDimBackground = true
    }
    /// 从按钮的 rect 弹出 列表
    private func showListFromRect() {
        let listView = FSPopoverListView()
        listView.items = makeDemoItems()
        listView.present(fromRect: exampleButton.convert(exampleButton.bounds, to: view), in: view)
    }
    /// 从 BarItem 弹出 自定义内容
    private func showCustomFromBarItem() {
        let p = FSPopoverView()
        p.dataSource = self
        p.present(fromView: btn)
    }
    // MARK: - 列表项
    private func makeDemoItems() -> [FSPopoverListItem] {
        enum Feature: CaseIterable {
            case copy, message, database, qr, settings
            var title: String {
                switch self {
                case .copy: return "复制"
                case .message: return "消息"
                case .database: return "数据库"
                case .qr: return "二维码"
                case .settings: return "设置"
                }
            }
            var image: UIImage? {
                switch self {
                case .copy: return "doc.on.doc".sysImg
                case .message: return "bubble.left.and.bubble.right".sysImg
                case .database: return "externaldrive".sysImg
                case .qr: return "qrcode".sysImg
                case .settings: return "gearshape".sysImg
                }
            }
        }

        let items: [FSPopoverListItem] = Feature.allCases.map { f in
            let it = FSPopoverListTextItem()
            it.image = f.image
            it.title = f.title
            it.isSeparatorHidden = false
            it.selectedHandler = { item in
                guard let i = item as? FSPopoverListTextItem else { return }
                ("点击：\(i.title ?? "")").toast
            }
            it.updateLayout()
            return it
        }
        items.last?.isSeparatorHidden = true
        return items
    }
}
// MARK: - FSPopoverViewDataSource（自定义内容）
extension FSPopoverDemoVC: FSPopoverViewDataSource {
    /// 背景（毛玻璃 + 圆角）
    func backgroundView(for popoverView: FSPopoverView) -> UIView? {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial)).byCornerRadius(12).byMasksToBounds(YES)
    }
    /// 内容
    func contentView(for popoverView: FSPopoverView) -> UIView? {
        let container = UIView().byBgColor(.clear)
        let title = UILabel()
            .byText("这是自定义内容")
            .byFont(.boldSystemFont(ofSize: 16))
            .byTextAlignment(.center)
            .byAddTo(container) { make in
                make.top.equalToSuperview().offset(14)
                make.left.right.equalToSuperview().inset(16)
            }

        UIButton.sys()
            .byTitle("我知道了", for: .normal)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .onTap { [weak self] _ in
                // 自定义：点按钮关闭（库会处理 dismiss）
                self?.dismiss(animated: true)
            }
            .byAddTo(container) { make in
                make.top.equalTo(title.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(14)
            }.byVisible(YES)

        return container
    }
    /// 固定内容尺寸
    func contentSize(for popoverView: FSPopoverView) -> CGSize {
        .init(width: 240, height: 110)
    }
    /// 容器安全区
    func containerSafeAreaInsets(for popoverView: FSPopoverView) -> UIEdgeInsets {
        view.safeAreaInsets
    }
    /// 点击外部关闭
    func popoverViewShouldDismissOnTapOutside(_ popoverView: FSPopoverView) -> Bool {
        true
    }
}
