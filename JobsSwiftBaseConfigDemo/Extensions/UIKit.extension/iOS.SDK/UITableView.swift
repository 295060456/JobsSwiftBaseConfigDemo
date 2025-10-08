//
//  UITableView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/15.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC
import SnapKit
import ESPullToRefresh
// MARK: - 🍬语法糖@注册：UITableViewCell、HeaderFooterView、HeaderFooterView
extension UITableView {
    @discardableResult
    public func registerCell<T: UITableViewCell>(_ cellClass: T.Type) -> Self {
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        return self
    }
    @discardableResult
    public func registerCellByID<T: UITableViewCell>(CellCls cellClass: T.Type,ID id:String) -> Self {
        self.register(cellClass, forCellReuseIdentifier: id)
        return self
    }
    @discardableResult
    public func py_register(cellClassType: UITableViewCell.Type) -> Self {
        let cellId = cellClassType.className
        let cellClass: AnyClass = cellClassType.classForCoder()
        self.register(cellClass, forCellReuseIdentifier: cellId)
        return self
    }
    @discardableResult
    public func py_register(cellNibType: UITableViewCell.Type) -> Self{
        let cellId = cellNibType.className
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.register(cellNib, forCellReuseIdentifier: cellId)
        return self
    }
    @discardableResult
    public func py_register(headerFooterViewClassType: UIView.Type) -> Self{
        let reuseId = headerFooterViewClassType.className
        let viewType: AnyClass = headerFooterViewClassType.classForCoder()
        self.register(viewType, forHeaderFooterViewReuseIdentifier: reuseId)
        return self
    }
    @discardableResult
    public func py_register(headerFooterViewNibType: UIView.Type) -> Self{
        let reuseId = headerFooterViewNibType.className
        let viewNib = UINib(nibName: reuseId, bundle: nil)
        self.register(viewNib, forHeaderFooterViewReuseIdentifier: reuseId)
        return self
    }
}
// MARK: - 🍬语法糖@数据源
extension UITableView {
    @discardableResult
    public func byDelegate(_ delegate: UITableViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    public func byDataSource(_ dataSource: UITableViewDataSource) -> Self {
        self.dataSource = dataSource
        return self
    }
}
// MARK: - 🍬语法糖@复用
extension UITableView {
    public func py_dequeueReusableCell<T: UITableViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        let cy_cellId = cellType.className
        return self.dequeueReusableCell(withIdentifier: cy_cellId, for: indexPath) as! T
    }

    public func py_dequeueReusableHeaderFooterView<T: UIView>(headerFooterViewWithType: T.Type) -> T {
        let reuseId = headerFooterViewWithType.className
        return self.dequeueReusableHeaderFooterView(withIdentifier: reuseId) as! T
    }
}
// MARK: - 🍬语法糖@UI
extension UITableView {
    // MARK: - iOS 11+ 禁止自动调整 contentInset
    @discardableResult
    public func byNoContentInsetAdjustment() -> Self {
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        return self
    }
    // MARK: - iOS 15+ 去掉 section header 顶部默认间距
    @discardableResult
    public func byNoSectionHeaderTopPadding() -> Self {
        if #available(iOS 15.0, *) {
            self.setValue(0, forKey: "sectionHeaderTopPadding")
        }
        return self
    }

    @discardableResult
    public func byRowHeight(_ height: CGFloat) -> Self {
        self.rowHeight = height
        return self
    }

    @discardableResult
    public func bySeparatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = style
        return self
    }

    @discardableResult
    public func byTableFooterView(_ view: UIView?) -> Self {
        self.tableFooterView = view
        return self
    }

    @discardableResult
    public func byTableHeaderView(_ view: UIView?) -> Self {
        self.tableHeaderView = view
        return self
    }
    // MARK: - 隐藏分割线
    public func hiddenSeparator() {
        tableFooterView = UIView().byBgColor(UIColor.clear)
    }
    // MARK: - 设置整个区圆角
    public func sectionConner(cell: UITableViewCell,
                       bgColor: UIColor = UIColor.systemBackground,
                       indexPath: IndexPath,
                       cornerRadius: CGFloat = 10.0) {

        let backgroundLayer = CAShapeLayer()
        let bounds = CGRect(x: self.separatorInset.left, y: 0, width: self.bounds.width - self.separatorInset.left*2, height: cell.bounds.height)

        let path: UIBezierPath
        let isFirst = indexPath.row == 0
        let isLast  = indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1

        if isFirst && isLast {
            path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        } else if isFirst {
            path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if isLast {
            path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else {
            path = UIBezierPath(rect: bounds)
        }

        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = bgColor.cgColor

        let backgroundView = UIView(frame: bounds)
        backgroundView.layer.insertSublayer(backgroundLayer, at: 0)
        backgroundView.backgroundColor = .clear

        cell.backgroundView = backgroundView
    }
}
// MARK: - UITableView@空数据源占位图
private var tableEmptyViewKey: Void?
extension UITableView {
    // MARK: - 关联的空视图
    private var jobs_emptyView: UIView? {
        get { objc_getAssociatedObject(self, &tableEmptyViewKey) as? UIView }
        set {
            // 移除旧视图
            (objc_getAssociatedObject(self, &tableEmptyViewKey) as? UIView)?.removeFromSuperview()

            if let view = newValue {
                addSubview(view)
                // 先清掉可能遗留的约束，再重建
                view.snp.removeConstraints()
                // 居中 + 宽度自适应（<= 父视图 90%），并尽量不贴边
                view.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.lessThanOrEqualToSuperview().multipliedBy(0.9)
                    make.leading.greaterThanOrEqualToSuperview().offset(16)
                    make.trailing.lessThanOrEqualToSuperview().inset(16)
                }
            }
            objc_setAssociatedObject(self,
                                     &tableEmptyViewKey,
                                     newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // MARK: - 设置空视图
    @discardableResult
    public func jobs_setEmptyView(_ view: UIView?) -> Self {
        self.jobs_emptyView = view
        return self
    }
    // MARK: - 手动指定计数刷新
    @discardableResult
    public func jobs_reloadEmptyView(rowCount: Int, sectionCount: Int = 1) -> Self {
        let isEmpty = (sectionCount == 0) || (rowCount == 0)
        self.jobs_emptyView?.isHidden = !isEmpty
        return self
    }
    // MARK: - 自动统计全表数据行数刷新（可选增强）
    /// 无需手算 rowCount：遍历 dataSource 的所有 section/row 自动判断
    @discardableResult
    public func jobs_reloadEmptyViewAuto() -> Self {
        guard let ds = dataSource else {
            self.jobs_emptyView?.isHidden = false
            return self
        }
        let sections = ds.numberOfSections?(in: self) ?? 1
        var totalRows = 0
        for s in 0..<sections {
            totalRows += ds.tableView(self, numberOfRowsInSection: s)
            if totalRows > 0 { break } // 早退出
        }
        let isEmpty = (sections == 0) || (totalRows == 0)
        self.jobs_emptyView?.isHidden = !isEmpty
        return self
    }
}
// MARK: - DataSource / Delegate Plus
extension UITableView {
    // MARK: - iOS 10.0+ 预取数据源
    @available(iOS 10.0, *)
    @discardableResult
    public func byPrefetchDataSource(_ ds: UITableViewDataSourcePrefetching?) -> Self {
        self.prefetchDataSource = ds
        return self
    }
    // MARK: - iOS 15.0+ 是否启用预取
    @available(iOS 15.0, *)
    @discardableResult
    public func byPrefetchingEnabled(_ enabled: Bool) -> Self {
        self.isPrefetchingEnabled = enabled
        return self
    }
    // MARK: - iOS 11.0+ 拖拽代理
    @available(iOS 11.0, *)
    @discardableResult
    public func byDragDelegate(_ delegate: UITableViewDragDelegate?) -> Self {
        self.dragDelegate = delegate
        return self
    }
    // MARK: - iOS 11.0+ 放置代理
    @available(iOS 11.0, *)
    @discardableResult
    public func byDropDelegate(_ delegate: UITableViewDropDelegate?) -> Self {
        self.dropDelegate = delegate
        return self
    }
    // MARK: - iOS 11.0+ 是否允许拖拽交互
    @available(iOS 11.0, *)
    @discardableResult
    public func byDragInteractionEnabled(_ enabled: Bool) -> Self {
        self.dragInteractionEnabled = enabled
        return self
    }
}
// MARK: - Heights & Insets
extension UITableView {

    @discardableResult
    public func bySectionHeaderHeight(_ h: CGFloat) -> Self {
        self.sectionHeaderHeight = h
        return self
    }

    @discardableResult
    public func bySectionFooterHeight(_ h: CGFloat) -> Self {
        self.sectionFooterHeight = h
        return self
    }
    /// iOS 7.0+
    @available(iOS 7.0, *)
    @discardableResult
    public func byEstimatedRowHeight(_ h: CGFloat) -> Self {
        self.estimatedRowHeight = h
        return self
    }
    /// iOS 7.0+
    @available(iOS 7.0, *)
    @discardableResult
    public func byEstimatedSectionHeaderHeight(_ h: CGFloat) -> Self {
        self.estimatedSectionHeaderHeight = h
        return self
    }
    /// iOS 7.0+
    @available(iOS 7.0, *)
    @discardableResult
    public func byEstimatedSectionFooterHeight(_ h: CGFloat) -> Self {
        self.estimatedSectionFooterHeight = h
        return self
    }
    /// iOS 15.0+ 填充行高度
    @available(iOS 15.0, *)
    @discardableResult
    public func byFillerRowHeight(_ h: CGFloat) -> Self {
        self.fillerRowHeight = h
        return self
    }
    /// iOS 15.0+ section header 顶部间距
    @available(iOS 15.0, *)
    @discardableResult
    public func bySectionHeaderTopPadding(_ padding: CGFloat) -> Self {
        self.sectionHeaderTopPadding = padding
        return self
    }
    /// iOS 11.0+ 分割线 inset 参考系
    @available(iOS 11.0, *)
    @discardableResult
    public func bySeparatorInsetReference(_ ref: UITableView.SeparatorInsetReference) -> Self {
        self.separatorInsetReference = ref
        return self
    }
    /// 分割线 inset
    @discardableResult
    public func bySeparatorInset(_ inset: UIEdgeInsets) -> Self {
        self.separatorInset = inset
        return self
    }
    /// iOS 11.0+ 单元自适应失效控制
    @available(iOS 16.0, *)
    @discardableResult
    public func bySelfSizingInvalidation(_ value: UITableView.SelfSizingInvalidation) -> Self {
        self.selfSizingInvalidation = value
        return self
    }
    /// iOS 11.0+ 子视图是否插入安全区
    @available(iOS 11.0, *)
    @discardableResult
    public func byInsetsContentViewsToSafeArea(_ enable: Bool) -> Self {
        self.insetsContentViewsToSafeArea = enable
        return self
    }
}
// MARK: - Background / Context Menu
extension UITableView {

    @discardableResult
    public func byBackgroundView(_ view: UIView?) -> Self {
        self.backgroundView = view
        return self
    }
    /// iOS 14.0+ 配置 contextMenuInteraction（只读属性，提供配置闭包）
    @available(iOS 14.0, *)
    @discardableResult
    public func byContextMenuInteraction(_ config: (UIContextMenuInteraction) -> Void) -> Self {
        if let interaction = self.contextMenuInteraction {
            config(interaction)
        }
        return self
    }
}
// MARK: - Separator & Layout Margins
extension UITableView {

    @discardableResult
    public func bySeparatorColor(_ color: UIColor?) -> Self {
        self.separatorColor = color
        return self
    }
    /// iOS 8.0+
    @available(iOS 8.0, *)
    @discardableResult
    public func bySeparatorEffect(_ effect: UIVisualEffect?) -> Self {
        self.separatorEffect = effect
        return self
    }
    /// iOS 9.0+
    @available(iOS 9.0, *)
    @discardableResult
    public func byCellLayoutMarginsFollowReadableWidth(_ follow: Bool) -> Self {
        self.cellLayoutMarginsFollowReadableWidth = follow
        return self
    }
}
// MARK: - Selection / Focus / Editing
extension UITableView {

    @discardableResult
    public func byAllowsSelection(_ allow: Bool) -> Self {
        self.allowsSelection = allow
        return self
    }

    @discardableResult
    public func byAllowsSelectionDuringEditing(_ allow: Bool) -> Self {
        self.allowsSelectionDuringEditing = allow
        return self
    }
    /// iOS 5.0+
    @available(iOS 5.0, *)
    @discardableResult
    public func byAllowsMultipleSelection(_ allow: Bool) -> Self {
        self.allowsMultipleSelection = allow
        return self
    }
    /// iOS 5.0+
    @available(iOS 5.0, *)
    @discardableResult
    public func byAllowsMultipleSelectionDuringEditing(_ allow: Bool) -> Self {
        self.allowsMultipleSelectionDuringEditing = allow
        return self
    }
    /// 设置编辑状态（带动画）
    @discardableResult
    public func byEditing(_ editing: Bool, animated: Bool = true) -> Self {
        self.setEditing(editing, animated: animated)
        return self
    }
    /// iOS 14.0+ 焦点移动自动选中
    @available(iOS 14.0, *)
    @discardableResult
    public func bySelectionFollowsFocus(_ enable: Bool) -> Self {
        self.selectionFollowsFocus = enable
        return self
    }
    /// iOS 15.0+ 允许焦点
    @available(iOS 15.0, *)
    @discardableResult
    public func byAllowsFocus(_ allow: Bool) -> Self {
        self.allowsFocus = allow
        return self
    }
    /// iOS 15.0+ 编辑时允许焦点
    @available(iOS 15.0, *)
    @discardableResult
    public func byAllowsFocusDuringEditing(_ allow: Bool) -> Self {
        self.allowsFocusDuringEditing = allow
        return self
    }
    /// iOS 9.0+ 记住上次聚焦行
    @available(iOS 9.0, *)
    @discardableResult
    public func byRemembersLastFocusedIndexPath(_ remember: Bool) -> Self {
        self.remembersLastFocusedIndexPath = remember
        return self
    }
    /// section 索引最少显示行数
    @discardableResult
    public func bySectionIndexMinimumDisplayRowCount(_ count: Int) -> Self {
        self.sectionIndexMinimumDisplayRowCount = count
        return self
    }
    /// iOS 6.0+
    @available(iOS 6.0, *)
    @discardableResult
    public func bySectionIndexColor(_ color: UIColor?) -> Self {
        self.sectionIndexColor = color
        return self
    }
    /// iOS 7.0+
    @available(iOS 7.0, *)
    @discardableResult
    public func bySectionIndexBackgroundColor(_ color: UIColor?) -> Self {
        self.sectionIndexBackgroundColor = color
        return self
    }
    /// iOS 6.0+
    @available(iOS 6.0, *)
    @discardableResult
    public func bySectionIndexTrackingBackgroundColor(_ color: UIColor?) -> Self {
        self.sectionIndexTrackingBackgroundColor = color
        return self
    }
    /// 选择 / 取消选择
    @discardableResult
    public func bySelectRow(_ indexPath: IndexPath?, animated: Bool = true, scrollPosition: UITableView.ScrollPosition = .none) -> Self {
        self.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        return self
    }
    @discardableResult
    public func byDeselectRow(_ indexPath: IndexPath, animated: Bool = true) -> Self {
        self.deselectRow(at: indexPath, animated: animated)
        return self
    }
}
// MARK: - Scrolling Helpers
extension UITableView {

    @discardableResult
    public func byScrollToRow(_ indexPath: IndexPath, at position: UITableView.ScrollPosition, animated: Bool = true) -> Self {
        self.scrollToRow(at: indexPath, at: position, animated: animated)
        return self
    }

    @discardableResult
    public func byScrollToNearestSelectedRow(at position: UITableView.ScrollPosition, animated: Bool = true) -> Self {
        self.scrollToNearestSelectedRow(at: position, animated: animated)
        return self
    }
}
// MARK: - Batch Updates & Reload APIs
extension UITableView {
    /// iOS 11.0+
    @available(iOS 11.0, *)
    @discardableResult
    public func byPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) -> Self {
        self.performBatchUpdates(updates, completion: completion)
        return self
    }

    @discardableResult
    public func byBeginUpdates() -> Self {
        self.beginUpdates()
        return self
    }

    @discardableResult
    public func byEndUpdates() -> Self {
        self.endUpdates()
        return self
    }

    @discardableResult
    public func byInsertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation = .automatic) -> Self {
        self.insertSections(sections, with: animation)
        return self
    }

    @discardableResult
    public func byDeleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation = .automatic) -> Self {
        self.deleteSections(sections, with: animation)
        return self
    }
    /// iOS 5.0+
    @available(iOS 5.0, *)
    @discardableResult
    public func byMoveSection(_ from: Int, to newSection: Int) -> Self {
        self.moveSection(from, toSection: newSection)
        return self
    }
    /// iOS 3.0+
    @available(iOS 3.0, *)
    @discardableResult
    public func byReloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation = .automatic) -> Self {
        self.reloadSections(sections, with: animation)
        return self
    }

    @discardableResult
    public func byInsertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .automatic) -> Self {
        self.insertRows(at: indexPaths, with: animation)
        return self
    }

    @discardableResult
    public func byDeleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .automatic) -> Self {
        self.deleteRows(at: indexPaths, with: animation)
        return self
    }
    /// iOS 5.0+
    @available(iOS 5.0, *)
    @discardableResult
    public func byMoveRow(from: IndexPath, to: IndexPath) -> Self {
        self.moveRow(at: from, to: to)
        return self
    }
    /// iOS 3.0+
    @available(iOS 3.0, *)
    @discardableResult
    public func byReloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .automatic) -> Self {
        self.reloadRows(at: indexPaths, with: animation)
        return self
    }
    /// iOS 15.0+ 仅重新配置（不重载）
    @available(iOS 15.0, *)
    @discardableResult
    public func byReconfigureRows(at indexPaths: [IndexPath]) -> Self {
        self.reconfigureRows(at: indexPaths)
        return self
    }
    /// 重新载入数据 / 索引标题
    @discardableResult
    public func byReloadData() -> Self {
        self.reloadData()
        return self
    }
    /// iOS 3.0+
    @available(iOS 3.0, *)
    @discardableResult
    public func byReloadSectionIndexTitles() -> Self {
        self.reloadSectionIndexTitles()
        return self
    }
}
// MARK: - iOS 18.0+ Content Hugging Elements
extension UITableView {
    /// iOS 18.0+ 内容 Hugging 策略
    @available(iOS 18.0, *)
    @discardableResult
    public func byContentHuggingElements(_ value: UITableViewContentHuggingElements) -> Self {
        self.contentHuggingElements = value
        return self
    }
}
// MARK: - Jobs Refresh Extension
public extension UITableView {
    // MARK: - 下拉刷新（Pull Down）
    /// 安装下拉刷新（默认 ESRefreshHeaderAnimator）
    @discardableResult
    func pullDown(_ action: @escaping () -> Void,
                  config: ((ESRefreshHeaderAnimator) -> Void)? = nil) -> Self {
        if self.header == nil {
            let animator = ESRefreshHeaderAnimator()
            config?(animator)
            let header = ESRefreshHeaderView(frame: .zero, handler: action, animator: animator)
            let headerH = animator.executeIncremental
            header.frame = CGRect(x: 0, y: -headerH, width: self.bounds.width, height: headerH)
            self.addSubview(header)
            self.header = header
        }
        return self
    }
    /// 安装下拉刷新（JobsHeaderAnimator 自定义样式）
    @discardableResult
    func pullDownWithJobsAnimator(_ action: @escaping () -> Void,
                                  config: ((JobsHeaderAnimator) -> Void)? = nil) -> Self {
        if self.header == nil {
            let animator = JobsHeaderAnimator()
            config?(animator)
            let header = ESRefreshHeaderView(frame: .zero, handler: action, animator: animator)
            let headerH = animator.executeIncremental
            header.frame = CGRect(x: 0, y: -headerH, width: self.bounds.width, height: headerH)
            self.addSubview(header)
            self.header = header
        }
        return self
    }
    /// 过期自动刷新
    @discardableResult
    func pullDownAutoIfExpired() -> Self {
        if let key = self.header?.refreshIdentifier, JobsRefreshCache.isExpired(forKey: key) {
            DispatchQueue.main.async { [weak self] in
                self?.header?.startRefreshing(isAuto: true)
            }
        }
        return self
    }
    /// 停止下拉刷新
    @discardableResult
    func pullDownStop(ignoreDate: Bool = false, ignoreFooter: Bool = false) -> Self {
        self.header?.stopRefreshing()
        if ignoreDate == false, let key = self.header?.refreshIdentifier {
            JobsRefreshCache.setDate(Date(), forKey: key) // ✅ 自家缓存
        }
        self.footer?.isHidden = ignoreFooter
        return self
    }
    /// 手动触发下拉刷新
    @discardableResult
    func pullDownStart(auto: Bool = false) -> Self {
        DispatchQueue.main.async { [weak self] in
            if auto { self?.header?.startRefreshing(isAuto: true) }
            else { self?.header?.startRefreshing(isAuto: false) }
        }
        return self
    }
    // MARK: - 上拉加载（Pull Up）
    /// 安装上拉加载（默认 ESRefreshFooterAnimator）
    @discardableResult
    func pullUp(_ action: @escaping () -> Void,
                config: ((ESRefreshFooterAnimator) -> Void)? = nil) -> Self {
        if self.footer == nil {
            let animator = ESRefreshFooterAnimator()
            config?(animator)
            let footer = ESRefreshFooterView(frame: .zero, handler: action, animator: animator)
            let footerH = animator.executeIncremental
            footer.frame = CGRect(
                x: 0,
                y: self.contentSize.height + self.contentInset.bottom,
                width: self.bounds.width,
                height: footerH
            )
            self.addSubview(footer)
            self.footer = footer
        }
        return self
    }
    /// 安装上拉加载（JobsFooterAnimator 自定义样式）
    @discardableResult
    func pullUpWithJobsAnimator(_ action: @escaping () -> Void,
                                config: ((JobsFooterAnimator) -> Void)? = nil) -> Self {
        if self.footer == nil {
            let animator = JobsFooterAnimator()
            config?(animator)
            let footer = ESRefreshFooterView(frame: .zero, handler: action, animator: animator)
            let footerH = animator.executeIncremental
            footer.frame = CGRect(
                x: 0,
                y: self.contentSize.height + self.contentInset.bottom,
                width: self.bounds.width,
                height: footerH
            )
            self.addSubview(footer)
            self.footer = footer
        }
        return self
    }
    /// 停止上拉加载
    @discardableResult
    func pullUpStop() -> Self {
        self.footer?.stopRefreshing()
        return self
    }
    /// 通知“没有更多数据”
    @discardableResult
    func pullUpNoMore() -> Self {
        self.footer?.stopRefreshing()
        self.footer?.noMoreData = true
        return self
    }
    /// 重置“没有更多数据”
    @discardableResult
    func pullUpReset() -> Self {
        self.footer?.noMoreData = false
        return self
    }
    // MARK: - 移除所有刷新控件
    @discardableResult
    func removeRefreshers() -> Self {
        self.header?.stopRefreshing()
        self.header?.removeFromSuperview()
        self.header = nil

        self.footer?.stopRefreshing()
        self.footer?.removeFromSuperview()
        self.footer = nil
        return self
    }
}
// MARK: - 下拉刷新（Header）
public final class JobsHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    public var state: ESRefreshViewState = .pullToRefresh

    public var idleDescription: String = "下拉刷新"
    public var releaseToRefreshDescription: String = "松开立即刷新"
    public var loadingDescription: String = "刷新中…"
    public var noMoreDataDescription: String = "已经是最新数据"

    public var view: UIView { self }
    public var insets: UIEdgeInsets = .zero
    public var trigger: CGFloat = 60
    public var executeIncremental: CGFloat = 60

    private let titleLabel = UILabel()
    private let indicator  = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        addSubview(indicator)
    }

    private func setupConstraints() {
        indicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.centerX).offset(-6)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.snp.centerX).offset(6)
        }
    }

    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {}
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        self.state = state
        switch state {
        case .pullToRefresh:
            titleLabel.text = idleDescription
            indicator.stopAnimating()
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshDescription
            indicator.stopAnimating()
        case .refreshing, .autoRefreshing:
            titleLabel.text = loadingDescription
            indicator.startAnimating()
        case .noMoreData:
            titleLabel.text = noMoreDataDescription
            indicator.stopAnimating()
        }
    }

    public func refreshAnimationBegin(view: ESRefreshComponent) { indicator.startAnimating() }
    public func refreshAnimationEnd(view: ESRefreshComponent) { indicator.stopAnimating() }
}
// MARK: - 上拉加载（Footer）
public final class JobsFooterAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    public var state: ESRefreshViewState = .pullToRefresh

    public var idleDescription: String = "上拉加载更多"
    public var releaseToRefreshDescription: String = "松开立即加载"
    public var loadingMoreDescription: String = "加载中…"
    public var noMoreDataDescription: String = "没有更多数据"

    public var view: UIView { self }
    public var insets: UIEdgeInsets = .zero
    public var trigger: CGFloat = 52
    public var executeIncremental: CGFloat = 52

    private let titleLabel = UILabel()
    private let indicator  = UIActivityIndicatorView(style: .medium)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        addSubview(indicator)
    }

    private func setupConstraints() {
        indicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.centerX).offset(-6)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.snp.centerX).offset(6)
        }
    }

    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {}
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        self.state = state
        switch state {
        case .pullToRefresh:
            titleLabel.text = idleDescription
            indicator.stopAnimating()
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshDescription
            indicator.stopAnimating()
        case .refreshing, .autoRefreshing:
            titleLabel.text = loadingMoreDescription
            indicator.startAnimating()
        case .noMoreData:
            titleLabel.text = noMoreDataDescription
            indicator.stopAnimating()
        }
    }

    public func refreshAnimationBegin(view: ESRefreshComponent) { indicator.startAnimating() }
    public func refreshAnimationEnd(view: ESRefreshComponent) { indicator.stopAnimating() }
}
// MARK: - 轻量的“最近刷新时间”缓存，替代 ESRefreshDataManager（避免跨模块 internal 访问问题）
public enum JobsRefreshCache {
    private static let prefix = "jobs.refresh."
    private static let ud = UserDefaults.standard

    @inline(__always)
    private static func key(_ k: String) -> String { prefix + k }

    public static func setDate(_ date: Date, forKey key: String) {
        ud.set(date.timeIntervalSince1970, forKey: self.key(key))
    }

    public static func date(forKey key: String) -> Date? {
        let ts = ud.double(forKey: self.key(key))
        return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }

    /// 可选：设置过期时长（秒）
    public static func setExpiredInterval(_ interval: TimeInterval?, forKey key: String) {
        let k = self.key(key) + ".expired"
        if let interval { ud.set(interval, forKey: k) } else { ud.removeObject(forKey: k) }
    }

    public static func expiredInterval(forKey key: String) -> TimeInterval? {
        let k = self.key(key) + ".expired"
        let v = ud.double(forKey: k)
        return v > 0 ? v : nil
    }

    /// 可选：是否已过期（模仿 ES 行为）
    public static func isExpired(forKey key: String) -> Bool {
        guard let last = date(forKey: key),
              let interval = expiredInterval(forKey: key) else { return false }
        return Date().timeIntervalSince(last) >= interval
    }
}
