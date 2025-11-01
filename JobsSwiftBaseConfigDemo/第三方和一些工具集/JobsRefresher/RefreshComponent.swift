//
//  RefreshComponent.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit

@MainActor
public protocol JobsAnimatable: AnyObject {
    func apply(state: JobsState)
    var heightOrWidth: CGFloat { get }   // header/footer 用高度；left/right 用宽度
}

@MainActor
public class JobsDefaultIndicatorView: UIView, JobsAnimatable {
    private let indicator = UIActivityIndicatorView(style: .medium)
    public var heightOrWidth: CGFloat = 60

    private let label = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        addSubview(indicator)
        addSubview(label)
        indicator.hidesWhenStopped = true
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
    }

    required init?(coder: NSCoder) { fatalError() }

    public func apply(state: JobsState) {
        switch state {
        case .idle:
            indicator.stopAnimating()
            label.text = "下拉可以刷新"
        case .pulling(let p):
            indicator.stopAnimating()
            label.text = p >= 1 ? "松开立即刷新" : String(format: "继续下拉 %.0f%%", min(1, p)*100)
        case .ready:
            indicator.stopAnimating()
            label.text = "松开立即刷新"
        case .refreshing:
            indicator.startAnimating()
            label.text = "刷新中..."
        case .noMore:
            indicator.stopAnimating()
            label.text = "没有更多了"
        case .removed:
            indicator.stopAnimating()
            label.text = nil
        }
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        indicator.sizeToFit()
        label.sizeToFit()
        let totalW = indicator.bounds.width + 8 + label.bounds.width
        let x = (bounds.width - totalW) * 0.5
        let y = (bounds.height - max(indicator.bounds.height, label.bounds.height)) * 0.5
        indicator.frame.origin = CGPoint(x: x, y: y)
        label.frame.origin = CGPoint(x: indicator.frame.maxX + 8,
                                     y: (bounds.height - label.bounds.height)/2)
    }
}
