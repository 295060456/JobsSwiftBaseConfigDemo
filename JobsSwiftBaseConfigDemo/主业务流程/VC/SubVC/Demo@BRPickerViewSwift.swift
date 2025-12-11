//
//  Demo@BRPickerViewSwift.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

final class BRPickerDemoVC: BaseVC {
    /// 文本：单列（学历）
    private lazy var textSinglePicker: BRTextPickerView = { [unowned self] in
        BRTextPickerView()
            .brMode(.single)
            .brTitle("学历")
            .brStyle { $0.isAutoSelect = false }
            .brDataSource(["大专以下", "大专", "本科", "硕士", "博士", "博士后"])
            .brSelectIndex(2)
            .brOnSingle { m, idx in
                ("单列：\(m?.text ?? "-")（index=\(idx)）").toast
            }
    }()

    /// 文本：多列（尺码/颜色）
    private lazy var textMultiPicker: BRTextPickerView = { [unowned self] in
        BRTextPickerView()
            .brMode(.multi)
            .brTitle("尺码/颜色")
            .brMultiDataSource([
                ["S", "M", "L", "XL"],
                ["黑", "白", "蓝", "粉"]
            ])
            .brSelectIndexs([1, 2])
            .brStyle { $0.isAutoSelect = false }
            .brOnMulti { ms, idxs in
                ("多列：\(ms.map { $0.text }.joined(separator: " / "))（index=\(idxs)）").toast
            }
    }()
    /// 文本：三级联动（省/市/区）
    private lazy var textCascadePicker: BRTextPickerView = { [unowned self] in
        BRTextPickerView()
            .brMode(.cascade)
            .brTitle("选择地区")
            .brCascadeData([
                RegionNode(text: "浙江省", children: [
                    RegionNode(text: "杭州市", children: [
                        RegionNode(text: "西湖区"),
                        RegionNode(text: "滨江区"),
                        RegionNode(text: "拱墅区")
                    ]),
                    RegionNode(text: "宁波市", children: [
                        RegionNode(text: "鄞州区"),
                        RegionNode(text: "海曙区")
                    ])
                ]),
                RegionNode(text: "江苏省", children: [
                    RegionNode(text: "南京市", children: [
                        RegionNode(text: "玄武区"),
                        RegionNode(text: "鼓楼区")
                    ])
                ])
            ])
            .brCascadeSelectIndexs([0, 0, 1])
            .brStyle { $0.isAutoSelect = true }
            .brOnCascade { ms, idxs in
                ("联动：\(ms.map { $0.text }.joined(separator: " / "))（index=\(idxs)）").toast
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
                ("系统 Date：\(dt.map { fmt($0, "yyyy-MM-dd") } ?? "-")").toast
            }
    }()
    /// 日期：系统 Date & Time
    private lazy var dateSysDateTimePicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.dateAndTime)
            .brTitle("开会时间")
            .brSelectDate(Date())
            .brStyle { $0.minuteInterval = 5 }
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("系统 Date&Time：\(dt.map { fmt($0, "yyyy-MM-dd HH:mm") } ?? "-")").toast
            }
    }()
    /// 日期：系统 Time（12h）
    private lazy var dateSysTimePicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.time)
            .brTitle("提醒时间")
            .brSelectDate(Date())
            .brStyle {
                $0.use12HourClock = true
                $0.minuteInterval = 10
            }
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("系统 Time：\(dt.map { fmt($0, "HH:mm") } ?? "-")").toast
            }
    }()
    /// 日期：系统 CountDownTimer
    private lazy var dateSysCountPicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.countDownTimer)
            .brTitle("倒计时")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("系统 CountDownTimer：\(dt.map { fmt($0, "HH:mm") } ?? "-")").toast
            }
    }()
    /// 日期：自定义 YMD（年月日）
    private lazy var dateYMDPicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.ymd)
            .brTitle("生日（YMD）")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("自定义 YMD：\(dt.map { fmt($0, "yyyy-MM-dd") } ?? "-")").toast
            }
    }()
    /// 日期：自定义 YM（年月）
    private lazy var dateYMPicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.ym)
            .brTitle("账期（月度）")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("自定义 YM：\(dt.map { fmt($0, "yyyy-MM") } ?? "-")").toast
            }
    }()
    /// 日期：自定义 Y（年）
    private lazy var dateYPicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.y)
            .brTitle("年份")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("自定义 Y：\(dt.map { fmt($0, "yyyy") } ?? "-")").toast
            }
    }()
    /// 日期：自定义 MD（月日）
    private lazy var dateMDPicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.md)
            .brTitle("纪念日（月/日）")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("自定义 MD：\(dt.map { fmt($0, "MM-dd") } ?? "-")").toast
            }
    }()
    /// 日期：自定义 HM（时:分，步进 = 5）
    private lazy var dateHMPicker: BRDatePickerView = { [unowned self] in
        BRDatePickerView()
            .brMode(.hm)
            .brTitle("提醒（时:分）")
            .brSelectDate(Date())
            .brStyle { $0.minuteInterval = 5 }
            .brOnResult { [weak self] dt in
                guard let self else { return }
                ("自定义 HM：\(dt.map { fmt($0, "HH:mm") } ?? "-")").toast
            }
    }()

    private lazy var scrollView: UIScrollView = {
        UIScrollView()
            .byAlwaysBounceVertical(YES)
            .byAddTo(view) { [unowned self] make in
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            }
    }()

    private lazy var stack: UIStackView = {
        UIStackView()
            .byAxis(.vertical)
            .bySpacing(12)
            .byAlignment(.fill)
            .byAddTo(scrollView) { [weak self] make in
                guard let self else { return }
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview().inset(16)
                } else {
                    make.edges.equalToSuperview().inset(16)
                }
                make.width.equalTo(self.scrollView.frameLayoutGuide).offset(-32)
            }
    }()

    private lazy var resultCard: UIView = {
        UIView()
            .byBgColor(.secondarySystemBackground)
            .byCornerRadius(12)
            .byAddArranged(to: stack)
            .byHeight(72)
    }()

    private lazy var secText: UILabel = {
        UILabel()
            .byText("文本选择器（BRTextPickerView）")
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byTextColor(.secondaryLabel)
            .byAddArranged(to: stack)
    }()

    private lazy var secSys: UILabel = {
        UILabel()
            .byText("日期选择器（系统样式）")
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byTextColor(.secondaryLabel)
            .byAddArranged(to: stack)
    }()

    private lazy var secCustom: UILabel = {
        UILabel()
            .byText("日期选择器（自定义样式）")
            .byFont(.systemFont(ofSize: 13, weight: .semibold))
            .byTextColor(.secondaryLabel)
            .byAddArranged(to: stack)
    }()

    private lazy var btnSingle: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemBlue)
            .byTitle("单列（学历）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.textSinglePicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnMulti: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemBlue)
            .byTitle("多列（尺码/颜色）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                textMultiPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnCascade: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemBlue)
            .byTitle("三级联动（省/市/区）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                textCascadePicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnSysDate: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemIndigo)
            .byTitle("系统：Date（年月日）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                dateSysDatePicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnSysDateTime: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemIndigo)
            .byTitle("系统：Date & Time", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                dateSysDateTimePicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnSysTime: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemIndigo)
            .byTitle("系统：Time（12h）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateSysTimePicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnSysCount: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemIndigo)
            .byTitle("系统：CountDownTimer", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateSysCountPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnYMD: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemTeal)
            .byTitle("自定义：YMD（年月日）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateYMDPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnYM: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemTeal)
            .byTitle("自定义：YM（年月）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateYMPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnY: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemTeal)
            .byTitle("自定义：Y（年）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateYPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnMD: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemTeal)
            .byTitle("自定义：MD（月日）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateMDPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    private lazy var btnHM: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemTeal)
            .byTitle("自定义：HM（时:分，步进=5）", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .medium))
            .byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14))
            .onTap { [weak self] _ in
                guard let self else { return }
                self.dateHMPicker.brPresent(in: self.view)
            }
            .byAddArranged(to: stack)
            .byHeight(44)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "Demo@BRPickerViewSwift")
        view.backgroundColor = .systemGroupedBackground
        _ = [scrollView, stack, resultCard,
             secText, btnSingle, btnMulti, btnCascade,
             secSys, btnSysDate, btnSysDateTime, btnSysTime, btnSysCount,
             secCustom, btnYMD, btnYM, btnY, btnMD, btnHM]
    }
}
