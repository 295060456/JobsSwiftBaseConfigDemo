//
//  UIImageView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
// MARK: - UIImageView 链式封装
public extension UIImageView {
    // MARK: 图片
    @discardableResult
    func byImage(_ img: UIImage?) -> Self {
        image = img
        return self
    }
    // MARK: 高亮图片
    @discardableResult
    func byHighlightedImage(_ image: UIImage?) -> Self {
        highlightedImage = image
        return self
    }
    // MARK: 是否可交互 UIView.byUserInteractionEnabled
    // MARK: 是否高亮
    @discardableResult
    func byHighlighted(_ highlighted: Bool = true) -> Self {
        isHighlighted = highlighted
        return self
    }
    // MARK: 动画图片组
    @discardableResult
    func byAnimationImages(_ images: [UIImage]?) -> Self {
        animationImages = images
        return self
    }
    // MARK: 高亮状态动画图片组
    @discardableResult
    func byHighlightedAnimationImages(_ images: [UIImage]?) -> Self {
        highlightedAnimationImages = images
        return self
    }
    // MARK: 动画时长
    @discardableResult
    func byAnimationDuration(_ duration: TimeInterval) -> Self {
        animationDuration = duration
        return self
    }
    // MARK: 动画重复次数
    @discardableResult
    func byAnimationRepeatCount(_ count: Int) -> Self {
        animationRepeatCount = count
        return self
    }
    // MARK: Tint 颜色（支持 SF Symbol / 模板渲染）
    @discardableResult
    func byTintColor(_ color: UIColor?) -> Self {
        tintColor = color
        return self
    }
    // MARK: iOS13+ Symbol 配置
    @available(iOS 13.0, *)
    @discardableResult
    func bySymbolConfig(_ config: UIImage.SymbolConfiguration?) -> Self {
        preferredSymbolConfiguration = config
        return self
    }
    // MARK: - HDR 动态范围 (iOS17+)
    @available(iOS 17.0, *)
    @discardableResult
    func byPreferredImageDynamicRange(_ range: UIImage.DynamicRange) -> Self {
        preferredImageDynamicRange = range
        return self
    }
    // MARK: - 启动动画
    @discardableResult
    func startAnimation() -> Self {
        startAnimating()
        return self
    }
    // MARK: - 停止动画
    @discardableResult
    func stopAnimation() -> Self {
        stopAnimating()
        return self
    }
}
#if canImport(Kingfisher)
import Kingfisher
public extension UIImageView {
    @discardableResult
    func kf_setImage(from string: String,
                     placeholder: UIImage? = nil,
                     fade: TimeInterval = 0.25) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            kf.setImage(with: url,
                             placeholder: placeholder,
                             options: [.transition(.fade(fade))])
        case .local(let name)?:
            image = UIImage(named: name) ?? placeholder
        case nil:
            image = placeholder
        }
        return self
    }

    @discardableResult
    func byAsyncImageKF(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        Task { @MainActor in
            let img = await src.kfLoadImage(fallbackImage: fallback())
            image = img
        }
        return self
    }
}
#endif

#if canImport(SDWebImage)
import SDWebImage
public extension UIImageView {
    @discardableResult
    func sd_setImage(from string: String,
                     placeholder: UIImage? = nil,
                     fade: TimeInterval = 0.25) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            sd_setImage(
                with: url,
                placeholderImage: placeholder,
                options: [.avoidAutoSetImage]
            ) { [weak self] image, _, _, _ in
                guard let self = self else { return }
                UIView.transition(with: self,
                                  duration: fade,
                                  options: .transitionCrossDissolve,
                                  animations: { self.image = image },
                                  completion: nil)
            }
        case .local(let name)?:
            image = UIImage(named: name) ?? placeholder
        case nil:
            image = placeholder
        }
        return self
    }

    @discardableResult
    func byAsyncImageSD(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        Task { @MainActor in
            let img = await src.sdLoadImage(fallbackImage: fallback())
            image = img
        }
        return self
    }
}
#endif

