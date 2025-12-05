//
//  WalletLayout.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/5/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

final class WalletLayout: UICollectionViewLayout {
    /// 左右内边距
    var padding: CGFloat = 16
    /// cell 高度
    var itemHeight: CGFloat = 76
    /// 被覆盖的高度（越大重叠越多）
    var overlap: CGFloat = 10
    /// 展开时向下腾出的高度
    var expandOffset: CGFloat = 10
    weak var layoutDelegate: WalletLayoutDelegate?
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private(set) var expandedIndexPath: IndexPath?
    private(set) var isExpanded: Bool = false
    // MARK: - 点击展开/收起
    func animateToggle(at indexPath: IndexPath, allowExpand: Bool) {
        guard let collectionView = collectionView else { return }
        UIView.transition(with: collectionView,
                          duration: 0.25,
                          options: .transitionCrossDissolve) { [weak self] in
            guard let self else { return }
            if allowExpand {
                if self.expandedIndexPath == indexPath {
                    self.expandedIndexPath = nil
                    self.isExpanded = false
                } else {
                    self.expandedIndexPath = indexPath
                    self.isExpanded = true
                }
            } else {
                self.expandedIndexPath = nil
                self.isExpanded = false
            }
            self.invalidateLayout()
            collectionView.layoutIfNeeded()
        }
    }
    // MARK: - UICollectionViewLayout
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        cachedAttributes.removeAll()
        contentHeight = 0

        let width = collectionView.bounds.width
        var yOffset: CGFloat = 0

        let numberOfSections = collectionView.numberOfSections

        for section in 0..<numberOfSections {
            // Header
            let headerHeight = layoutDelegate?
                .collectionView(collectionView, reusableHeaderHeightFor: section) ?? 0
            if headerHeight > 0 {
                let indexPath = IndexPath(item: 0, section: section)
                let headerAttr = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    with: indexPath
                )
                headerAttr.frame = CGRect(x: 0,
                                          y: yOffset,
                                          width: width,
                                          height: headerHeight)
                cachedAttributes.append(headerAttr)
                yOffset = headerAttr.frame.maxY
            }
            // Cells
            let itemsCount = collectionView.numberOfItems(inSection: section)
            for item in 0..<itemsCount {
                let indexPath = IndexPath(item: item, section: section)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attr.zIndex = item * 2

                let cellWidth = width - 2 * padding
                let size = CGSize(width: cellWidth, height: itemHeight)

                let baseOverlap: CGFloat = (item == 0 ? 0 : overlap)
                var expandH = baseOverlap

                // 是否为“被选中卡片的下一张”
                if isExpanded,
                   let expanded = expandedIndexPath,
                   expanded.section == section,
                   expanded.item + 1 == item {
                    expandH = -expandOffset
                }

                let origin = CGPoint(x: padding,
                                     y: yOffset - expandH)
                attr.frame = CGRect(origin: origin, size: size)

                cachedAttributes.append(attr)
                yOffset = attr.frame.maxY
            }
            // Footer
            let footerHeight = layoutDelegate?
                .collectionView(collectionView, reusableFooterHeightFor: section) ?? 0
            if footerHeight > 0 {
                let indexPath = IndexPath(item: max(0, itemsCount - 1), section: section)
                let footerAttr = UICollectionViewLayoutAttributes(
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    with: indexPath
                )
                footerAttr.frame = CGRect(x: 0,
                                          y: yOffset,
                                          width: width,
                                          height: footerHeight)
                cachedAttributes.append(footerAttr)
                yOffset = footerAttr.frame.maxY
            }
        };contentHeight = yOffset + collectionView.adjustedContentInset.bottom + 8
    }

    override var collectionViewContentSize: CGSize {
        let width = collectionView?.bounds.width ?? 0
        return CGSize(width: width, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cachedAttributes.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedAttributes.first {
            $0.representedElementCategory == .cell && $0.indexPath == indexPath
        }
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        cachedAttributes.first {
            $0.representedElementKind == elementKind && $0.indexPath == indexPath
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return true }
        return abs(newBounds.width - collectionView.bounds.width) > 0.5
    }
}

extension WalletLayout {
    /// 左右边距
    @discardableResult
    func byPadding(_ value: CGFloat) -> Self {
        padding = value
        return self
    }
    /// Cell 高度
    @discardableResult
    func byItemHeight(_ value: CGFloat) -> Self {
        itemHeight = value
        return self
    }
    /// 覆盖高度（重叠量）
    @discardableResult
    func byOverlap(_ value: CGFloat) -> Self {
        overlap = value
        return self
    }
    /// 展开时往下腾出的高度
    @discardableResult
    func byExpandOffset(_ value: CGFloat) -> Self {
        expandOffset = value
        return self
    }
    /// 设置 delegate
    @discardableResult
    func byLayoutDelegate(_ delegate: WalletLayoutDelegate?) -> Self {
        layoutDelegate = delegate
        return self
    }
    /// 整体配置 Block（可选）
    @discardableResult
    func byConfig(_ block: (WalletLayout) -> Void) -> Self {
        block(self)
        return self
    }
}
