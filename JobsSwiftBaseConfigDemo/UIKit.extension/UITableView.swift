//
//  UITableView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/15.
//

import UIKit
import ObjectiveC

extension UITableView {
    @discardableResult
    func registerCell<T: UITableViewCell>(_ cellClass: T.Type) -> Self {
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        return self
    }

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
}
// MARK: - UITableView Empty View
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
