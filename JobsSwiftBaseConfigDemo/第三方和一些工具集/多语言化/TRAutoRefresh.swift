//
//  TRAutoRefresh.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//
//  只暴露 .tr；无须重建 Root；切语言后 .tr 文本自动刷新。
//  运行时拦截 UILabel.setText / UIButton.setTitle / UITextField.setPlaceholder
//  将 key 隐藏在零宽标记中，setter 解析后存起来，显示不含标记的纯文本。

import UIKit
import ObjectiveC

// ========== 1) 唯一公开 API：.tr ==========
public extension String {
    var tr: String {
        let b = LanguageManager.shared.localizedBundle
        let s = NSLocalizedString(self, tableName: nil, bundle: b, value: self, comment: "")
        return TRAutoRefresh.Marker.pack(translated: s, key: self, table: nil)
    }
    func tr(args: [CVarArg]) -> String {
        let b = LanguageManager.shared.localizedBundle
        let fmt = NSLocalizedString(self, tableName: nil, bundle: b, value: self, comment: "")
        let localeID = LanguageManager.shared.currentLanguageCode ?? "en"
        let s = String(format: fmt, locale: Locale(identifier: localeID), arguments: args)
        return TRAutoRefresh.Marker.pack(translated: s, key: self, table: nil)
    }
}

// ========== 2) 自动刷新核心 ==========
public enum TRAutoRefresh {
    // App 启动时调用一次
    public static func install() {
        guard !installed else { return }
        installed = true
        swizzleLabel()
        swizzleTextField()
        swizzleButton()
        NotificationCenter.default.addObserver(forName: .TRLanguageDidChange, object: nil, queue: .main) { _ in
            refreshAll()
        }
    }

    private static var installed = false

    // 用零宽分隔符做不可见标记
    enum Marker {
        static let prefix = "\u{2063}\u{2063}tr:"
        static let suffix = ":\u{2063}"
        static func pack(translated: String, key: String, table: String?) -> String {
            let payload = "\(table ?? "_")|\(key)"
            let token = Data(payload.utf8).base64EncodedString()
            return translated + prefix + token + suffix
        }
        static func unpack(_ s: String?) -> (clean: String?, key: String?, table: String?) {
            guard let s else { return (nil, nil, nil) }
            guard let r1 = s.range(of: prefix),
                  let r2 = s.range(of: suffix, range: r1.upperBound..<s.endIndex) else {
                return (s, nil, nil)
            }
            let token = String(s[r1.upperBound..<r2.lowerBound])
            let clean = String(s[..<r1.lowerBound]) + String(s[r2.upperBound...])
            if let data = Data(base64Encoded: token),
               let payload = String(data: data, encoding: .utf8) {
                let parts = payload.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
                let table = parts.first.map(String.init)
                let key = (parts.count > 1) ? String(parts[1]) : nil
                return (clean, key, table == "_" ? nil : table)
            }
            return (clean, nil, nil)
        }
    }

    // --- 这些要被控件扩展访问：改成 fileprivate ---
    fileprivate static let labels = NSHashTable<UILabel>.weakObjects()
    fileprivate static let textFields = NSHashTable<UITextField>.weakObjects()
    fileprivate static let buttons = NSHashTable<UIButton>.weakObjects()

    fileprivate static var kLabelKey: UInt8 = 0
    fileprivate static var kLabelTable: UInt8 = 0
    fileprivate static var kTFKey: UInt8 = 0
    fileprivate static var kTFTable: UInt8 = 0
    fileprivate static var kBtnMap: UInt8 = 0 // [UInt: (String, String?)]

    // 刷新所有已绑定控件
    fileprivate static func refreshAll() {
        let bundle = LanguageManager.shared.localizedBundle

        for label in labels.allObjects {
            guard let key = objc_getAssociatedObject(label, &kLabelKey) as? String else { continue }
            let table = objc_getAssociatedObject(label, &kLabelTable) as? String
            let text = NSLocalizedString(key, tableName: table, bundle: bundle, value: key, comment: "")
            label.text = text
        }

        for tf in textFields.allObjects {
            guard let key = objc_getAssociatedObject(tf, &kTFKey) as? String else { continue }
            let table = objc_getAssociatedObject(tf, &kTFTable) as? String
            let text = NSLocalizedString(key, tableName: table, bundle: bundle, value: key, comment: "")
            tf.placeholder = text
        }

        for btn in buttons.allObjects {
            guard let map = objc_getAssociatedObject(btn, &kBtnMap) as? [UInt: (String, String?)] else { continue }
            for (raw, pair) in map {
                let st = UIControl.State(rawValue: raw)
                let text = NSLocalizedString(pair.0, tableName: pair.1, bundle: bundle, value: pair.0, comment: "")
                btn.setTitle(text, for: st)
            }
        }
    }

    // MARK: Swizzles（仍可 private）
    private static func swizzleLabel() {
        exchange(UILabel.self, #selector(setter: UILabel.text), #selector(UILabel._tr_setText(_:)))
    }
    private static func swizzleTextField() {
        exchange(UITextField.self, #selector(setter: UITextField.placeholder), #selector(UITextField._tr_setPlaceholder(_:)))
    }
    private static func swizzleButton() {
        exchange(UIButton.self, #selector(UIButton.setTitle(_:for:)), #selector(UIButton._tr_setTitle(_:for:)))
    }
    private static func exchange(_ cls: AnyClass, _ ori: Selector, _ new: Selector) {
        guard let m1 = class_getInstanceMethod(cls, ori),
              let m2 = class_getInstanceMethod(cls, new) else { return }
        method_exchangeImplementations(m1, m2)
    }
}

// ========== 3) 被交换的方法实现 ==========
private extension UILabel {
    @objc func _tr_setText(_ text: String?) {
        let (clean, key, table) = TRAutoRefresh.Marker.unpack(text)
        if let key {
            objc_setAssociatedObject(self, &TRAutoRefresh.kLabelKey, key, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(self, &TRAutoRefresh.kLabelTable, table, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            TRAutoRefresh.labels.add(self)
        } else {
            objc_setAssociatedObject(self, &TRAutoRefresh.kLabelKey, nil, .OBJC_ASSOCIATION_ASSIGN)
            objc_setAssociatedObject(self, &TRAutoRefresh.kLabelTable, nil, .OBJC_ASSOCIATION_ASSIGN)
        }
        _tr_setText(clean)
    }
}

private extension UITextField {
    @objc func _tr_setPlaceholder(_ text: String?) {
        let (clean, key, table) = TRAutoRefresh.Marker.unpack(text)
        if let key {
            objc_setAssociatedObject(self, &TRAutoRefresh.kTFKey, key, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(self, &TRAutoRefresh.kTFTable, table, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            TRAutoRefresh.textFields.add(self)
        } else {
            objc_setAssociatedObject(self, &TRAutoRefresh.kTFKey, nil, .OBJC_ASSOCIATION_ASSIGN)
            objc_setAssociatedObject(self, &TRAutoRefresh.kTFTable, nil, .OBJC_ASSOCIATION_ASSIGN)
        }
        _tr_setPlaceholder(clean)
    }
}

private extension UIButton {
    @objc func _tr_setTitle(_ title: String?, for state: UIControl.State) {
        let (clean, key, table) = TRAutoRefresh.Marker.unpack(title)
        if let key {
            var map = (objc_getAssociatedObject(self, &TRAutoRefresh.kBtnMap) as? [UInt: (String, String?)]) ?? [:]
            map[state.rawValue] = (key, table)
            objc_setAssociatedObject(self, &TRAutoRefresh.kBtnMap, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            TRAutoRefresh.buttons.add(self)
        } else {
            if var map = objc_getAssociatedObject(self, &TRAutoRefresh.kBtnMap) as? [UInt: (String, String?)] {
                map.removeValue(forKey: state.rawValue)
                objc_setAssociatedObject(self, &TRAutoRefresh.kBtnMap, map, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        _tr_setTitle(clean, for: state)
    }
}

// 兜底：如果你没定义过，就给 Notification.Name 补一个
public extension Notification.Name {
    static let TRLanguageDidChange = Notification.Name("TRLanguageDidChange")
}
