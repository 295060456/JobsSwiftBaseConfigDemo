//
//  XLSXDemoVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

import UIKit
import CoreXLSX
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers // iOS 14+
#endif
import SnapKit
// MARK: - XLSX Demo（文件导入 + 本地数据注入，全面采用你的链式 DSL）
final class XLSXDemoVC: BaseVC {
    // MARK: UI（链式 DSL）
    private lazy var openButton: UIButton = {
        UIButton.sys()
            .byTitle("打开 .xlsx", for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage("doc.badge.plus".sysImg, for: .normal)
            .byImagePlacement(.leading)
            .byCornerRadius(10)
            .onJobsTap { [weak self] (_: UIButton) in
                self?.openTapped()
            }
            .byAddTo(view) { [unowned self] make in
                if view.jobs_hasVisibleTopBar() {
                    make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
                }
                make.left.equalToSuperview().offset(16)
                make.height.equalTo(36)
            }
    }()

    private lazy var localButton: UIButton = {
        UIButton.sys()
            .byTitle("加载本地", for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage("internaldrive".sysImg, for: .normal)
            .byImagePlacement(.leading)
            .byCornerRadius(10)
            .onJobsTap { [weak self] (_: UIButton) in
                self?.loadLocalDemo() // 示例：注入一份本地数据
            }
            .byAddTo(view) { make in
                make.centerY.equalTo(self.openButton.snp.centerY)
                make.left.greaterThanOrEqualTo(self.openButton.snp.right).offset(12)
            }
    }()

    private lazy var sheetControl: UISegmentedControl = {
        UISegmentedControl(items: [])
            // ✅ 用你的 UIControl 扩展：不用 addTarget，统一走 onJobsChange
            .onJobsChange { [weak self] (sc: UISegmentedControl) in
                self?.currentSheetIndex = sc.selectedSegmentIndex
            }
            .byAddTo(view) { make in
                make.centerY.equalTo(self.openButton.snp.centerY)
                make.left.greaterThanOrEqualTo(self.localButton.snp.right).offset(12)
                make.right.equalToSuperview().inset(16)
            }
    }()

    private lazy var tableView: UITableView = {
        UITableView(frame: .zero, style: .plain)
            .bySeparatorStyle(.singleLine)
            .registerCell(RowCell.self)
            .byDataSource(self)
            .byDelegate(self)
            .byAddTo(view) { make in
                make.top.equalTo(self.openButton.snp.bottom).offset(12)
                make.left.right.bottom.equalToSuperview()
            }
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        UIActivityIndicatorView(style: .medium)
            .byAddTo(view) { make in
                make.center.equalToSuperview()
            }
    }()

    // MARK: Model
    private struct SheetData: Equatable {
        let name: String
        let rows: [[String]]
    }
    /// 你在代码里注入的 Sheet（本地）
    private var injectedSheets: [SheetData] = []
    /// 从 .xlsx 解析出来的 Sheet（文件）
    private var xlsxSheets: [SheetData] = []

    private var sharedStrings: SharedStrings?
    /// 所有要展示的 Sheet = 本地 + 文件（本地在前）
    private var allSheets: [SheetData] { injectedSheets + xlsxSheets }

    private var currentSheetIndex: Int = 0 {
        didSet { tableView.byReloadData() }
    }
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(
            title: "CoreXLSX"
        )
        sheetControl.apportionsSegmentWidthsByContent = true
        spinner.hidesWhenStopped = true
        // 可选：如果 Bundle 里有 sample.xlsx，自动加载
        if let url = Bundle.main.url(forResource: "sample", withExtension: "xlsx") {
            loadXLSX(from: url)
        }
    }
    // MARK: Public API —— 用代码注入“本地 Sheet”
    /// 覆盖本地 Sheet；rows 支持 String / Number / Bool / Date / 自定义类型(用 description)
    public func setLocalSheets(_ sheets: [(name: String, rows: [[Any]])]) {
        injectedSheets = sheets.map { SheetData(name: $0.name, rows: Self.coerceToStrings($0.rows)) }
        refreshSegments(preserveSelection: true)
    }
    /// 追加一个本地 Sheet
    public func appendLocalSheet(name: String, rows: [[Any]]) {
        injectedSheets.append(.init(name: name, rows: Self.coerceToStrings(rows)))
        refreshSegments(preserveSelection: true)
    }
    /// 链式风格（和你工程里的 API 风格一致）
    @discardableResult
    public func bySetLocalSheets(_ sheets: [(name: String, rows: [[Any]])]) -> Self {
        setLocalSheets(sheets); return self
    }
    // MARK: Actions
    @objc private func openTapped() {
        // iOS 14+ 用 UTType；更低版本用老的 documentTypes 构造器
        #if canImport(UniformTypeIdentifiers)
        if #available(iOS 14.0, *) {
            if let xlsx = UTType(filenameExtension: "xlsx") {
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [xlsx], asCopy: true)
                picker.allowsMultipleSelection = false
                picker.delegate = self
                present(picker, animated: true)
                return
            }
        }
        #endif
        let picker = UIDocumentPickerViewController(
            documentTypes: ["org.openxmlformats.spreadsheetml.sheet"],
            in: .import
        )
        picker.allowsMultipleSelection = false
        picker.delegate = self
        present(picker, animated: true)
    }
    // MARK: Parsing XLSX
    private func loadXLSX(from url: URL) {
        spinner.startAnimating()
        // ⚠️ 不要清空 injectedSheets（本地），仅替换 xlsxSheets
        xlsxSheets.removeAll()
        refreshSegments(preserveSelection: true) // 先清 UI（避免上一份名字残留）

        let needsStop = url.startAccessingSecurityScopedResource()
        defer {
            if needsStop { url.stopAccessingSecurityScopedResource() }
            spinner.stopAnimating()
        }

        guard let file = XLSXFile(filepath: url.path) else {
            showError("无法打开 XLSX：文件不存在或已损坏")
            return
        }

        do {
            sharedStrings = try file.parseSharedStrings()

            var parsed: [SheetData] = []
            for wbk in try file.parseWorkbooks() {
                for (maybeName, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
                    let ws = try file.parseWorksheet(at: path)
                    let name = maybeName ?? "Worksheet"
                    let rows = makeRowsDisplayStrings(from: ws)
                    parsed.append(.init(name: name, rows: rows))
                }
            }
            xlsxSheets = parsed
            refreshSegments(preserveSelection: false)

            if allSheets.isEmpty {
                showError("文件中未发现任何工作表")
            }
        } catch {
            showError("解析失败：\(error.localizedDescription)")
        }
    }
    /// worksheet -> [[String]]（按出现顺序）
    private func makeRowsDisplayStrings(from worksheet: Worksheet) -> [[String]] {
        var result: [[String]] = []
        let rows = worksheet.data?.rows ?? []
        for row in rows {
            var displayRow: [String] = []
            for cell in row.cells {
                displayRow.append(render(cell))
            }
            result.append(displayRow)
        }
        return result
    }
    /// 单元格文本渲染：SharedStrings -> inlineString -> dateValue -> value
    private func render(_ cell: Cell) -> String {
        if let ss = sharedStrings, let s = cell.stringValue(ss) { return s }
        if let inline = cell.inlineString?.text { return inline }
        if let d = cell.dateValue {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df.string(from: d)
        }
        return cell.value ?? ""
    }
    // MARK: UI Helpers
    private func refreshSegments(preserveSelection: Bool) {
        // 尝试保留当前选中的 sheet 名称
        let selectedName: String? = (0..<sheetControl.numberOfSegments).contains(currentSheetIndex)
            ? sheetControl.titleForSegment(at: currentSheetIndex)
            : nil

        sheetControl.removeAllSegments()
        for (i, s) in allSheets.enumerated() {
            sheetControl.insertSegment(withTitle: s.name, at: i, animated: false)
        }

        if allSheets.isEmpty {
            currentSheetIndex = 0
            tableView.byReloadData()
            return
        }

        if preserveSelection, let sel = selectedName,
           let idx = allSheets.firstIndex(where: { $0.name == sel }) {
            sheetControl.selectedSegmentIndex = idx
            currentSheetIndex = idx
        } else {
            sheetControl.selectedSegmentIndex = 0
            currentSheetIndex = 0
        }
    }
    // 你的 Alert 链式 API
    private func showError(_ message: String) {
        UIAlertController
            .makeAlert("提示")
            .byMessage(message)
            .byAddOK("好的", isPreferred: true)
            .byPresent(self)
    }
}
// MARK: - UIDocumentPickerDelegate
extension XLSXDemoVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        loadXLSX(from: url)
    }
}
// MARK: - UITableViewDataSource & Delegate
extension XLSXDemoVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard allSheets.indices.contains(currentSheetIndex) else { return 0 }
        return allSheets[currentSheetIndex].rows.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RowCell.reuseID,
                                                       for: indexPath) as? RowCell else {
            return UITableViewCell()
        }
        let row = allSheets[currentSheetIndex].rows[indexPath.row]
        cell.configure(with: row, rowIndex: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - RowCell（SnapKit 布局）
private final class RowCell: UITableViewCell {
    static let reuseID = "RowCell"

    private let stack = UIStackView()
    private let indexLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        indexLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        indexLabel.textColor = .secondaryLabel
        indexLabel.setContentHuggingPriority(.required, for: .horizontal)

        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 12
        stack.distribution = .fillProportionally

        contentView.addSubview(indexLabel)
        contentView.addSubview(stack)

        indexLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(12)
        }
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(indexLabel.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with values: [String], rowIndex: Int) {
        indexLabel.text = "#\(rowIndex)"
        stack.arrangedSubviews.forEach { v in
            stack.removeArrangedSubview(v); v.removeFromSuperview()
        }
        for text in values {
            let label = UILabel()
            label.numberOfLines = 1
            label.font = .systemFont(ofSize: 15)
            label.text = text
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            stack.addArrangedSubview(label)
        }
    }
}
// MARK: - Local demo & stringify
private extension XLSXDemoVC {
    /// 示例：一键注入本地数据（可删）
    func loadLocalDemo() {
        let rows: [[Any]] = [
            ["编号","姓名","得分","更新时间","标签"],
            [1, "Jobs", 100, Date(), "🟩📊"],
            [2, "Alice", 97.5, Date().addingTimeInterval(-3600), "📈"],
            [3, "Bob", true, Date().addingTimeInterval(-86400), "🧮"],
        ]
        setLocalSheets([("本地示例", rows)])
    }

    /// 把 [[Any]] 变成 [[String]]，保留 emoji；Date 做人类可读格式
    static func coerceToStrings(_ anyRows: [[Any]]) -> [[String]] {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return anyRows.map { row in
            row.map { cell -> String in
                switch cell {
                case let s as String: return s
                case let d as Date:   return df.string(from: d)
                case let b as Bool:   return b ? "true" : "false"
                case let n as NSNumber: return n.stringValue
                case let f as Float:  return String(f)
                case let d as Double: return String(d)
                case let i as Int:    return String(i)
                case let c as CustomStringConvertible: return c.description
                default: return "\(cell)"
                }
            }
        }
    }
}
