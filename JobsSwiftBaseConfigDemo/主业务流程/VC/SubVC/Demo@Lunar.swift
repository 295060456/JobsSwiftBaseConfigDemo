//
//  Demo@Lunar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import UIKit
import LunarSwift
import SnapKit
#if canImport(GKNavigationBar)
import GKNavigationBar
#endif
/// 农历 <-> 公历 Demo（全面适配你的 UITableView/SnapKit/Jobs DSL）
final class LunarDemoVC: UIViewController {
    // MARK: - Sections & Rows
    private enum Section: Int, CaseIterable {
        case example     // README 示例：农历 -> 公历
        case today       // 今天：公历 & 农历
        case interactive // 交互：选择任意公历日期
    }

    private struct Row {
        let title: String
        let value: String
    }
    // MARK: - Data
    private var exampleRows: [Row] = []
    private var todayRows: [Row] = []
    private var interactiveRows: [Row] = []
    // 为了适配空态/上下拉演示，保留 items
    private var items: [String] = []
    private var isPullRefreshing = false
    private var isLoadingMore = false
    // MARK: - UI
    private lazy var datePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) { p.preferredDatePickerStyle = .inline }
        p.locale = Locale(identifier: "zh-Hans")
        // ✅ 用你的 onJobsChange 在懒加载里绑定 .valueChanged
        p.onJobsChange { [weak self] (_: UIDatePicker) in
            self?.onDateChanged()
        }
        return p
    }()
    // 使用你的链式 API + SnapKit 约束 + JobsRefresher
    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .insetGrouped)
            .byDataSource(self)
            .byDelegate(self)
            .registerCell(UITableViewCell.self)                 
            .byNoContentInsetAdjustment()
            .bySeparatorStyle(.singleLine)
            .byNoSectionHeaderTopPadding()

            .jobs_emptyButtonProvider { [unowned self] in
                UIButton(type: .system)
                    .byTitle("暂无数据", for: .normal)
                    .bySubTitle("点我填充示例数据", for: .normal)
                    .byImage("tray".sysImg, for: .normal)
                    .byImagePlacement(.top)
                    .onJobsTap { [weak self] (_: UIButton) in
                        guard let self else { return }
                        self.items = (1...10).map { "Row \($0)" }
                        self.tableView.byReloadData()
                    }
                    .jobs_setEmptyLayout { btn, make, host in
                        make.centerX.equalTo(host)
                        make.centerY.equalTo(host).offset(-40)
                        make.leading.greaterThanOrEqualTo(host).offset(16)
                        make.trailing.lessThanOrEqualTo(host).inset(16)
                        make.width.lessThanOrEqualTo(host).multipliedBy(0.9)
                    }
            }
            // 下拉刷新 Header（保持你的 DSL）
            .configRefreshHeader(component: JobsDefaultHeader(),
                                 container: self,
                                 trigger: 66) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    self.buildTodayRows()
                    self.buildInteractiveRows(for: self.datePicker.date)
                    self.tableView.byReloadData()
                    self.tableView.switchRefreshHeader(to: .normal)
                    self.tableView.switchRefreshFooter(to: .normal)
                }
            }
            // 上拉加载 Footer（保持你的 DSL）
            .configRefreshFooter(component: JobsDefaultFooter(),
                                 container: self,
                                 trigger: 66) { [weak self] in
                guard let self else { return }
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    let base = self.items.count
                    self.items += (1...5).map { "Row \(base + $0)" }
                    self.tableView.byReloadData()
                    self.tableView.switchRefreshFooter(to: .noMoreData)
                }
            }

            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                } else {
                    make.edges.equalToSuperview()
                }
            }
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "日历"
        )
        // 表头：用你的 DSL + SnapKit
        let header = UIView()
        datePicker.byAddTo(header) { [unowned self] make in
            if view.jobs_hasVisibleTopBar() {
                make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                make.left.right.bottom.equalToSuperview()
            } else {
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
            }
        }
        attachHeader(header)

        // 初始数据
        buildExampleRows()
        buildTodayRows()
        buildInteractiveRows(for: datePicker.date)
        updateFooterAvailability()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recalcHeaderIfNeeded()
    }
    // MARK: - Header Helpers（用你的 byTableHeaderView 包装）
    private func attachHeader(_ header: UIView) {
        header.frame.size.width = tableView.bounds.width
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let fitH = header.systemLayoutSizeFitting(
            CGSize(width: header.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        header.frame.size.height = fitH
        tableView.byTableHeaderView(header)
    }

    private func recalcHeaderIfNeeded() {
        guard let header = tableView.tableHeaderView else { return }
        var needs = false
        if header.frame.width != tableView.bounds.width {
            header.frame.size.width = tableView.bounds.width
            needs = true
        }
        let fitH = header.systemLayoutSizeFitting(
            CGSize(width: header.frame.width, height: UIView.layoutFittingCompressedSize.height)
        ).height
        if header.frame.height != fitH {
            header.frame.size.height = fitH
            needs = true
        }
        if needs {
            tableView.byTableHeaderView(header)
        }
    }
    // MARK: - Actions
    @objc private func onDateChanged() {
        buildInteractiveRows(for: datePicker.date)
        tableView.byReloadSections(IndexSet(integer: Section.interactive.rawValue), with: .automatic)
    }
    // MARK: - Data Builders
    private func buildExampleRows() {
        // README 示例：农历 1986-04-21
        let lunar = Lunar.fromYmdHms(lunarYear: 1986, lunarMonth: 4, lunarDay: 21)
        let desc  = lunar.description
        let solar = lunar.solar.fullString
        exampleRows = [
            .init(title: "农历（描述）", value: desc),
            .init(title: "对应公历", value: solar)
        ]
    }

    private func buildTodayRows() {
        todayRows = convertSolar(date: Date())
    }

    private func buildInteractiveRows(for date: Date) {
        interactiveRows = convertSolar(date: date)
    }

    private func convertSolar(date: Date) -> [Row] {
        let cal = Calendar(identifier: .gregorian)
        let c   = cal.dateComponents(in: TimeZone.current, from: date)
        let y   = c.year   ?? 2000
        let m   = c.month  ?? 1
        let d   = c.day    ?? 1
        let hh  = c.hour   ?? 0
        let mm  = c.minute ?? 0
        let ss  = c.second ?? 0

        // 不同版本可能是 year/month/day 标签（而非 solarYear/solarMonth/...）
        let solar = Solar.fromYmdHms(year: y, month: m, day: d, hour: hh, minute: mm, second: ss)
        let solarStr = solar.fullString
        let lunarStr = solar.lunar.description

        return [
            .init(title: "公历", value: solarStr),
            .init(title: "农历", value: lunarStr)
        ]
    }
    // MARK: - Helpers
    private func updateFooterAvailability() {
        // 若你有“无更多数据”开关逻辑，可在此根据 items.count 决定 footer 状态
    }
}
// MARK: - UITableViewDataSource / UITableViewDelegate
extension LunarDemoVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .example:     return exampleRows.count
        case .today:       return todayRows.count
        case .interactive: return interactiveRows.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .example:     return "示例：农历→公历（README 同款）"
        case .today:       return "今天"
        case .interactive: return "选择公历日期（公历→农历）"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ✅ 用你的 API 按类名出队，和 registerCell(UITableViewCell.self) 对齐
        let cell: UITableViewCell = tableView.py_dequeueReusableCell(withType: UITableViewCell.self, for: indexPath)

        let row: Row
        switch Section(rawValue: indexPath.section)! {
        case .example:     row = exampleRows[indexPath.row]
        case .today:       row = todayRows[indexPath.row]
        case .interactive: row = interactiveRows[indexPath.row]
        }

        if #available(iOS 14.0, *) {
            var cfg = cell.defaultContentConfiguration()
            cfg.text = row.title
            cfg.secondaryText = row.value
            cfg.secondaryTextProperties.numberOfLines = 0
            cell.contentConfiguration = cfg
        } else {
            // 老系统：避免 subtitle 样式需求，直接合并成一行
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(row.title)  \(row.value)"
        }
        cell.selectionStyle = .none
        return cell
    }
}
