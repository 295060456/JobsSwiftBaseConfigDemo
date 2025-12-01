//
//  DefaultSkins.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit

@MainActor
public final class JobsDefaultHeader: JobsDefaultIndicatorView {
    public override init(frame: CGRect) { super.init(frame: frame); heightOrWidth = 60 }
    required init?(coder: NSCoder) { fatalError() }
}

@MainActor
public final class JobsDefaultFooter: JobsDefaultIndicatorView {
    public override init(frame: CGRect) { super.init(frame: frame); heightOrWidth = 60 }
    required init?(coder: NSCoder) { fatalError() }
}
/// —— 横向侧拉专用：竖排文案 ——
/// 结构：指示器（上） + 竖排 UILabel（下），在非 refreshing 时隐藏转圈，仅显示竖排提示。
@MainActor
public class JobsSideIndicatorView: UIView, JobsAnimatable {
    private lazy var indicator : UIActivityIndicatorView = {
        self.byAddSubviewRetSub(UIActivityIndicatorView(style: .medium).byHidesWhenStopped(true))
    }()
    private lazy var label:UILabel = {
        self.byAddSubviewRetSub(
            UILabel()
                .byFont(.systemFont(ofSize: 14, weight: .medium))
                .byTextColor(.secondaryLabel)
                .byNumberOfLines(0)
                .byTextAlignment(.center)
        )
    }()
    public var heightOrWidth: CGFloat = 60
    /// 外部可自定义文案（不含状态词），内部会自动竖排化。
    public var idleText: String = "继续侧拉"
    public var readyText: String = "松手刷新"
    public var refreshingText: String = "刷新中"
    public var doneText: String = "完成"
    public var noMoreText: String = "没有更多"

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        indicator.byVisible(YES)
        label.byVisible(YES)
    }

    required init?(coder: NSCoder) { fatalError() }

    public func apply(state: JobsState) {
        func setVertical(_ s: String) { label.text = s.verticalized }

        switch state {
        case .idle:
            indicator.stopAnimating()
            setVertical(idleText)
        case .pulling(let p):
            indicator.stopAnimating()
            // 进度文案也竖排（示例：继续侧拉 80%）
            let percent = Int(min(1, max(0, p)) * 100)
            setVertical("\(idleText) \(percent)%")
        case .ready:
            indicator.stopAnimating()
            setVertical(readyText)
        case .refreshing:
            indicator.startAnimating()
            setVertical(refreshingText)
        case .noMore:
            indicator.stopAnimating()
            setVertical(noMoreText)
        case .removed:
            indicator.stopAnimating()
            label.text = nil
        }
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let availableW = bounds.width
        let availableH = bounds.height

        indicator.sizeToFit()
        let labelSize = label.sizeThatFits(CGSize(width: availableW, height: .greatestFiniteMagnitude))

        // 垂直堆叠：indicator 在上，label 在下，居中
        let spacing: CGFloat = 8
        let totalH = indicator.bounds.height + spacing + labelSize.height
        let originY = (availableH - totalH) * 0.5

        indicator.frame.origin = CGPoint(
            x: (availableW - indicator.bounds.width) * 0.5,
            y: originY
        )
        label.frame = CGRect(
            x: (availableW - labelSize.width) * 0.5,
            y: indicator.frame.maxY + spacing,
            width: labelSize.width,
            height: labelSize.height
        )
    }
}
@MainActor
public final class JobsDefaultLeft: JobsSideIndicatorView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        heightOrWidth = 60
        idleText = "继续左拉"
        readyText = "松手刷新"
        refreshingText = "刷新中"
    }
    required init?(coder: NSCoder) { fatalError() }
}
@MainActor
public final class JobsDefaultRight: JobsSideIndicatorView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        heightOrWidth = 60
        idleText = "继续右拉"
        readyText = "松手刷新"
        refreshingText = "刷新中"
    }
    required init?(coder: NSCoder) { fatalError() }
}
