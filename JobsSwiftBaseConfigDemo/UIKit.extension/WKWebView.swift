//
//  WKWebView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import WebKit

extension WKWebView {
    @discardableResult
    func loadURL(_ urlString: String) -> Self {
        guard let url = URL(string: urlString) else { return self }
        let request = URLRequest(url: url)
        self.load(request)
        return self
    }

    @discardableResult
    func loadRequest(_ request: URLRequest) -> Self {
        self.load(request)
        return self
    }

    @discardableResult
    func byNavigationDelegate(_ delegate: WKNavigationDelegate?) -> Self {
        self.navigationDelegate = delegate
        return self
    }

    @discardableResult
    func byUIDelegate(_ delegate: WKUIDelegate?) -> Self {
        self.uiDelegate = delegate
        return self
    }

    @discardableResult
    func byAllowsBackForwardNavigationGestures(_ enabled: Bool) -> Self {
        self.allowsBackForwardNavigationGestures = enabled
        return self
    }
}
