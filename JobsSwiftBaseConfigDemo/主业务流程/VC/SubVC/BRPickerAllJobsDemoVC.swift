//
//  BRPickerAllJobsDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

final class BRPickerDemoVC: BaseVC {

    // MARK: - UI（代码块 + 链式）

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
            .byAddTo(scrollView) { make in
                make.edges.equalToSuperview().inset(16)
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
    private lazy var resultTitleLabel: UILabel = {
        UILabel()
            .byText("选择结果").byFont(.systemFont(ofSize: 13, weight: .semibold)).byTextColor(.secondaryLabel)
            .byAddTo(resultCard) { $0.top.leading.trailing.equalToSuperview().inset(12) }
    }()
    private lazy var resultLabel: UILabel = {
        UILabel()
            .byText("—").byFont(.systemFont(ofSize: 15)).byTextColor(.label).byNumberOfLines(0)
            .byAddTo(resultCard) {
                $0.top.equalTo(self.resultTitleLabel.snp.bottom).offset(8)
                $0.leading.trailing.bottom.equalToSuperview().inset(12)
            }
    }()

    // 你的“风格样例”按钮（完全照你写法）
    private lazy var exampleButton: UIButton = {
        let b = UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("显示", for: .normal)
            .byTitle("隐藏", for: .selected)
            .byTitleColor(.systemBlue, for: .normal)
            .byTitleColor(.systemRed, for: .selected)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .bySubTitle("显示", for: .normal)
            .bySubTitle("隐藏", for: .selected)
            .bySubTitleColor(.systemBlue, for: .normal)
            .bySubTitleColor(.systemRed, for: .selected)
            .bySubTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byRichTitle(JobsRichText.make([
                JobsRichRun(.text("¥99")).font(.systemFont(ofSize: 18, weight: .semibold)).color(.systemRed),
                JobsRichRun(.text(" /月")).font(.systemFont(ofSize: 16)).color(.white)
            ]))
            .byRichSubTitle(JobsRichText.make([
                JobsRichRun(.text("原价 ")).font(.systemFont(ofSize: 12)).color(.white.withAlphaComponent(0.8)),
                JobsRichRun(.text("¥199")).font(.systemFont(ofSize: 12, weight: .medium)).color(.systemYellow)
            ]))
            .byImage(UIImage(systemName: "eye.slash"), for: .normal)
            .byImage(UIImage(systemName: "eye"), for: .selected)
            .byContentEdgeInsets(.init(top: 4, left: 8, bottom: 4, right: 8))
            .byTitleEdgeInsets(.init(top: 0, left: 6, bottom: 0, right: -6))
            .byTapSound("Sounddd.wav")
            .onTap { [weak self] sender in
                guard let self else { return }
                sender.isSelected.toggle()
                self.result("👁 当前状态：\(sender.isSelected ? "隐藏密码" : "显示密码")")
            }
            .byCornerDot(diameter: 10, offset: .init(horizontal: -4, vertical: 4))
            .byCornerBadgeText("NEW") { cfg in
                cfg.offset = .init(horizontal: -6, vertical: 6)
                cfg.inset = .init(top: 2, left: 6, bottom: 2, right: 6)
                cfg.bgColor = .systemRed
                cfg.font = .systemFont(ofSize: 11, weight: .bold)
                cfg.shadow = (UIColor.black.withAlphaComponent(0.25), 2, 0.6, .init(width: 0, height: 1))
            }
            .byAddArranged(to: stack)
            .byHeight(44)

        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                var cc = c
                cc.title = "背景图：Base64 / URL"
                cc.baseForegroundColor = .white
                cc.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                cc.cornerStyle = .large
                cc.imagePlacement = .trailing
                cc.imagePadding = 8
                return cc
            }
        } else {
            _ = b.byTitle("背景图：Base64 / URL", for: .normal)
                 .byTitleColor(.white, for: .normal)
                 .byContentEdgeInsets(.init(top: 16, left: 16, bottom: 16, right: 16))
                 .byBackgroundColor(.systemBlue, for: .normal)
        }
        return b
    }()

    private lazy var secText: UILabel = { UILabel().byText("文本选择器（BRTextPickerView）").byFont(.systemFont(ofSize: 13, weight: .semibold)).byTextColor(.secondaryLabel).byAddArranged(to: stack) }()
    private lazy var secSys:  UILabel = { UILabel().byText("日期选择器（系统样式）").byFont(.systemFont(ofSize: 13, weight: .semibold)).byTextColor(.secondaryLabel).byAddArranged(to: stack) }()
    private lazy var secCustom: UILabel = { UILabel().byText("日期选择器（自定义样式）").byFont(.systemFont(ofSize: 13, weight: .semibold)).byTextColor(.secondaryLabel).byAddArranged(to: stack) }()

    private lazy var btnSingle: UIButton = {
        UIButton.sys().byBackgroundColor(.systemBlue).byTitle("单列（学历）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showSingleText() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnMulti: UIButton = {
        UIButton.sys().byBackgroundColor(.systemBlue).byTitle("多列（尺码/颜色）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showMultiText() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnCascade: UIButton = {
        UIButton.sys().byBackgroundColor(.systemBlue).byTitle("三级联动（省/市/区）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showCascade() }.byAddArranged(to: stack).byHeight(44)
    }()

    private lazy var btnSysDate: UIButton = {
        UIButton.sys().byBackgroundColor(.systemIndigo).byTitle("系统：Date（年月日）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showSystemDate() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnSysDateTime: UIButton = {
        UIButton.sys().byBackgroundColor(.systemIndigo).byTitle("系统：Date & Time", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showSystemDateTime() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnSysTime: UIButton = {
        UIButton.sys().byBackgroundColor(.systemIndigo).byTitle("系统：Time（12h）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showSystemTime() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnSysCount: UIButton = {
        UIButton.sys().byBackgroundColor(.systemIndigo).byTitle("系统：CountDownTimer", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showSystemCountDown() }.byAddArranged(to: stack).byHeight(44)
    }()

    private lazy var btnYMD: UIButton = {
        UIButton.sys().byBackgroundColor(.systemTeal).byTitle("自定义：YMD（年月日）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showCustomYMD() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnYM: UIButton = {
        UIButton.sys().byBackgroundColor(.systemTeal).byTitle("自定义：YM（年月）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showCustomYM() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnY: UIButton = {
        UIButton.sys().byBackgroundColor(.systemTeal).byTitle("自定义：Y（年）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showCustomY() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnMD: UIButton = {
        UIButton.sys().byBackgroundColor(.systemTeal).byTitle("自定义：MD（月日）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showCustomMD() }.byAddArranged(to: stack).byHeight(44)
    }()
    private lazy var btnHM: UIButton = {
        UIButton.sys().byBackgroundColor(.systemTeal).byTitle("自定义：HM（时:分，步进=5）", for: .normal).byTitleColor(.white, for: .normal).byTitleFont(.systemFont(ofSize: 15, weight: .medium)).byContentEdgeInsets(.init(top: 10, left: 14, bottom: 10, right: 14)).onTap { [weak self] _ in self?.showCustomHM() }.byAddArranged(to: stack).byHeight(44)
    }()

    // MARK: - Data
    private let singleItems = ["大专以下", "大专", "本科", "硕士", "博士", "博士后"]
    private let multiItems = [
        ["S", "M", "L", "XL"],
        ["黑", "白", "蓝", "粉"]
    ]
    private let regions: [TextCascadeNode] = [
        RegionNode(text: "浙江省", children: [
            RegionNode(text: "杭州市", children: [RegionNode(text: "西湖区"), RegionNode(text: "滨江区"), RegionNode(text: "拱墅区")]),
            RegionNode(text: "宁波市", children: [RegionNode(text: "鄞州区"), RegionNode(text: "海曙区")])
        ]),
        RegionNode(text: "江苏省", children: [
            RegionNode(text: "南京市", children: [RegionNode(text: "玄武区"), RegionNode(text: "鼓楼区")])
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BRPickerViewSwift + Jobs DSL（SnapKit）"
        view.backgroundColor = .systemGroupedBackground
        _ = [scrollView, stack, resultCard, resultTitleLabel, resultLabel,
             exampleButton,
             secText, btnSingle, btnMulti, btnCascade,
             secSys, btnSysDate, btnSysDateTime, btnSysTime, btnSysCount,
             secCustom, btnYMD, btnYM, btnY, btnMD, btnHM]
    }

    // MARK: - 结果展示
    private func result(_ text: String) { resultLabel.text = text }

    // MARK: - Picker 触发（按钮闭包调用）
    private func showSingleText() {
        BRTextPickerView()
            .brMode(.single)
            .brTitle("学历")
            .brStyle { $0.isAutoSelect = false }
            .brDataSource(singleItems)
            .brSelectIndex(2)
            .brOnSingle { [weak self] m, idx in
                self?.result("单列：\(m?.text ?? "-")（index=\(idx)）")
            }
            .brPresent(in: view)
    }

    private func showMultiText() {
        BRTextPickerView()
            .brMode(.multi)
            .brTitle("尺码/颜色")
            .brMultiDataSource(multiItems)
            .brSelectIndexs([1, 2])
            .brStyle { $0.isAutoSelect = false }
            .brOnMulti { [weak self] ms, idxs in
                self?.result("多列：\(ms.map{$0.text}.joined(separator: " / "))（index=\(idxs)）")
            }
            .brPresent(in: view)
    }

    private func showCascade() {
        BRTextPickerView()
            .brMode(.cascade)
            .brTitle("选择地区")
            .brCascadeData(regions)
            .brCascadeSelectIndexs([0,0,1])
            .brStyle { $0.isAutoSelect = true }
            .brOnCascade { [weak self] ms, idxs in
                self?.result("联动：\(ms.map{$0.text}.joined(separator: " / "))（index=\(idxs)）")
            }
            .brPresent(in: view)
    }

    private func showSystemDate() {
        BRDatePickerView()
            .brMode(.date)
            .brTitle("出生日")
            .brSelectDate(Date())
            .brMinDate(Calendar.current.date(byAdding: .year, value: -80, to: Date()))
            .brMaxDate(Date())
            .brStyle { $0.minuteInterval = 1 }
            .brOnResult { [weak self] dt in
                self?.result("系统 Date：\(dt.map { Self.fmt($0, "yyyy-MM-dd") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showSystemDateTime() {
        BRDatePickerView()
            .brMode(.dateAndTime)
            .brTitle("开会时间")
            .brSelectDate(Date())
            .brStyle { $0.minuteInterval = 5 }
            .brOnResult { [weak self] dt in
                self?.result("系统 Date&Time：\(dt.map { Self.fmt($0, "yyyy-MM-dd HH:mm") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showSystemTime() {
        BRDatePickerView()
            .brMode(.time)
            .brTitle("提醒时间")
            .brSelectDate(Date())
            .brStyle { $0.use12HourClock = true; $0.minuteInterval = 10 }
            .brOnResult { [weak self] dt in
                self?.result("系统 Time：\(dt.map { Self.fmt($0, "HH:mm") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showSystemCountDown() {
        BRDatePickerView()
            .brMode(.countDownTimer)
            .brTitle("倒计时")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                self?.result("系统 CountDownTimer：\(dt.map { Self.fmt($0, "HH:mm") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showCustomYMD() {
        BRDatePickerView()
            .brMode(.ymd)
            .brTitle("生日（YMD）")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                self?.result("自定义 YMD：\(dt.map { Self.fmt($0, "yyyy-MM-dd") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showCustomYM() {
        BRDatePickerView()
            .brMode(.ym)
            .brTitle("账期（月度）")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                self?.result("自定义 YM：\(dt.map { Self.fmt($0, "yyyy-MM") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showCustomY() {
        BRDatePickerView()
            .brMode(.y)
            .brTitle("年份")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                self?.result("自定义 Y：\(dt.map { Self.fmt($0, "yyyy") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showCustomMD() {
        BRDatePickerView()
            .brMode(.md)
            .brTitle("纪念日（月/日）")
            .brSelectDate(Date())
            .brOnResult { [weak self] dt in
                self?.result("自定义 MD：\(dt.map { Self.fmt($0, "MM-dd") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private func showCustomHM() {
        BRDatePickerView()
            .brMode(.hm)
            .brTitle("提醒（时:分）")
            .brSelectDate(Date())
            .brStyle { $0.minuteInterval = 5 }
            .brOnResult { [weak self] dt in
                self?.result("自定义 HM：\(dt.map { Self.fmt($0, "HH:mm") } ?? "-")")
            }
            .brPresent(in: view)
    }

    private static func fmt(_ date: Date, _ f: String) -> String {
        let df = DateFormatter(); df.locale = .current; df.dateFormat = f; return df.string(from: date)
    }
}
