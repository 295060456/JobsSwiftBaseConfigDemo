//
//  RootListVC.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/29/25.
//

import UIKit

final class RootListVC: UIViewController {
    private let demos: [(title: String, vcType: UIViewController.Type)] = [
        ("ViewController", ViewController.self),
        ("UITextField Demo", UITextFieldDemoVC.self),
        ("UITextView Demo", UITextViewDemoVC.self),
        ("RichText Demo", RichTextDemoVC.self),
        ("UIButton Demo", UIButtonDemoVC.self),
        ("SafetyPushDemo Demo", SafetyPushDemoVC.self),
        ("SafetyPresent Demo", SafetyPresentDemoVC.self),
        ("JobsCountdown Demo", JobsCountdownDemoVC.self),
        ("KeyboardDemo Demo", KeyboardDemoVC.self),
        ("ControlEventsDemo Demo", JobsControlEventsDemoVC.self)
    ]

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demo 列表"
        view.backgroundColor = .systemBackground

        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension RootListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = demos[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcType = demos[indexPath.row].vcType
        let vc = vcType.init()
        vc.title = demos[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }
}
