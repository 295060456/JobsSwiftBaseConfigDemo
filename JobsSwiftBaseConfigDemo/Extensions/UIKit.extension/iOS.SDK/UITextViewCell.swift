//
//  UITextViewCell.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/23/25.
//

import UIKit
// MARK: - UITableViewCell · 基础状态 & 选择/高亮/编辑
public extension UITableViewCell {
    /// selectionStyle
    @discardableResult
    func bySelectionStyle(_ style: UITableViewCell.SelectionStyle) -> Self {
        self.selectionStyle = style
        return self
    }
    /// isSelected（支持动画）
    @discardableResult
    func bySelected(_ selected: Bool, animated: Bool = false) -> Self {
        self.setSelected(selected, animated: animated)
        return self
    }
    /// isHighlighted（支持动画）
    @discardableResult
    func byHighlighted(_ highlighted: Bool, animated: Bool = false) -> Self {
        self.setHighlighted(highlighted, animated: animated)
        return self
    }
    /// 编辑状态
    @discardableResult
    func byEditing(_ editing: Bool, animated: Bool = true) -> Self {
        self.setEditing(editing, animated: animated)
        return self
    }
    /// accessoryType / accessoryView
    @discardableResult
    func byAccessoryType(_ type: UITableViewCell.AccessoryType) -> Self {
        self.accessoryType = type
        return self
    }

    @discardableResult
    func byAccessoryView(_ view: UIView?) -> Self {
        self.accessoryView = view
        return self
    }
    /// 编辑态 accessory
    @discardableResult
    func byEditingAccessoryType(_ type: UITableViewCell.AccessoryType) -> Self {
        self.editingAccessoryType = type
        return self
    }

    @discardableResult
    func byEditingAccessoryView(_ view: UIView?) -> Self {
        self.editingAccessoryView = view
        return self
    }
    /// 缩进 & 拖拽/重排
    @discardableResult
    func byIndentationLevel(_ level: Int) -> Self {
        self.indentationLevel = level
        return self
    }

    @discardableResult
    func byIndentationWidth(_ width: CGFloat) -> Self {
        self.indentationWidth = width
        return self
    }

    @discardableResult
    func byShowsReorderControl(_ show: Bool) -> Self {
        self.showsReorderControl = show
        return self
    }

    @discardableResult
    func byShouldIndentWhileEditing(_ indent: Bool) -> Self {
        self.shouldIndentWhileEditing = indent
        return self
    }
    /// 分割线 inset
    @discardableResult
    func bySeparatorInset(_ inset: UIEdgeInsets) -> Self {
        self.separatorInset = inset
        return self
    }
    /// 背景视图
    @discardableResult
    func byBackgroundView(_ view: UIView?) -> Self {
        self.backgroundView = view
        return self
    }

    @discardableResult
    func bySelectedBackgroundView(_ view: UIView?) -> Self {
        self.selectedBackgroundView = view
        return self
    }

    @discardableResult
    func byMultipleSelectionBackgroundView(_ view: UIView?) -> Self {
        self.multipleSelectionBackgroundView = view
        return self
    }
    /// 焦点 & 拖拽
    @available(iOS 9.0, *)
    @discardableResult
    func byFocusStyle(_ style: UITableViewCell.FocusStyle) -> Self {
        self.focusStyle = style
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func byUserInteractionEnabledWhileDragging(_ enabled: Bool) -> Self {
        self.userInteractionEnabledWhileDragging = enabled
        return self
    }
}
// MARK: - iOS 14+ List Content（文本/副标题/图片 的统一配置）
public extension UITableViewCell {
    /// 直接覆盖 contentConfiguration（默认会禁用自动更新，避免被系统覆盖）
    @available(iOS 14.0, *)
    @discardableResult
    func byContentConfiguration(_ build: (inout UIListContentConfiguration) -> Void,
                                automaticallyUpdates: Bool = false) -> Self {
        var cfg = self.defaultContentConfiguration()
        build(&cfg)
        self.automaticallyUpdatesContentConfiguration = automaticallyUpdates
        self.contentConfiguration = cfg
        return self
    }
    /// 文本
    @discardableResult
    func byText(_ text: String?) -> Self {
        if #available(iOS 14.0, *) {
            return byContentConfiguration { $0.text = text }
        } else {
            self.textLabel?.text = text
            return self
        }
    }
    /// 富文本标题
    @discardableResult
    func byAttributedText(_ text: NSAttributedString?) -> Self {
        if #available(iOS 14.0, *) {
            return byContentConfiguration { $0.attributedText = text }
        } else {
            self.textLabel?.attributedText = text
            return self
        }
    }
    /// 副标题
    @discardableResult
    func bySecondaryText(_ text: String?) -> Self {
        if #available(iOS 14.0, *) {
            return byContentConfiguration { $0.secondaryText = text }
        } else {
            byDetailText(text) // 旧系统需要 .subtitle 风格才显示
            return self
        }
    }

    @discardableResult
    func byDetailText(_ text: String?) -> Self {
        self.detailTextLabel?.text = text
        return self
    }

    @discardableResult
    func byDetailAttributedText(_ text: NSAttributedString?) -> Self {
        self.detailTextLabel?.attributedText = text
        return self
    }
    /// 富文本副标题
    @discardableResult
    func byAttributedSecondaryText(_ text: NSAttributedString?) -> Self {
        if #available(iOS 14.0, *) {
            return byContentConfiguration { $0.secondaryAttributedText = text }
        } else {
            byDetailAttributedText(text)
            return self
        }
    }
    /// 主图
    @discardableResult
    func byImage(_ image: UIImage?) -> Self {
        if #available(iOS 14.0, *) {
            return byContentConfiguration { $0.image = image }
        } else {
            self.imageView?.image = image
            return self
        }
    }
    /// 文本行数/对齐/间距等（iOS14+）
    @available(iOS 14.0, *)
    @discardableResult
    func byTextConfig(_ build: (inout UIListContentConfiguration) -> Void) -> Self {
        return byContentConfiguration(build)
    }
}
// MARK: - iOS 14+ 背景配置（分离语义：选中/高亮自动更新）
public extension UITableViewCell {
    @available(iOS 14.0, *)
    @discardableResult
    func byBackgroundConfiguration(_ build: (inout UIBackgroundConfiguration) -> Void,
                                   automaticallyUpdates: Bool = false) -> Self {
        var bg = UIBackgroundConfiguration.listPlainCell()
        build(&bg)
        self.automaticallyUpdatesBackgroundConfiguration = automaticallyUpdates
        self.backgroundConfiguration = bg
        return self
    }
    /// 快捷：选中态背景色
    @available(iOS 14.0, *)
    @discardableResult
    func bySelectedBackgroundColor(_ color: UIColor?) -> Self {
        return byBackgroundConfiguration { bg in
            bg.backgroundColor = .clear
            if let color {
                var selected = UIBackgroundConfiguration.listPlainCell()
                selected.backgroundColor = color
                self.setHighlighted(self.isHighlighted, animated: false)
                self.setSelected(self.isSelected, animated: false)
                self.selectedBackgroundView = {
                    let v = UIView()
                    v.backgroundColor = color
                    return v
                }()
            } else {
                self.selectedBackgroundView = nil
            }
        }
    }
}
// MARK: - 工厂：按样式创建（便于老系统 detailTextLabel 显示）
public extension UITableViewCell {
    /// 便捷工厂：指定 CellStyle 与复用 ID
    static func make(style: UITableViewCell.CellStyle = .default,
                     reuseIdentifier: String? = nil) -> UITableViewCell {
        UITableViewCell(style: style, reuseIdentifier: reuseIdentifier ?? String(describing: self))
    }
}
