//
//  JobsBlock.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//
import UIKit

// 占位声明（必须至少空实现）
public class JobsTextView {}
public class ZFAVPlayerManager {}
public class ZFDouYinControlView {}
public class ZFCustomControlView {}
public class CustomZFPlayerControlView {}
public class JobsRightBtnsView {}
public class JobsBitsMonitorSuspendLab {}
public class BaseView {}
public class JobsTabBarVC {}
public class JobsCustomTabBarVC {}
public class JobsCustomTabBarConfig {}
public class MGSwipeButtonModel {}
public class JobsRichTextConfig {}
public class SDWebImageModel {}
public class URLManagerModel {}
public class UIViewModel {}
public class BaseTableView {}
public class JobsSearchBar {}
public class JobsAppDoorModel {}
public class UNNotificationRequestModel {}
public class JobsAlertModel {}
public class UITextModel {}
public class JobsMagicTextField {}
public class RACModel {}
public class JobsGestureModel {}
public class JobsIMChatInfoModel {}
public class NSTimerManager {}
public class ButtonTimerConfigModel {}
public class JobsAppDoorInputViewBaseStyleModel {}
public class JobsAppDoorInputViewBaseStyle {}
public class JobsCorModel {}
public class JobsMenuView {}
public class JobsViewNavigator {}
public class BaseNavigationBar {}
public class MasonryModel {}
public class LZTabBar {}
public class LZTabBarItem {}
public class UITextFieldModel {}
public class JobsFileModel {}
public class BaseUploadFileRequest {}
public class UIButtonModel {}
public class JobsImageModel {}
public class PointLabBaseView {}
public class JobsTabBar {}
public class FileFolderHandleModel {}
public class JobsNavBarConfig {}
public class JobsNavBar {}
public class JobsTextField {}
public class CJTextField {}
public class ZYTextField {}
public class JobsStepView {}
public class BaseLabel {}
public class BaseTextView {}
public class JobsToggleBaseView {}
public class JobsHotLabelBySingleLine {}
public class FileNameModel {}
public class JobsUserModel {}
public class UserDefaultModel {}
public class JobsTabBarItemConfig {}
public class GKCustomNavigationBar {}
public class HXPhotoPickerModel {}
public class JobsParagraphStyleModel {}
public class JobsLocationModel {}
public class GTCaptcha4Model {}
public class FMDoorModel {}
public class FMNameModel {}
public class FMWithDrawModel {}
public class JobsTimeModel {}
public class VideoModel_Core {}
public class NotificationModel {}
public class NSNotificationKeyboardModel {}
public class JobsExcelConfigureViewModel {}
public class PopListBaseView {}
public class JobsExcelView {}
public class JobsExcelContentView {}
public class JobsExcelTopHeadView {}
public class JobsExcelLeftListView {}
public class JobsUserHeaderDataViewTBVCell {}
public class JobsKeyValueModel {}
public class SPAlertControllerConfig {}
public class JobsToggleNavView {}
public class JobsCustomTabBar {}
public class JobsResponseModel {}
public class IpifyModel {}
public class IPApiModel {}
public class IpinfoModel {}
public class RequestTool {}
public class BaseModel {}
public class BRStringPickerViewModel {}
public class JobsDecorationModel {}
public class GKPhotoBrowser {}
public class GKPhoto {}
public class SZTextView {}
public class XZMRefreshNormalHeader {}
public class YTKNetworkConfig {}
public class YTKRequest {}
public class YTKChainRequest {}
public class YTKBatchRequest {}
public class YTKBaseRequest {}
public class JhtBannerScrollView {}
public class JhtBannerCardView {}
public class GDFadeView {}
public class CFGradientLabel {}
public class WGradientProgressModel {}
public class FSCalendar {}
public class HXPhotoView {}
public class HXPhotoManager {}
public class HTMLDocument {}
public class HXPhotoConfiguration {}
public class BRPickerStyle {}
public class BRDatePickerView {}
public class BRAddressPickerView {}
public class BRStringPickerView {}
public class AFSecurityPolicy {}
public class IQKeyboardManager {}
public class JobsTransitionAnimator {}
public class JobsNavigationTransitionMgr {}
public class WMZBannerView {}
public class WMZBannerParam {}
public class MJRefreshConfigModel {}
public class MJRefreshNormalHeader {}
public class MJRefreshStateHeader {}
public class MJRefreshHeader {}
public class MJRefreshGifHeader {}
public class MJRefreshFooter {}
public class MJRefreshAutoGifFooter {}
public class MJRefreshBackNormalFooter {}
public class MJRefreshAutoNormalFooter {}
public class MJRefreshAutoStateFooter {}
public class MJRefreshAutoFooter {}
public class MJRefreshBackGifFooter {}
public class MJRefreshBackStateFooter {}
public class MJRefreshBackFooter {}
public class LOTAnimationMJRefreshHeader {}
public class SRWebSocket {}
public class RACDisposable {}
public class RACSignal {}
public class JXCategoryTitleView {}
public class JXCategoryImageView {}
public class JXCategoryDotView {}
public class JXCategoryNumberView {}
public class JXCategoryIndicatorBackgroundView {}
public class JXCategoryIndicatorLineView {}
public class JXCategoryListContainerView {}
public class JXCategoryIndicatorView {}
public class JXCategoryBaseView {}
public class MGSwipeTableCell {}
public class MASConstraintMaker {}
public class ZFIJKPlayerManager {}
public class LZTabBarConfig {}
public class ConstraintMaker {}
public class GoodsClassModel {}
public class FMBannerAdsModel {}
public class JobsBtnStyleCVCell {}

protocol JXCategoryIndicatorProtocol {}
protocol JXCategoryViewDelegate {}
protocol JXCategoryViewListContainer {}
protocol UIViewModelOthersProtocol {}
protocol MGSwipeTableCellDelegate {}

enum JXCategoryDotRelativePosition {}

//基础类型别名转换（示例）
typealias JobsReturnComponentTypeByVoidBlock = () -> ComponentType
typealias JobsReturnDeviceOrientationByVoidBlock = () -> DeviceOrientation
typealias JobsReturnAppLanguageByVoidBlock = () -> AppLanguage
typealias JobsReturnDeviceOrientationByViewBlock = (_ data: UIView?) -> DeviceOrientation
typealias JobsReturnTimeZoneByTypeBlock = (_ timeZoneType: TimeZoneType) -> TimeZone?
typealias JobsReturnIDByAppLanguageBlock = (_ data: AppLanguage) -> Any?
typealias JobsReturnIDByComponentTypeAndUIViewBlock = (_ componentType: ComponentType, _ view: UIView?) -> Any?
typealias JobsByJobsTextViewBlock = (_ textView: JobsTextView?) -> Void
//各类自定义 Block 类型（保留类型、命名和参数结构）
typealias JobsByZFDouYinControlViewBlock = (_ controlView: ZFDouYinControlView?) -> Void
typealias JobsByZFCustomControlViewBlock = (_ controlView: ZFCustomControlView?) -> Void
typealias JobsByCustomZFPlayerControlViewBlock = (_ controlView: CustomZFPlayerControlView?) -> Void
typealias JobsByRightBtnsViewBlock = (_ view: JobsRightBtnsView?) -> Void
typealias JobsByBitsMonitorSuspendLabBlock = (_ label: JobsBitsMonitorSuspendLab?) -> Void
typealias JobsByBaseViewBlock = (_ view: BaseView?) -> Void
typealias JobsByTabBarVCBlock = (_ vc: JobsTabBarVC?) -> Void
typealias JobsByCustomTabBarVCBlock = (_ vc: JobsCustomTabBarVC?) -> Void
typealias JobsByCustomTabBarConfigBlock = (_ config: JobsCustomTabBarConfig?) -> Void
typealias JobsByMGSwipeButtonModelBlock = (_ model: MGSwipeButtonModel?) -> Void
typealias JobsReturnAttributedStringByRichTextConfigArrayBlock = (_ configs: [JobsRichTextConfig]?) -> NSMutableAttributedString?
typealias JobsByRichTextConfigBlock = (_ config: JobsRichTextConfig?) -> Void
typealias JobsBySDWebImageModelBlock = (_ model: SDWebImageModel?) -> Void
typealias JobsByURLManagerModelBlock = (_ model: URLManagerModel?) -> Void
typealias JobsReturnURLManagerModelByStringBlock = (_ data: String?) -> URLManagerModel?
typealias JobsByViewModelAndBOOLBlock = (_ model: UIViewModel, _ data: Bool) -> Void
typealias JobsReturnButtonByViewModelAndBOOLBlock = (_ model: UIViewModel, _ data: Bool) -> UIButton?
typealias JobsReturnViewModelByVoidBlock = () -> UIViewModel?
typealias JobsReturnViewModelByStringBlock = (_ string: String?) -> UIViewModel?
typealias JobsReturnButtonByViewModelBlock = (_ model: UIViewModel?) -> UIButton?
typealias JobsByViewModelBlock = (_ model: UIViewModel?) -> Void
typealias JobsByArrWithViewModelBlock = (_ models: [UIViewModel]?) -> Void
typealias JobsReturnCGSizeByViewModelBlock = (_ model: UIViewModel?) -> CGSize
typealias JobsReturnCGRectByViewModelBlock = (_ model: UIViewModel?) -> CGRect
typealias JobsReturnCGFloatByViewModelBlock = (_ model: UIViewModel?) -> CGFloat
typealias JobsReturnViewModelInArrByArrBlock = (_ arr: [Any]?) -> [UIViewModel]?
typealias JobsByBaseTableViewBlock = (_ tableView: BaseTableView?) -> Void
typealias JobsBySearchBarBlock = (_ searchBar: JobsSearchBar?) -> Void
typealias JobsByAppDoorModelBlock = (_ model: JobsAppDoorModel?) -> Void
typealias JobsReturnBOOLByAppDoorModelBlock = (_ model: JobsAppDoorModel?) -> Bool
typealias JobsByUNNotificationRequestModelBlock = (_ model: UNNotificationRequestModel?) -> Void
typealias JobsReturnUNNotificationRequestByModelBlock = (_ model: UNNotificationRequestModel?) -> UNNotificationRequest?
typealias JobsByAlertModelBlock = (_ model: JobsAlertModel?) -> Void
typealias JobsReturnAlertControllerByAlertModelBlock = (_ model: JobsAlertModel?) -> UIAlertController?
typealias JobsReturnButtonByTextModelBlock = (_ model: UITextModel?) -> UIButton?
typealias JobsReturnViewByTextModelBlock = (_ model: UITextModel?) -> UIView?
typealias JobsByTextModelBlock = (_ model: UITextModel?) -> Void
typealias JobsByMagicTextFieldBlock = (_ textField: JobsMagicTextField?) -> Void
typealias JobsByRACModelBlock = (_ model: RACModel?) -> Void
typealias JobsByGestureModelBlock = (_ model: JobsGestureModel?) -> Void
typealias JobsByIMChatInfoModelBlock = (_ model: JobsIMChatInfoModel?) -> Void
typealias JobsByTimerManagerBlock = (_ manager: NSTimerManager?) -> Void
typealias JobsReturnButtonByTimerConfigModelBlock = (_ model: ButtonTimerConfigModel) -> UIButton?
typealias JobsByAppDoorInputViewBaseStyleModelBlock = (_ model: JobsAppDoorInputViewBaseStyleModel?) -> Void
typealias JobsReturnAppDoorInputViewBaseStyleByClassBlock = (_ cls: AnyClass) -> JobsAppDoorInputViewBaseStyle?
typealias JobsReturnCorModelByVoidBlock = () -> JobsCorModel
typealias JobsReturnCorModelByCorBlock = (_ data: UIColor?) -> JobsCorModel
typealias JobsByCorModelBlock = (_ data: JobsCorModel?) -> Void
typealias JobsByMenuViewBlock = (_ view: JobsMenuView?) -> Void
typealias JobsByViewNavigatorBlock = (_ navigator: JobsViewNavigator?) -> Void
typealias JobsReturnViewNavigatorByViewAndAnimatedBlock = (_ view: UIView?, _ animated: Bool) -> JobsViewNavigator
typealias JobsReturnViewNavigatorByBOOLBlock = (_ data: Bool) -> JobsViewNavigator
typealias JobsByButtonTimerConfigModelBlock = (_ model: ButtonTimerConfigModel?) -> Void
typealias JobsByBaseNavigationBarBlock = (_ navBar: BaseNavigationBar?) -> Void
typealias JobsByMasonryModelBlock = (_ model: MasonryModel?) -> Void
typealias JobsReturnIDByMasonryModelBlock = (_ model: MasonryModel?) -> Any?
typealias JobsReturnArrByMasonryModelBlock = (_ model: MasonryModel?) -> [Any]?

typealias JobsByLZTabBarBlock = (_ tabBar: LZTabBar?) -> Void
typealias JobsByLZTabBarItemBlock = (_ item: LZTabBarItem?) -> Void

typealias JobsByTextFieldModelBlock = (_ model: UITextFieldModel?) -> Void
typealias JobsReturnTextFieldModelByString = (_ data: String?) -> UITextFieldModel?

typealias JobsByFileModelBlock = (_ model: JobsFileModel?) -> Void
typealias JobsReturnRequestByFileModelBlock = (_ model: JobsFileModel?) -> BaseUploadFileRequest?

typealias JobsByButtonModelBlock = (_ model: UIButtonModel?) -> Void
typealias JobsByButtonModelAndBOOLBlock = (_ model: UIButtonModel, _ data: Bool) -> Void
typealias JobsReturnButtonByButtonModelAndBOOLBlock = (_ model: UIButtonModel, _ data: Bool) -> UIButton?
typealias JobsReturnViewByButtonModelBlock = (_ model: UIButtonModel?) -> UIView?
typealias JobsReturnBOOLByButtonModelBlock = (_ model: UIButtonModel?) -> Bool
typealias JobsReturnButtonModelArrByArrBlock = (_ arr: [Any]?) -> [UIButtonModel]?
typealias JobsReturnButtonModelByString = (_ string: String?) -> UIButtonModel?
typealias JobsReturnButtonModelByAttributedString = (_ aString: NSAttributedString?) -> UIButtonModel?
typealias JobsReturnButtonByButtonModelBlock = (_ model: UIButtonModel?) -> UIButton?
typealias JobsReturnViewByButtonModelArrayBlock = (_ models: [UIButtonModel]?) -> UIView?

typealias JobsByImageModelBlock = (_ model: JobsImageModel?) -> Void
typealias JobsByPointLabBaseViewBlock = (_ view: PointLabBaseView?) -> Void
typealias JobsByTabBarBlock = (_ tabBar: JobsTabBar?) -> Void
typealias JobsByFileFolderHandleModelBlock = (_ model: FileFolderHandleModel?) -> Void

typealias JobsByNavBarConfigBlock = (_ config: JobsNavBarConfig?) -> Void
typealias JobsReturnNavBarConfigByStringBlock = (_ string: String?) -> JobsNavBarConfig?
typealias JobsReturnNavBarConfigByStringsBlock = (_ fontString: String?, _ tailString: String?) -> JobsNavBarConfig?
typealias JobsReturnNavBarConfigByAttributedStringBlock = (_ aString: NSAttributedString?) -> JobsNavBarConfig?
typealias JobsReturnNavBarConfigByStringAndActionBlock = (_ string: String?, _ backActionBlock: ((Any?) -> Any?)?) -> JobsNavBarConfig?
typealias JobsReturnNavBarConfigByStringsAndActionBlock = (_ title: String?, _ backTitle: String?, _ backActionBlock: ((Any?) -> Any?)?) -> JobsNavBarConfig?
typealias JobsReturnNavBarConfigByButtonModelBlock = (_ backBtnModel: UIButtonModel?, _ closeBtnModel: UIButtonModel?) -> JobsNavBarConfig?

typealias JobsByNavBarBlock = (_ data: JobsNavBar?) -> Void

typealias JobsByJobsTextFieldBlock = (_ data: JobsTextField?) -> Void
typealias JobsReturnJobsTextFieldByCGFloatBlock = (_ data: CGFloat) -> JobsTextField
typealias JobsReturnJobsTextFieldByBOOLBlock = (_ data: Bool) -> JobsTextField
typealias JobsReturnJobsTextFieldByGestureRecognizerBlock = (_ gesture: UIGestureRecognizer?) -> JobsTextField
typealias JobsReturnJobsTextFieldByCorBlock = (_ cor: UIColor?) -> JobsTextField
typealias JobsReturnJobsTextFieldByViewBlock = (_ view: UIView?) -> JobsTextField
typealias JobsReturnJobsTextFieldByModeBlock = (_ mode: UITextField.ViewMode) -> JobsTextField? /// 在 Swift 中，UITextFieldViewMode 已经被废弃，并由 Swift 原生的 UITextField.ViewMode 枚举所替代，并且它是 UITextField 的嵌套类型。

typealias JobsByCJTextField = (_ textField: CJTextField?) -> Void
typealias JobsByZYTextFieldBlock = (_ textField: ZYTextField?) -> Void

typealias JobsByStepViewBlock = (_ stepView: JobsStepView?) -> Void
typealias JobsReturnStepViewByCGFloatBlock = (_ data: CGFloat) -> JobsStepView?
typealias JobsReturnStepViewByNSIntegerBlock = (_ data: Int) -> JobsStepView?
typealias JobsReturnStepViewByColorBlock = (_ cor: UIColor?) -> JobsStepView?

typealias JobsByBaseLabelBlock = (_ label: BaseLabel?) -> Void
typealias JobsByBaseTextViewBlock = (_ textView: BaseTextView?) -> Void

typealias JobsByToggleBaseViewBlock = (_ toggleBaseView: JobsToggleBaseView?) -> Void
typealias JobsByHotLabelBlock = (_ view: JobsHotLabelBySingleLine?) -> Void

typealias JobsReturnFileNameModelByFileFullNameStringBlock = (_ fileFullName: String?) -> FileNameModel

typealias JobsReturnUserModelByVoidBlock = () -> JobsUserModel?
typealias JobsReturnUserModelByKeyBlock = (_ key: String?) -> JobsUserModel?
typealias JobsByUserModelBlock = (_ model: JobsUserModel?) -> Void
typealias JobsByIDAndKeyBlock = (_ userModel: NSCoding, _ key: String?) -> Void

typealias JobsByUserDefaultModelBlock = (_ data: UserDefaultModel) -> Void

typealias JobsByTabBarItemConfigBlock = (_ config: JobsTabBarItemConfig?) -> Void
typealias JobsReturnTabBarItemByConfigBlock = (_ config: JobsTabBarItemConfig?) -> UITabBarItem?

typealias JobsByLZTabBarConfigBlock = (_ config: LZTabBarConfig?) -> Void

typealias JobsByHXPhotoPickerModelBlock = (_ model: HXPhotoPickerModel?) -> Void

typealias JobsByParagraphStyleModelBlock = (_ model: JobsParagraphStyleModel?) -> Void
typealias JobsReturnMutAttributedStringByParagraphStyleModelBlock = (_ model: JobsParagraphStyleModel?) -> NSMutableAttributedString?

typealias JobsByLocationModelBlock = (_ model: JobsLocationModel?) -> Void
typealias JobsReturnViewByLocationModelBlock = (_ model: JobsLocationModel?) -> UIView?

typealias JobsByGTCaptcha4ModelBlock = (_ model: GTCaptcha4Model?) -> Void
typealias JobsReturnDicByGTCaptcha4ModelBlock = (_ model: GTCaptcha4Model?) -> NSDictionary?

typealias JobsByDoorModelBlock = (_ model: FMDoorModel?) -> Void
typealias JobsDoorModelBlock = (_ model: FMDoorModel?) -> FMDoorModel?
typealias JobsReturnDoorModelByGTCaptcha4ModelBlock = (_ model: GTCaptcha4Model?) -> FMDoorModel?

typealias JobsByNameModelBlock = (_ model: FMNameModel?) -> Void
typealias JobsByWithDrawModelBlock = (_ model: FMWithDrawModel?) -> Void

typealias JobsByTimeModelBlock = (_ model: JobsTimeModel?) -> Void
typealias JobsReturnStringByTimeModelBlock = (_ model: JobsTimeModel?) -> String?
typealias JobsReturnTimeModelByIntegerBlock = (_ timeSec: Int) -> JobsTimeModel?
typealias JobsReturnTimeModelByStringBlock = (_ dateFormat: String?) -> JobsTimeModel?

typealias JobsByVideoModelCoreBlock = (_ model: VideoModel_Core?) -> Void
typealias JobsByNotificationModelBlock = (_ model: NotificationModel?) -> Void
typealias JobsByNSNotificationKeyboardModelBlock = (_ model: NSNotificationKeyboardModel?) -> Void

typealias JobsByExcelConfigureViewModelBlock = (_ model: JobsExcelConfigureViewModel?) -> Void

typealias JobsByPopListBaseViewBlock = (_ data: PopListBaseView?) -> Void
typealias JobsReturnPopListBaseViewByID = (_ data: Any?) -> PopListBaseView

typealias JobsByExcelViewBlock = (_ view: JobsExcelView?) -> Void
typealias JobsByExcelContentViewBlock = (_ contentView: JobsExcelContentView?) -> Void
typealias JobsByExcelTopHeadViewBlock = (_ topHeadView: JobsExcelTopHeadView?) -> Void
typealias JobsByExcelLeftListViewBlock = (_ leftListView: JobsExcelLeftListView?) -> Void

typealias JobsByUserHeaderDataViewTBVCellBlock = (_ cell: JobsUserHeaderDataViewTBVCell?) -> Void

typealias JobsByKeyValueModelBlock = (_ data: JobsKeyValueModel?) -> Void
typealias JobsReturnMutableDicByKeyValueModelBlock = (_ model: JobsKeyValueModel?) -> NSMutableDictionary

typealias JobsBySPAlertControllerConfigBlock = (_ config: SPAlertControllerConfig?) -> Void

typealias JobsByToggleNavViewBlock = (_ taggedNavView: JobsToggleNavView?) -> Void

typealias JobsByCustomTabBarBlock = (_ customTabBar: JobsCustomTabBar?) -> Void
typealias JobsReturnCustomTabBarByViewBlock = (_ view: UIView?) -> JobsCustomTabBar?

typealias JobsByResponseModelBlock = (_ model: JobsResponseModel?) -> Void
typealias JobsReturnIDByResponseModelBlock = (_ model: JobsResponseModel?) -> Any?

typealias JobsByIpifyModelBlock = (_ model: IpifyModel?) -> Void
typealias JobsByIPApiModelBlock = (_ model: IPApiModel?) -> Void
typealias JobsByIpinfoModelBlock = (_ model: IpinfoModel?) -> Void

typealias JobsByRequestToolBlock = (_ tool: RequestTool?) -> Void

typealias JobsByBaseModelBlock = (_ model: BaseModel?) -> Void
typealias JobsByBaseModelAndIndexBlock = (_ model: BaseModel?, _ index: Int) -> Void

typealias JobsByBRStringPickerViewModelBlock = (_ model: BRStringPickerViewModel?) -> Void

typealias JobsByDecorationModelBlock = (_ model: JobsDecorationModel?) -> Void
typealias JobsReturnViewModelByDecorationModelBlock = (_ model: JobsDecorationModel?) -> UIViewModel?

typealias JobsReturnMGSwipeTableCellByBOOLBlock = (_ data: Bool) -> MGSwipeTableCell?
typealias JobsReturnMGSwipeTableCellByDelegateBlock = (_ delegate: MGSwipeTableCellDelegate?) -> MGSwipeTableCell

typealias JobsReturnGKNavBarByButtonModelBlock = (_ model: UIButtonModel?) -> GKCustomNavigationBar?

typealias JobsByGDFadeViewBlock = (_ view: GDFadeView?) -> Void
typealias JobsByCFGradientLabelBlock = (_ label: CFGradientLabel?) -> Void
typealias JobsByWGradientProgressModelBlock = (_ model: WGradientProgressModel?) -> Void

typealias JobsReturnJhtBannerScrollViewByFrame = (_ frame: CGRect) -> JhtBannerScrollView?
typealias JobsReturnCGSizeByJhtBannerScrollView = (_ view: JhtBannerScrollView?) -> CGSize
typealias JobsReturnNSIntegerByJhtBannerScrollView = (_ view: JhtBannerScrollView?) -> Int

typealias JobsReturnJhtBannerCardViewByFrame = (_ frame: CGRect) -> JhtBannerCardView?

typealias JobsByFSCalendarBlock = (_ calendar: FSCalendar?) -> Void

typealias JobsReturnHXPhotoViewByPhotoManagerBlock = (_ manager: HXPhotoManager?) -> HXPhotoView?

typealias JobsReturnHTMLDocumentByStringBlock = (_ string: String?) -> HTMLDocument?

typealias JobsByHXPhotoManagerBlock = (_ manager: HXPhotoManager?) -> Void
typealias JobsReturnHXPhotoManagerByNSUIntegerBlock = (_ type: UInt) -> HXPhotoManager
typealias JobsByHXPhotoConfigurationBlock = (_ config: HXPhotoConfiguration?) -> Void

typealias JobsByBRPickerStyleBlock = (_ pickerStyle: BRPickerStyle?) -> Void
typealias JobsByBRDatePickerViewBlock = (_ datePickerView: BRDatePickerView?) -> Void
typealias JobsByBRAddressPickerViewBlock = (_ addressPickerView: BRAddressPickerView?) -> Void
typealias JobsReturnBRDatePickerViewByPickerStyleBlock = (_ style: BRPickerStyle?) -> BRDatePickerView
typealias JobsReturnBRAddressPickerViewByPickerStyleBlock = (_ style: BRPickerStyle?) -> BRAddressPickerView
typealias JobsReturnBRStringPickerViewByPickerModeBlock = (_ mode: Int) -> BRStringPickerView

typealias JobsReturnAFSecurityPolicyByAFSSLPinningModeBlock = (_ data: UInt) -> AFSecurityPolicy

typealias JobsByIQKeyboardManagerBlock = (_ manager: IQKeyboardManager?) -> Void

typealias JobsByCJTextFieldBlock = (_ data: CJTextField?) -> Void

typealias JobsReturnAnimatorByTransDirectionBlock = (_ direction: JobsTransitionDirection) -> JobsTransitionAnimator?

typealias JobsByNavigationTransitionManagerBlock = (_ manager: JobsNavigationTransitionMgr?) -> Void

typealias JobsReturnWMZBannerViewByBannerParamBlock = (_ bannerParam: WMZBannerParam) -> WMZBannerView

typealias JobsReturnArrByMASConstraintMakerBlock = (_ data: MASConstraintMaker) -> [Any]?
typealias JobsByMASConstraintMakerBlock = (_ make: MASConstraintMaker) -> Void

typealias JobsByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel?) -> Void
typealias JobsReturnMJRefreshStateHeaderByMJRefreshConfigModelBlock = (_ config: MJRefreshConfigModel?) -> MJRefreshStateHeader?
//MJRefresh 系列（Header / Footer）
typealias JobsReturnMJRefreshNormalHeaderByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshNormalHeader
typealias JobsByMJRefreshNormalHeaderBlock = (_ view: MJRefreshNormalHeader?) -> Void

typealias JobsReturnMJRefreshStateHeaderByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshStateHeader
typealias JobsByMJRefreshStateHeaderBlock = (_ view: MJRefreshStateHeader?) -> Void

typealias JobsReturnScrollViewByMJRefreshHeaderBlock = (_ header: MJRefreshHeader?) -> UIScrollView?
typealias JobsReturnTableViewByMJRefreshHeaderBlock = (_ header: MJRefreshHeader?) -> UITableView?
typealias JobsReturnCollectionViewByMJRefreshHeaderBlock = (_ header: MJRefreshHeader?) -> UICollectionView?
typealias JobsReturnMJRefreshHeaderByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshHeader
typealias JobsByMJRefreshHeaderBlock = (_ view: MJRefreshHeader?) -> Void

typealias JobsReturnMJRefreshGifHeaderByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshGifHeader
typealias JobsByMJRefreshGifHeaderBlock = (_ view: MJRefreshGifHeader?) -> Void

typealias JobsReturnMJRefreshFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshFooter
typealias JobsByMJRefreshFooterBlock = (_ view: MJRefreshFooter?) -> Void
typealias JobsReturnScrollViewByMJRefreshFooterBlock = (_ footer: MJRefreshFooter?) -> UIScrollView?
typealias JobsReturnTableViewByMJRefreshFooterBlock = (_ footer: MJRefreshFooter?) -> UITableView?
typealias JobsReturnCollectionViewByMJRefreshFooterBlock = (_ footer: MJRefreshFooter?) -> UICollectionView?

typealias JobsReturnMJRefreshAutoGifFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshAutoGifFooter
typealias JobsByMJRefreshAutoGifFooterBlock = (_ view: MJRefreshAutoGifFooter?) -> Void

typealias JobsReturnMJRefreshBackNormalFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshBackNormalFooter
typealias JobsByMJRefreshBackNormalFooterBlock = (_ view: MJRefreshBackNormalFooter?) -> Void

typealias JobsReturnMJRefreshAutoNormalFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshAutoNormalFooter
typealias JobsByMJRefreshAutoNormalFooterBlock = (_ view: MJRefreshAutoNormalFooter?) -> Void

typealias JobsReturnMJRefreshAutoStateFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshAutoStateFooter
typealias JobsByMJRefreshAutoStateFooterBlock = (_ view: MJRefreshAutoStateFooter?) -> Void

typealias JobsReturnMJRefreshAutoFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshAutoFooter
typealias JobsByMJRefreshAutoFooterBlock = (_ view: MJRefreshAutoFooter?) -> Void

typealias JobsReturnMJRefreshBackGifFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshBackGifFooter
typealias JobsByMJRefreshBackGifFooterBlock = (_ view: MJRefreshBackGifFooter?) -> Void

typealias JobsReturnMJRefreshBackStateFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshBackStateFooter
typealias JobsByMJRefreshBackStateFooterBlock = (_ view: MJRefreshBackStateFooter?) -> Void

typealias JobsReturnMJRefreshBackFooterByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> MJRefreshBackFooter
typealias JobsByMJRefreshBackFooterBlock = (_ view: MJRefreshBackFooter?) -> Void
//其他 UI、网络、播放器等 Block
typealias JobsReturnLOTAnimationMJRefreshHeaderByRefreshConfigModelBlock = (_ model: MJRefreshConfigModel) -> LOTAnimationMJRefreshHeader
typealias JobsReturnLOTAnimationMJRefreshHeaderBySizeBlock = (_ size: CGSize) -> LOTAnimationMJRefreshHeader
typealias JobsByLOTAnimationMJRefreshHeaderBlock = (_ view: LOTAnimationMJRefreshHeader?) -> Void

typealias JobsReturnSRWebSocketByNSURLRequestBlock = (_ request: URLRequest?) -> SRWebSocket

typealias JobsReturnRACDisposableByVoidBlock = () -> RACDisposable
typealias JobsByRACDisposableBlock = (_ disposable: RACDisposable?) -> Void
typealias JobsReturnRACDisposableByTimeIntervalBlock = (_ data: TimeInterval) -> RACDisposable

typealias JobsReturnRACSignalArrByVoidBlock = () -> [RACSignal]

typealias JobsByGKPhotoBrowserBlock = (_ browser: GKPhotoBrowser) -> Void
typealias JobsReturnGKPhotoBrowserByPhotosArrayAndCurrentIndexBlock = (_ photosArray: [Any]?, _ currentIndex: Int) -> GKPhotoBrowser?
typealias JobsByGKPhotoBlock = (_ data: GKPhoto) -> Void

typealias JobsBySZTextViewBlock = (_ textView: SZTextView) -> Void

typealias JobsByXZMRefreshNormalHeaderBlock = (_ data: XZMRefreshNormalHeader) -> Void

typealias JobsByYTKNetworkConfigBlock = (_ data: YTKNetworkConfig?) -> Void
typealias JobsByYTKRequestBlock = (_ request: YTKRequest?) -> Void
typealias JobsByYTKChainRequestBlock = (_ chainRequest: YTKChainRequest?) -> Void
typealias JobsByYTKBatchRequestBlock = (_ data: YTKBatchRequest?) -> Void
typealias JobsReturnBatchRequestByArrBlock = (_ requests: [YTKRequest]?) -> YTKBatchRequest?

typealias JobsByYTKBaseRequestBlock = (_ request: YTKBaseRequest) -> Void
typealias JobsReturnResponseModelByYTKBaseRequestBlock = (_ request: YTKBaseRequest) -> JobsResponseModel?
typealias JobsHandelNoSuccessBlock = (_ request: YTKBaseRequest) -> Void
typealias JobsReturnYTKRequestByVoidBlock = () -> YTKBaseRequest
typealias JobsReturnYTKRequestByIDBlock = (_ data: Any?) -> YTKBaseRequest
typealias JobsReturnYTKRequestByDictionaryBlock = (_ dic: [String: Any]?) -> YTKBaseRequest

typealias JobsByZFAVPlayerManagerBlock = (_ data: ZFAVPlayerManager?) -> Void
typealias JobsByZFIJKPlayerManagerBlock = (_ data: ZFIJKPlayerManager?) -> Void

typealias JobsByCategoryTitleViewBlock = (_ view: JXCategoryTitleView?) -> Void
typealias JobsByCategoryImageViewBlock = (_ view: JXCategoryImageView?) -> Void
typealias JobsByCategoryDotViewBlock = (_ view: JXCategoryDotView?) -> Void
typealias JobsByCategoryNumberViewBlock = (_ view: JXCategoryNumberView?) -> Void
typealias JobsByCategoryIndicatorBackgroundViewBlock = (_ bgView: JXCategoryIndicatorBackgroundView?) -> Void
typealias JobsCategoryIndicatorLineViewBlock = (_ indicator: JXCategoryIndicatorLineView?) -> Void

typealias JobsReturnCategoryListContainerViewByNSIntegerBlock = (_ data: Int) -> JXCategoryListContainerView?
typealias JobsReturnCategoryIndicatorViewByViewsBlock = (_ views: [UIView & JXCategoryIndicatorProtocol]?) -> JXCategoryIndicatorView?

typealias JobsReturnCategoryBaseViewByVoidBlock = () -> JXCategoryBaseView?
typealias JobsReturnCategoryBaseViewByDelegateBlock = (_ delegate: JXCategoryViewDelegate?) -> JXCategoryBaseView?
typealias JobsReturnCategoryBaseViewByListContainerBlock = (_ listContainer: JXCategoryViewListContainer?) -> JXCategoryBaseView?
typealias JobsReturnCategoryBaseViewByCGFloatBlock = (_ data: CGFloat) -> JXCategoryBaseView?
typealias JobsReturnCategoryBaseViewByViewBlock = (_ view: UIView?) -> JXCategoryBaseView?

typealias JobsReturnCategoryTitleViewByCorBlock = (_ cor: UIColor?) -> JXCategoryTitleView?
typealias JobsReturnCategoryTitleViewByFontBlock = (_ font: UIFont?) -> JXCategoryTitleView?
typealias JobsReturnCategoryTitleViewByStringsBlock = (_ strings: [String]?) -> JXCategoryTitleView?
typealias JobsReturnCategoryTitleViewByNSIntegerBlock = (_ data: Int) -> JXCategoryTitleView?
typealias JobsReturnCategoryTitleViewByBOOLBlock = (_ data: Bool) -> JXCategoryTitleView?

typealias JobsReturnCategoryImageViewByStringsBlock = (_ strings: [String]?) -> JXCategoryImageView?
typealias JobsReturnCategoryImageViewBySizeBlock = (_ size: CGSize) -> JXCategoryImageView?
typealias JobsReturnCategoryImageViewByCGFloatBlock = (_ data: CGFloat) -> JXCategoryImageView?
typealias JobsReturnCategoryImageViewByBOOLBlock = (_ data: Bool) -> JXCategoryImageView?
typealias JobsReturnCategoryImageViewByNSIntegerBlock = (_ data: Int) -> JXCategoryImageView?
typealias JobsReturnCategoryImageViewByIndicatorLineViewsBlock = (_ indicatorLineViews: [JXCategoryIndicatorLineView]?) -> JXCategoryImageView?

typealias JobsReturnCategoryDotViewByRelativePositionBlock = (_ position: JXCategoryDotRelativePosition) -> JXCategoryDotView?
typealias JobsReturnCategoryDotViewByCGFloatBlock = (_ data: CGFloat) -> JXCategoryDotView?
typealias JobsReturnCategoryDotViewBySizeBlock = (_ size: CGSize) -> JXCategoryDotView?
typealias JobsReturnCategoryDotViewByPointBlock = (_ point: CGPoint) -> JXCategoryDotView?
typealias JobsReturnCategoryDotViewByCorBlock = (_ cor: UIColor?) -> JXCategoryDotView?
typealias JobsReturnCategoryDotViewByNumbersBlock = (_ numbers: [NSNumber]?) -> JXCategoryDotView?

typealias JobsReturnCategoryNumberViewByNumbersBlock = (_ numbers: [NSNumber]?) -> JXCategoryNumberView?
typealias JobsReturnCategoryNumberViewByCGPointBlock = (_ point: CGPoint) -> JXCategoryNumberView?
//typealias JobsReturnCategoryNumberViewByReturnStringByIntegerBlocks = (_ block: JobsReturnStringByIntegerBlock?) -> JXCategoryNumberView?
//复合型 Block
//typealias JobsByErrBlocks = (_ block: jobsByErrorBlock?) -> Void
//typealias JobsByRetIDByIDBlocks = (_ block: JobsReturnIDByIDBlock?) -> Void
//typealias JobsDelegateBlocks = (_ string: String?, _ block: jobsByVoidBlock?) -> Void
//
//typealias JobsReturnIDByVoidBlocks = (_ block: jobsByVoidBlock?) -> Any?
//typealias JobsReturnIDByVoidIDBlocks = (_ block: jobsByIDBlock?) -> Any?
//typealias JobsReturnIDByRetIDVoidBlocks = (_ block: JobsReturnIDByVoidBlock?) -> Any?
//typealias JobsReturnIDByRetIDByIDBlocks = (_ block: JobsReturnIDByIDBlock?) -> Any?
//typealias JobsRetIDByIDBlockByViewModelOthersProtocolID = (_ data: UIViewModelOthersProtocol?) -> JobsReturnIDByIDBlock?
//
////嵌套 View/Button/ViewController/Masonry Block
//typealias JobsReturnViewByVoidBlocks = (_ block: jobsByVoidBlock?) -> UIView?
//typealias JobsReturnViewByIDBlocks = (_ block: jobsByIDBlock?) -> UIView?
//typealias JobsReturnViewByRetIDBlocks = (_ block: JobsReturnIDByVoidBlock?) -> UIView?
//typealias JobsReturnViewByRetIDByIDBlocks = (_ block: JobsReturnIDByIDBlock?) -> UIView?
//typealias JobsReturnViewByMasonryConstraintsBlocks = (_ block: jobsByMASConstraintMakerBlock?) -> UIView?
//typealias JobsReturnViewByViewAndMasonryConstraintsBlocks = (_ subview: UIView, _ block: jobsByMASConstraintMakerBlock?) -> UIView?
//
//typealias JobsReturnButtonByButtonModel2Blocks = (_ block: jobsByButtonModelBlock?) -> UIButton?
//typealias JobsReturnButtonByTimerManagerBlocks = (_ block: jobsByTimerManagerBlock?) -> UIButton?
//typealias JobsReturnButtonByClickBlocks = (_ block: jobsByBtnBlock?) -> UIButton?
//typealias JobsReturnButtonByIDBlocks = (_ block: jobsByIDBlock?) -> UIButton?
//
//typealias JobsReturnCollectionViewByBlock1 = (_ block: jobsByIDBlock?) -> UICollectionView?
//
//typealias JobsReturnNavBarByVoidBtnBlocks = (_ block: jobsByBtnBlock?) -> JobsNavBar?
//
//typealias JobsReturnVCByVoidBlocks = (_ block: jobsByVoidBlock?) -> UIViewController?
//typealias JobsReturnVCByIDBlocks = (_ block: jobsByIDBlock?) -> UIViewController?
//typealias JobsReturnVCByRetIDByVoidBlocks = (_ block: JobsReturnIDByVoidBlock?) -> UIViewController?
//typealias JobsReturnVCByRetIDByIDBlocks = (_ block: JobsReturnIDByIDBlock?) -> UIViewController?
//typealias JobsReturnVCByMasonryConstraintsBlocks = (_ block: jobsByMASConstraintMakerBlock?) -> UIViewController?
//
////RAC / Masonry / MJRefresh Config Block
//typealias JobsReturnRACDisposableByReturnIDByIDBlocks = (_ block: JobsReturnIDByIDBlock?) -> RACDisposable
//
//typealias JobsReturnArrByMasonryBlocks = (_ block: jobsByMASConstraintMakerBlock) -> [Any]?
//typealias JobsByMasonryBlock = (_ block: jobsByMASConstraintMakerBlock) -> Void
//typealias JobsReturnMASConstraintMakerByBOOLBlock = (_ data: Bool) -> jobsByMASConstraintMakerBlock
//
//typealias JobsReturnMJRefreshConfigModelByReturnIDByIDBlocks = (_ block: JobsReturnIDByIDBlock?) -> MJRefreshConfigModel?

