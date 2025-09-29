//
//  UICollectionView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC
/// UICollectionView、UICollectionViewCell、UICollectionReusableView@注册和提取
extension UICollectionView {
    // MARK: - 注册 Cell（Nib）
    @discardableResult
    public func registerCellNib<T: UICollectionViewCell>(_ cellClass: T.Type) -> Self {
        let id = String(describing: cellClass)
        let nib = UINib(nibName: id, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: id)
        return self
    }
    // MARK: - 当前类名注册 Cell
    @discardableResult
    func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) -> Self {
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
        return self
    }
    // MARK: - 指定 ID 注册 Cell（Class）
    @discardableResult
    public func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type, reuseID: String) -> Self {
        self.register(cellClass, forCellWithReuseIdentifier: reuseID)
        return self
    }
    // MARK: - 指定 ID 注册 Cell（Nib）
    @discardableResult
    public func registerCellNib<T: UICollectionViewCell>(_ cellClass: T.Type, reuseID: String) -> Self {
        let nib = UINib(nibName: String(describing: cellClass), bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: reuseID)
        return self
    }
    // MARK: - 注册 SupplementaryView（Class）
    @discardableResult
    public func registerSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type,
                                                                       kind: String) -> Self {
        let id = String(describing: viewClass)
        self.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
        return self
    }
    // MARK: - 注册 SupplementaryView（Nib）
    @discardableResult
    public func registerSupplementaryNib<T: UICollectionReusableView>(_ viewClass: T.Type,
                                                                      kind: String) -> Self {
        let id = String(describing: viewClass)
        let nib = UINib(nibName: id, bundle: nil)
        self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
        return self
    }
    // MARK: - 出队 Cell（泛型安全）
    public func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        let id = String(describing: type)
        return self.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! T
    }
    // MARK: - 出队 SupplementaryView（泛型安全）
    public func dequeueSupplementary<T: UICollectionReusableView>(_ type: T.Type,
                                                                  kind: String,
                                                                  for indexPath: IndexPath) -> T {
        let id = String(describing: type)
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! T
    }
}
/// UICollectionView@数据源
extension UICollectionView {
    // MARK: - 数据源 delegate
    @discardableResult
    public func byDelegate(_ delegate: UICollectionViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    // MARK: - 数据源 dataSource
    @discardableResult
    func byDataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }
}
/// UICollectionView@UICollectionViewLayout
extension UICollectionView {
    // MARK: - 布局对象 UICollectionViewLayout
    @discardableResult
    func byCollectionViewLayout(_ layout: UICollectionViewLayout) -> Self {
        self.collectionViewLayout = layout
        return self
    }
    // MARK: - FlowLayout 的滚动方向
    @discardableResult
    public func byScrollDirection(_ direction: UICollectionView.ScrollDirection) -> Self {
        (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = direction
        return self
    }
    // MARK: - 切换布局（动画）
    @discardableResult
    public func bySetLayout(_ layout: UICollectionViewLayout, animated: Bool) -> Self {
        self.setCollectionViewLayout(layout, animated: animated)
        return self
    }
    // MARK: - iOS 7.0+ 切换布局（动画 + 完成回调）
    @available(iOS 7.0, *)
    @discardableResult
    public func bySetLayout(_ layout: UICollectionViewLayout,
                            animated: Bool,
                            completion: ((Bool) -> Void)?) -> Self {
        self.setCollectionViewLayout(layout, animated: animated, completion: completion)
        return self
    }
}
/// 预取、拖拽放置、重排、自适应失效@UICollectionView
extension UICollectionView {
    // MARK: - iOS 10.0+ 预取数据源
    @available(iOS 10.0, *)
    @discardableResult
    public func byPrefetchDataSource(_ ds: UICollectionViewDataSourcePrefetching?) -> Self {
        self.prefetchDataSource = ds
        return self
    }
    // MARK: - iOS 10.0+ 是否启用预取
    @available(iOS 10.0, *)
    @discardableResult
    public func byPrefetchingEnabled(_ enabled: Bool) -> Self {
        self.isPrefetchingEnabled = enabled
        return self
    }
    // MARK: - iOS 11.0+ 拖拽代理
    @available(iOS 11.0, *)
    @discardableResult
    public func byDragDelegate(_ delegate: UICollectionViewDragDelegate?) -> Self {
        self.dragDelegate = delegate
        return self
    }
    // MARK: - iOS 11.0+ 放置代理
    @available(iOS 11.0, *)
    @discardableResult
    public func byDropDelegate(_ delegate: UICollectionViewDropDelegate?) -> Self {
        self.dropDelegate = delegate
        return self
    }
    // MARK: - iOS 11.0+ 是否启用拖拽交互
    @available(iOS 11.0, *)
    @discardableResult
    public func byDragInteractionEnabled(_ enabled: Bool) -> Self {
        self.dragInteractionEnabled = enabled
        return self
    }
    // MARK: - iOS 11.0+ 重排节奏
    @available(iOS 11.0, *)
    @discardableResult
    public func byReorderingCadence(_ cadence: UICollectionView.ReorderingCadence) -> Self {
        self.reorderingCadence = cadence
        return self
    }
    // MARK: - iOS 16.0+ 自适应失效策略
    @available(iOS 16.0, *)
    @discardableResult
    public func bySelfSizingInvalidation(_ value: UICollectionView.SelfSizingInvalidation) -> Self {
        self.selfSizingInvalidation = value
        return self
    }
}
/// 背景、Context_Menu@UICollectionView
extension UICollectionView {
    @discardableResult
    public func byBackgroundView(_ view: UIView?) -> Self {
        self.backgroundView = view
        return self
    }
    // MARK: - iOS 13.2+ ContextMenuInteraction 配置闭包
    @available(iOS 13.2, *)
    @discardableResult
    public func byContextMenuInteraction(_ config: (UIContextMenuInteraction) -> Void) -> Self {
        if let interaction = self.contextMenuInteraction {
            config(interaction)
        }
        return self
    }
}
/// 选择、编辑、焦点@UICollectionView
extension UICollectionView {

    @discardableResult
    public func byAllowsSelection(_ allow: Bool) -> Self {
        self.allowsSelection = allow
        return self
    }

    @discardableResult
    public func byAllowsMultipleSelection(_ allow: Bool) -> Self {
        self.allowsMultipleSelection = allow
        return self
    }
    // MARK: - 选择/取消选择
    @discardableResult
    public func bySelectItem(_ indexPath: IndexPath?, animated: Bool = true,
                             scrollPosition: UICollectionView.ScrollPosition = []) -> Self {
        self.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        return self
    }

    @discardableResult
    public func byDeselectItem(_ indexPath: IndexPath, animated: Bool = true) -> Self {
        self.deselectItem(at: indexPath, animated: animated)
        return self
    }
    // MARK: - iOS 14.0+ 编辑状态
    @available(iOS 14.0, *)
    @discardableResult
    public func byEditing(_ editing: Bool) -> Self {
        self.isEditing = editing
        return self
    }
    // MARK: - iOS 14.0+ 编辑时允许选择
    @available(iOS 14.0, *)
    @discardableResult
    public func byAllowsSelectionDuringEditing(_ allow: Bool) -> Self {
        self.allowsSelectionDuringEditing = allow
        return self
    }
    // MARK: - iOS 14.0+ 编辑时允许多选
    @available(iOS 14.0, *)
    @discardableResult
    public func byAllowsMultipleSelectionDuringEditing(_ allow: Bool) -> Self {
        self.allowsMultipleSelectionDuringEditing = allow
        return self
    }
    // MARK: - iOS 9.0+ 记住上次聚焦
    @available(iOS 9.0, *)
    @discardableResult
    public func byRemembersLastFocusedIndexPath(_ remember: Bool) -> Self {
        self.remembersLastFocusedIndexPath = remember
        return self
    }
    // MARK: - iOS 14.0+ 焦点移动自动选中
    @available(iOS 14.0, *)
    @discardableResult
    public func bySelectionFollowsFocus(_ enable: Bool) -> Self {
        self.selectionFollowsFocus = enable
        return self
    }
    // MARK: - iOS 15.0+ 允许聚焦
    @available(iOS 15.0, *)
    @discardableResult
    public func byAllowsFocus(_ allow: Bool) -> Self {
        self.allowsFocus = allow
        return self
    }
    // MARK: - iOS 15.0+ 编辑时允许聚焦
    @available(iOS 15.0, *)
    @discardableResult
    public func byAllowsFocusDuringEditing(_ allow: Bool) -> Self {
        self.allowsFocusDuringEditing = allow
        return self
    }
}
/// 滚动、可视区域@UICollectionView
extension UICollectionView {

    @discardableResult
    public func byScrollToItem(_ indexPath: IndexPath,
                               at position: UICollectionView.ScrollPosition,
                               animated: Bool = true) -> Self {
        self.scrollToItem(at: indexPath, at: position, animated: animated)
        return self
    }
}
/// 更新、批量操作、交互式过渡_移动@UICollectionView
extension UICollectionView {

    @discardableResult
    public func byReloadData() -> Self {
        self.reloadData()
        return self
    }

    @discardableResult
    public func byPerformBatchUpdates(_ updates: (() -> Void)?,
                                      completion: ((Bool) -> Void)? = nil) -> Self {
        self.performBatchUpdates(updates, completion: completion)
        return self
    }
    // MARK: - Sections
    @discardableResult
    public func byInsertSections(_ sections: IndexSet) -> Self {
        self.insertSections(sections)
        return self
    }

    @discardableResult
    public func byDeleteSections(_ sections: IndexSet) -> Self {
        self.deleteSections(sections)
        return self
    }

    @discardableResult
    public func byMoveSection(_ from: Int, to: Int) -> Self {
        self.moveSection(from, toSection: to)
        return self
    }

    @discardableResult
    public func byReloadSections(_ sections: IndexSet) -> Self {
        self.reloadSections(sections)
        return self
    }
    // MARK: - Items
    @discardableResult
    public func byInsertItems(at indexPaths: [IndexPath]) -> Self {
        self.insertItems(at: indexPaths)
        return self
    }

    @discardableResult
    public func byDeleteItems(at indexPaths: [IndexPath]) -> Self {
        self.deleteItems(at: indexPaths)
        return self
    }

    @discardableResult
    public func byMoveItem(from: IndexPath, to: IndexPath) -> Self {
        self.moveItem(at: from, to: to)
        return self
    }

    @discardableResult
    public func byReloadItems(at indexPaths: [IndexPath]) -> Self {
        self.reloadItems(at: indexPaths)
        return self
    }
    // MARK: - iOS 15.0+ 重新配置（不重载）
    @available(iOS 15.0, *)
    @discardableResult
    public func byReconfigureItems(at indexPaths: [IndexPath]) -> Self {
        self.reconfigureItems(at: indexPaths)
        return self
    }
    // MARK: - iOS 7.0+ 交互式布局过渡
    @available(iOS 7.0, *)
    @discardableResult
    public func byStartInteractiveTransition(to layout: UICollectionViewLayout,
                                             completion: UICollectionView.LayoutInteractiveTransitionCompletion? = nil)
    -> UICollectionViewTransitionLayout {
        return self.startInteractiveTransition(to: layout, completion: completion)
    }
    // MARK: - iOS 7.0+ 完成交互式过渡
    @available(iOS 7.0, *)
    @discardableResult
    public func byFinishInteractiveTransition() -> Self {
        self.finishInteractiveTransition()
        return self
    }
    // MARK: - iOS 7.0+ 取消交互式过渡
    @available(iOS 7.0, *)
    @discardableResult
    public func byCancelInteractiveTransition() -> Self {
        self.cancelInteractiveTransition()
        return self
    }
    // MARK: - iOS 9.0+ 交互式移动（开始/更新/结束/取消）
    @available(iOS 9.0, *)
    @discardableResult
    public func byBeginInteractiveMovement(for indexPath: IndexPath) -> Bool {
        return self.beginInteractiveMovementForItem(at: indexPath)
    }

    @available(iOS 9.0, *)
    @discardableResult
    public func byUpdateInteractiveMovementTargetPosition(_ position: CGPoint) -> Self {
        self.updateInteractiveMovementTargetPosition(position)
        return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    public func byEndInteractiveMovement() -> Self {
        self.endInteractiveMovement()
        return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    public func byCancelInteractiveMovement() -> Self {
        self.cancelInteractiveMovement()
        return self
    }
}
// MARK: - UICollectionView Empty View
private var collectionEmptyViewKey: Void?
extension UICollectionView {
    private var jobs_emptyView: UIView? {
        get { objc_getAssociatedObject(self, &collectionEmptyViewKey) as? UIView }
        set {
            jobs_emptyView?.removeFromSuperview()
            if let view = newValue {
                addSubview(view)
                bringSubviewToFront(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.centerXAnchor.constraint(equalTo: centerXAnchor),
                    view.centerYAnchor.constraint(equalTo: centerYAnchor),
                    view.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9)
                ])
            }
            objc_setAssociatedObject(self, &collectionEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @discardableResult
    func jobs_setEmptyView(_ view: UIView?) -> Self {
        self.jobs_emptyView = view
        return self
    }

    @discardableResult
    func jobs_reloadEmptyView(itemCount: Int, sectionCount: Int = 1) -> Self {
        let isEmpty = itemCount == 0 || sectionCount == 0
        self.jobs_emptyView?.isHidden = !isEmpty
        return self
    }
}
