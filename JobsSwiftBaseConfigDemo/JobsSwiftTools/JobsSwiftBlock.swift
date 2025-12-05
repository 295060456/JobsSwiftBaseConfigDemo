//
//  JobsSwiftBlock.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/5/25.
//

import UIKit
import ObjectiveC
// MARK: —— Cocoapods
#if canImport(Kingfisher)
import Kingfisher
public typealias KFCompleted = (Result<RetrieveImageResult, KingfisherError>) -> Void
#else
// 没有集成 Kingfisher 时给一个退化版本，避免整个工程编不过
public typealias KFCompleted = (Result<UIImage, Error>) -> Void
#endif

#if canImport(SnapKit)
import SnapKit
/// SnapKit 语法糖🍬
// 存的就是这个类型
public typealias JobsConstraintClosure = (_ make: ConstraintMaker) -> Void
#endif

#if canImport(YTKNetwork)
import YTKNetwork
public typealias JobsYTKBatchCompletion = (_ batch: YTKBatchRequest) -> Void
public typealias JobsYTKCompletion = (_ request: YTKBaseRequest) -> Void
public typealias JobsYTKChainSuccess = (_ chain: YTKChainRequest) -> Void
public typealias JobsYTKChainFailure = (_ chain: YTKChainRequest,
                                        _ failedRequest: YTKBaseRequest) -> Void
public typealias JobsYTKChainStepCallback = (_ chain: YTKChainRequest,
                                             _ finishedRequest: YTKBaseRequest) -> Void
#endif
// MARK: —— CreatedBy@Jobs
public typealias JobsYTKProgress = (_ progress: Progress) -> Void
public typealias BarItemHandler = (UIBarButtonItem) -> Void
public typealias JobsButtonTapBlock = (UIButton) -> Void
public typealias JobsButtonLongPressBlock = (UIButton, UILongPressGestureRecognizer) -> Void
public typealias NativeHandler = (_ payload: Any?, _ reply: @escaping (Any?) -> Void) -> Void
public typealias UASuffixProvider = (URLRequest) -> String?
public typealias MobileActionHandler = (_ body: [String: Any], _ reply: (Any?) -> Void) -> Void
public typealias TimerStateChangeHandler = (_ button: UIButton,
                                            _ oldState: TimerState,
                                            _ newState: TimerState) -> Void
/// 限长状态变化时的回调
/// isLimited = true  : 进入“被限长”状态（尝试超出时被拦截）
/// isLimited = false : 从“被限长”状态恢复（删到 maxLength 以下）
public typealias JobsTFOnLimitChanged = (_ isLimited: Bool, _ textField: UITextField) -> Void
public typealias UITextFieldOnChange = (_ tf: UITextField,
                                        _ input: String,
                                        _ oldText: String,
                                        _ isDeleting: Bool) -> Void

public typealias TVOnBackspace = (_ tv: UITextView) -> Void
public typealias TVOnChange = (_ tv: UITextView,
                               _ input: String,
                               _ old: String,
                               _ isDeleting: Bool) -> Void
/// 封装在UIView层的✅确认和🚫取消回调
public typealias JobsConfirmHandler = () -> Void
public typealias JobsCancelHandler  = () -> Void
public typealias Completion = () -> Void
public typealias BackHandler = () -> Void                     // 未配置 -> Debug Toast

public typealias TitleProvider = () -> NSAttributedString?    // 返回 nil 隐藏
public typealias BackButtonProvider = () -> UIButton?         // 返回 nil 隐藏
public typealias BackButtonLayout = (JobsNavBar, UIButton, ConstraintMaker) -> Void
