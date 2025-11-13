//
//  EditProfileDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/11/13.
//

import UIKit
import SnapKit

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
        case .avatar:     return "Avatar"
        case .nickname:   return "Nick name"
        case .gender:     return "Gender"
        case .sign:       return "Sign"
        case .birthday:   return "Birthday"
        case .emotion:    return "Emotion"
        case .hometown:   return "Hometown"
        case .profession: return "Profession"
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

// MARK: - VC
final class EditProfileDemoVC: BaseVC {

    // section0: 头像 + 昵称 + 性别 + 签名
    // section1: 生日 + 情感 + 家乡 + 职业
    private let sections: [[EditProfileRow]] = [
        [.avatar, .nickname, .gender, .sign],
        [.birthday, .emotion, .hometown, .profession]
    ]

    // MARK: - UI
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(AvatarCell.self)
            .registerCell(UITableViewCell.self)
            .byRowHeight(52)
            .byEstimatedRowHeight(52)
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

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "Edit profile")
        view.backgroundColor = .systemGroupedBackground
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
            let cell: AvatarCell = tableView.py_dequeueReusableCell(
                withType: AvatarCell.self,
                for: indexPath
            )
            cell.configure(
                title: row.title,
                image: UIImage(named: "avatar_placeholder") // 自己换成真实头像
            )
            return cell

        default:
            let cell: UITableViewCell = tableView.py_dequeueReusableCell(
                withType: UITableViewCell.self,
                for: indexPath
            )
            cell
                .bySelectionStyle(.none)
                .byAccessoryType(.disclosureIndicator)
                .byText(row.title)
                .bySecondaryText(row.detail)

            // 分割线稍微往内缩一点
            cell.bySeparatorInset(.init(top: 0, left: 16, bottom: 0, right: 16))
            return cell
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
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section][indexPath.row]
        // TODO: push 具体编辑页
        print("tap row: \(row)")
    }
}

// MARK: - 头像 cell
final class AvatarCell: UITableViewCell {

    private lazy var avatarView: UIImageView = {
        UIImageView()
            .byContentMode(.scaleAspectFill)
            .byClipsToBounds(true)
            .byCornerRadius(22)   // 44 / 2
            .byBgColor(.systemGray5)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        bySelectionStyle(.none)
            .byAccessoryType(.disclosureIndicator)

        textLabel?.font = .systemFont(ofSize: 16)
        textLabel?.textColor = .label

        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.centerY.equalToSuperview()
            // 留一点位置给系统的披露箭头
            make.trailing.equalToSuperview().inset(16 + 24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, image: UIImage?) {
        textLabel?.text = title
        avatarView.image = image
    }
}
