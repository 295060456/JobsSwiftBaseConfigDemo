//
//  Demo@Texture.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/5/25.
//

import UIKit
import Texture
import SnapKit

// MARK: - 数据模型（等价 CKDemoItem）
enum DemoKind {
    case text,
         image,
         button,
         flexRow,
         flexColumn,
         insetCard,
         backgroundOverlay,
         center,
         ratio,
         zstack
}

struct DemoItem {
    let kind: DemoKind
    let title: String
    let subtitle: String
    let image: UIImage?
    static func item(_ k: DemoKind, _ t: String, _ s: String = "", _ img: UIImage? = nil) -> DemoItem {
        .init(kind: k, title: t, subtitle: s, image: img)
    }
}
// MARK: - 卡片节点（等价 CK 的“一张卡”）
final class CardNode: ASDisplayNode {
    // 头部
    private let titleNode = ASTextNode()
    private let subtitleNode = ASTextNode()
    // 内容（按 kind 切）
    private var contentNode: ASDisplayNode = ASDisplayNode()
    // 背景卡片
    private let backgroundNode: ASDisplayNode = {
        let n = ASDisplayNode()
        n.backgroundColor = .secondarySystemBackground
        n.cornerRadius = 12
        n.clipsToBounds = true
        return n
    }()
    // 主题色
    private let theme: UIColor
    // Button 的回调示例
    var onButtonTap: (() -> Void)?

    init(item: DemoItem, theme: UIColor) {
        self.theme = theme
        super.init()
        automaticallyManagesSubnodes = true

        titleNode.attributedText = NSAttributedString(
            string: item.title,
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                         .foregroundColor: UIColor.label]
        )
        subtitleNode.attributedText = NSAttributedString(
            string: item.subtitle,
            attributes: [.font: UIFont.systemFont(ofSize: 13),
                         .foregroundColor: UIColor.secondaryLabel]
        )

        switch item.kind {
        case .text:
            let text = ASTextNode()
            text.attributedText = NSAttributedString(
                string: "ASTextNode：字体/颜色/多行…（对应 CKLabelComponent）。",
                attributes: [.font: UIFont.systemFont(ofSize: 14),
                             .foregroundColor: UIColor.label]
            )
            contentNode = text

        case .image:
            let img = ASImageNode()
            img.image = item.image ?? UIImage(systemName: "photo")
            img.contentMode = .scaleAspectFill
            img.style.preferredSize = CGSize(width: 120, height: 120)
            img.clipsToBounds = true
            img.cornerRadius = 8
            contentNode = img

        case .button:
            let btn = ASButtonNode()
            btn.setTitle("Tap Me", with: .systemFont(ofSize: 15, weight: .medium), with: theme, for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
            btn.backgroundColor = theme.withAlphaComponent(0.12)
            btn.cornerRadius = 8
            btn.addTarget(self, action: #selector(handleTap), forControlEvents: .touchUpInside)
            contentNode = btn

        case .flexRow:
            // 横向 3 列，等比伸展（flexGrow）
            let a = textNode("A", color: theme)
            let b = textNode("B", color: theme)
            let c = textNode("C", color: theme)
            a.style.flexGrow = 1; b.style.flexGrow = 1; c.style.flexGrow = 1
            contentNode = ASDisplayNode() // 占位，布局里再组合

            // 把子节点挂上，避免自动管理下丢失
            addSubnode(a); addSubnode(b); addSubnode(c)

            // 用闭包返回布局（见 layoutSpecThatFits）
            self._customContentLayout = { [weak a, weak b, weak c] in
                let row = ASStackLayoutSpec.horizontal()
                row.spacing = 6
                row.alignItems = .center
                row.justifyContent = .spaceBetween
                row.children = [a, b, c].compactMap { $0 }
                return row
            }

        case .flexColumn:
            let t1 = textNode("1️⃣ 上")
            let t2 = textNode("2️⃣ 中", color: .secondaryLabel)
            let t3 = textNode("3️⃣ 下", color: theme)
            contentNode = ASDisplayNode()
            addSubnode(t1); addSubnode(t2); addSubnode(t3)
            self._customContentLayout = { [weak t1, weak t2, weak t3] in
                let col = ASStackLayoutSpec.vertical()
                col.spacing = 4
                col.children = [t1, t2, t3].compactMap { $0 }
                return col
            }

        case .insetCard:
            let t = textNode("ASInsetLayoutSpec: 卡片内容留白。")
            contentNode = t

        case .backgroundOverlay:
            let baseImage = ASImageNode()
            baseImage.image = UIImage(systemName: "photo")
            baseImage.style.preferredSize = CGSize(width: 140, height: 90)
            baseImage.contentMode = .scaleAspectFill
            baseImage.cornerRadius = 6
            baseImage.clipsToBounds = true

            let bg = ASDisplayNode()
            bg.backgroundColor = .tertiarySystemFill

            let overlay = textNode("Overlay", font: .systemFont(ofSize: 12, weight: .semibold), color: theme)

            // 直接作为内容树子节点，布局时组合 Background+Overlay
            addSubnode(baseImage)
            addSubnode(bg)
            addSubnode(overlay)
            contentNode = ASDisplayNode()
            self._customContentLayout = { [weak baseImage, weak bg, weak overlay] in
                guard let base = baseImage, let bg = bg, let ov = overlay else { return ASLayoutSpec() }
                let bgSpec = ASBackgroundLayoutSpec(child: base, background: bg)
                let ovInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 6, bottom: 0, right: 0), child: ov)
                return ASOverlayLayoutSpec(child: bgSpec, overlay: ovInset)
            }

        case .center:
            let inner = textNode("居中", font: .systemFont(ofSize: 14, weight: .medium), color: theme)
            addSubnode(inner)
            contentNode = ASDisplayNode()
            self._customContentLayout = { [weak inner] in
                ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: inner)
            }

        case .ratio:
            // 16:9
            let img = ASImageNode()
            img.image = UIImage(systemName: "photo")
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            addSubnode(img)
            contentNode = ASDisplayNode()
            self._customContentLayout = { [weak img] in
                ASRatioLayoutSpec(ratio: 16.0 / 9.0, child: img)
            }

        case .zstack:
            let bottom = ASImageNode()
            bottom.image = UIImage(systemName: "photo")
            bottom.style.preferredSize = CGSize(width: 120, height: 80)
            bottom.contentMode = .scaleAspectFill
            bottom.cornerRadius = 6
            bottom.clipsToBounds = true

            let top = textNode("Top", color: .white, font: .systemFont(ofSize: 12))
            addSubnode(bottom); addSubnode(top)
            contentNode = ASDisplayNode()
            self._customContentLayout = { [weak bottom, weak top] in
                guard let b = bottom, let t = top else { return ASLayoutSpec() }
                let tInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 6, bottom: 0, right: 0), child: t)
                return ASOverlayLayoutSpec(child: b, overlay: tInset)
            }
        }
    }

    @objc private func handleTap() { onButtonTap?() }

    // 可注入的内容布局（用于 flexRow/Column 等组合）
    private var _customContentLayout: (() -> ASLayoutSpec)?

    // 小工具：文本节点
    private func textNode(_ s: String,
                          font: UIFont = .systemFont(ofSize: 14),
                          color: UIColor = .label) -> ASTextNode {
        let n = ASTextNode()
        n.attributedText = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color])
        return n
    }

    // 布局：标题 / 副标题 / 内容 + 背景 + 外层内边距（等价 Inset+Background+Overlay 组合）
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // 标题列
        let column = ASStackLayoutSpec.vertical()
        column.spacing = 8

        // 标题 + 副标题
        let head = ASStackLayoutSpec.vertical()
        head.spacing = 2
        head.children = [titleNode, subtitleNode]

        // 内容布局
        let contentSpec: ASLayoutSpec = {
            if let make = _customContentLayout {
                return make()
            } else {
                return contentNode
            }
        }()

        column.children = [head, contentSpec]

        // 内边距（卡片内容留白）
        let innerInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12),
                                           child: column)

        // 背景卡片
        let bg = ASBackgroundLayoutSpec(child: innerInset, background: backgroundNode)

        // 外层卡边距
        let outer = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16), child: bg)
        return outer
    }
}

// MARK: - 整页节点：纵向栈，持有多张卡
final class KitchenSinkNode: ASDisplayNode {
    private var items: [DemoItem]
    private let theme: UIColor
    private var cardNodes: [CardNode] = []

    init(items: [DemoItem], theme: UIColor = .systemBlue) {
        self.items = items
        self.theme = theme
        super.init()
        automaticallyManagesSubnodes = true
        buildsCards()
    }

    private func buildsCards() {
        cardNodes = items.map { item in
            let n = CardNode(item: item, theme: theme)
            n.onButtonTap = { [weak self] in
                guard let self else { return }
                // 简单交互：点按钮后插入一条新文本
                var copy = self.items
                copy.append(.item(.text, "New Text", "Appended by button"))
                self.update(items: copy, animated: true)
            }
            return n
        }
    }

    func update(items: [DemoItem], animated: Bool) {
        self.items = items
        buildsCards()
        if animated {
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        } else {
            setNeedsLayout()
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let v = ASStackLayoutSpec.vertical()
        v.spacing = 0
        v.alignItems = .stretch
        v.children = cardNodes
        return v
    }
}

// MARK: - 视图控制器：外层用 SnapKit 约束
final class ComponentKitLikeKitchenSinkVC: UIViewController {

    private var items: [DemoItem] = [
        .item(.text, "Text", "ASTextNode"),
        .item(.image, "Image", "ASImageNode", UIImage(systemName: "photo")),
        .item(.flexRow, "Flex Row", "ASStackLayoutSpec(.horizontal)"),
        .item(.flexColumn, "Flex Column", "ASStackLayoutSpec(.vertical)"),
        .item(.insetCard, "Inset", "ASInsetLayoutSpec"),
        .item(.backgroundOverlay, "BG + Overlay", "ASBackgroundLayoutSpec + ASOverlayLayoutSpec"),
        .item(.center, "Center", "ASCenterLayoutSpec"),
        .item(.ratio, "Ratio 16:9", "ASRatioLayoutSpec"),
        .item(.zstack, "ZStack", "Overlay as stack"),
        .item(.button, "Button", "ASButtonNode (action)"),
    ]

    private let rootNode = KitchenSinkNode(items: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kitchen-Sink (Swift+Texture)"
        view.backgroundColor = .systemBackground

        // 把 Texture 节点作为普通 view 用 SnapKit 约束
        view.addSubview(rootNode.view)
        rootNode.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        // 初次渲染
        rootNode.update(items: items, animated: false)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle)),
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addOne))
        ]
    }

    @objc private func shuffle() {
        items.shuffle()
        rootNode.update(items: items, animated: true)
    }

    @objc private func addOne() {
        items.append(.item(.text, "New Text", "Append at \(items.count)"))
        rootNode.update(items: items, animated: true)
    }
}
