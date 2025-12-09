//JobsAppDoorDemoVC
//  JobsAppDoorDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  保持与 OC 动画“平行”的 Swift 实现：
//  - 视频当底（BMPlayer，循环，fill）
//  - 居中弹窗进场：① 圆形揭示 ② 弹性放大（二选一）
//  - 登录 / 注册 面板切换：轻透视 + 位移/缩放 + keyframe
//

import UIKit
import SnapKit
import BMPlayer
import AVFoundation
// MARK: - 小工具
private extension CATransform3D {
    static func m34(_ v: CGFloat) -> CATransform3D { var t = CATransform3DIdentity; t.m34 = v; return t }
}
private extension UIView {
    /// 给容器加一点透视（越小越夸张，-1/800 ~ -1/500 之间比较自然）
    func enablePerspective(_ m34: CGFloat = -1/800) { layer.sublayerTransform = .m34(m34) }
}
// MARK: - Demo
final class JobsAppDoorDemoVC: BaseVC {
    deinit {
        if let o = loopObserver { NotificationCenter.default.removeObserver(o) }
    }
    // MARK: 模型
    private enum PanelKind { case login, register }
    private enum EntranceStyle {
        case circularReveal(from: CGPoint, startRadius: CGFloat)   // 从一个小点炸开
        case springPop                                              // 弹性放大
    }
    // 当前展示的面板
    private var current: PanelKind = .login
    // MARK: UI
    private lazy var player: BMPlayer = {
        // 注意：把 "welcome_video.mp4" 放到主 bundle
        BMPlayer()
            .byResource(
                BMPlayerResource(
                    name: "welcome_video",
                    definitions: [
                        .init(url: "welcome_video.mp4".bundleMediaURLRequire, definition: "本地")
                    ],
                    cover: nil,
                    subtitles: nil
                ),
                definitionIndex: 0,
                autoPlay: true
            )
            .byVideoGravity(.resizeAspectFill)
            .byPanGestureEnabled(false)
            .byAddTo(view) { make in
                make.edges.equalToSuperview()
            }
    }()
    /// 居中承载面板的容器（加圆角/毛玻璃都可以放这层）
    private lazy var panelHost: UIView = {
        UIView()
            .byBgColor(UIColor(white: 1, alpha: 0.08))
            .byCornerRadius(14)
            .byAlpha(0)
            .byTransform(CGAffineTransform(scaleX: 0.001, y: 0.001)) // 进场起态（春
            .byAddTo(view) { [unowned self] make in
                make.center.equalToSuperview()
                make.width.equalTo(view.snp.width).offset(-100)      // 屏宽-100
                make.height.equalTo(view.snp.height).multipliedBy(0.48)
            }
    }()
    /// 登录面板（把你真实的登录表单塞进来即可）
    private lazy var loginPanel: UIView = {
        UIView()
            .byBgColor(.systemBackground.withAlphaComponent(0.75))
            .byCornerRadius(14)
            .byAddTo(panelHost) { [unowned self] make in
                make.edges.equalToSuperview()
            }
    }()
    /// 注册面板（同理，塞你自己的注册表单）
    private lazy var registerPanel: UIView = {
        UIView()
            .byBgColor(.systemBackground.withAlphaComponent(0.75))
            .byCornerRadius(14)
            .byHidden(YES)
            .byAddTo(panelHost) { [unowned self] make in
                make.edges.equalToSuperview()
            }
    }()
    /// 右下角客服按钮（与 OC 的 alpha 动画保持“平行”）
//    private lazy var customerServiceBtn: UIButton = {
//        UIButton(type: .system)
//            .byTitle("客服", for: .normal)
//            .byTitleFont(.systemFont(ofSize: 16, weight: .semibold))
//            .byBgColor(UIColor.black.withAlphaComponent(0.35))
//            .byCornerRadius(10)
//            .byContentEdgeInsets(.init(top: 8, left: 12, bottom: 8, right: 12))
//            .byAddTo(view) { make in
//                make.right.equalTo(view.safeAreaLayoutGuide).inset(16)
//                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
//            }
//    }()

    private var loopObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        player.byVisible(YES)
        panelHost.byVisible(YES)
        loginPanel.byVisible(YES)
        registerPanel.byVisible(YES)
//        customerServiceBtn.byVisible(YES)
        setupLoopPlayback()
        buildDemoSwitchButtons()   // Demo：顶部切换按钮（替换为你的真实跳转入口即可）
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 选择你要的进场效果（和视频里的“从点炸开”对齐）
        runEntranceAnimation(
            style: .circularReveal(
                from: view.center,     // 也可以传你点击的坐标
                startRadius: 6
            )
        )
        // 如果你更想保守/平行 OC 的 spring:
        // runEntranceAnimation(style: .springPop)
    }
    // MARK: 进场动画
    private func runEntranceAnimation(style: EntranceStyle) {
        // 轻透视（后面切换面板也会用到）
        panelHost.enablePerspective(-1/800)
        switch style {
        case let .circularReveal(from, startRadius):
            view.layoutIfNeeded()

            // 1) 先把整体缩放态复位到 1（不然 mask 看起来会“收缩”）
            panelHost.transform = .identity
            panelHost.alpha = 1

            // 2) 给 panelHost 做圆形揭示 mask
            let local = panelHost.convert(from, from: view)
            let endR = maxDistanceToCorner(from: local, in: panelHost.bounds.size) + 20

            let startPath = UIBezierPath(
                arcCenter: local, radius: startRadius,
                startAngle: 0, endAngle: .pi * 2, clockwise: true
            )

            let endPath = UIBezierPath(
                arcCenter: local, radius: endR,
                startAngle: 0, endAngle: .pi * 2, clockwise: true
            )

            let mask = CAShapeLayer()
            mask.fillColor = UIColor.black.cgColor
            mask.path = endPath.cgPath
            panelHost.layer.mask = mask

            let anim = CABasicAnimation(keyPath: "path")
            anim.fromValue = startPath.cgPath
            anim.toValue = endPath.cgPath
            anim.duration = 0.52
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            mask.add(anim, forKey: "circularReveal")

            // 客服按钮与 OC 保持“渐显”
//            UIView.animate(withDuration: 0.60,
//                           delay: 0.05,
//                           usingSpringWithDamping: 0.85,
//                           initialSpringVelocity: 0.6,
//                           options: [.curveEaseOut]) {
//                self.customerServiceBtn.alpha = 1
//            }
        case .springPop:
            panelHost.alpha = 0
            panelHost.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            UIView.animate(withDuration: 0.50,
                           delay: 0.05,
                           usingSpringWithDamping: 0.82,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut]) {
                self.panelHost.alpha = 1
                self.panelHost.transform = .identity
            }
//            UIView.animate(withDuration: 0.60, delay: 0.10, options: [.curveEaseOut]) {
//                self.customerServiceBtn.alpha = 1
//            }
        }
    }
    /// 计算到四角最远距离（为圆形揭示提供终点半径）
    private func maxDistanceToCorner(from p: CGPoint, in size: CGSize) -> CGFloat {
        [
            CGPoint(x: 0, y: 0),
            CGPoint(x: size.width, y: 0),
            CGPoint(x: 0, y: size.height),
            CGPoint(x: size.width, y: size.height)
        ].map { hypot($0.x - p.x, $0.y - p.y) }.max() ?? 0
    }
    // MARK: 面板切换（与 OC 路数平行：轻 3D + 位移缩放 + 淡入淡出）
    private enum SwitchDirection { case toLeft, toRight }
    private func switchPanel(to target: PanelKind, direction: SwitchDirection) {
        guard target != current else { return }

        let fromView = (current == .login) ? loginPanel : registerPanel
        let toView   = (target == .login) ? loginPanel : registerPanel

        // 起态准备
        toView.alpha = 0
        toView.isHidden = false
        toView.transform = make2DTransform(
            translateX: (direction == .toRight ? panelHost.bounds.width * 0.12 : -panelHost.bounds.width * 0.12),
            scale: 0.96
        )

        // 为了立体感：容器统一加透视（只需设一次，但在这里再设一遍也无伤）
        panelHost.enablePerspective(-1/800)

        let total: TimeInterval = 0.42
        UIView.animateKeyframes(withDuration: total, delay: 0, options: [.calculationModeCubic]) {

            // fromView 退场（轻后退 + 轻缩 + 淡出）
            UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.35) {
                fromView.alpha = 0
                fromView.transform = self.make2DTransform(
                    translateX: (direction == .toRight ? -18 : 18),
                    scale: 0.96
                )
            }

            // toView 进场（从侧面靠近 + 放大到 1 + 淡入）
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75) {
                toView.alpha = 1
                toView.transform = .identity
            }
        } completion: { _ in
            fromView.isHidden = true
            fromView.alpha = 1
            fromView.transform = .identity
            self.current = target

            // 与 OC 一样：非登录页隐藏客服按钮（举例）
            _ = (target == .login)
//            UIView.animate(withDuration: 0.28) {
//                self.customerServiceBtn.alpha = shouldShowService ? 1 : 0
//            }
        }
    }

    private func make2DTransform(translateX: CGFloat, scale: CGFloat) -> CGAffineTransform {
        CGAffineTransform.identity.translatedBy(x: translateX, y: 0).scaledBy(x: scale, y: scale)
    }
    // MARK: 视频循环
    private func setupLoopPlayback() {
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main
        ) { [weak self] _ in
            guard let self, let av = self.player.playerLayer?.player else { return }
            av.seek(to: .zero)
            av.play()
        }
    }
    // MARK: Demo 触发（把它换成你现有按钮/手势）
    private func buildDemoSwitchButtons() {
        let seg = UISegmentedControl(items: ["登录", "注册"])
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(onSeg(_:)), for: .valueChanged)
        view.addSubview(seg)
        seg.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func onSeg(_ s: UISegmentedControl) {
        let target: PanelKind = (s.selectedSegmentIndex == 0) ? .login : .register
        switchPanel(to: target, direction: (target == .login ? .toLeft : .toRight))
    }
}
