//
//  SafetyPresentDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 2025/09/30.
//

import UIKit
import SnapKit
// MARK: - Demo 页面
final class SafetyPresentDemoVC: UIViewController {
    // MARK: - UI
    private let stack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .center
    }
    /// 半屏高度（可按需改）
    private let halfHeight: CGFloat = 320
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🧱 Safety Present Demo"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        // 1️⃣ 系统 present 按钮（会触发我们 swizzle 的逻辑）
        let btn1 = UIButton(type: .system)
        btn1.setTitle("系统 present (连点不会重复)", for: .normal)
        btn1.addTarget(self, action: #selector(onSystemPresent), for: .touchUpInside)
        stack.addArrangedSubview(btn1)
        // 2️⃣ 从 UIView 内触发 presentSafely
        let demoView = DemoInnerPresentView()
        demoView.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        demoView.layer.cornerRadius = 8
        demoView.snp.makeConstraints { make in
            make.width.equalTo(260)
            make.height.equalTo(60)
        }
        stack.addArrangedSubview(demoView)

        let tip = UILabel()
        tip.text = "👆 点击绿色区域也会触发 presentSafely"
        tip.textColor = .secondaryLabel
        tip.font = .systemFont(ofSize: 14)
        stack.addArrangedSubview(tip)

        // 3️⃣ 新增入口：自定义高度 present
        let btn2 = UIButton(type: .system)
        btn2.setTitle("自定义高度 present (320)", for: .normal)
        btn2.addTarget(self, action: #selector(onCustomHeightPresent), for: .touchUpInside)
        stack.addArrangedSubview(btn2)
    }
    // MARK: - Actions
    /// 系统 present：直接调用系统 API（可能被你的 present 安全防抖 swizzle 接管）
    @objc private func onSystemPresent() {
//        let vc = DemoDetailVC()
//        present(vc, animated: true, completion: nil)
        DemoDetailVC()
            .byData(3.14)// 基本数据类型
            .onResult { name in
                print("回来了 \(name)")
            }
            .byPresent(self)
    }
    /// 自定义高度 present：.custom + UIPresentationController
    /// .custom 之后，系统不会给你装手势 → 需要自己加 pan + 交互式转场（上面已给补丁）。
    /// 想省事且 iOS 15+ → 用 .pageSheet + detents，系统自带手势。
    @objc private func onCustomHeightPresent() {
        HalfSheetDemoVC()
            .byModalPresentationStyle(.custom)
            .byTransitioningDelegate(self)
            .byData(["大树","小草","太阳"])
            .onResult { id in
                print("回来了 \(id)")
            }
            .byPresent(self)           // 自带防重入，连点不重复
    }
}
// MARK: - UIResponder 内触发 presentVC 示例（保持不变）
final class DemoInnerPresentView: UIView {
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "👉 点我 (View 内触发 presentSafely)"
        lbl.textAlignment = .center
        lbl.textColor = .systemGreen
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onTap() {
        // 这里仍然使用你项目里的 presentVC() / presentSafely()（定义在 UIResponder 的扩展中）
        DemoDetailVC()
            .byData("Jobs")// 字符串
            .onResult { name in
                print("回来了 \(name)")
            }
            .byPresent(self)           // 自带防重入，连点不重复
    }
}
// MARK: - 自定义 PresentationController（控制高度/位置/遮罩）
final class HalfSheetPresentationController: UIPresentationController {
    private let height: CGFloat
    private lazy var dimmingView: UIView = {
        let v = UIView(frame: containerView?.bounds ?? .zero)
        v.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        v.alpha = 0
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDim)))
        return v
    }()

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         height: CGFloat) {
        self.height = height
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        let y = container.bounds.height - height
        return CGRect(x: 0, y: max(0, y), width: container.bounds.width, height: min(container.bounds.height, height))
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView else { return }
        dimmingView.frame = container.bounds
        container.addSubview(dimmingView)

        // 跟随系统转场动画
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    @objc private func onTapDim() {
        presentedViewController.dismiss(animated: true)
    }
}
// MARK: - UIViewControllerTransitioningDelegate
extension SafetyPresentDemoVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return HalfSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: halfHeight
        )
    }
}
