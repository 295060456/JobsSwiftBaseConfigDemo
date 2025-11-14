//
//  EditProfileDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/11/13.
//

import UIKit
import SnapKit
import SwiftEntryKit

// MARK: - 行模型
private enum EditProfileRow: CaseIterable {
    case avatar
    case nickname
    case gender
    case sign
    case birthday
    case emotion
    case hometown
    case profession

    var title: String {
        switch self {
        case .avatar:     return "头像"
        case .nickname:   return "昵称"
        case .gender:     return "性别"
        case .sign:       return "签名"
        case .birthday:   return "生日"
        case .emotion:    return "情感"
        case .hometown:   return "家乡"
        case .profession: return "职业"
        }
    }

    var detail: String? {
        switch self {
        case .avatar:
            return nil
        case .nickname:
            return "I am the user's nickname"
        case .gender:
            return "female"
        case .sign:
            return "This person left nothing behind"
        case .birthday:
            return "2025-09-22"
        case .emotion:
            return "secret"
        case .hometown:
            return "Mars"
        case .profession:
            return "product manager"
        }
    }
}

final class EditProfileDemoVC: BaseVC {
    
    private let sections: [[EditProfileRow]] = [
        [.avatar, .nickname, .gender, .sign],
        [.birthday, .emotion, .hometown, .profession]
    ]

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .byBgColor("#EFEFEF".cor)
            .byDataSource(self)
            .byDelegate(self)
            .register()
            .byScrollEnabled(NO)
            .byNoContentInsetAdjustment()
            .byNoSectionHeaderTopPadding()
            .byTableFooterView(UIView())
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.edges.equalTo(view.safeAreaLayoutGuide)
                }
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBgColor("#EFEFEF".cor)
        jobsSetupGKNav(title: "Edit profile")
        tableView.byVisible(YES)
    }
}
// MARK: - UITableViewDataSource
extension EditProfileDemoVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section][indexPath.row]

        switch row {
        case .avatar:
            return tableView.py_dequeueReusableCell(
                withType: AvatarCell.self,
                for: indexPath
            ).byConfigure(JobsCellConfig(title: row.title))
        default:
            return tableView.py_dequeueReusableCell(withType: BaseTableViewCellByValue1.self, for: indexPath)
                .byTitleFont(.systemFont(ofSize: 16))
                .byDetailTitleFont((.systemFont(ofSize: 14)))
                .bySelectionStyle(.none)
                .byAccessoryType(.disclosureIndicator)
                .bySeparatorInset(.init(top: 0, left: 16, bottom: 0, right: 16))
                .byConfigure(JobsCellConfig(title: row.title,detail:row.detail))
        }
    }
}
// MARK: - UITableViewDelegate
extension EditProfileDemoVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section][indexPath.row]
        return row == .avatar ? 72 : 52
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 8 : 16
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        UIView().byBgColor(.clear)
    }

    func tipsGrantPermission(){
        SwiftEntryKit.display(
            entry: TipsGrantPermissionView().onConfirm {
                print("去开启")
                SwiftEntryKit.dismiss(.all)
            },
            using: makeEKAttributes().bySize(width: .constant(value: 326.w), height: .constant(value: 206.h))
        )
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section][indexPath.row]
        switch row {
        case .avatar:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss{ [weak self] in
                            guard let self else { return }
                            tipsGrantPermission()
                        }
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes().bySize(width: .constant(value: 340.w), height: .constant(value: 217.h))
            )
        case .nickname:
            SwiftEntryKit.display(
                entry: TipsGrantPermissionView().onConfirm {
                    print("去开启")
                    SwiftEntryKit.dismiss(.all)
                },
                using: makeEKAttributes().bySize(width: .constant(value: 326.w), height: .constant(value: 206.h))
            )
        case .gender:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss()
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes()
            )
        case .sign:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss()
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes()
            )
        case .birthday:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss()
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes()
            )
        case .emotion:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss()
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes()
            )
        case .hometown:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss()
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes()
            )
        case .profession:
            SwiftEntryKit.display(
                entry: PhotoPermissionAlertView()
                    .onLimited {
                        print("有限访问")
                        SwiftEntryKit.dismiss()
                    }
                    .onFull {
                        print("全部允许")
                        SwiftEntryKit.dismiss()
                    }
                    .onDeny {
                        print("不允许")
                        SwiftEntryKit.dismiss()
                    },
                using: makeEKAttributes()
            )
        }
    }
}
// MARK: - 头像 cell
final class AvatarCell: UITableViewCell {

    private lazy var avatarView: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds()
            .kf_setImage(from: "https://picsum.photos/200", placeholder: "Ani".img)
            .byClipsToBounds(true)
            .byCornerRadius(22)
            .byBgColor(.systemGray5)
            .byAddTo(contentView) { [unowned self] make in
                make.size.equalTo(CGSize(width: 44, height: 44))
                make.centerY.equalToSuperview()
                // 预留 disclosureIndicator 的空间
                make.trailing.equalToSuperview().inset(16)
            }
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.byFont(.systemFont(ofSize: 16)).byTextColor(.label)
        detailTextLabel?.byFont(.systemFont(ofSize: 14)).byTextColor(.secondaryLabel)
        avatarView.byVisible(YES)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    @objc
    override func byConfigure(_ any: Any?) -> Self {
        guard let cfg = any as? JobsCellConfig else { return self }
        if let title = cfg.title {
            textLabel?.byText(title)
        }
        if let detail = cfg.detail {
            detailTextLabel?.byText(detail)
        }
        if let image = cfg.image {
            avatarView.byImage(image)
        };return self
    }
}
