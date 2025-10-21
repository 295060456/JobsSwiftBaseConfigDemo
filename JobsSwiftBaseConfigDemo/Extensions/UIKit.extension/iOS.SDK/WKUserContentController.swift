//
//  WKUserContentController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/20/25.
//

import WebKit

@MainActor
public extension WKUserContentController {
    // MARK: - UserScripts
    @discardableResult
    func byAddUserScript(_ script: WKUserScript) -> Self {
        addUserScript(script); return self
    }

    @discardableResult
    func byAddUserScripts(_ scripts: [WKUserScript]) -> Self {
        scripts.forEach(addUserScript(_:)); return self
    }
    /// 便捷：直接用源码拼一个 WKUserScript（支持 iOS 14 的 contentWorld）
    /// 注意：不要在默认参数里用 .page（MainActor 隔离），用可选在方法体里回退。
    @discardableResult
    func byAddUserScript(
        source: String,
        injectionTime: WKUserScriptInjectionTime = .atDocumentEnd,
        forMainFrameOnly: Bool = false,
        in world: WKContentWorld? = nil
    ) -> Self {
        if #available(iOS 14.0, *) {
            let w = world ?? .page
            let s = WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly, in: w)
            addUserScript(s)
        } else {
            let s = WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
            addUserScript(s)
        }
        return self
    }

    @discardableResult
    func byRemoveAllUserScripts() -> Self {
        removeAllUserScripts(); return self
    }
    // MARK: - Message Handlers (no-reply)
    /// 安全设置：先移除同名再添加（避免重复添加崩溃）
    @discardableResult
    func bySetHandler(
        _ handler: (any WKScriptMessageHandler)?,
        name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        if #available(iOS 14.0, *) {
            let w = world ?? .page
            removeScriptMessageHandler(forName: name, contentWorld: w)
            if let handler { add(handler, contentWorld: w, name: name) }
        } else {
            removeScriptMessageHandler(forName: name)
            if let handler { add(handler, name: name) }
        }
        return self
    }
    /// 直接添加（不做“先移除”）
    @discardableResult
    func byAddHandler(
        _ handler: any WKScriptMessageHandler,
        name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        if #available(iOS 14.0, *) {
            add(handler, contentWorld: (world ?? .page), name: name)
        } else {
            add(handler, name: name)
        }
        return self
    }

    @discardableResult
    func byRemoveHandler(
        named name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        if #available(iOS 14.0, *) {
            removeScriptMessageHandler(forName: name, contentWorld: (world ?? .page))
        } else {
            removeScriptMessageHandler(forName: name)
        }
        return self
    }
    // MARK: - Message Handlers (with-reply)
    @available(iOS 14.0, *)
    @discardableResult
    func bySetHandlerWithReply(
        _ handler: (any WKScriptMessageHandlerWithReply)?,
        name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        let w = world ?? .page
        removeScriptMessageHandler(forName: name, contentWorld: w)
        if let h = handler { addScriptMessageHandler(h, contentWorld: w, name: name) }
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func byAddHandlerWithReply(
        _ handler: any WKScriptMessageHandlerWithReply,
        name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        addScriptMessageHandler(handler, contentWorld: (world ?? .page), name: name); return self
    }
    // MARK: - Bulk remove
    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveAllHandlers(from world: WKContentWorld) -> Self {
        removeAllScriptMessageHandlers(from: world); return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveAllHandlers() -> Self {
        removeAllScriptMessageHandlers(); return self
    }
    // MARK: - Content Rule Lists
    @available(iOS 11.0, *)
    @discardableResult
    func byAddContentRuleList(_ list: WKContentRuleList) -> Self {
        add(list); return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func byRemoveContentRuleList(_ list: WKContentRuleList) -> Self {
        remove(list); return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func byRemoveAllContentRuleLists() -> Self {
        removeAllContentRuleLists(); return self
    }
}
