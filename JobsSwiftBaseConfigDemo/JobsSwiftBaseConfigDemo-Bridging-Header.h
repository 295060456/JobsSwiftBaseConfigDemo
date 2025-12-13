//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <TargetConditionals.h>
#import "OCCls.h"

#if !TARGET_OS_SIMULATOR && __has_include(<UnityFramework/UnityFramework.h>)
/// 只有真机（iPhone / iPad）才加入 Unity
/// https://github.com/JobsKits/JobsDocs/blob/main/iOS相关的文档和资料.md/iOS项目集成Unity.md/iOS项目集成Unity.md
#import <UnityFramework/UnityFramework.h>
#endif
