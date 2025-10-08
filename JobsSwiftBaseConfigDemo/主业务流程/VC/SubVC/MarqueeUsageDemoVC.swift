//
//  MarqueeUsageDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/08.
//

import UIKit
import SnapKit

final class MarqueeUsageDemoVC: BaseVC {
    private let kSectionSpacing: CGFloat = 12
    private let kDirToControlSpacing: CGFloat = 16

    // MARK: - 跑马灯（4 组）
    /// 1) 主标题 + 富文本
    private lazy var marqueeTitleRich: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.continuous(speed: 40))
            .byContentWrapEnabled(true)                 // 按内容流式滚动
            .byLoopEnabled(true)
            .byGestureScrollEnabled(false)
            .byOnTap { [unowned self] idx, _ in
                Task { @MainActor in
                    JobsToast.show(
                        text: "跑马灯①：点击第 \(idx + 1) 项",
                        config: JobsToast.Config()
                            .byBgColor(.systemGreen.withAlphaComponent(0.9))
                            .byCornerRadius(12)
                    )
                }
            }
            .byItems([
                .init(title: "🔥 爆款", image: UIImage(systemName: "flame.fill"), tip: "爆款"),
                .init(title: "⚡ 速达", image: UIImage(systemName: "bolt.fill"),  tip: "速达"),
                .init(title: "🛒 优惠", image: UIImage(systemName: "cart.fill"),  tip: "优惠")
            ]) { btn, item, _ in
                // 主标题 + 富文本（价格/单位）
                let priceRich = JobsRichText.make([
                    JobsRichRun(.text("¥99")).font(.systemFont(ofSize: 18, weight: .semibold)).color(.systemRed),
                    JobsRichRun(.text(" /月")).font(.systemFont(ofSize: 16)).color(.white)
                ])
                let offRich = JobsRichText.make([
                    JobsRichRun(.text("立减 ")).font(.systemFont(ofSize: 16)).color(.white),
                    JobsRichRun(.text("¥20")).font(.systemFont(ofSize: 18, weight: .semibold)).color(.systemYellow)
                ])
                let rich: NSAttributedString = {
                    if item.title?.contains("爆款") == true {
                        return JobsRichText.make([JobsRichRun(.text("爆款 ")).font(.systemFont(ofSize: 16)).color(.white)]).add(priceRich)
                    } else {
                        return JobsRichText.make([JobsRichRun(.text("特惠 ")).font(.systemFont(ofSize: 16)).color(.white)]).add(offRich)
                    }
                }()
                btn.byRichTitle(rich, for: .normal)
                if #available(iOS 15.0, *) {
                    btn.byConfiguration { c in
                        c.image = item.image
                        c.imagePlacement = .leading
                        c.imagePadding = 8
                        c.baseForegroundColor = .white
                        c.baseBackgroundColor = .systemIndigo
                        c.titleAlignment = .center
                        c.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
                    }
                }
            }
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(52)
            }
    }()

    /// 2) 主标题 + 普通文本
    private lazy var marqueeTitlePlain: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.continuous(speed: 36))
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(false)
            .byOnTap { [unowned self] idx, _ in
                Task { @MainActor in
                    JobsToast.show(
                        text: "跑马灯②：点击第 \(idx + 1) 项",
                        config: JobsToast.Config()
                            .byBgColor(.systemGreen.withAlphaComponent(0.9))
                            .byCornerRadius(12)
                    )
                }
            }
            .byItems([
                .init(title: "新品上线", image: UIImage(systemName: "sparkles")),
                .init(title: "今日特价", image: UIImage(systemName: "tag.fill")),
                .init(title: "人气推荐", image: UIImage(systemName: "hand.thumbsup.fill"))
            ]) { btn, item, _ in
                btn.byTitle(item.title)
                if #available(iOS 15.0, *) {
                    btn.byConfiguration { c in
                        c.image = item.image
                        c.imagePlacement = .leading
                        c.imagePadding = 6
                        c.baseForegroundColor = .white
                        c.baseBackgroundColor = .systemBlue
                        c.titleAlignment = .center
                        c.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
                    }
                }
            }
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.marqueeTitleRich.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(52)
            }
    }()

    /// 3) 主标题 + 副标题（副标题富文本）
    private lazy var marqueeTitleSubRich: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.continuous(speed: 32))
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(false)
            .byOnTap { [unowned self] idx, _ in
                Task { @MainActor in
                    JobsToast.show(
                        text: "跑马灯③：点击第 \(idx + 1) 项",
                        config: JobsToast.Config()
                            .byBgColor(.systemGreen.withAlphaComponent(0.9))
                            .byCornerRadius(12)
                    )
                }
            }
            .byItems([
                .init(title: "Pro 会员", image: UIImage(systemName: "person.crop.circle.badge.checkmark")),
                .init(title: "企业版", image: UIImage(systemName: "building.2.fill")),
                .init(title: "教育版", image: UIImage(systemName: "graduationcap.fill"))
            ]) { btn, _, idx in
                let priceRich = JobsRichText.make([
                    JobsRichRun(.text(idx == 0 ? "¥69" : "¥49"))
                        .font(.systemFont(ofSize: 17, weight: .semibold)).color(.systemYellow),
                    JobsRichRun(.text(" /月")).font(.systemFont(ofSize: 14)).color(.white)
                ])
                btn.byTitle(idx == 0 ? "Pro 会员" : (idx == 1 ? "企业版" : "教育版"))
                btn.byRichSubTitle(priceRich, for: .normal)
                if #available(iOS 15.0, *) {
                    btn.byConfiguration { c in
                        c.image = [UIImage(systemName: "person.crop.circle.badge.checkmark"),
                                   UIImage(systemName: "building.2.fill"),
                                   UIImage(systemName: "graduationcap.fill")][idx]
                        c.imagePlacement = .leading
                        c.imagePadding = 6
                        c.baseForegroundColor = .white
                        c.baseBackgroundColor = .systemPurple
                        c.titleAlignment = .leading
                        c.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)
                    }
                }
            }
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.marqueeTitlePlain.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(60)
            }
    }()

    /// 4) 主标题 + 副标题（副标题普通文本）
    private lazy var marqueeTitleSubPlain: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.continuous(speed: 28))
            .byContentWrapEnabled(true)
            .byLoopEnabled(true)
            .byGestureScrollEnabled(false)
            .byOnTap { [unowned self] idx, _ in
                Task { @MainActor in
                    JobsToast.show(
                        text: "跑马灯④：点击第 \(idx + 1) 项",
                        config: JobsToast.Config()
                            .byBgColor(.systemGreen.withAlphaComponent(0.9))
                            .byCornerRadius(12)
                    )
                }
            }
            .byItems([
                .init(title: "基础版", image: UIImage(systemName: "circle.grid.2x2.fill")),
                .init(title: "增强版", image: UIImage(systemName: "square.stack.3d.up.fill")),
                .init(title: "旗舰版", image: UIImage(systemName: "crown.fill"))
            ]) { btn, _, idx in
                let sub = idx == 0 ? "入门所需" : (idx == 1 ? "更多资源" : "全特性解锁")
                btn.byTitle(idx == 0 ? "基础版" : (idx == 1 ? "增强版" : "旗舰版"))
                btn.bySubTitle(sub, for: .normal)
                if #available(iOS 15.0, *) {
                    btn.byConfiguration { c in
                        c.image = [UIImage(systemName: "circle.grid.2x2.fill"),
                                   UIImage(systemName: "square.stack.3d.up.fill"),
                                   UIImage(systemName: "crown.fill")][idx]
                        c.imagePlacement = .leading
                        c.imagePadding = 6
                        c.baseForegroundColor = .white
                        c.baseBackgroundColor = .systemTeal
                        c.titleAlignment = .leading
                        c.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)
                    }
                }
            }
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.marqueeTitleSubRich.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(60)
            }
    }()

    // MARK: - 跑马灯方向控制（上/下/左/右）
    private lazy var marqueeDirBar: UIStackView = {
        UIStackView()
            .byAxis(.horizontal)
            .byDistribution(.fillEqually)
            .bySpacing(8)
            .byAddArrangedSubviews([
                dirBtn("上") { [unowned self] in setMarqueeDirection(.up)   },
                dirBtn("下") { [unowned self] in setMarqueeDirection(.down) },
                dirBtn("左") { [unowned self] in setMarqueeDirection(.left) },
                dirBtn("右") { [unowned self] in setMarqueeDirection(.right)}
            ])
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.marqueeTitleSubPlain.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(40)
            }
    }()

    // MARK: - 轮播图（本地 / 网络）——使用 intervalOnce 模式分页滚动
    private lazy var imageCarouselLocal: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.intervalOnce(interval: 2.5, duration: 0.30))
            .byLoopEnabled(true)
            .byGestureScrollEnabled(false)
            .byOnTap { [unowned self] idx, _ in
                Task { @MainActor in
                    JobsToast.show(
                        text: "本地轮播：点击第 \(idx + 1) 项",
                        config: JobsToast.Config()
                            .byBgColor(.systemGreen.withAlphaComponent(0.9))
                            .byCornerRadius(12)
                    )
                }
            }
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.marqueeDirBar.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(120)
            }
    }()

    private lazy var imageCarouselRemote: JobsMarqueeView = {
        JobsMarqueeView()
            .byDirection(.left)
            .byMode(.intervalOnce(interval: 2.5, duration: 0.30))
            .byLoopEnabled(true)
            .byGestureScrollEnabled(false)
            .byOnTap { [unowned self] idx, _ in
                Task { @MainActor in
                    JobsToast.show(
                        text: "网络轮播：点击第 \(idx + 1) 项",
                        config: JobsToast.Config()
                            .byBgColor(.systemGreen.withAlphaComponent(0.9))
                            .byCornerRadius(12)
                    )
                }
            }
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.imageCarouselLocal.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(120)
            }
    }()

    // MARK: - 轮播方向控制（上/下/左/右）
    private lazy var carouselDirBar: UIStackView = {
        UIStackView()
            .byAxis(.horizontal)
            .byDistribution(.fillEqually)
            .bySpacing(8)
            .byAddArrangedSubviews([
                dirBtn("上") { [unowned self] in setCarouselDirection(.up)   },
                dirBtn("下") { [unowned self] in setCarouselDirection(.down) },
                dirBtn("左") { [unowned self] in setCarouselDirection(.left) },
                dirBtn("右") { [unowned self] in setCarouselDirection(.right)}
            ])
            .byAddTo(self.view) { [unowned self] make in
                make.top.equalTo(self.imageCarouselRemote.snp.bottom).offset(kSectionSpacing)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(40)
            }
    }()

    // MARK: - 底部控制（2×2：开始/暂停/恢复/停止）
    private lazy var controlGrid: UIStackView = {
        UIStackView()
            .byAxis(.vertical)
            .bySpacing(10)
            .byAddArrangedSubviews([
                UIStackView().byAxis(.horizontal).bySpacing(10).byAddArrangedSubviews([
                    actionButton("开始")  { [unowned self] in startAll()  },
                    actionButton("暂停")  { [unowned self] in pauseAll()  }
                ]),
                UIStackView().byAxis(.horizontal).bySpacing(10).byAddArrangedSubviews([
                    actionButton("恢复")  { [unowned self] in resumeAll() },
                    actionButton("停止")  { [unowned self] in stopAll()   }
                ])
            ])
            .byAddTo(self.view) { [unowned self] make in
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(16)
                make.top.greaterThanOrEqualTo(self.carouselDirBar.snp.bottom).offset(kDirToControlSpacing)
                make.top.greaterThanOrEqualTo(self.marqueeDirBar.snp.bottom).offset(kDirToControlSpacing)
            }
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "JobsMarqueeView Demo")

        setupLocalCarousel()
        Task { [weak self] in await self?.setupImageCarouselRemote() }

        // alpha 唤起
        UIView.animate(withDuration: 0.25) {
            self.marqueeTitleRich.byAlpha(1)
            self.marqueeTitlePlain.byAlpha(1)
            self.marqueeTitleSubRich.byAlpha(1)
            self.marqueeTitleSubPlain.byAlpha(1)
            self.marqueeDirBar.byAlpha(1)
            self.imageCarouselLocal.byAlpha(1)
            self.imageCarouselRemote.byAlpha(1)
            self.carouselDirBar.byAlpha(1)
            self.controlGrid.byAlpha(1)
        }

        startAll()
    }

    deinit { stopAll() }

    // MARK: - 本地轮播
    private func setupLocalCarousel() {
        let btns: [UIButton] = [imageBtn(), imageBtn(), imageBtn()]
        imageCarouselLocal.setButtons(btns)

        func img(_ name: String) -> UIImage? { UIImage(named: name) }
        applyBackgroundImage(img("Ani"),  to: btns[0])
        applyBackgroundImage(img("Ani2"), to: btns[1])
        applyBackgroundImage(img("Ani3"), to: btns[2])
    }

    // MARK: - 并发加载网络轮播图（按钮背景 = layer.contents，AspectFill）
    @MainActor
    private func setupImageCarouselRemote() async {
        let urls = remoteURLs()
        let btns: [UIButton] = (0..<urls.count).map { _ in imageBtn() }
        imageCarouselRemote.setButtons(btns)   // 先占位

        for (i, u) in urls.enumerated() {
            let b = btns[i]
            Task.detached { [weak b] in
                guard let b else { return }
                do {
                    let img = try await u.kfLoadImage()
                    await MainActor.run { self.applyBackgroundImage(img, to: b) }
                } catch {
                    await MainActor.run { self.applyBackgroundImage(UIImage(systemName: "exclamationmark.triangle"), to: b) }
                }
            }
        }
    }

    private func remoteURLs() -> [URL] {
        let s = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5V57u3uwX8dGkmezFuaB0DJZAKZ96WSqkIESLbqA9tDovtwHMenRqkZSgnU53po0D848OguVoTqzxzzGaUusl-OorK_miHQ3p4c6gjrJI9w"
        return [URL(string: s)!, URL(string: s)!, URL(string: s)!, URL(string: s)!]
    }

    // MARK: - 方向切换
    private func setMarqueeDirection(_ d: MarqueeDirection) {
        [marqueeTitleRich, marqueeTitlePlain, marqueeTitleSubRich, marqueeTitleSubPlain].forEach { $0.byDirection(d) }
    }
    private func setCarouselDirection(_ d: MarqueeDirection) {
        [imageCarouselLocal, imageCarouselRemote].forEach { $0.byDirection(d) }
    }

    // MARK: - 控制
    private func startAll()  { [marqueeTitleRich, marqueeTitlePlain, marqueeTitleSubRich, marqueeTitleSubPlain, imageCarouselLocal, imageCarouselRemote].forEach { $0.start() } }
    private func pauseAll()  { [marqueeTitleRich, marqueeTitlePlain, marqueeTitleSubRich, marqueeTitleSubPlain, imageCarouselLocal, imageCarouselRemote].forEach { $0.pause() } }
    private func resumeAll() { [marqueeTitleRich, marqueeTitlePlain, marqueeTitleSubRich, marqueeTitleSubPlain, imageCarouselLocal, imageCarouselRemote].forEach { $0.resume() } }
    private func stopAll()   { [marqueeTitleRich, marqueeTitlePlain, marqueeTitleSubRich, marqueeTitleSubPlain, imageCarouselLocal, imageCarouselRemote].forEach { $0.stop() } }

    // MARK: - 小工具
    private func dirBtn(_ title: String, _ action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var c = UIButton.Configuration.tinted()
            c.title = title
            c.baseBackgroundColor = .systemGray5
            b.configuration = c
        } else {
            b.byTitle(title).byBgColor(.systemGray5)
        }
        b.onTap { _ in action() }
        return b
    }

    private func actionButton(_ title: String, _ action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var c = UIButton.Configuration.filled()
            c.title = title
            c.baseBackgroundColor = .systemBlue
            c.baseForegroundColor = .white
            c.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
            c.cornerStyle = .fixed
            var bg = c.background; bg.cornerRadius = 0; c.background = bg
            b.configuration = c
        } else {
            b.byTitle(title).byTitleColor(.white).byBgColor(.systemBlue)
        }
        b.onTap { _ in action() }
        return b
    }

    /// 轮播图专用按钮（不使用 configuration 的背景图；用 layer.contents 实现 AspectFill）
    private func imageBtn() -> UIButton {
        let b = UIButton(type: .custom)
        b.clipsToBounds = true
        b.backgroundColor = .tertiarySystemFill
        if #available(iOS 15.0, *), var c = b.configuration {
            c.cornerStyle = .fixed
            var bg = c.background; bg.cornerRadius = 0; c.background = bg
            b.configuration = c
        } else {
            b.layer.cornerRadius = 0
        }
        b.setTitle(nil, for: .normal)
        b.setImage(nil, for: .normal)
        b.contentEdgeInsets = .zero
        return b
    }

    /// 将图片作为“背景图”绘制到按钮 layer（支持 AspectFill，不叠加子视图）
    private func applyBackgroundImage(_ img: UIImage?, to button: UIButton) {
        if let cg = img?.cgImage {
            button.layer.contents = cg
            button.layer.contentsScale = img?.scale ?? UIScreen.main.scale
            button.layer.contentsGravity = .resizeAspectFill
            button.layer.masksToBounds = true
        } else {
            button.layer.contents = nil
        }
    }
}
