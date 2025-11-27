//
//  JobsMarqueeDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/10/11.
//

import UIKit
import SnapKit

/// Demo：11 组 JobsMarqueeView
/// 1. 向上连续滚动
/// 2. 向下连续滚动
/// 3. 向左连续滚动
/// 4. 向右连续滚动
/// 5. 向上间隔滚动
/// 6. 向下间隔滚动
/// 7. 向左间隔滚动
/// 8. 向右间隔滚动
/// 9. 极端：只有 1 个按钮
/// 10. 极端：只有 2 个按钮
/// 11. 极端：没有按钮（空数据源）
final class JobsMarqueeDemoVC: BaseVC {

    // MARK: - Layout Metrics

    private let horizontalInset: CGFloat = 16
    private let verticalSpacing: CGFloat = 12
    private let marqueeHeight: CGFloat = 50

    // MARK: - UI: ScrollView 容器

    /// 所有 JobsMarqueeView 统一加在这个 scrollView 上
    private lazy var scrollView: UIScrollView = { [unowned self] in
        let v = UIScrollView()
        v.showsVerticalScrollIndicator = true
        v.alwaysBounceVertical = true

        v.byAddTo(self.view) { [unowned self] make in
            make.top.equalTo(self.gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        return v
    }()

    /// scrollView 的内容容器
    private lazy var contentView: UIView = { [unowned self] in
        let v = UIView()
        self.scrollView.addSubview(v)
        v.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView.snp.width)
        }
        return v
    }()

    // MARK: - 1. 向上连续滚动

    private lazy var upContinuousMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemYellow.withAlphaComponent(0.2), for: .normal)
            .byTitle("向上连续 · 公告 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 1", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("megaphone.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向上连续 · 公告 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemYellow.withAlphaComponent(0.2), for: .normal)
            .byTitle("向上连续 · 公告 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 2", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("megaphone.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向上连续 · 公告 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemYellow.withAlphaComponent(0.2), for: .normal)
            .byTitle("向上连续 · 公告 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 3", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("megaphone.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向上连续 · 公告 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.up)
            .byScrollMode(.continuous(speed: 40))
            .byItemSizeMode(.fitContent)   // 典型公告跑马灯
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.contentView.snp.top).offset(10)
            make.left.equalToSuperview().offset(self.horizontalInset)
            make.right.equalToSuperview().inset(self.horizontalInset)
            make.height.equalTo(self.marqueeHeight)
        }

        return v
    }()

    // MARK: - 2. 向下连续滚动

    private lazy var downContinuousMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemGreen.withAlphaComponent(0.2), for: .normal)
            .byTitle("向下连续 · 公告 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 1", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.down.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向下连续 · 公告 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemGreen.withAlphaComponent(0.2), for: .normal)
            .byTitle("向下连续 · 公告 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 2", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.down.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向下连续 · 公告 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemGreen.withAlphaComponent(0.2), for: .normal)
            .byTitle("向下连续 · 公告 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 3", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.down.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向下连续 · 公告 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.down)
            .byScrollMode(.continuous(speed: 40))
            .byItemSizeMode(.fitContent)
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.upContinuousMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 3. 向左连续滚动（典型横向跑马灯）

    private lazy var leftContinuousMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemOrange.withAlphaComponent(0.2), for: .normal)
            .byTitle("向左连续 · 公告 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 1", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.left.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向左连续 · 公告 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemOrange.withAlphaComponent(0.2), for: .normal)
            .byTitle("向左连续 · 公告 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 2", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.left.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向左连续 · 公告 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemOrange.withAlphaComponent(0.2), for: .normal)
            .byTitle("向左连续 · 公告 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 3", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.left.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向左连续 · 公告 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.left)
            .byScrollMode(.continuous(speed: 60))
            .byItemSizeMode(.fitContent)
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.downContinuousMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 4. 向右连续滚动

    private lazy var rightContinuousMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemPink.withAlphaComponent(0.2), for: .normal)
            .byTitle("向右连续 · 公告 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 1", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.right.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向右连续 · 公告 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemPink.withAlphaComponent(0.2), for: .normal)
            .byTitle("向右连续 · 公告 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 2", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.right.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向右连续 · 公告 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemPink.withAlphaComponent(0.2), for: .normal)
            .byTitle("向右连续 · 公告 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("更多内容 3", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.right.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向右连续 · 公告 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.right)
            .byScrollMode(.continuous(speed: 60))
            .byItemSizeMode(.fitContent)
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.leftContinuousMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 5. 向上间隔滚动（公告一条一条翻）

    private lazy var upFrequencyMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemBlue.withAlphaComponent(0.2), for: .normal)
            .byTitle("向上间隔 · 公告 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("每 1 秒翻页", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.up.square.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向上间隔 · 公告 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemBlue.withAlphaComponent(0.2), for: .normal)
            .byTitle("向上间隔 · 公告 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("每 1 秒翻页", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.up.square.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向上间隔 · 公告 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemBlue.withAlphaComponent(0.2), for: .normal)
            .byTitle("向上间隔 · 公告 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("每 1 秒翻页", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.up.square.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向上间隔 · 公告 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.up)
            .byScrollMode(.frequency(interval: 1.0))
            .byItemSizeMode(.fillBounds)   // 每页 1 行
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.rightContinuousMarquee.snp.bottom).offset(self.verticalSpacing * 2)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 6. 向下间隔滚动

    private lazy var downFrequencyMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemTeal.withAlphaComponent(0.2), for: .normal)
            .byTitle("向下间隔 · 公告 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("每 1 秒翻页", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.down.square.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向下间隔 · 公告 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemTeal.withAlphaComponent(0.2), for: .normal)
            .byTitle("向下间隔 · 公告 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("每 1 秒翻页", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.down.square.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向下间隔 · 公告 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemTeal.withAlphaComponent(0.2), for: .normal)
            .byTitle("向下间隔 · 公告 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("每 1 秒翻页", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("arrow.down.square.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向下间隔 · 公告 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.down)
            .byScrollMode(.frequency(interval: 1.0))
            .byItemSizeMode(.fillBounds)
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.upFrequencyMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 7. 向左间隔滚动（轮播图：一屏一页）

    private lazy var leftFrequencyMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemPurple.withAlphaComponent(0.2), for: .normal)
            .byTitle("向左间隔 · Banner 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("轮播图左滑", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("rectangle.portrait.on.rectangle.portrait".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向左间隔 · Banner 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemPurple.withAlphaComponent(0.2), for: .normal)
            .byTitle("向左间隔 · Banner 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("轮播图左滑", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("rectangle.portrait.on.rectangle.portrait".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向左间隔 · Banner 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemPurple.withAlphaComponent(0.2), for: .normal)
            .byTitle("向左间隔 · Banner 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("轮播图左滑", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("rectangle.portrait.on.rectangle.portrait".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向左间隔 · Banner 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.left)
            .byScrollMode(.frequency(interval: 1.5))
            .byItemSizeMode(.fillBounds)   // 轮播图：一页一个按钮
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.downFrequencyMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 8. 向右间隔滚动（轮播图）

    private lazy var rightFrequencyMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemIndigo.withAlphaComponent(0.2), for: .normal)
            .byTitle("向右间隔 · Banner 1", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("轮播图右滑", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("rectangle.portrait.on.rectangle.portrait".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向右间隔 · Banner 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemIndigo.withAlphaComponent(0.2), for: .normal)
            .byTitle("向右间隔 · Banner 2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("轮播图右滑", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("rectangle.portrait.on.rectangle.portrait".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向右间隔 · Banner 2 tapped, selected=\(sender.isSelected)")
            }

        let btn3 = UIButton.sys()
            .byBackgroundColor(.systemIndigo.withAlphaComponent(0.2), for: .normal)
            .byTitle("向右间隔 · Banner 3", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("轮播图右滑", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("rectangle.portrait.on.rectangle.portrait".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔔 向右间隔 · Banner 3 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.right)
            .byScrollMode(.frequency(interval: 1.5))
            .byItemSizeMode(.fillBounds)
            .byDataSourceButtons([btn1, btn2, btn3])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.leftFrequencyMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 9. 极端：只有 1 个按钮

    private lazy var oneButtonMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn = UIButton.sys()
            .byBackgroundColor(.systemRed.withAlphaComponent(0.2), for: .normal)
            .byTitle("极端 · 只有 1 个按钮", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("测试少量数据源", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("1.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔴 极端 1 个按钮 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.left)
            .byScrollMode(.continuous(speed: 40))
            .byItemSizeMode(.fillBounds)   // 视图宽度 == 按钮宽度，内部会复制到至少 3 个
            .byDataSourceButtons([btn])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.rightFrequencyMarquee.snp.bottom).offset(self.verticalSpacing * 2)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 10. 极端：只有 2 个按钮

    private lazy var twoButtonsMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        let btn1 = UIButton.sys()
            .byBackgroundColor(.systemRed.withAlphaComponent(0.2), for: .normal)
            .byTitle("极端 · 按钮 1/2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("测试 2 个按钮", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("2.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔴 极端 2 个按钮 · 1 tapped, selected=\(sender.isSelected)")
            }

        let btn2 = UIButton.sys()
            .byBackgroundColor(.systemRed.withAlphaComponent(0.2), for: .normal)
            .byTitle("极端 · 按钮 2/2", for: .normal)
            .byTitleColor(.label, for: .normal)
            .byTitleFont(.systemFont(ofSize: 14, weight: .medium))
            .bySubTitle("测试 2 个按钮", for: .normal)
            .bySubTitleColor(.secondaryLabel, for: .normal)
            .bySubTitleFont(.systemFont(ofSize: 11, weight: .regular))
            .byImage("2.circle.fill".sysImg, for: .normal)
            .byContentEdgeInsets(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
            .byTitleEdgeInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
            .byTapSound("Sound.wav")
            .onTap { sender in
                print("🔴 极端 2 个按钮 · 2 tapped, selected=\(sender.isSelected)")
            }

        v
            .byDirection(.left)
            .byScrollMode(.continuous(speed: 40))
            .byItemSizeMode(.fillBounds)
            .byDataSourceButtons([btn1, btn2])

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.oneButtonMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
        }

        return v
    }()

    // MARK: - 11. 极端：没有按钮（空数据源）

    private lazy var zeroButtonsMarquee: JobsMarqueeView = { [unowned self] in
        let v = JobsMarqueeView()

        v
            .byDirection(.left)
            .byScrollMode(.continuous(speed: 40))
            .byItemSizeMode(.fillBounds)
            .byDataSourceButtons([])    // 空数组，验证内部对空数据的处理

        v.backgroundColor = .secondarySystemBackground

        v.byAddTo(self.contentView) { [unowned self] make in
            make.top.equalTo(self.twoButtonsMarquee.snp.bottom).offset(self.verticalSpacing)
            make.left.right.height.equalTo(self.upContinuousMarquee)
            make.bottom.equalToSuperview().inset(self.verticalSpacing)
        }

        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        jobsSetupGKNav(title: "JobsMarqueeView@Demo")

        // 先确保 scrollView / contentView 创建出来
        _ = scrollView
        _ = contentView

        // 触发懒加载 & 使用你封装的 byVisible API
        upContinuousMarquee.byVisible(true)
        downContinuousMarquee.byVisible(true)
        leftContinuousMarquee.byVisible(true)
        rightContinuousMarquee.byVisible(true)
        upFrequencyMarquee.byVisible(true)
        downFrequencyMarquee.byVisible(true)
        leftFrequencyMarquee.byVisible(true)
        rightFrequencyMarquee.byVisible(true)
        oneButtonMarquee.byVisible(true)
        twoButtonsMarquee.byVisible(true)
        zeroButtonsMarquee.byVisible(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        allMarquees.forEach { $0.start() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        allMarquees.forEach { $0.stop() }
    }

    // MARK: - 私有

    private var allMarquees: [JobsMarqueeView] {
        [
            upContinuousMarquee,
            downContinuousMarquee,
            leftContinuousMarquee,
            rightContinuousMarquee,
            upFrequencyMarquee,
            downFrequencyMarquee,
            leftFrequencyMarquee,
            rightFrequencyMarquee,
            oneButtonMarquee,
            twoButtonsMarquee,
            zeroButtonsMarquee
        ]
    }
}
