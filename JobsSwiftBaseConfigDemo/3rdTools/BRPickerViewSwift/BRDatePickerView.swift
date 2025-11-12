//
//  BRDatePickerView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/12/25.
//

import UIKit
import SnapKit

public enum BRDatePickerMode: Int {
    case date, dateAndTime, time, countDownTimer
    case ymdhms, ymdhm, ymdh, mdhm, ymd, ym, y, md, hms, hm, ms, yq, ymw, yw
}

public final class BRDatePickerView: NSObject {
    public var pickerMode: BRDatePickerMode = .date
    public var title: String?
    public var style = BRPickerStyle()
    public var minDate: Date? = nil
    public var maxDate: Date? = nil
    public var selectDate: Date = Date()
    public var allowToNow: Bool = false
    public var resultBlock: ((Date?) -> Void)?

    private var panel: BRPickerPanel?
    private let systemPicker = UIDatePicker()
    private let customPicker = UIPickerView()

    private var years: [Int] = []
    private var months: [Int] = Array(1...12)
    private var days: [Int] = []
    private var hours: [Int] = Array(0...23)
    private var minutes: [Int] = Array(0...59)

    public override init() { super.init() }

    public func present(in container: UIView? = nil) {
        style.title = title ?? style.title
        let panel = BRPickerPanel(style: style)
        self.panel = panel

        switch pickerMode {
        case .date, .dateAndTime, .time, .countDownTimer:
            configureSystemPicker()
            panel.contentContainer.addSubview(systemPicker)
            systemPicker.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.greaterThanOrEqualTo(216)
            }
        default:
            configureCustomData()
            customPicker.dataSource = self
            customPicker.delegate = self
            panel.contentContainer.addSubview(customPicker)
            customPicker.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.greaterThanOrEqualTo(216)
            }
            preselectCustom()
        }

        panel.onConfirm = { [weak self] in self?.emitResult() }
        if style.isAutoSelect { panel.onConfirm = nil }
        panel.onCancel = { [weak self] in self?.panel = nil }
        panel.present(in: container)
    }

    public func dismiss() { panel?.dismiss() }

    // MARK: - System
    private func configureSystemPicker() {
        if #available(iOS 13.4, *) { systemPicker.preferredDatePickerStyle = .wheels }
        systemPicker.locale = .current
        systemPicker.minuteInterval = max(1, min(style.minuteInterval, 30))
        switch pickerMode {
        case .date: systemPicker.datePickerMode = .date
        case .dateAndTime: systemPicker.datePickerMode = .dateAndTime
        case .time: systemPicker.datePickerMode = .time
        case .countDownTimer: systemPicker.datePickerMode = .countDownTimer
        default: break
        }
        systemPicker.date = selectDate
        if let minDate { systemPicker.minimumDate = minDate }
        if let maxDate { systemPicker.maximumDate = maxDate }
        if style.use12HourClock, pickerMode == .time || pickerMode == .dateAndTime {
            systemPicker.locale = Locale(identifier: "en_US_POSIX")
        }
        if style.isAutoSelect { systemPicker.addTarget(self, action: #selector(systemChanged), for: .valueChanged) }
    }
    @objc private func systemChanged() { emitResult() }

    // MARK: - Custom
    private func configureCustomData() {
        let cal = Calendar.current
        let yNow = cal.component(.year, from: Date())
        let minY = minDate.map { cal.component(.year, from: $0) } ?? (yNow - 100)
        let maxY = maxDate.map { cal.component(.year, from: $0) } ?? (yNow + 100)
        years = Array(minY...maxY)
        rebuildDays()
    }
    private func rebuildDays(year: Int? = nil, month: Int? = nil) {
        let cal = Calendar.current
        let y = year ?? cal.component(.year, from: selectDate)
        let m = month ?? cal.component(.month, from: selectDate)
        if let date = cal.date(from: DateComponents(year: y, month: m)),
           let range = cal.range(of: .day, in: .month, for: date) {
            days = Array(range)
        } else { days = Array(1...30) }
    }
    private func preselectCustom() {
        let cal = Calendar.current
        let y = cal.component(.year, from: selectDate)
        let m = cal.component(.month, from: selectDate)
        let d = cal.component(.day, from: selectDate)
        let h = cal.component(.hour, from: selectDate)
        let mi = cal.component(.minute, from: selectDate) / max(style.minuteInterval,1) * max(style.minuteInterval,1)

        func sel(_ c: Int, _ r: Int) { customPicker.selectRow(r, inComponent: c, animated: false) }
        switch pickerMode {
        case .ymd:
            sel(0, years.firstIndex(of: y) ?? 0); sel(1, m - 1); rebuildDays(year: y, month: m); sel(2, min(d - 1, days.count - 1))
        case .ym:
            sel(0, years.firstIndex(of: y) ?? 0); sel(1, m - 1)
        case .y:
            sel(0, years.firstIndex(of: y) ?? 0)
        case .md:
            sel(0, m - 1); rebuildDays(month: m); sel(1, min(d - 1, days.count - 1))
        case .hm:
            sel(0, h); sel(1, mi)
        default: break
        }
    }
    private func makeCustomDate() -> Date? {
        let cal = Calendar.current
        var comps = DateComponents()
        func s(_ c: Int) -> Int { customPicker.selectedRow(inComponent: c) }

        switch pickerMode {
        case .ymd:
            comps.year = years[s(0)]; comps.month = s(1) + 1; comps.day = days[min(s(2), max(0, days.count-1))]
        case .ym:
            comps.year = years[s(0)]; comps.month = s(1) + 1; comps.day = 1
        case .y:
            comps.year = years[s(0)]; comps.month = 1; comps.day = 1
        case .md:
            comps.year = Calendar.current.component(.year, from: selectDate); comps.month = s(0) + 1; comps.day = days[min(s(1), max(0, days.count-1))]
        case .hm:
            comps.year = Calendar.current.component(.year, from: selectDate)
            comps.month = Calendar.current.component(.month, from: selectDate)
            comps.day = Calendar.current.component(.day, from: selectDate)
            comps.hour = s(0); comps.minute = s(1) * max(style.minuteInterval, 1)
        default: return nil
        }
        return cal.date(from: comps)
    }
    private func emitResult() {
        switch pickerMode {
        case .date, .dateAndTime, .time, .countDownTimer:
            resultBlock?(systemPicker.date)
        default:
            if allowToNow && isToNowSelected() { resultBlock?(nil) } else { resultBlock?(makeCustomDate()) }
        }
        panel = nil
    }
    private func isToNowSelected() -> Bool { false }
}

extension BRDatePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerMode { case .ymd: return 3; case .ym, .md, .hm: return 2; case .y: return 1; default: return 0 }
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent c: Int) -> Int {
        switch pickerMode {
        case .ymd: return c == 0 ? years.count : (c == 1 ? months.count : days.count)
        case .ym:  return c == 0 ? years.count : months.count
        case .y:   return years.count
        case .md:  return c == 0 ? months.count : days.count
        case .hm:  return c == 0 ? hours.count : (minutes.count / max(style.minuteInterval,1))
        default: return 0
        }
    }
    public func pickerView(_ pickerView: UIPickerView, widthForComponent c: Int) -> CGFloat {
        style.columnWidth ?? pickerView.bounds.width / CGFloat(numberOfComponents(in: pickerView))
    }
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent c: Int) -> CGFloat { style.rowHeight }
    public func pickerView(_ pickerView: UIPickerView, viewForRow r: Int, forComponent c: Int, reusing v: UIView?) -> UIView {
        let lab = (v as? UILabel) ?? UILabel(); lab.textAlignment = .center; lab.font = .systemFont(ofSize: 17); lab.textColor = .label
        switch pickerMode {
        case .ymd: lab.text = c == 0 ? "\(years[r])年" : (c == 1 ? "\(months[r])月" : "\(days[r])日")
        case .ym:  lab.text = c == 0 ? "\(years[r])年" : "\(months[r])月"
        case .y:   lab.text = "\(years[r])年"
        case .md:  lab.text = c == 0 ? "\(months[r])月" : "\(days[r])日"
        case .hm:  lab.text = c == 0 ? "\(hours[r])时" : String(format: "%02d分", r*max(style.minuteInterval,1))
        default: break
        }
        return lab
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow r: Int, inComponent c: Int) {
        if pickerMode == .ymd, (c == 0 || c == 1) {
            let y = years[pickerView.selectedRow(inComponent: 0)]
            let m = months[pickerView.selectedRow(inComponent: 1)]
            rebuildDays(year: y, month: m); pickerView.reloadComponent(2)
        } else if pickerMode == .md, c == 0 {
            let m = months[pickerView.selectedRow(inComponent: 0)]
            rebuildDays(month: m); pickerView.reloadComponent(1)
        }
        if style.isAutoSelect { emitResult() }
    }
}
