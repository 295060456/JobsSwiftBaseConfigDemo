//
//  Demo@PDF.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/3/25.
//

import UIKit
import PDFKit
import SnapKit

final class PDFDemoVC: BaseVC {
    // MARK: - Config
    private let resourceName: String = "Terms of Use"
    private let fileExtension: String = "pdf"
    private var document: PDFDocument?
    private var loadedURL: URL?

    private lazy var pdfView: PDFView = {
        PDFView()
            .byAutoScales(NO) // 交给我们手动控制
            .byDisplayMode(.singlePageContinuous)
            .byDisplayDirection(.vertical)
            .byBgColor(.secondarySystemBackground)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                make.bottom.equalTo(thumbnailView.snp.top)
            }
    }()

    private lazy var thumbnailView: PDFThumbnailView = { [unowned self] in
        PDFThumbnailView()
            .byLayoutMode(.horizontal)
            .byThumbnailSize(CGSize(width: 60, height: 80))
            .byBgColor(.tertiarySystemBackground)
            .byContentInset(UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
            .byAddTo(view) { [unowned self] make in
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                make.height.equalTo(96)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav( title: "PDF",
                        rightButtons: [
                            UIButton.sys()
                                .byTitle("上一页", for: .normal) /// 按钮图片@图文关系
                                .byImage("moon.circle.fill".sysImg, for: .normal)
                                .byImage("moon.circle.fill".sysImg, for: .selected) /// 事件触发@点按
                                .onTap { [weak self] sender in
                                    guard let self else { return }
                                    pdfView.goToPreviousPage(nil)
                                },
                            UIButton.sys() .byTitle("下一页", for: .normal) /// 按钮图片@图文关系
                                .byImage("tray".sysImg, for: .normal)
                                .byImage("tray".sysImg, for: .selected) /// 事件触发@点按
                                .onTap { [weak self] sender in
                                    guard let self else { return }
                                    pdfView.goToNextPage(nil)
                                },
                            UIButton.sys() .byTitle("分享", for: .normal) /// 按钮图片@图文关系
                                .byImage("globe".sysImg, for: .normal)
                                .byImage("globe".sysImg, for: .selected) /// 事件触发@点按
                                .onTap { [weak self] sender in
                                    guard let self else { return }
                                    guard let url = loadedURL else { return }
                                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                    if let pop = vc.popoverPresentationController {
                                        pop.barButtonItem = navigationItem.rightBarButtonItems?.first
                                    };present(vc, animated: true)
                                }])

        thumbnailView.byPDFView(to: pdfView)
        loadDocumentOrFail()
    }
    /// 布局后再校准一次
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.byFitScale(max: 4.0)
            .byFitNow(maxScale: 4.0)
    }
    /// 可选增强（避免旋转后又变样）：
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let fit = self.pdfView.scaleFactorForSizeToFit
            self.pdfView.minScaleFactor = fit
            self.pdfView.maxScaleFactor = max(fit, 4.0)
            self.pdfView.scaleFactor   = fit
        })
    }
    // MARK: - Load
    private func loadDocumentOrFail() {
        let bundleURL = Bundle.main.url(forResource: resourceName, withExtension: fileExtension)

        var docsURL: URL?
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let candidate = dir.appendingPathComponent("\(resourceName).\(fileExtension)")
            if FileManager.default.fileExists(atPath: candidate.path) { docsURL = candidate }
        }

        guard let url = bundleURL ?? docsURL else {
            "未找到 \(resourceName).\(fileExtension)\n请将文件放入 Bundle 或 Documents 目录。".toast
            return
        }
        guard let doc = PDFDocument(url: url) else {
            "无法打开 PDF：\(url.lastPathComponent)".toast
            return
        }

        loadedURL = url
        document = doc
        pdfView.document = doc
        if let first = doc.page(at: 0) { pdfView.go(to: first) }
    }
}
