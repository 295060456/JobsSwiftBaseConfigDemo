//
//  NSProtocol.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/18.
//

import Foundation
import ReactiveSwift
import WebKit
import CoreGraphics
/// 在 Swift 中，不需要像 Objective-C 那样手动写 @synthesize，Swift 会自动为协议中声明的属性合成存储或访问器（取决于上下文）：
/// 👉 如果属性是只读计算属性（var xxx: Type { get }），可以用 extension 实现默认值。
protocol RACProtocol {
    /// 用于释放资源
    var racDisposable: Disposable? { get set }
    /// 用于手动控制发送事件
    var racSubject: Signal<Void, Never>.Observer? { get set }
    /// 信号通常是持久存在的
    var reqSignal: Signal<Void, Never>? { get set }
    /// 通常绑定到按钮操作或用户输入
    var actionCommand: Action<Void, Void, Never>? { get set }
    /// 适用于处理集合数据
    var dataSequence: SignalProducer<[Any], Never>? { get set }
    /// 控制多订阅行为（ReactiveSwift 推荐用 `Multicast` 或 `Property`）
    var dataConnection: Signal<Void, Never>? { get set }
    /// 管理调度线程
    var mainScheduler: DateScheduler { get }
    var backgroundScheduler: DateScheduler { get }
    /// 传递多个值（Swift 通常用 Tuple 或 Struct）
    var dataTuple: (Any?, Any?)? { get set }
    /// 信号和订阅的映射关系
    var signalDisposableMap: [ObjectIdentifier: Signal<Void, Never>] { get set }
    /// 定时器任务：带参数
    var doSthByIDBlock: ((Any?) -> Void)? { get set }
    /// 定时器任务：无参数
    var doSthBlock: (() -> Void)? { get set }
}

protocol BaseProtocol: RACProtocol {
    /// 锁
    var lock: NSLock? { get set }
    var recursiveLock: NSRecursiveLock? { get set }
    var os_lock: os_unfair_lock { get }
    var mutex: pthread_mutex_t { get }
    /// 状态
    var isLock: Bool { get set }
    var isRead: Bool { get set }
    var becomeFirstResponder: Bool { get set }
    var appLanguage: AppLanguage { get set }
    var lastContentOffset: CGPoint { get set }
    /// 计时器
    var time: CGFloat { get set }
    var timerHandler: (() -> Void)? { get set }/// 用于替代 NSInvocation：封装某个待执行行为
    var timer: Timer? { get set }
    var userInfo: Any? { get set }
    var semaphore: DispatchSemaphore { get set }
    var dispatchTimer: DispatchSourceTimer? { get set }
    var anticlockwiseTime: CGFloat { get set }
    var timeSecIntervalSinceDate: TimeInterval { get set }
    var startTime: TimeInterval { get set }
    var timeInterval: TimeInterval { get set }
    var repeats: Bool { get set }
    var isValid: Bool { get }
    var start: Bool { get set }
    var running: Bool { get set }
    var pause: Bool { get set }
    var resume: Bool { get set }
    var stop: Bool { get set }
    var state: DispatchTimerState { get set }
    var timerType: ScheduledTimerType { get set }
    var timerStyle: TimerStyle { get set }
    var timerCurrentStatus: NSTimerCurrentStatus { get }
    var timerProcessType: TimerProcessType { get set }
    /// JS
    var userContentCtrl: WKUserContentController? { get set }
    var scriptMsg: WKScriptMessage? { get set }
    var handlerName: String? { get set }
    var evaluateJavaScript: String? { get set }
//    var completionHandlerBlock: jobsJSCompletionHandlerBlock? { get set }
    // MARK: Data
    var urls: [URL]? { get set }
    var url: URL? { get set }
    var imageUrl: URL? { get set }
    var internationalizationKEY: String? { get set }
    var jobsDataMutSet: NSMutableSet? { get set }
    var jobsDataMutArr: NSMutableArray? { get set }
    var jobsDataMutDic: NSMutableDictionary? { get set }
    var cls: AnyClass? { get set }
    // Runtime
    var selector: Selector? { get set }
    var implementation: IMP? { get set }
    var target: AnyObject? { get set }
    var weak_target: AnyObject? { get set }
    // Data Binding
    var data: Any? { get set }
    var requestParams: Any? { get set }
    var modelData: Any? { get set }
    var value_CGFloat: CGFloat { get set }
    var value_NSInteger: Int { get set }
    var value_NSUInteger: UInt { get set }
    var data_weak: AnyObject? { get set }
    var requestParams_weak: AnyObject? { get set }
    // Tab Bar
//    func changeTabBarItemTitleBy() -> jobsByIndexPathBlock
    // MARK: 通知
    func monitorNotification(_ notificationName: String, withSelector selector: Selector)
//    func monitorNotification(_ notificationName: String, withBlock actionBlock: @escaping JobsReturnIDByTwoIDBlock)
    static func target(_ target: Any, languageSwitchNotificationWithSelector selector: Selector)
    func monitorAppLanguage()
//    func appLanguageAtAppLanguageBy() -> jobsByNSIntegerBlock
//    func jobsLanguageSwitchNotification() -> jobsByNotificationBlock
    // MARK: 单例
    static func destroySingleton()
    static func sharedManager() -> Self
//    static func SharedInstance() -> JobsReturnIDByVoidBlock
//    static func DestroySingleton() -> jobsByVoidBlock
}
@available(iOS 11.0, *)
protocol GestureProtocol: BaseProtocol {
    // MARK: - Gesture Configuration
    /// 最小触摸点数量（不可用于 tvOS）
    var minimumNumberOfTouches: UInt? { get set } // API_UNAVAILABLE(tvos)
    /// 最大触摸点数量（不可用于 tvOS）
    var maximumNumberOfTouches: UInt? { get set } // API_UNAVAILABLE(tvos)
    /// 设置轻拍次数【UILongPressGestureRecognizer】【UITapGestureRecognizer】
    /// ⚠️注意：如果要设置长按手势，此属性必须设置为0⚠️
    var numberOfTapsRequired: UInt? { get set }
    /// 设置手指数【UILongPressGestureRecognizer】【UITapGestureRecognizer】
    var numberOfTouchesRequired: UInt? { get set }
    /// LongPress 最小长按时间
    var minimumPressDuration: TimeInterval? { get set }
    /// 允许的最大移动距离（用于 LongPress）
    var allowableMovement: CGFloat? { get set }
    /// 轻扫手势方向
    var swipeGRDirection: UISwipeGestureRecognizer.Direction? { get set }
    /// 滚动允许的类型（iOS 13.4+）
    @available(iOS 13.4, *)
    var allowedScrollTypesMask: UIScrollTypeMask? { get set }
    /// 捏合范围
    var scale: CGFloat? { get set }
    /// 旋转角度
    var rotate: CGFloat? { get set }
    // MARK: - Gesture Recognizers
    var longPressGR: UILongPressGestureRecognizer? { get set }
    var tapGR: UITapGestureRecognizer? { get set }
    var doubleTapGR: UITapGestureRecognizer? { get set }
    var swipeGR: UISwipeGestureRecognizer? { get set }
    var panGR: UIPanGestureRecognizer? { get set }
    var pinchGR: UIPinchGestureRecognizer? { get set }
    var rotationGR: UIRotationGestureRecognizer? { get set }
    var screenEdgePanGR: UIScreenEdgePanGestureRecognizer? { get set }
    // MARK: - Gesture Selector/IMP 包装器（类似映射结构）
//    var longPressGR_SelImp: JobsSEL_IMP? { get set }
//    var tapGR_SelImp: JobsSEL_IMP? { get set }
//    var doubleTapGR_SelImp: JobsSEL_IMP? { get set }
//    var swipeGR_SelImp: JobsSEL_IMP? { get set }
//    var panGR_SelImp: JobsSEL_IMP? { get set }
//    var pinchGR_SelImp: JobsSEL_IMP? { get set }
//    var rotationGR_SelImp: JobsSEL_IMP? { get set }
//    var screenEdgePanGR_SelImp: JobsSEL_IMP? { get set }
    // MARK: - 生命周期
    func dealloc()
}

protocol UITextFieldProtocol: AnyObject {
    // MARK: - 数据相关
    var text: String? { get set }                       // 主标题
    var textCor: UIColor? { get set }                   // 主标题文字颜色
    var textFont: UIFont? { get set }                   // 主标题字体
    
    var textFieldPlaceholder: String? { get set }       // 避免与系统 placeholder 冲突
    var placeholderColor: UIColor? { get set }
    var placeholderFont: UIFont? { get set }
    @available(iOS 6.0, *)
    var attributedPlaceholder: NSAttributedString? { get set }
    // MARK: - UI 样式
    var baseBackgroundColor: UIColor? { get set }
    var placeHolderAlignment: NSTextAlignment { get set }
    var cornerRadiusValue: CGFloat { get set }
    var layerBorderCor: UIColor? { get set }
    var borderWidth: CGFloat { get set }
    // MARK: - 偏移量设置
    var text_offset: CGFloat { get set }
    var placeHolderOffset: CGFloat { get set }
    var leftViewOffsetX: CGFloat { get set }
    var rightViewOffsetX: CGFloat { get set }
    var fieldEditorOffset: CGFloat { get set }
    // MARK: - 子视图
    var leftView: UIView? { get set }
    var rightView: UIView? { get set }
    var leftViewMode: UITextField.ViewMode { get set }
    var rightViewMode: UITextField.ViewMode { get set }
    
    var isShowDelBtn: Bool { get set }
    var useCustomClearButton: Bool { get set }
    var isShowMenu: Bool { get set }
    var notAllowEdit: Bool { get set }
    var textFieldSecureTextEntry: Bool { get set }
    // MARK: - 键盘相关
    var TFRiseHeight: CGFloat { get set }                   // 键盘最高弹起
    var keyboardAppearance_: UIKeyboardAppearance { get set }
    var keyboardType_: UIKeyboardType { get set }
    var returnKeyType_: UIReturnKeyType { get set }
    // MARK: - 系统重载位置属性
    var clearButtonRectForBounds: CGRect { get set }
    var borderRectForBounds: CGRect { get set }
    var drawPlaceholderInRect: CGRect { get set }           // 初始化时调用
    var leftViewRectForBounds: CGRect { get set }           // 键盘弹起调用
    var rightViewRectForBounds: CGRect { get set }          // 键盘弹起调用
    var placeholderRectForBounds: CGRect { get set }        // placeholder 区域
    var textRectForBounds: CGRect { get set }               // 文字显示区域
    var editingRectForBounds: CGRect { get set }            // 编辑状态区域
    // MARK: - 动作回调
    func otherActionBlock(_ block: ((Any?) -> Any?)?)
}
