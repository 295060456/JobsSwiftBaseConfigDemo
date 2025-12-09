//
//  JobsWalletDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/5/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import SnapKit

// MARK: - 数据模型
struct WalletCard {
    let bankName: String
    let lastDigits: String
    let holder: String
    let brand: String
    let gradientColors: [UIColor]
}

enum WalletItem {
    case card(WalletCard)
    case addNew
}

final class JobsWalletDemoVC: BaseVC {
    private let horizontalInset: CGFloat = 0
    private lazy var walletLayout: WalletLayout = {
        WalletLayout()
            .byPadding(20)
            .byItemHeight(120)
            .byOverlap(14)
            .byExpandOffset(14)
            .byLayoutDelegate(self);
    }()

    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: walletLayout)
            .byBgColor(.clear)
            .byShowsVerticalScrollIndicator(NO)
            .byContentInset(UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0))
            .registerCell(WalletCardCell.self)
            .registerCell(WalletAddCardCell.self)
            .byDelegate(self)
            .registerSupplementaryView(WalletSectionHeaderView.self,kind: UICollectionView.elementKindSectionHeader)
            .byDataSource(self).byAddTo(view) { [unowned self] make in
                make.top.equalTo(gk_navigationBar.snp.bottom)
                make.left.equalToSuperview().offset(self.horizontalInset)
                make.right.equalToSuperview().inset(self.horizontalInset)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }()

    private var sections: [[WalletItem]] = [[
        .card(WalletCard(bankName: "上海银行",
                         lastDigits: "7895",
                         holder: "Jobs",
                         brand: "VISA",
                         gradientColors: [.systemPurple, .systemBlue])),
        .card(WalletCard(bankName: "国泰世华",
                         lastDigits: "2345",
                         holder: "Jobs",
                         brand: "Mastercard",
                         gradientColors: [.systemPink, .systemOrange])),
        .card(WalletCard(bankName: "台湾银行",
                         lastDigits: "7654",
                         holder: "Jobs",
                         brand: "VISA",
                         gradientColors: [.systemTeal, .systemBlue])),
        .card(WalletCard(bankName: "嘉华银行",
                         lastDigits: "2345",
                         holder: "Jobs",
                         brand: "UnionPay",
                         gradientColors: [.systemIndigo, .systemTeal])),
        .card(WalletCard(bankName: "包头银行",
                         lastDigits: "7654",
                         holder: "Jobs",
                         brand: "Debit",
                         gradientColors: [.systemGreen, .systemTeal])),
        .card(WalletCard(bankName: "成都银行",
                         lastDigits: "2345",
                         holder: "Jobs",
                         brand: "Credit",
                         gradientColors: [.systemRed, .systemOrange])),
        .card(WalletCard(bankName: "南充商业银行",
                         lastDigits: "7654",
                         holder: "Jobs",
                         brand: "VISA",
                         gradientColors: [.systemBlue, .systemGreen]))
    ],[.addNew]]
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        jobsSetupGKNav(
            title: "钱包卡片效果"
        )
        // 触发 collectionView 懒加载 + 布局
        collectionView.byVisible(YES)
        collectionView.reloadData()
    }
}
// MARK: - UICollectionViewDataSource
extension JobsWalletDemoVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        sections[section].count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section][indexPath.item] {
        case .card(let card):
            let cell: WalletCardCell = collectionView.dequeueCell(WalletCardCell.self, for: indexPath)
            let isSelectedCard = (selectedIndexPath == indexPath)
            cell.configure(with: card, isHighlightedCard: isSelectedCard)
            return cell

        case .addNew:
            let cell: WalletAddCardCell = collectionView.dequeueCell(WalletAddCardCell.self, for: indexPath)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header: WalletSectionHeaderView =
            collectionView.dequeueSupplementary(WalletSectionHeaderView.self,
                                               kind: kind,
                                               for: indexPath)
        if indexPath.section == 0 {
            header.configure(title: "我的银行卡")
        } else {
            header.configure(title: "更多操作")
        };return header
    }
}
// MARK: - UICollectionViewDelegate
extension JobsWalletDemoVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section][indexPath.item] {
        case .card:
            // 仿 OC：最后一张 / 其他 section 不展开
            let isLastInSection = indexPath.item ==
                (collectionView.numberOfItems(inSection: indexPath.section) - 1)
            let allowExpand = !isLastInSection && indexPath.section == 0
            if allowExpand {
                if selectedIndexPath == indexPath {
                    selectedIndexPath = nil
                } else {
                    selectedIndexPath = indexPath
                }
            } else {
                selectedIndexPath = nil
            }
            walletLayout.animateToggle(at: indexPath, allowExpand: allowExpand)
            collectionView.reloadData()
        case .addNew:
            // 这里接你自己的跳转绑卡页面逻辑
            print("📇 点击添加新的银行卡")
        }
    }
}
// MARK: - WalletLayoutDelegate
extension JobsWalletDemoVC: WalletLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        reusableHeaderHeightFor section: Int) -> CGFloat {
        if section == sections.count - 1 {
            return 45
        };return 30
    }

    func collectionView(_ collectionView: UICollectionView,
                        reusableFooterHeightFor section: Int) -> CGFloat {
        return 0
    }
}
