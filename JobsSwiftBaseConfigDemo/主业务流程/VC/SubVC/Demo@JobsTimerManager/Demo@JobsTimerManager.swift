//
//  Demo@JobsTimerManager.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/13/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

import SnapKit
/// Demo Timer ID
private enum JobsTimerManagerDemoID: String, JobsTimerIdentifiable {
    case A_pauseResume
    case B_cancelInBackground
    case C_oneShot

    var timerIdentifier: String { "com.jobs.demo.timer.\(rawValue)" }
}
/// UI Bridge（规避 @Sendable 闭包直接抓 VC）
private final class JobsTimerManagerDemoUIBridge: @unchecked Sendable {
    weak var vc: JobsTimerManagerDemoVC?

    private var aCount = 0
    private var bCount = 0

    init(_ vc: JobsTimerManagerDemoVC) {
        self.vc = vc
    }

    func resetCounters() {
        aCount = 0
        bCount = 0
        Task { @MainActor [weak vc] in
            vc?.countALabel.text = "A ticks: 0"
            vc?.countBLabel.text = "B ticks: 0"
            vc?.oneShotLabel.text = "OneShot: not started"
        }
    }

    func setStatus(_ s: String) {
        Task { @MainActor [weak vc] in
            vc?.statusLabel.text = s
        }
    }

    func incA() {
        aCount += 1
        Task { @MainActor [weak vc] in
            vc?.countALabel.text = "A ticks: \(self.aCount)"
        }
    }

    func incB() {
        bCount += 1
        Task { @MainActor [weak vc] in
            vc?.countBLabel.text = "B ticks: \(self.bCount)"
        }
    }

    func setOneShot(_ s: String) {
        Task { @MainActor [weak vc] in
            vc?.oneShotLabel.text = s
        }
    }

    func log(_ s: String) {
        Task { @MainActor [weak vc] in
            vc?.appendLog(s)
        }
    }
}

final class JobsTimerManagerDemoVC: BaseVC {

    private let horizontalInset: CGFloat = 16
    private let verticalGap: CGFloat = 10
    private let rowHeight: CGFloat = 44

    private lazy var uiBridge: JobsTimerManagerDemoUIBridge = .init(self)

    private lazy var hintLabel: UILabel = {
        UILabel()
            .byNumberOfLines(0)
            .byFont(.systemFont(ofSize: 13, weight: .regular))
            .byTextColor(.secondaryLabel)
            .byText(
                """
                特点演示：
                1) identifier 管理 + upsert 防重复（同 id 直接替换旧 Timer）
                2) A: pauseAndResume（后台 autoPause；前台只恢复 autoPaused，不误恢复手动暂停）
                3) B: cancel（进后台 stop+remove）
                4) OneShot: repeats=false + onFinish + remove
                """
            )
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
            }
    }()

    private lazy var kindSegment: UISegmentedControl = {
        UISegmentedControl(items: ["GCD", "DisplayLink", "NSTimer"])
            .bySelectedSegmentIndex(0)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(hintLabel.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(32)
            }
    }()

    fileprivate lazy var statusLabel: UILabel = {
        UILabel()
            .byNumberOfLines(0)
            .byFont(.systemFont(ofSize: 14, weight: .semibold))
            .byTextColor(.label)
            .byText("Ready")
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(kindSegment.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
            }
    }()

    fileprivate lazy var countALabel: UILabel = {
        UILabel()
            .byFont(.monospacedDigitSystemFont(ofSize: 15, weight: .regular))
            .byTextColor(.label)
            .byText("A ticks: 0")
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(statusLabel.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
            }
    }()

    fileprivate lazy var countBLabel: UILabel = {
        UILabel()
            .byFont(.monospacedDigitSystemFont(ofSize: 15, weight: .regular))
            .byTextColor(.label)
            .byText("B ticks: 0")
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(countALabel.snp.bottom).offset(8)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
            }
    }()

    fileprivate lazy var oneShotLabel: UILabel = {
        UILabel()
            .byFont(.monospacedDigitSystemFont(ofSize: 15, weight: .regular))
            .byTextColor(.label)
            .byText("OneShot: not started")
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(countBLabel.snp.bottom).offset(8)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
            }
    }()

    private lazy var createBtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGreen, for: .normal)
            .byTitle("Create Timers", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }

                let uiBridge = self.uiBridge
                let kindA = self.selectedKindForA()
                let intervalA: TimeInterval = (kindA == .displayLink) ? (1.0 / 30.0) : 1.0

                Task { [uiBridge, kindA, intervalA] in
                    uiBridge.resetCounters()
                    uiBridge.setStatus("Creating...")

                    // A：pauseAndResume
                    do {
                        let cfgA = JobsTimerConfig(interval: intervalA,
                                                  repeats: true,
                                                  tolerance: 0.01,
                                                  queue: .main)

                        _ = await JobsTimerManager.shared.upsertTimer(
                            identifier: JobsTimerManagerDemoID.A_pauseResume,
                            kind: kindA,
                            config: cfgA,
                            policy: .pauseAndResume,
                            startImmediately: true
                        ) { [uiBridge] in
                            uiBridge.log("A initial handler tick")
                        }

                        _ = await JobsTimerManager.shared.onTick(
                            identifier: JobsTimerManagerDemoID.A_pauseResume.timerIdentifier
                        ) { [uiBridge] in
                            uiBridge.incA()
                        }

                        uiBridge.log("Created A ✅  policy=pauseAndResume  kind=\(kindA.jobs_displayName)")
                    }

                    // B：cancel（进后台 stop+remove）
                    do {
                        let cfgB = JobsTimerConfig(interval: 0.7,
                                                  repeats: true,
                                                  tolerance: 0.01,
                                                  queue: .main)

                        _ = await JobsTimerManager.shared.upsertTimer(
                            identifier: JobsTimerManagerDemoID.B_cancelInBackground,
                            kind: .gcd,
                            config: cfgB,
                            policy: .cancel,
                            startImmediately: true
                        ) { [uiBridge] in
                            uiBridge.log("B initial handler tick")
                        }

                        _ = await JobsTimerManager.shared.onTick(
                            identifier: JobsTimerManagerDemoID.B_cancelInBackground.timerIdentifier
                        ) { [uiBridge] in
                            uiBridge.incB()
                        }

                        uiBridge.log("Created B ✅  policy=cancel（后台 stop+remove） kind=GCD")
                    }

                    uiBridge.setStatus("Created. Try: Pause A(Manual) -> background -> foreground -> Dump IDs.")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(oneShotLabel.snp.bottom).offset(14)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.height.equalTo(rowHeight)
            }
    }()

    private lazy var replaceABtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemBlue, for: .normal)
            .byTitle("Replace A (Upsert)", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }

                let uiBridge = self.uiBridge
                let id = JobsTimerManagerDemoID.A_pauseResume.timerIdentifier

                // 用当前 segment 作为“当前 kind”，然后轮换到下一个 kind，演示“同 id 替换内核”
                let current = self.selectedKindForA()
                let newKind = self.nextKind(current)
                let interval: TimeInterval = (newKind == .displayLink) ? (1.0 / 30.0) : 1.0

                Task { [uiBridge, id, newKind, interval] in
                    guard await JobsTimerManager.shared.exists(identifier: id) else {
                        uiBridge.log("Replace A ❌ 先 Create Timers")
                        return
                    }

                    uiBridge.setStatus("Replacing A...")

                    let cfg = JobsTimerConfig(interval: interval,
                                              repeats: true,
                                              tolerance: 0.01,
                                              queue: .main)

                    _ = await JobsTimerManager.shared.upsertTimer(
                        identifier: JobsTimerManagerDemoID.A_pauseResume,
                        kind: newKind,
                        config: cfg,
                        policy: .pauseAndResume,
                        startImmediately: true
                    ) { [uiBridge] in
                        uiBridge.log("A replaced initial handler tick")
                    }

                    _ = await JobsTimerManager.shared.onTick(identifier: id) { [uiBridge] in
                        uiBridge.incA()
                    }

                    uiBridge.log("Replace A ✅  same identifier / new core = \(newKind.jobs_displayName)")
                    uiBridge.setStatus("A replaced. Same identifier, different core.")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(createBtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var pauseABtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemOrange, for: .normal)
            .byTitle("Pause A (Manual)", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                let uiBridge = self.uiBridge
                let id = JobsTimerManagerDemoID.A_pauseResume.timerIdentifier

                Task { [uiBridge, id] in
                    let ok = await JobsTimerManager.shared.pause(identifier: id)
                    uiBridge.log(ok ? "Pause A ✅（手动暂停：回前台不会自动恢复）" : "Pause A ❌（A 不存在）")
                    uiBridge.setStatus("A manual paused. Now background -> foreground: A should stay paused.")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(replaceABtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var resumeABtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemTeal, for: .normal)
            .byTitle("Resume A", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                let uiBridge = self.uiBridge
                let id = JobsTimerManagerDemoID.A_pauseResume.timerIdentifier

                Task { [uiBridge, id] in
                    let ok = await JobsTimerManager.shared.resume(identifier: id)
                    uiBridge.log(ok ? "Resume A ✅" : "Resume A ❌（A 不存在）")
                    uiBridge.setStatus("A resumed.")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(pauseABtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var oneShotBtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemIndigo, for: .normal)
            .byTitle("Start OneShot (2s)", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                let uiBridge = self.uiBridge
                let id = JobsTimerManagerDemoID.C_oneShot.timerIdentifier

                Task { [uiBridge, id] in
                    uiBridge.setOneShot("OneShot: running...")
                    uiBridge.setStatus("Starting OneShot...")

                    let cfg = JobsTimerConfig(interval: 2.0,
                                              repeats: false,
                                              tolerance: 0.01,
                                              queue: .main)

                    _ = await JobsTimerManager.shared.upsertTimer(
                        identifier: JobsTimerManagerDemoID.C_oneShot,
                        kind: .gcd,
                        config: cfg,
                        policy: .ignore,
                        startImmediately: true
                    ) { [uiBridge] in
                        uiBridge.log("OneShot tick (repeats=false)")
                    }

                    _ = await JobsTimerManager.shared.onFinish(identifier: id) { [uiBridge] in
                        uiBridge.log("OneShot onFinish ✅ -> stop+remove")
                        Task { [uiBridge, id] in
                            _ = await JobsTimerManager.shared.stopAndRemove(identifier: id)
                            uiBridge.setOneShot("OneShot: finished + removed")
                        }
                    }

                    uiBridge.log("Start OneShot ✅ interval=2s repeats=false kind=GCD")
                    uiBridge.setStatus("OneShot started. Wait ~2s.")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(resumeABtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var fireOnceRemoveBtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemPurple, for: .normal)
            .byTitle("FireOnce + Remove OneShot", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                let uiBridge = self.uiBridge
                let id = JobsTimerManagerDemoID.C_oneShot.timerIdentifier

                Task { [uiBridge, id] in
                    let ok = await JobsTimerManager.shared.fireOnceAndRemove(identifier: id)
                    uiBridge.log(ok ? "FireOnce+Remove OneShot ✅" : "FireOnce+Remove OneShot ❌（不存在）")
                    uiBridge.setOneShot(ok ? "OneShot: fireOnce + removed" : "OneShot: not exists")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(oneShotBtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var dumpIdsBtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemGray, for: .normal)
            .byTitle("Dump IDs", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                let uiBridge = self.uiBridge

                Task { [uiBridge] in
                    let ids = await JobsTimerManager.shared.allIdentifiers()
                    uiBridge.log("Active IDs: \(ids)")
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(fireOnceRemoveBtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var stopAllBtn: UIButton = {
        UIButton.sys()
            .byBackgroundColor(.systemRed, for: .normal)
            .byTitle("Stop All", for: .normal)
            .byTitleColor(.white, for: .normal)
            .byTitleFont(.systemFont(ofSize: 15, weight: .semibold))
            .onTap { [weak self] _ in
                guard let self else { return }
                let uiBridge = self.uiBridge

                Task { [uiBridge] in
                    await JobsTimerManager.shared.stopAndRemoveAll()
                    uiBridge.log("Stop All ✅")
                    uiBridge.setStatus("All stopped & removed.")
                    uiBridge.resetCounters()
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(dumpIdsBtn.snp.bottom).offset(verticalGap)
                make.left.right.height.equalTo(createBtn)
            }
    }()

    private lazy var logView: UITextView = {
        UITextView()
            .byEditable(NO)
            .byFont(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .byBgColor(.secondarySystemBackground)
            .byCornerRadius(10)
            .byTextContainerInset(.init(top: 10, left: 10, bottom: 10, right: 10))
            .byText("")
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(stopAllBtn.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(horizontalInset)
                make.right.equalToSuperview().inset(horizontalInset)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        jobsSetupGKNav(title: "JobsTimerManager@Demo")
        view.backgroundColor = .systemBackground

        hintLabel.byVisible(YES)
        kindSegment.byVisible(YES)
        statusLabel.byVisible(YES)
        countALabel.byVisible(YES)
        countBLabel.byVisible(YES)
        oneShotLabel.byVisible(YES)

        createBtn.byVisible(YES)
        replaceABtn.byVisible(YES)
        pauseABtn.byVisible(YES)
        resumeABtn.byVisible(YES)
        oneShotBtn.byVisible(YES)
        fireOnceRemoveBtn.byVisible(YES)
        dumpIdsBtn.byVisible(YES)
        stopAllBtn.byVisible(YES)

        logView.byVisible(YES)

        appendLog("提示：切到后台/切回前台：B（cancel）会消失；A（pauseAndResume）仍存在且仅恢复 autoPaused。")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Task { await JobsTimerManager.shared.stopAndRemoveAll() }
    }

    @MainActor
    fileprivate func appendLog(_ s: String) {
        let t = ISO8601DateFormatter().string(from: Date())
        let line = "[\(t)] \(s)\n"
        logView.text = (logView.text ?? "") + line
        let bottom = NSRange(location: max(0, (logView.text as NSString).length - 1), length: 1)
        logView.scrollRangeToVisible(bottom)
    }

    private func selectedKindForA() -> JobsTimerKind {
        switch kindSegment.selectedSegmentIndex {
        case 1: return .displayLink
        case 2: return .foundation
        default: return .gcd
        }
    }

    private func nextKind(_ kind: JobsTimerKind) -> JobsTimerKind {
        switch kind {
        case .gcd: return .displayLink
        case .displayLink: return .foundation
        case .foundation: return .gcd
        default: return .gcd
        }
    }
}
