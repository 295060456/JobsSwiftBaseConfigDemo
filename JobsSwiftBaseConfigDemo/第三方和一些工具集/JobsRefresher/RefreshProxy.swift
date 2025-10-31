import UIKit

@MainActor
final class MRKProxy: NSObject {
    weak var scrollView: UIScrollView?
    private var kvo: NSKeyValueObservation?
    private var panKvo: NSKeyValueObservation?

    var header: MRKSlot?
    var footer: MRKSlot?
    var left:   MRKSlot?
    var right:  MRKSlot?

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        observe()
    }

    deinit { kvo?.invalidate(); panKvo?.invalidate() }

    private func observe() {
        guard let sv = scrollView else { return }
        kvo = sv.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            Task { @MainActor in self?.tick() }
        }
        panKvo = sv.panGestureRecognizer.observe(\.state, options: [.new]) { [weak self] _, _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func tick() {
        guard let sv = scrollView else { return }
        header?.handle(with: sv)
        footer?.handle(with: sv)
        left?.handle(with: sv)
        right?.handle(with: sv)
    }
}

@MainActor
final class MRKSlot {
    let position: MRKPosition
    let view: (UIView & MRKAnimatable)
    let trigger: CGFloat
    var action: (() -> Void)?
    weak var container: AnyObject?

    // —— 行为开关 —— //
    /// 结束刷新：指示视图先退场，再让内容区回位
    var retreatAhead: Bool = true
    /// 先退场后再回位之间的停顿（更容易看出“先/后”的时序）
    var retreatAheadDelay: TimeInterval = 0.06
    /// A 段（指示视图退场）时长
    var retreatAnimDuration: TimeInterval = 0.14
    /// B 段（内容回位：contentInset 还原）时长
    var restoreInsetDuration: TimeInterval = 0.25

    /// 先退场阶段屏蔽 tick/布局，避免 KVO 干扰
    private var isEndingAnimation = false

    private(set) var state: MRKState = .idle {
        didSet { view.apply(state: state) }
    }

    init(position: MRKPosition,
         view: (UIView & MRKAnimatable),
         trigger: CGFloat,
         container: AnyObject?,
         action: @escaping () -> Void) {
        self.position = position
        self.view = view
        self.trigger = trigger
        self.container = container
        self.action = action
    }

    func attach(to sv: UIScrollView) {
        if view.superview !== sv { sv.addSubview(view) }
        layout(in: sv)
        if state == .removed { state = .idle }
    }

    func detach() {
        view.removeFromSuperview()
        state = .removed
    }

    func layout(in sv: UIScrollView) {
        let inset = sv.adjustedContentInset
        switch position {
        case .header:
            view.frame = CGRect(x: 0,
                                y: -view.heightOrWidth - inset.top,
                                width: sv.bounds.width,
                                height: view.heightOrWidth)
        case .footer:
            let h = max(sv.contentSize.height, sv.bounds.height - (inset.top + inset.bottom))
            view.frame = CGRect(x: 0,
                                y: h + inset.bottom,
                                width: sv.bounds.width,
                                height: view.heightOrWidth)
        case .left:
            view.frame = CGRect(x: -view.heightOrWidth - inset.left,
                                y: 0,
                                width: view.heightOrWidth,
                                height: sv.bounds.height)
        case .right:
            let w = max(sv.contentSize.width, sv.bounds.width - (inset.left + inset.right))
            view.frame = CGRect(x: w + inset.right,
                                y: 0,
                                width: view.heightOrWidth,
                                height: sv.bounds.height)
        }
    }

    func handle(with sv: UIScrollView) {
        guard state != .removed, !isEndingAnimation else { return }
        attach(to: sv)

        let inset = sv.adjustedContentInset
        let offset = sv.contentOffset
        let isDragging = sv.isDragging

        switch position {
        case .header:
            let distance = -(offset.y + inset.top)
            progress(distance: distance, axis: .vertical, isDragging: isDragging, sv: sv)
        case .footer:
            let contentH = max(sv.contentSize.height, sv.bounds.height - (inset.top + inset.bottom))
            let distance = offset.y + sv.bounds.height - contentH - inset.bottom
            progress(distance: distance, axis: .vertical, isDragging: isDragging, sv: sv, isFooter: true)
        case .left:
            let distance = -(offset.x + inset.left)
            progress(distance: distance, axis: .horizontal, isDragging: isDragging, sv: sv)
        case .right:
            let contentW = max(sv.contentSize.width, sv.bounds.width - (inset.left + inset.right))
            let distance = offset.x + sv.bounds.width - contentW - inset.right
            progress(distance: distance, axis: .horizontal, isDragging: isDragging, sv: sv)
        }
    }

    private func progress(distance: CGFloat,
                          axis: MRKAxis,
                          isDragging: Bool,
                          sv: UIScrollView,
                          isFooter: Bool = false) {
        guard state != .refreshing && state != .noMore else { return }

        let p = max(0, min(1, distance / trigger))
        if isDragging {
            state = (p >= 1) ? .ready : .pulling(progress: p)
        } else {
            if state == .ready {
                beginRefreshing(on: sv, axis: axis, isFooter: isFooter)
            } else if case .pulling = state {
                state = .idle
            }
        }
    }

    func beginRefreshing(on sv: UIScrollView, axis: MRKAxis? = nil, isFooter: Bool = false) {
        guard state != .refreshing else { return }
        state = .refreshing

        let h = view.heightOrWidth
        var inset = sv.contentInset

        switch position {
        case .header: inset.top    += h
        case .footer: inset.bottom += h
        case .left:   inset.left   += h
        case .right:  inset.right  += h
        }

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            sv.contentInset = inset
        }

        action?()
        if container == nil { endRefreshing(on: sv) } // 容器释放时兜底
    }

    func endRefreshing(on sv: UIScrollView, backTo targetInsetOpt: UIEdgeInsets? = nil) {
        guard case .refreshing = state else { return }
        state = .idle

        let h = view.heightOrWidth
        let targetInset = targetInsetOpt ?? resetInset(from: sv.contentInset)

        // 旧行为：直接还原 inset（同步回位）
        guard retreatAhead else {
            UIView.animate(withDuration: restoreInsetDuration,
                           delay: 0,
                           options: [.allowUserInteraction, .beginFromCurrentState]) {
                sv.contentInset = targetInset
            } completion: { _ in
                self.layout(in: sv)
            }
            return
        }

        // —— 新行为：A 先退场 → (delay) → B 内容回位 —— //
        isEndingAnimation = true
        let oldEnabled = sv.isScrollEnabled
        sv.isScrollEnabled = false   // 钉住内容，避免系统减速/回弹干扰 A 段

        let retreatTransform: CGAffineTransform = {
            switch position {
            case .header: return CGAffineTransform(translationX: 0, y: -h)
            case .footer: return CGAffineTransform(translationX: 0, y:  h)
            case .left:   return CGAffineTransform(translationX: -h, y: 0)
            case .right:  return CGAffineTransform(translationX:  h, y: 0)
            }
        }()

        // A 段：指示视图先退场（不动 contentInset）
        UIView.animate(withDuration: retreatAnimDuration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.view.transform = retreatTransform
            self.view.alpha = 0
        } completion: { _ in
            // 明确隐藏，避免 B 段 inset 变化时闪一下
            self.view.isHidden = true

            // 小停顿，强化“先/后”的感知
            let delay = self.retreatAheadDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // B 段：开始让内容回位（还原 inset），不做任何 offset 补偿
                UIView.animate(withDuration: self.restoreInsetDuration,
                               delay: 0,
                               options: [.allowUserInteraction, .beginFromCurrentState]) {
                    sv.contentInset = targetInset
                } completion: { _ in
                    // 复原指示视图，准备下次使用
                    self.view.isHidden = false
                    self.view.transform = .identity
                    self.view.alpha = 1
                    self.layout(in: sv)

                    sv.isScrollEnabled = oldEnabled
                    self.isEndingAnimation = false
                }
            }
        }
    }

    func noticeNoMoreData(on sv: UIScrollView) {
        guard position == .footer else { return }
        state = .noMore
    }

    private func resetInset(from current: UIEdgeInsets) -> UIEdgeInsets {
        var inset = current
        switch position {
        case .header: inset.top    -= view.heightOrWidth
        case .footer: inset.bottom -= view.heightOrWidth
        case .left:   inset.left   -= view.heightOrWidth
        case .right:  inset.right  -= view.heightOrWidth
        }
        return inset
    }
}
