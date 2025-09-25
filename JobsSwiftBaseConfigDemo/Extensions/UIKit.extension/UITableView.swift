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

/// 🍬语法糖@注册：UITableViewCell、HeaderFooterView、HeaderFooterView
extension UITableView {
    @discardableResult
    func registerCell<T: UITableViewCell>(_ cellClass: T.Type) -> Self {
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        return self
    }
    public func py_register(cellClassType: UITableViewCell.Type) {
        let cellId = cellClassType.className
        let cellClass: AnyClass = cellClassType.classForCoder()
        self.register(cellClass, forCellReuseIdentifier: cellId)
    }

    public func py_register(cellNibType: UITableViewCell.Type) {
        let cellId = cellNibType.className
        let cellNib = UINib(nibName: cellId, bundle: nil)
        self.register(cellNib, forCellReuseIdentifier: cellId)
    }

    public func py_register(headerFooterViewClassType: UIView.Type) {
        let reuseId = headerFooterViewClassType.className
        let viewType: AnyClass = headerFooterViewClassType.classForCoder()
        self.register(viewType, forHeaderFooterViewReuseIdentifier: reuseId)
    }

    public func py_register(headerFooterViewNibType: UIView.Type) {
        let reuseId = headerFooterViewNibType.className
        let viewNib = UINib(nibName: reuseId, bundle: nil)
        self.register(viewNib, forHeaderFooterViewReuseIdentifier: reuseId)
    }
}
/// 🍬语法糖@数据源
extension UITableView {
    @discardableResult
    func byDelegate(_ delegate: UITableViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byDataSource(_ dataSource: UITableViewDataSource) -> Self {
        self.dataSource = dataSource
        return self
    }
}
/// 🍬语法糖@复用
extension UITableView {
    public func py_dequeueReusableCell<T: UITableViewCell>(withType cellType: T.Type, for indexPath: IndexPath) -> T {
        let cy_cellId = cellType.className
        return self.dequeueReusableCell(withIdentifier: cy_cellId, for: indexPath) as! T
    }

    func py_dequeueReusableHeaderFooterView<T: UIView>(headerFooterViewWithType: T.Type) -> T {
        let reuseId = headerFooterViewWithType.className
        return self.dequeueReusableHeaderFooterView(withIdentifier: reuseId) as! T
    }
}
/// 🍬语法糖@UI
extension UITableView {
    @discardableResult
    func byRowHeight(_ height: CGFloat) -> Self {
        self.rowHeight = height
        return self
    }

    @discardableResult
    func bySeparatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = style
        return self
    }

    @discardableResult
    func byTableFooterView(_ view: UIView?) -> Self {
        self.tableFooterView = view
        return self
    }

    @discardableResult
    func byTableHeaderView(_ view: UIView?) -> Self {
        self.tableHeaderView = view
        return self
    }
    // MARK: - 隐藏分割线
    func hiddenSeparator() {
        tableFooterView = UIView().byBgColor(UIColor.clear)
    }
    // MARK: -设置整个区圆角
    func sectionConner(cell: UITableViewCell,
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
/// UITableView@空数据源占位图
private var tableEmptyViewKey: Void?
extension UITableView {
    private var jobs_emptyView: UIView? {
        get { objc_getAssociatedObject(self, &tableEmptyViewKey) as? UIView }
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
            objc_setAssociatedObject(self, &tableEmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @discardableResult
    func jobs_setEmptyView(_ view: UIView?) -> Self {
        self.jobs_emptyView = view
        return self
    }

    @discardableResult
    func jobs_reloadEmptyView(rowCount: Int, sectionCount: Int = 1) -> Self {
        let isEmpty = rowCount == 0 || sectionCount == 0
        self.jobs_emptyView?.isHidden = !isEmpty
        return self
    }
}
