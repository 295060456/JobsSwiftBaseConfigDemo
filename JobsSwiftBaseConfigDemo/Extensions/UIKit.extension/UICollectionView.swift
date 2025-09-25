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

extension UICollectionView {
    @discardableResult
    func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) -> Self {
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
        return self
    }

    @discardableResult
    func byDelegate(_ delegate: UICollectionViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byDataSource(_ dataSource: UICollectionViewDataSource) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult
    func byCollectionViewLayout(_ layout: UICollectionViewLayout) -> Self {
        self.collectionViewLayout = layout
        return self
    }

    @discardableResult
    func byScrollDirection(_ direction: UICollectionView.ScrollDirection) -> Self {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = direction
        }
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
