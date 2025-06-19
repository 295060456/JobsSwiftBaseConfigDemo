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
    var signalDisposableMap: [Disposable: Signal<Void, Never>] { get set }
    /// 定时器任务：带参数
    var doSthByIDBlock: ((Any?) -> Void)? { get set }
    /// 定时器任务：无参数
    var doSthBlock: (() -> Void)? { get set }
}

//protocol BaseProtocol: AnyObject /* Add: YTKChainRequestDelegate, RACProtocol */ {
//    // MARK: 锁
//    var lock: NSLock? { get set }
//    var recursiveLock: NSRecursiveLock? { get set }
//    var os_lock: os_unfair_lock { get }
//    var mutex: pthread_mutex_t { get }
//
//    // MARK: 状态
//    var isLock: Bool { get set }
//    var isRead: Bool { get set }
//    var becomeFirstResponder: Bool { get set }
//    var appLanguage: AppLanguage { get set }
//    var lastContentOffset: CGPoint { get set }
//
//    // MARK: 计时器
//    var time: CGFloat { get set }
//    var invocation: NSInvocation? { get set }
//    var timer: Timer? { get set }
//    var userInfo: Any? { get set }
//    var semaphore: DispatchSemaphore { get set }
//    var dispatchTimer: DispatchSourceTimer? { get set }
//    var anticlockwiseTime: CGFloat { get set }
//    var timeSecIntervalSinceDate: TimeInterval { get set }
//    var startTime: TimeInterval { get set }
//    var timeInterval: TimeInterval { get set }
//    var repeats: Bool { get set }
//    var isValid: Bool { get }
//    var start: Bool { get set }
//    var running: Bool { get set }
//    var pause: Bool { get set }
//    var resume: Bool { get set }
//    var stop: Bool { get set }
//    var state: DispatchTimerState { get set }
//    var timerType: ScheduledTimerType { get set }
//    var timerStyle: TimerStyle { get set }
//    var timerCurrentStatus: NSTimerCurrentStatus { get }
//    var timerProcessType: TimerProcessType { get set }
//
//    // MARK: JS
//    var userContentCtrl: WKUserContentController? { get set }
//    var scriptMsg: WKScriptMessage? { get set }
//    var handlerName: String? { get set }
//    var evaluateJavaScript: String? { get set }
//    var completionHandlerBlock: jobsJSCompletionHandlerBlock? { get set }
//
//    // MARK: Data
//    var urls: [URL]? { get set }
//    var url: URL? { get set }
//    var imageUrl: URL? { get set }
//    var internationalizationKEY: String? { get set }
//    var jobsDataMutSet: NSMutableSet? { get set }
//    var jobsDataMutArr: NSMutableArray? { get set }
//    var jobsDataMutDic: NSMutableDictionary? { get set }
//    var cls: AnyClass? { get set }
//
//    // Runtime
//    var selector: Selector? { get set }
//    var implementation: IMP? { get set }
//    var target: AnyObject? { get set }
//    var weak_target: AnyObject? { get set }
//
//    // Data Binding
//    var data: Any? { get set }
//    var requestParams: Any? { get set }
//    var modelData: Any? { get set }
//    var value_CGFloat: CGFloat { get set }
//    var value_NSInteger: Int { get set }
//    var value_NSUInteger: UInt { get set }
//    var data_weak: AnyObject? { get set }
//    var requestParams_weak: AnyObject? { get set }
//
//    // Tab Bar
//    func changeTabBarItemTitleBy() -> jobsByIndexPathBlock
//
//    // MARK: 通知
//    func monitorNotification(_ notificationName: String, withSelector selector: Selector)
//    func monitorNotification(_ notificationName: String, withBlock actionBlock: @escaping JobsReturnIDByTwoIDBlock)
//    static func target(_ target: Any, languageSwitchNotificationWithSelector selector: Selector)
//    func monitorAppLanguage()
//    func appLanguageAtAppLanguageBy() -> jobsByNSIntegerBlock
//    func jobsLanguageSwitchNotification() -> jobsByNotificationBlock
//
//    // MARK: 单例
//    static func destroySingleton()
//    static func sharedManager() -> Self
//    static func SharedInstance() -> JobsReturnIDByVoidBlock
//    static func DestroySingleton() -> jobsByVoidBlock
//}
