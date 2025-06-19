//
//  JobsBlock.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//
import UIKit
// MARK: - 基础类型 Block
typealias JobsReturnComponentTypeByVoidBlock = () -> ComponentType
typealias JobsReturnDeviceOrientationByVoidBlock = () -> DeviceOrientation
typealias JobsReturnAppLanguageByVoidBlock = () -> AppLanguage
typealias JobsReturnDeviceOrientationByViewBlock = (_ data: UIView?) -> DeviceOrientation
typealias JobsReturnTimeZoneByTypeBlock = (_ timeZoneType: TimeZoneType) -> TimeZone?
typealias JobsReturnIDByAppLanguageBlock = (_ data: AppLanguage) -> Any?
typealias JobsReturnIDByComponentTypeAndUIViewBlock = (_ args: Jobs_ReturnIDByComponentTypeAndUIViewBlock_Arguments) -> Any?

// MARK: - JobsTextView
typealias JobsByJobsTextViewBlock = (_ textView: JobsTextView?) -> Void

// MARK: - ZF Player 相关
typealias JobsByZFAVPlayerManagerBlock = (_ manager: ZFAVPlayerManager?) -> Void
typealias JobsByZFDouYinControlViewBlock = (_ controlView: ZFDouYinControlView?) -> Void
typealias JobsByZFCustomControlViewBlock = (_ controlView: ZFCustomControlView?) -> Void
typealias JobsByCustomZFPlayerControlViewBlock = (_ controlView: CustomZFPlayerControlView?) -> Void

// MARK: - 组件类 View
typealias JobsByRightBtnsViewBlock = (_ view: JobsRightBtnsView?) -> Void
typealias JobsByBitsMonitorSuspendLabBlock = (_ label: JobsBitsMonitorSuspendLab?) -> Void
typealias JobsByBaseViewBlock = (_ view: BaseView?) -> Void

// MARK: - TabBar
typealias JobsByTabBarVCBlock = (_ vc: JobsTabBarVC?) -> Void
typealias JobsByCustomTabBarVCBlock = (_ vc: JobsCustomTabBarVC?) -> Void
typealias JobsByCustomTabBarConfigBlock = (_ config: JobsCustomTabBarConfig?) -> Void

// MARK: - MGSwipe
typealias JobsByMGSwipeButtonModelBlock = (_ model: MGSwipeButtonModel?) -> Void

// MARK: - 富文本
typealias JobsReturnAttributedStringByRichTextConfigArrayBlock = (_ configs: [JobsRichTextConfig]?) -> NSMutableAttributedString?
typealias JobsByRichTextConfigBlock = (_ config: JobsRichTextConfig?) -> Void

// MARK: - 图片模型
typealias JobsBySDWebImageModelBlock = (_ model: SDWebImageModel?) -> Void

// MARK: - URL管理
typealias JobsByURLManagerModelBlock = (_ model: URLManagerModel?) -> Void
typealias JobsReturnURLManagerModelByStringBlock = (_ data: String?) -> URLManagerModel?

// MARK: - ViewModel 相关
typealias JobsByViewModelAndBOOLBlock = (_ args: Jobs_ViewModelAndBOOLBlock_Arguments) -> Void
typealias JobsReturnButtonByViewModelAndBOOLBlock = (_ args: Jobs_ViewModelAndBOOLBlock_Arguments) -> UIButton?
typealias JobsReturnViewModelByVoidBlock = () -> UIViewModel?
typealias JobsReturnViewModelByStringBlock = (_ string: String?) -> UIViewModel?
typealias JobsReturnButtonByViewModelBlock = (_ model: UIViewModel?) -> UIButton?
typealias JobsByViewModelBlock = (_ model: UIViewModel?) -> Void
typealias JobsByArrWithViewModelBlock = (_ models: [UIViewModel]?) -> Void
typealias JobsReturnCGSizeByViewModelBlock = (_ model: UIViewModel?) -> CGSize
typealias JobsReturnCGRectByViewModelBlock = (_ model: UIViewModel?) -> CGRect
typealias JobsReturnCGFloatByViewModelBlock = (_ model: UIViewModel?) -> CGFloat
typealias JobsReturnViewModelInArrByArrBlock = (_ arr: [Any]?) -> [UIViewModel]?

// MARK: - TableView / SearchBar
typealias JobsByBaseTableViewBlock = (_ tableView: BaseTableView?) -> Void
typealias JobsBySearchBarBlock = (_ searchBar: JobsSearchBar?) -> Void

// MARK: - 门户相关
typealias JobsByAppDoorModelBlock = (_ model: JobsAppDoorModel?) -> Void
typealias JobsReturnBOOLByAppDoorModelBlock = (_ model: JobsAppDoorModel?) -> Bool

// MARK: - 通知
typealias JobsByUNNotificationRequestModelBlock = (_ model: UNNotificationRequestModel?) -> Void
typealias JobsReturnUNNotificationRequestByModelBlock = (_ model: UNNotificationRequestModel?) -> UNNotificationRequest?

// MARK: - 警告框
typealias JobsByAlertModelBlock = (_ model: JobsAlertModel?) -> Void
typealias JobsReturnAlertControllerByAlertModelBlock = (_ model: JobsAlertModel?) -> UIAlertController?

// MARK: - 文本模型
typealias JobsReturnButtonByTextModelBlock = (_ model: UITextModel?) -> UIButton?
typealias JobsReturnViewByTextModelBlock = (_ model: UITextModel?) -> UIView?
typealias JobsByTextModelBlock = (_ model: UITextModel?) -> Void

// MARK: - 输入框
typealias JobsByMagicTextFieldBlock = (_ textField: JobsMagicTextField?) -> Void

// MARK: - RAC模型
typealias JobsByRACModelBlock = (_ model: RACModel?) -> Void

// MARK: - 手势模型
typealias JobsByGestureModelBlock = (_ model: JobsGestureModel?) -> Void

// MARK: - 聊天信息模型
typealias JobsByIMChatInfoModelBlock = (_ model: JobsIMChatInfoModel?) -> Void

// MARK: - 定时器
typealias JobsByTimerManagerBlock = (_ manager: NSTimerManager?) -> Void

// MARK: - 按钮定时器
typealias JobsReturnButtonByTimerConfigModelBlock = (_ model: ButtonTimerConfigModel) -> UIButton?
typealias JobsByButtonTimerConfigModelBlock = (_ model: ButtonTimerConfigModel?) -> Void

// MARK: - 门户输入框样式
typealias JobsByAppDoorInputViewBaseStyleModelBlock = (_ model: JobsAppDoorInputViewBaseStyleModel?) -> Void
typealias JobsReturnAppDoorInputViewBaseStyleByClassBlock = (_ cls: AnyClass) -> JobsAppDoorInputViewBaseStyle?

// MARK: - 色彩模型
typealias JobsReturnCorModelByVoidBlock = () -> JobsCorModel
typealias JobsReturnCorModelByCorBlock = (_ data: UIColor?) -> JobsCorModel
typealias JobsByCorModelBlock = (_ data: JobsCorModel?) -> Void

// MARK: - 菜单导航
typealias JobsByMenuViewBlock = (_ view: JobsMenuView?) -> Void
typealias JobsByViewNavigatorBlock = (_ navigator: JobsViewNavigator?) -> Void
typealias JobsReturnViewNavigatorByViewAndAnimatedBlock = (_ args: Jobs_ReturnViewNavigatorByViewAndAnimatedBlock_Arguments) -> JobsViewNavigator
typealias JobsReturnViewNavigatorByBOOLBlock = (_ data: Bool) -> JobsViewNavigator

// MARK: - 导航栏
typealias JobsByBaseNavigationBarBlock = (_ navBar: BaseNavigationBar?) -> Void

// MARK: - Masonry布局
typealias JobsByMasonryModelBlock = (_ model: MasonryModel?) -> Void
typealias JobsReturnIDByMasonryModelBlock = (_ model: MasonryModel?) -> Any?
typealias JobsReturnArrByMasonryModelBlock = (_ model: MasonryModel?) -> [Any]?

// MARK: - 自定义TabBar
typealias JobsByLZTabBarBlock = (_ tabBar: LZTabBar?) -> Void
typealias JobsByLZTabBarItemBlock = (_ item: LZTabBarItem?) -> Void

// MARK: - TextFieldModel
typealias JobsByTextFieldModelBlock = (_ model: UITextFieldModel?) -> Void
typealias JobsReturnTextFieldModelByString = (_ data: String?) -> UITextFieldModel?

// MARK: - 文件模型
typealias JobsByFileModelBlock = (_ model: JobsFileModel?) -> Void
typealias JobsReturnRequestByFileModelBlock = (_ model: JobsFileModel?) -> BaseUploadFileRequest?

// MARK: - 按钮模型
typealias JobsByButtonModelBlock = (_ model: UIButtonModel?) -> Void
typealias JobsByButtonModelAndBOOLBlock = (_ args: Jobs_ByButtonModelAndBOOLBlock_Arguments) -> Void
typealias JobsReturnButtonByButtonModelAndBOOLBlock = (_ args: Jobs_ByButtonModelAndBOOLBlock_Arguments) -> UIButton?
typealias JobsReturnViewByButtonModelBlock = (_ model: UIButtonModel?) -> UIView?
typealias JobsReturnBOOLByButtonModelBlock = (_ data: UIButtonModel?) -> Bool
typealias JobsReturnButtonModelArrByArrBlock = (_ arr: [Any]?) -> [UIButtonModel]?
typealias JobsReturnButtonModelByString = (_ string: String?) -> UIButtonModel?
typealias JobsReturnButtonModelByAttributedString = (_ aString: NSAttributedString?) -> UIButtonModel?
typealias JobsReturnButtonByButtonModelBlock = (_ model: UIButtonModel?) -> UIButton?
typealias JobsReturnViewByButtonModelArrayBlock = (_ models: [UIButtonModel]?) -> UIView?

