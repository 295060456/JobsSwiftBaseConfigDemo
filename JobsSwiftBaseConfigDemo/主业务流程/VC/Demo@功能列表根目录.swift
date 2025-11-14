//
//  RootListVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/29/25.
//

import UIKit
import GKNavigationBarSwift

final class RootListVC: BaseVC {

    private var langToken: NSObjectProtocol?

    deinit {
        suspendBtn.stopTimer()
        suspendSpinBtn.stopTimer()
    }
    private func makeDemos() -> [(title: String, vcType: UIViewController.Type)] {
        return [
            ("ViewController", ViewController.self),
            ("✍️ UITextField", UITextFieldDemoVC.self),
            ("✍️ UITextView", UITextViewDemoVC.self),
            ("📌 自定义注解", 自定义注解Demo.self),
            ("🍚 选择器", BRPickerDemoVC.self),
            ("🔥", EditProfileDemoVC.self),
            ("📅 日历", LunarDemoVC.self),
            ("📊 Excel", XLSXDemoVC.self),
            ("🌘 滚动留言", LiveCommentDemoVC.self),
            ("🌹 弹出方式", SwiftEntryKitDemoVC.self),
            ("🔽 下拉三角小菜单", FSPopoverDemoVC.self),
            ("☠️ 骨架屏", SkeletonViewDemoVC.self),
            ("🏠 首页联动", CashbackRootVC.self),
            ("🌛 PDF", PDFDemoVC.self),
            ("🧒 Lottie动画", LottieDemoVC.self),
            ("🌋 富文本", RichTextDemoVC.self),
            ("🌋 普通文本和富文本的融合数据类型", JobsTextDemoVC.self),
            ("🌍 JobsTabBarCtrl", TabBarDemoVC.self),
            ("📷 鉴权后调用相机/相册", PhotoAlbumDemoVC.self),
            ("🛢️ 解码", SafeCodableDemoVC.self),
            ("🔘 按钮", UIButtonDemoVC.self),
            ("🔑 注册登录".tr, JobsAppDoorDemoVC.self), // 👈 这里需要 .tr
            ("🛜 Moya网络请求框架", MoyaDemoVC.self),
            ("🛜 Alamofire网络请求框架", AFDemoVC.self),
            ("🧹 支持左右上下刷新", JobsRefresherDemoVC.self),
            ("🧧 TraitChange", TraitChangeDemoVC.self),
            ("⛑️ 支持上下左右安全Push和原路返回", SafetyPushDemoVC.self),
            ("⛑️ 安全Present", SafetyPresentDemoVC.self),
            ("📹 播放器@BMPlayer", BMPlayerDemoVC.self),
            ("📹 播放器@PNPlayer", PNPlayerDemoVC.self),
            ("❄️ 雪花算法", SnowflakeDemoVC.self),
            ("💬 LiveChat", LiveChatDemoVC.self),
            ("🗄️ UITableView", EmptyTableViewDemoVC.self),
            ("🗄️ UICollectionView", EmptyCollectionViewDemoVC.self),
            ("🐎 跑马灯/🛞 轮播图", JobsMarqueeDemoVC.self),
            ("🐎 二维码/条形码", QRCodeDemoVC.self),
            ("🌞 BaseWebView", BaseWebViewDemoVC.self),
            ("💥 JobsCountdown", JobsCountdownDemoVC.self),
            ("⏰ Timer", TimerDemoVC.self),
            ("⌨️ 键盘", KeyboardDemoVC.self),
            ("🕹️ ControlEvents", JobsControlEventsDemoVC.self),
            ("🏞️ 图片加载", PicLoadDemoVC.self),
            ("👮 中国大陆公民身份证号码校验", CNIDDemoVC.self),
            ("🏷️ Toast", ToastDemoVC.self),
            ("⚠️ 系统的弹出框", UIAlertDemoVC.self),
            ("🚀 JobsOpen", JobsOpenDemoVC.self),
        ]
    }
    private lazy var demos: [(title: String, vcType: UIViewController.Type)] = makeDemos()
    private lazy var suspendLab: UILabel = {
        UILabel()
            .byText("VIP")
            .byTextColor(.yellow)
            .byFont(.boldSystemFont(ofSize: 14))
            .byTextAlignment(.center)
            .byBgCor(.systemRed)
            .byCornerRadius(12)
            .byMasksToBounds(true)
            .byUserInteractionEnabled(true)
            .suspend(
                .default
                    .byContainer(view)
                    .byFallbackSize(CGSize(width: 88, height: 44))
                    .byStart(.point(CGPoint(x: 100, y: 200))) // 起始点
                    .byHapticOnDock(true)
            )
    }()

    private lazy var suspendBtn: UIButton = {
        UIButton(type: .system)
            .byTitle("开始", for: .normal)
            .byTitleFont(.systemFont(ofSize: 22, weight: .bold))
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemBlue, for: .normal)
            .byCornerRadius(10)
            .byMasksToBounds(true)
            .startTimer(total: nil,
                        interval: 1.0,
                        kind: .gcd)
            // 每 tick：更新时间 & 最近触发时间
            .onTimerTick { [weak self] btn, elapsed, _, kind in
                guard let self else { return }
                if btn.title(for: .normal) != "VIP" {
                    btn.byTitle("VIP", for: .normal)
                }
                btn.bySubTitle(nowClock(), for: .normal)
                btn.bySetNeedsUpdateConfiguration()
            }
            .onLongPress(minimumPressDuration: 0.8) { btn, gr in
//                if gr.state == .began { btn.alpha = 0.6 }
//                else if gr.state == .ended || gr.state == .cancelled { btn.alpha = 1.0 }
                toastBy("长按了悬浮按钮")
            }
            // 点击开始：不传 total => 正计时
            .onTap { [weak self] btn in
                guard let self else { return }
                toastBy("点击了悬浮按钮")
//                btn.startTimer(total: nil,
//                               interval: 1.0,
//                               kind: .gcd)
            }
            .bySuspend { cfg in
                cfg
                    .byContainer(view)
//                    .byStart(.topLeft)
                    .byStart(.point(CGPoint(x: 0, y: 200))) // 起始点（可用区域坐标）
                    .byFallbackSize(CGSize(width: 90, height: 50))
                    .byDocking(.nearestEdge)
                    .byHapticOnDock(true)
            }
    }()

    private lazy var suspendSpinBtn: UIButton = {
        UIButton(type: .system)
            .byTitle("0", for: .normal) // 中间数字：秒
            .byTitleFont(.systemFont(ofSize: 22, weight: .bold))
            .byTitleColor(.white, for: .normal)
            .byBackgroundColor(.systemOrange, for: .normal)
            .byCornerRadius(25)
            .byMasksToBounds(true)

            // 正计时：每秒触发一次
            .startTimer(total: nil, interval: 1.0, kind: .gcd)

            // 每 tick：更新中心数字
            .onTimerTick { [weak self] btn, elapsed, _, _ in
                guard let _ = self else { return }
                let sec = Int(elapsed)             // 累计秒
                // 只有变化时才刷新，避免不必要的重绘
                if btn.title(for: .normal) != "\(sec)" {
                    btn.byTitle("\(sec)", for: .normal)
                        .bySetNeedsUpdateConfiguration()
                }
            }
            // 长按：原逻辑
            .onLongPress(minimumPressDuration: 0.8) { btn, _ in
                toastBy("长按了悬浮按钮")
            }
            // 点击：保持原来的 Toast（不改动计时逻辑）
            .onTap { [weak self] btn in
                guard let _ = self else { return }
                btn.playTapBounce(haptic: .light)  // 👈 临时放大→回弹（不注册任何手势/事件）
                if btn.jobs_isSpinning {
                    // 暂停旋转
                    btn.bySpinPause()
                    // 暂停计时（保留已累计秒，不重置）
                    btn.timer?.pause()        // ✅ 推荐：你的统一内核挂在 button.timer 上
                    // 如果你有封装方法，则用：btn.pauseTimer()
                    toastBy("已暂停旋转 & 计时")
                } else {
                    // 恢复旋转
                    btn.bySpinStart()
                    // 恢复计时（从暂停处继续累加）
                    btn.timer?.resume()       // ✅ 推荐
                    // 如果你有封装方法，则用：btn.resumeTimer()
                    toastBy("继续旋转 & 计时")
                }
            }
            // 悬浮配置
            .bySuspend { cfg in
                cfg
                    .byContainer(view)
//                    .byStart(.bottomRight)
                    .byStart(.point(CGPoint(x: Screen.width - 60, y: Screen.height - 100))) // 起始点（可用区域坐标）
                    .byFallbackSize(CGSize(width: 50, height: 50))
                    .byHapticOnDock(true)
            }
    }()

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UITableViewCell.self)
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()
            .byContentInset(UIEdgeInsets(
                top: UIApplication.jobsSafeTopInset + 30,
                left: 0,
                bottom: 0,
                right: 0
            ))
            .byAddTo(view) { make in
                make.edges.equalToSuperview()
            }
    }()
    // 防抖标记
    private var isPullRefreshing = false
    private var isLoadingMore    = false

    override func loadView() {
        super.loadView()
        // 监听后续切换
        langToken = NotificationCenter.default.addObserver(
            forName: .JobsLanguageDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            // 如有列表
            (self.view as? UITableView)?.reloadData()
            // 或者你有 tableView / collectionView 成员：
            // self.tableView.reloadData()
            // self.collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "Demo 列表",
            leftButton:UIButton.sys()
                .byFrame(CGRect(x: 0, y: 0, width: 32.w, height: 32.h))
                /// 按钮图片@图文关系
                .byImage("list.bullet".sysImg, for: .normal)
                .byImage("list.bullet".sysImg, for: .selected)
                /// 事件触发@点按
                .onTap { sender in
                    sender.isSelected.toggle()
                    debugOnly {  // 仅 Debug 执行
                        toastBy("点按了列表按钮")
                    }
                }
                /// 事件触发@长按
                .onLongPress(minimumPressDuration: 0.8) { btn, gr in
                     if gr.state == .began {
                         btn.alpha = 0.6
                         print("长按开始 on \(btn)")
                     } else if gr.state == .ended || gr.state == .cancelled {
                         btn.alpha = 1.0
                         print("长按结束")
                     }
                },
            rightButtons: [
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("moon.circle.fill".sysImg, for: .normal)
                    .byImage("moon.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { sender in
                        sender.isSelected.toggle()
                        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let win = ws.windows.first else { return }
                        win.overrideUserInterfaceStyle =
                            (win.overrideUserInterfaceStyle == .dark) ? .light : .dark
                        print("🌓 主题已切换 -> \(win.overrideUserInterfaceStyle == .dark ? "Dark" : "Light")")
                    },
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("globe".sysImg, for: .normal)
                    .byImage("globe".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        let to = (LanguageManager.shared.currentLanguageCode == "zh-Hans") ? "en" : "zh-Hans"
                        LanguageManager.shared.switchTo(to)
//                        var s = "🔑 注册登录".tr
                        demos = makeDemos()
                        tableView.reloadData()
                        print("🌐 切换语言 tapped（占位）")
                    },
                UIButton.sys()
                    /// 按钮图片@图文关系
                    .byImage("stop.circle.fill".sysImg, for: .normal)
                    .byImage("stop.circle.fill".sysImg, for: .selected)
                    /// 事件触发@点按
                    .onTap { [weak self] sender in
                        guard let self else { return }
                        sender.isSelected.toggle()
                        print("🛑 手动停止刷新")
                        isPullRefreshing = false
                        isLoadingMore    = false
                    }
            ]
        )
        tableView.byAlpha(1)
        updateFooterAvailability()
//        suspendLab.byAlpha(1)
        suspendSpinBtn.bySpinStart()
        suspendBtn.byVisible(YES)
    }
    // MARK: - Footer 自动显隐逻辑
    private func updateFooterAvailability() {
        tableView.layoutIfNeeded()
        let contentH = tableView.contentSize.height
        let visibleH = tableView.bounds.height 
            - tableView.adjustedContentInset.top
            - tableView.adjustedContentInset.bottom
        let enableLoadMore = contentH > visibleH + 20

        tableView.mj_footer?.isHidden = !enableLoadMore
        if !enableLoadMore {
            /// TODO
        }
    }

    func _langSanityCheck() {
        print("== BEFORE ==")
        print(TRLang.bundle().bundlePath)
        print("🔑 =", "🔑 注册登录".tr)

        LanguageManager.shared.switchTo("en") // 异步；加个小延时观察
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            print("== AFTER en ==")
            print(TRLang.bundle().bundlePath)
            print("🔑 =", "🔑 注册登录".tr)

            LanguageManager.shared.switchTo("zh-Hans")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                print("== AFTER zh-Hans ==")
                print(TRLang.bundle().bundlePath)
                print("🔑 =", "🔑 注册登录".tr)
            }
        }
    }
}
// MARK: - DataSource & Delegate
extension RootListVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            .byText(demos[indexPath.row].title)
            .byAccessoryType(.disclosureIndicator)
    }
}

extension RootListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        demos[indexPath.row].vcType.init().byPush(self)
    }
}

extension RootListVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFooterAvailability()
    }
}
