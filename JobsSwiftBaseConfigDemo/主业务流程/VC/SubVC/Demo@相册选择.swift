//
//  PhotoAlbumDemoVC.swift
//  JobsSwiftBaseConfigDemo
//

import UIKit
import SnapKit
import AVFoundation
import Photos
import PhotosUI   // 新增：视频选择（PHPicker）

@MainActor
final class PhotoAlbumDemoVC: BaseVC, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private enum SourceMode { case none, cameraPhoto, albumImages, cameraVideo, albumVideos }
    private var mode: SourceMode = .none
    private var images: [UIImage] = []
    private var videoURL: URL?              // 单个视频（拍摄 / 单选）
    private var albumVideoURLs: [URL] = []  // 多个视频（相册多选）
    private var pickerHold: AnyObject?      // 持有 PHPicker/UIImagePicker 的代理，防释放

    private let gridColumns: CGFloat = 3
    private let gridSpacing: CGFloat = 8
    private let gridInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private var imageMaxSelection = 7       // 自定义“多选图片”上限（0 表示不限制）
    private var videoMaxSelection = 8       // 自定义“多选视频”上限（0 表示不限制）

    private func albumImageButtonTitle() -> String {
        imageMaxSelection == 0 ? "打开相册选照片（不限制）" : "打开相册选照片（最多\(imageMaxSelection)张）"
    }

    private func albumVideoButtonTitle() -> String {
        videoMaxSelection == 0 ? "打开相册选视频（不限制）" : "打开相册选视频（最多\(videoMaxSelection)个）"
    }

    // MARK: - Buttons
    private lazy var cameraBtn: UIButton = { [unowned self] in
        let b = UIButton(type: .system)
            .byTitle("调用相机照相", for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage(UIImage(systemName: "camera.fill"), for: .normal)
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byCornerRadius(12)
            .byBgColor(.systemBlue)
            .onTap { [weak self] _ in
                guard let self else { return }
                #if targetEnvironment(simulator)
                showToast("模拟器无法使用相机"); return
                #else
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    showToast("此设备不支持相机"); return
                }
                pickFromCamera(allowsEditing: false) { [weak self] img in
                    guard let self else { return }
                    showToast("已拍照 1 张")
                    self.showCameraImage(img)
                }
                #endif
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.gk_navigationBar.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(48)
            }
        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("调用相机照相")
                    .byBaseForegroundCor(.white)
                    .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .byCornerStyle(.large)
                    .byImage(UIImage(systemName: "camera.fill"))
                    .byImagePlacement(.leading)
                    .byImagePadding(8)
            }
        }
        return b
    }()

    private lazy var albumBtn: UIButton = { [unowned self] in
        let b = UIButton(type: .system)
            .byTitle(albumImageButtonTitle(), for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byCornerRadius(12)
            .byBgColor(.systemGreen)
            .onTap { [weak self] _ in
                guard let self else { return }
                pickFromPhotoLibrary(maxSelection: imageMaxSelection, imagesOnly: true) { [weak self] imgs in
                    guard let self else { return }
                    showToast(imgs.isEmpty ? "未选择图片" : "已选择 \(imgs.count) 张")
                    self.showAlbumImages(imgs)
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.cameraBtn.snp.bottom).offset(16)
                make.left.right.height.equalTo(self.cameraBtn)
            }
        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle(albumImageButtonTitle())
                    .byBaseForegroundCor(.white)
                    .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .byCornerStyle(.large)
                    .byImage(UIImage(systemName: "photo.on.rectangle"))
                    .byImagePlacement(.leading)
                    .byImagePadding(8)
            }
        }
        return b
    }()

    private lazy var recordBtn: UIButton = { [unowned self] in
        let b = UIButton(type: .system)
            .byTitle("录制视频", for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage(UIImage(systemName: "video.fill"), for: .normal)
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byCornerRadius(12)
            .byBgColor(.systemPink)
            .onTap { [weak self] _ in
                guard let self else { return }
                #if targetEnvironment(simulator)
                showToast("模拟器无法录制视频"); return
                #else
                MediaPickerService.recordVideo(from: self, maxDuration: 30, quality: .typeHigh) { [weak self] url in
                    guard let self else { return }
                    showToast("已录制 1 段视频")
                    self.showCameraVideo(url)
                }
                #endif
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.albumBtn.snp.bottom).offset(16)
                make.left.right.height.equalTo(self.cameraBtn)
            }
        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("录制视频")
                    .byBaseForegroundCor(.white)
                    .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .byCornerStyle(.large)
                    .byImage(UIImage(systemName: "video.fill"))
                    .byImagePlacement(.leading)
                    .byImagePadding(8)
            }
        }
        return b
    }()
    // 相册单选视频
    private lazy var pickOneVideoBtn: UIButton = { [unowned self] in
        let b = UIButton(type: .system)
            .byTitle("选择一个视频", for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage(UIImage(systemName: "film"), for: .normal)
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byCornerRadius(12)
            .byBgColor(.systemIndigo)
            .onTap { [weak self] _ in
                guard let self else { return }
                pickVideosFromLibrary(maxSelection: 1) { [weak self] urls in
                    guard let self, let u = urls.first else { return }
                    showToast("已选择 1 个视频")
                    self.showCameraVideo(u)
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.recordBtn.snp.bottom).offset(16)
                make.left.right.height.equalTo(self.cameraBtn)
            }
        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("选择一个视频")
                    .byBaseForegroundCor(.white)
                    .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .byCornerStyle(.large)
                    .byImage(UIImage(systemName: "film"))
                    .byImagePlacement(.leading)
                    .byImagePadding(8)
            }
        }
        return b
    }()
    // 相册多选视频（上限可自定义）
    private lazy var pickMultiVideoBtn: UIButton = { [unowned self] in
        let b = UIButton(type: .system)
            .byTitle(albumVideoButtonTitle(), for: .normal)
            .byTitleFont(.systemFont(ofSize: 16, weight: .medium))
            .byTitleColor(.white, for: .normal)
            .byImage(UIImage(systemName: "film.stack"), for: .normal)
            .byContentEdgeInsets(.init(top: 12, left: 16, bottom: 12, right: 16))
            .byCornerRadius(12)
            .byBgColor(.systemTeal)
            .onTap { [weak self] _ in
                guard let self else { return }
                self.pickVideosFromLibrary(maxSelection: self.videoMaxSelection) { [weak self] urls in
                    guard let self else { return }
                    if urls.isEmpty { showToast("未选择视频"); return }
                    showToast("已选择 \(urls.count) 个视频")
                    self.showAlbumVideos(urls)
                }
            }
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.pickOneVideoBtn.snp.bottom).offset(16)
                make.left.right.height.equalTo(self.cameraBtn)
            }
        if #available(iOS 15.0, *) {
            b.byConfiguration { c in
                c.byTitle("选择多个视频（上限可改）")
                    .byBaseForegroundCor(.white)
                    .byContentInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .byCornerStyle(.large)
                    .byImage(UIImage(systemName: "film.stack"))
                    .byImagePlacement(.leading)
                    .byImagePadding(8)
            }
        }
        return b
    }()
    // MARK: - Preview
    private lazy var previewContainer: UIView = { [unowned self] in
        let v = UIView()
        v.byBgColor(.secondarySystemBackground)
            .byCornerRadius(12)
            .byAddTo(view) { [unowned self] make in
                make.top.equalTo(self.pickMultiVideoBtn.snp.bottom).offset(16) // ← 改为跟多选视频按钮对齐
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(v.snp.width) // 正方形
            }
        return v
    }()

    private lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = gridSpacing
        layout.minimumLineSpacing = gridSpacing

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseId)
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseId)
        cv.register(VideoThumbCell.self, forCellWithReuseIdentifier: VideoThumbCell.reuseId)
        self.previewContainer.addSubview(cv)
        cv.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(gridInsets)
        }
        cv.isScrollEnabled = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        jobsSetupGKNav(title: "鉴权后：相机 / 相册 / 录制 / 选视频")

        cameraBtn.byAlpha(1)
        albumBtn.byAlpha(1)
        recordBtn.byAlpha(1)
        pickOneVideoBtn.byAlpha(1)
        pickMultiVideoBtn.byAlpha(1)
        previewContainer.byAlpha(1)
        collectionView.byAlpha(1)

        mode = .none
        reloadPreviewAndScrollMode()
    }

    // MARK: - Data switching
    private func showCameraImage(_ image: UIImage) {
        mode = .cameraPhoto
        images = [image]; videoURL = nil; albumVideoURLs.removeAll()
        reloadPreviewAndScrollMode()
    }

    private func showAlbumImages(_ imgs: [UIImage]) {
        mode = .albumImages
        images = imgs; videoURL = nil; albumVideoURLs.removeAll()
        reloadPreviewAndScrollMode()
    }

    private func showCameraVideo(_ url: URL) {
        mode = .cameraVideo
        images.removeAll(); videoURL = url; albumVideoURLs.removeAll()
        reloadPreviewAndScrollMode()
    }

    private func showAlbumVideos(_ urls: [URL]) {
        mode = .albumVideos
        images.removeAll(); videoURL = nil; albumVideoURLs = urls
        reloadPreviewAndScrollMode()
    }

    private func reloadPreviewAndScrollMode() {
        collectionView.setContentOffset(.zero, animated: false)
        collectionView.collectionViewLayout.invalidateLayout()
        applyScrollPolicy()
        collectionView.reloadData()
    }

    /// 滚动策略
    private func applyScrollPolicy() {
        switch mode {
        case .cameraPhoto, .cameraVideo, .none:
            collectionView.isScrollEnabled = false
            collectionView.showsVerticalScrollIndicator = false
        case .albumImages:
            let disable = images.count <= 9
            collectionView.isScrollEnabled = !disable
            collectionView.showsVerticalScrollIndicator = !disable
        case .albumVideos:
            let disable = albumVideoURLs.count <= 9
            collectionView.isScrollEnabled = !disable
            collectionView.showsVerticalScrollIndicator = !disable
        }
        collectionView.alwaysBounceVertical = collectionView.isScrollEnabled
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch mode {
        case .cameraPhoto: return images.isEmpty ? 0 : 1
        case .albumImages: return images.count
        case .cameraVideo: return videoURL == nil ? 0 : 1
        case .albumVideos: return albumVideoURLs.count
        case .none:        return 1 // 空态
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch mode {
        case .cameraPhoto, .albumImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseId, for: indexPath) as! ImageCell
            let img = (mode == .cameraPhoto) ? images[0] : images[indexPath.item]
            cell.configure(with: img)
            return cell
        case .cameraVideo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseId, for: indexPath) as! VideoCell
            if let url = videoURL { cell.configure(with: url) }
            return cell
        case .albumVideos:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoThumbCell.reuseId, for: indexPath) as! VideoThumbCell
            cell.configure(with: albumVideoURLs[indexPath.item])
            return cell
        case .none:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseId, for: indexPath) as! ImageCell
            cell.configure(with: "暂无内容@黑底蓝字".img)
            return cell
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch mode {
        case .cameraPhoto, .cameraVideo, .none:
            let w = width - gridInsets.left - gridInsets.right
            return CGSize(width: w, height: w) // 单格
        case .albumImages, .albumVideos:
            let totalSpacing = gridInsets.left + gridInsets.right + gridSpacing * (gridColumns - 1)
            let side = floor((width - totalSpacing) / gridColumns)
            return CGSize(width: side, height: side)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets { gridInsets }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch mode {
        case .cameraPhoto, .cameraVideo, .none: return 0
        case .albumImages, .albumVideos:       return gridSpacing
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch mode {
        case .cameraPhoto, .cameraVideo, .none: return 0
        case .albumImages, .albumVideos:        return gridSpacing
        }
    }
}

// MARK: - Cells
private final class ImageCell: UICollectionViewCell {
    static let reuseId = "ImageCell"
    private let iv = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        contentView.addSubview(iv)
        iv.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with image: UIImage) { iv.image = image }
}
/// 单个视频：自动播放，结束后出现「播放按钮」可重播
private final class VideoCell: UICollectionViewCell {
    static let reuseId = "VideoCell"

    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    // 用你家的链式 API 创建覆盖按钮
    private lazy var playOverlay: UIButton = { [unowned self] in
        let img = "播放按钮".img.withRenderingMode(.alwaysOriginal)   // 确保非模板渲染
        let b = UIButton(type: .system)
            .byImage(img, for: .normal)
            .byBgColor(.clear)
            .byContentEdgeInsets(.zero)
            .onTap { [weak self] _ in self?.onReplay() }
            .byAddTo(self.contentView) { make in
                make.center.equalToSuperview()
                // 按你原设计 64x64；想用原图尺寸就改成 img.size.width/height
                make.width.height.equalTo(64)
            }
        // 绝对置顶
        b.layer.zPosition = 9999
        b.isHidden = true
        return b
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        tearDownPlayer()
    }
    deinit { tearDownPlayer() }

    private func tearDownPlayer() {
        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        playOverlay.isHidden = true
    }

    func configure(with url: URL) {
        tearDownPlayer()

        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .pause        // 到尾暂停，等你点按钮
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = contentView.bounds
        layer.zPosition = -1                    // ⬅︎ 永远在按钮下面
        contentView.layer.addSublayer(layer)
        playerLayer = layer

        // 再兜底把按钮提到最上
        contentView.bringSubviewToFront(playOverlay)
        playOverlay.layer.zPosition = 9999
        playOverlay.isHidden = true

        // 结束后显示按钮 —— object 用 nil 更稳
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.playOverlay.isHidden = false
        }

        player.seek(to: .zero)
        player.play()
        setNeedsLayout(); layoutIfNeeded()
        playerLayer?.frame = contentView.bounds
    }

    @objc private func onReplay() {
        playOverlay.isHidden = true
        player?.seek(to: .zero)
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
        // 再次确保覆盖层在最顶
        if let pl = playerLayer { pl.zPosition = -1 }
        playOverlay.layer.zPosition = 9999
    }
}
/// 多个视频缩略格：显示首帧缩略图（不自动播放）
private final class VideoThumbCell: UICollectionViewCell {
    static let reuseId = "VideoThumbCell"
    private let iv = UIImageView()
    private let playBadge = UIImageView(image: UIImage(systemName: "play.circle.fill"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        iv.contentMode = .scaleAspectFill; iv.clipsToBounds = true
        contentView.addSubview(iv)
        iv.snp.makeConstraints { $0.edges.equalToSuperview() }

        if #available(iOS 13.0, *) { playBadge.tintColor = .white }
        playBadge.alpha = 0.9
        contentView.addSubview(playBadge)
        playBadge.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(28) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with url: URL) {
        iv.image = nil
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let gen = AVAssetImageGenerator(asset: asset)
            gen.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0.1, preferredTimescale: 600)
            if let cg = try? gen.copyCGImage(at: time, actualTime: nil) {
                let img = UIImage(cgImage: cg)
                DispatchQueue.main.async { self.iv.image = img }
            }
        }
    }
}
//////////////////////////////////////////////////////////////
// MARK: - 相册选择视频（单/多）
// 放在 VC 内，复用 PermissionCenter；也可抽到 MediaPickerService
//////////////////////////////////////////////////////////////
private extension PhotoAlbumDemoVC {
    func pickVideosFromLibrary(maxSelection: Int, completion: @escaping ([URL]) -> Void) {
        PermissionCenter.ensure(.photoLibraryReadWrite, from: self) { [weak self] in
            guard let self else { return }
            if #available(iOS 14, *) {
                var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                config.selectionLimit = maxSelection <= 0 ? 0 : maxSelection  // 0 = 不限制
                config.filter = .videos
                let proxy = PHPickerVideoProxy { [weak self] urls in
                    completion(urls); self?.pickerHold = nil
                }
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = proxy
                self.pickerHold = proxy
                self.present(picker, animated: true)
            } else {
                // iOS 13 及以下仅支持单选
                if maxSelection != 1 {
                    Task { @MainActor in showToast("多选视频仅支持 iOS 14 及以上") }
                }
                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
                let proxy = LegacyVideoLibraryProxy { [weak self] url in
                    completion(url.map { [$0] } ?? []); self?.pickerHold = nil
                }
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.mediaTypes = [UTType.movie.identifier]
                picker.delegate = proxy
                self.pickerHold = proxy
                self.present(picker, animated: true)
            }
        }
    }
}

@available(iOS 14, *)
private final class PHPickerVideoProxy: NSObject, PHPickerViewControllerDelegate {
    let completion: ([URL]) -> Void
    init(completion: @escaping ([URL]) -> Void) { self.completion = completion }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard !results.isEmpty else { completion([]); return }
        let group = DispatchGroup()
        var urls: [URL] = []

        for r in results {
            let provider = r.itemProvider
            let typeId = UTType.movie.identifier  // "public.movie"
            if provider.hasItemConformingToTypeIdentifier(typeId) {
                group.enter()
                provider.loadFileRepresentation(forTypeIdentifier: typeId) { tmpURL, _ in
                    defer { group.leave() }
                    guard let tmpURL else { return }
                    // 复制到我们的临时目录，避免系统回收
                    let dst = FileManager.default.temporaryDirectory
                        .appendingPathComponent("picked-\(UUID().uuidString).mov")
                    do {
                        try FileManager.default.copyItem(at: tmpURL, to: dst)
                        urls.append(dst)
                    } catch {
                        // 忽略复制失败个案
                    }
                }
            }
        }

        group.notify(queue: .main) { [completion] in completion(urls) }
    }
}

private final class LegacyVideoLibraryProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let completion: (URL?) -> Void
    init(completion: @escaping (URL?) -> Void) { self.completion = completion }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let url = info[.mediaURL] as? URL
        completion(url)
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion(nil)
        picker.dismiss(animated: true)
    }
}


