//
//  单个红包视图.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/10/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import SnapKit
// MARK: —— 单个红包视图
final class RedPacketView: UIControl {
    public lazy var imageView: UIImageView = {
        UIImageView().byAddTo(self) { [unowned self] make in
            make.edges.equalToSuperview()
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        imageView.byVisible(YES)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        imageView.byVisible(YES)
    }
}
