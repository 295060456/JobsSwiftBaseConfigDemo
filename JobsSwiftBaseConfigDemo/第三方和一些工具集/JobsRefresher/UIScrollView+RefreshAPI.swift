//
//  UIScrollView+RefreshAPI.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/31/25.
//

import UIKit

@MainActor
public struct JobsSideFactory {
    public static func left() -> JobsDefaultIndicatorView { JobsDefaultIndicatorView() }
    public static func right() -> JobsDefaultIndicatorView { JobsDefaultIndicatorView() }
}

@MainActor
public extension UIScrollView {
    // MARK: Header
    func configRefreshHeader(component: (UIView & JobsAnimatable)? = nil,
                             container: AnyObject? = nil,
                             trigger: CGFloat = 60,
                             action: @escaping () -> Void) -> Self{
        let c = component ?? JobsDefaultIndicatorView()
        let slot = JobsSlot(position: .header, view: c, trigger: trigger, container: container, action: action)
        mrk_proxy.header = slot
        slot.attach(to: self)
        return self
    }

    func switchRefreshHeader(to state: JobsSwitch) {
        guard let slot = mrk_proxy.header, let sv = mrk_proxy.scrollView else { return }
        switch state {
        case .refreshing:
            slot.beginRefreshing(on: sv)
        case .normal:
            slot.endRefreshing(on: sv)
        case .removed:
            slot.detach()
            mrk_proxy.header = nil
        case .noMoreData:
            // header 不支持 noMoreData，忽略
            break
        }
    }

    // MARK: Footer
    func configRefreshFooter(component: (UIView & JobsAnimatable)? = nil,
                             container: AnyObject? = nil,
                             trigger: CGFloat = 60,
                             action: @escaping () -> Void) -> Self{
        let c = component ?? JobsDefaultIndicatorView()
        let slot = JobsSlot(position: .footer, view: c, trigger: trigger, container: container, action: action)
        mrk_proxy.footer = slot
        slot.attach(to: self)
        return self
    }

    func switchRefreshFooter(to state: JobsSwitch) {
        guard let slot = mrk_proxy.footer, let sv = mrk_proxy.scrollView else { return }
        switch state {
        case .refreshing:
            slot.beginRefreshing(on: sv, isFooter: true)
        case .normal:
            slot.endRefreshing(on: sv)
        case .removed:
            slot.detach()
            mrk_proxy.footer = nil
        case .noMoreData:
            slot.noticeNoMoreData(on: sv)
        }
    }

    // MARK: Side (Left/Right)
    func configSideRefresh(with component: (UIView & JobsAnimatable),
                           container: AnyObject? = nil,
                           at position: JobsPosition,
                           trigger: CGFloat = 60,
                           action: @escaping () -> Void) -> Self {
        precondition(position == .left || position == .right, "SideRefresh 仅支持 .left / .right")
        let slot = JobsSlot(position: position, view: component, trigger: trigger, container: container, action: action)
        if position == .left {
            mrk_proxy.left = slot
        } else {
            mrk_proxy.right = slot
        }
        slot.attach(to: self)
        return self
    }

    func switchSideRefresh(_ position: JobsPosition, to state: JobsSwitch) {
        guard (position == .left || position == .right),
              let sv = mrk_proxy.scrollView else { return }
        let slot = (position == .left) ? mrk_proxy.left : mrk_proxy.right
        guard let s = slot else { return }
        switch state {
        case .refreshing: s.beginRefreshing(on: sv)
        case .normal:     s.endRefreshing(on: sv)
        case .removed:
            s.detach()
            if position == .left { mrk_proxy.left = nil } else { mrk_proxy.right = nil }
        case .noMoreData:
            // side 不支持 noMoreData，忽略
            break
        }
    }
}
