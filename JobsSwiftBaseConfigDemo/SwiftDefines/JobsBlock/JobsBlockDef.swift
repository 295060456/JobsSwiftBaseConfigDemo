//
//  JobsBlockDef.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/18.
//
import UIKit
import WebKit
//// MARK: - 基础通用参数类型定义（1~10参数）
//public typealias Jobs2Arguments = (_ data: Any?, _ data2: Any?) -> Void
//public typealias Jobs3Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?) -> Void
//public typealias Jobs4Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?) -> Void
//public typealias Jobs5Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?, _ data5: Any?) -> Void
//public typealias Jobs6Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?, _ data5: Any?, _ data6: Any?) -> Void
//public typealias Jobs7Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?, _ data5: Any?, _ data6: Any?, _ data7: Any?) -> Void
//public typealias Jobs8Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?, _ data5: Any?, _ data6: Any?, _ data7: Any?, _ data8: Any?) -> Void
//public typealias Jobs9Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?, _ data5: Any?, _ data6: Any?, _ data7: Any?, _ data8: Any?, _ data9: Any?) -> Void
//public typealias Jobs10Arguments = (_ data: Any?, _ data2: Any?, _ data3: Any?, _ data4: Any?, _ data5: Any?, _ data6: Any?, _ data7: Any?, _ data8: Any?, _ data9: Any?, _ data10: Any?) -> Void
//// MARK: - 业务逻辑相关参数别名
//public typealias JobsTitleFontArguments = (_ title: String, _ font: UIFont?) -> Void
//public typealias JobsTitleFontTitleColorArguments = (_ title: String, _ font: UIFont?, _ titleColor: UIColor?) -> Void
//public typealias JobsTitleFontTitleColorImageImagePlacementXArguments = (_ title: String, _ font: UIFont?, _ titleColor: UIColor?, _ image: UIImage, _ imagePlacement: NSDirectionalRectEdge, _ x: CGFloat) -> Void
//public typealias JobsTitleFontTitleColorImageXArguments = (_ title: String, _ font: UIFont?, _ titleColor: UIColor?, _ image: UIImage, _ x: CGFloat) -> Void
//public typealias JobsTitleFontTitleColorImageArguments = (_ title: String, _ font: UIFont?, _ titleColor: UIColor?, _ image: UIImage) -> Void
//public typealias JobsTitleFontTitleColorImageBackgroundImageImagePlacementArguments = (_ title: String, _ font: UIFont?, _ titleColor: UIColor?, _ image: UIImage, _ backgroundImage: UIImage, _ imagePlacement: NSDirectionalRectEdge) -> Void
//public typealias JobsTitleFontTitleColorImageDirectionalRectEdgeXArguments = (_ title: String, _ font: UIFont?, _ titleColor: UIColor?, _ image: UIImage, _ directionalRectEdge: NSDirectionalRectEdge, _ x: CGFloat) -> Void
//public typealias JobsWKNavigationDelegateArguments = (_ policy: WKNavigationActionPolicy, _ preferences: WKWebpagePreferences?) -> Void
//public typealias JobsNavBarConfigTitleActionArguments = (_ string: String?, _ backActionBlock: ((Any?) -> Any?)?) -> Void
//public typealias JobsNavBarConfigTitlesActionArguments = (_ title: String?, _ backTitle: String?, _ backActionBlock: ((Any?) -> Any?)?) -> Void
//public typealias JobsNavBarConfigBackCloseArguments = (_ backBtnModel: UIButtonModel?, _ closeBtnModel: UIButtonModel?) -> Void
//public typealias JobsViewArrayRowsColumnsBlockArguments = (_ views: [UIView]?, _ rows: Int, _ columns: Int) -> Void
//public typealias JobsKeyValueBlockArguments = (_ key: NSCopying, _ value: Any) -> Void
//public typealias JobsJSCompletionHandlerBlockArguments = (_ result: Any?, _ error: Error?) -> Void
//public typealias JobsUITableViewHeaderFooterViewBlockArguments = (_ cls: AnyClass, _ salt: String?) -> Void
//public typealias JobsUITableViewCellBlockArguments = (_ cls: AnyClass, _ salt: String?, _ indexPath: IndexPath) -> Void
//public typealias JobsNSStringBlock1Arguments = (_ arr: [Any]?, _ index: Int) -> Void
//public typealias JobsNSStringBlock2Arguments = (_ data: TimeInterval, _ dateFormatter: DateFormatter?) -> Void
//public typealias JobsNSStringBlock3Arguments = (_ fontString: String?, _ tailString: String?) -> Void
//public typealias JobsUIColorBlockArguments = (_ hexValue: UInt32, _ alpha: CGFloat) -> UIColor
//public typealias JobsReturnIDByCenterBlockArguments = (_ x: CGFloat, _ y: CGFloat) -> Any?
//public typealias JobsReturnButtonModelByStringAndImagesBlockArguments = (_ title: String?, _ image: UIImage?, _ highlightImage: UIImage?) -> UIButtonModel?
//public typealias JobsReturnButtonByImagePlacementAndPaddingBlockArguments = (_ placement: NSDirectionalRectEdge, _ padding: CGFloat) -> UIButton
//public typealias JobsReturnButtonByColorFloatBlockArguments = (_ color: UIColor?, _ borderWidth: Float) -> UIButton
//public typealias JobsReturnButtonByAttributedStringsBlockArguments = (_ title: NSAttributedString, _ subTitle: NSAttributedString) -> UIButton
//public typealias JobsReturnMutableDicByKeyValueBlockArguments = (_ key: NSCopying, _ value: Any) -> [AnyHashable: Any]
//public typealias JobsReturnCGRectByCGFloatAndUIViewBlockArguments = (_ data: CGFloat, _ superView: UIView) -> CGRect
//public typealias JobsByClassAndSaltBlockArguments = (_ cls: AnyClass, _ salt: String?) -> Void
//public typealias JobsReturnIDByComponentTypeAndUIViewBlockArguments = (_ type: ComponentType, _ view: UIView?) -> Any?
//public typealias JobsViewModelAndBoolBlockArguments = (_ model: UIViewModel, _ data: Bool) -> Void
//public typealias JobsReturnViewNavigatorByViewAndAnimatedBlockArguments = (_ view: UIView?, _ animated: Bool) -> Any?
//public typealias JobsByButtonModelAndBoolBlockArguments = (_ model: UIButtonModel, _ data: Bool) -> Void
//public typealias JobsReturnGKPhotoBrowserByPhotosArrayAndCurrentIndexBlockArguments = (_ photosArray: [Any]?, _ currentIndex: Int) -> GKPhotoBrowser?
//public typealias JobsDelegateBlocksArguments = (_ string: String?, _ block: (() -> Void)?) -> Void
//public typealias JobsReturnViewByViewAndMasonryConstraintsBlockArguments = (_ subview: UIView, _ block: ((ConstraintMaker) -> Void)?) -> UIView
//public typealias JobsReturnGoodsClassModelByInt2BlockArguments = (_ data1: UInt, _ data2: Int) -> GoodsClassModel
//public typealias JobsReturnGoodsClassModelByIntStringBlockArguments = (_ data1: Int, _ data2: String?) -> GoodsClassModel
//public typealias JobsByBannerAdsModelAndCellBlockArguments = (_ model: FMBannerAdsModel?, _ cell: JobsBtnStyleCVCell) -> Void
//public typealias JobsByVCAndDataBlockArguments = (_ viewController: UIViewController?, _ data: Any?) -> Void
//public typealias JobsByView2BlockArguments = (_ superview: UIView?, _ view: UIView?) -> Void
//public typealias JobsByViewAndDataBlockArguments = (_ view: UIView?, _ data: Any?) -> Void
