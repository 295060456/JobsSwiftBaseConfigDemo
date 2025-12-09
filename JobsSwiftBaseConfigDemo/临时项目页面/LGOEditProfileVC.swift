//
//  LGOEditProfileVC.swift
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

    var title: JobsText {
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
    /// ❤️ 这里的字段“detail”，既可以是String类型，也可以是NSAttributedString类型。合二为一
    var detail: JobsText? {
        switch self {
        case .avatar:
            return nil
        case .nickname:
            return JobsText(JobsRichText.make([
                JobsRichRun(.text("等级达到2级才能修改昵称"))
                    .font(.systemFont(ofSize: 14))
                    .color(.systemRed),
                JobsRichRun(.text("Eric"))
                    .font(.systemFont(ofSize: 14, weight: .semibold))
                    .color(.secondaryLabel)
            ]))
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

final class LGOEditProfileVC: BaseVC {
    
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
    /// 文本：单列（学历）
    private lazy var eduPicker: BRTextPickerView = { [unowned self] in
        BRTextPickerView()
            .brMode(.single)
            .brTitle("")
            .brStyle { $0.isAutoSelect = false }
            .brDataSource(["女", "男", "不想透露"])
            .brSelectIndex(2)
            .brOnSingle { m, idx in
                toastBy("单列：\(m?.text ?? "-")（index=\(idx)）")
            }
    }()
    /// 文本：单列（情感状态）
    private lazy var emotionPicker: BRTextPickerView = { [unowned self] in
        BRTextPickerView()
            .brMode(.single)
            .brTitle("")
            .brStyle { $0.isAutoSelect = false }
            .brDataSource(["已婚", "单身", "不想透露"])
            .brSelectIndex(2)
            .brOnSingle { m, idx in
                toastBy("单列：\(m?.text ?? "-")（index=\(idx)）")
            }
    }()
    /// 日期：系统 Date（年月日）
    private lazy var dateSysDatePicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.date)
            .brTitle("出生日")
            .brSelectDate(Date())
            .brMinDate(Calendar.current.date(byAdding: .year, value: -80, to: Date()))
            .brMaxDate(Date())
            .brStyle { $0.minuteInterval = 1 }
            .brOnResult { [weak self] dt in
                guard let self else { return }
                toastBy("系统 Date：\(dt.map { fmt($0, "yyyy-MM-dd") } ?? "-")")
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
extension LGOEditProfileVC: UITableViewDataSource {

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
extension LGOEditProfileVC: UITableViewDelegate {

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

//            SwiftEntryKit.display(
//                entry: TipsGrantPermissionView().onConfirm {
//                    print("去开启")
//                    SwiftEntryKit.dismiss(.all)
//                },
//                using: makeEKAttributes().bySize(width: .constant(value: 326.w), height: .constant(value: 206.h))
//            )
        case .nickname:
            LGOEditNicknameVC()
                .byData("https://www.baidu.com")
                .byPush(self)
                .byJobsVoidBlock { print("❤️结束❤️ fromBottom") }
        case .gender:
            self.eduPicker.brPresent(in: self.view)
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
            dateSysDatePicker.brPresent(in: self.view)
        case .emotion:
            self.eduPicker.brPresent(in: self.view)
        case .hometown:
            toastBy("可能这个最后要被取消")
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
    /// 富文本的优先级比普通文本高。即，如果同时设置富文本和普通文本，优先展示富文本
    override func byConfigure(_ any: Any?) -> Self {
        guard let cfg = any as? JobsCellConfig else { return self }
        if let title = cfg.title {
            textLabel?.byJobsAttributedText(title)
        }
        if let detail = cfg.detail {
            detailTextLabel?.byJobsAttributedText(detail)
        }
        if let image = cfg.image {
            avatarView.byImage(image)
        };return self
    }
}
