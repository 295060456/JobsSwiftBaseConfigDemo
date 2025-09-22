# **iOS.[Swift](https://developer.apple.com/swift/) **@<font color=red>靶场项目</font>蓝皮书📘


<p align="left">
  <a><img src="https://img.shields.io/badge/Swift-red" alt="Swift"/></a>
  <a><img src="https://img.shields.io/badge/Xcode-15.4-blue" alt="Xcode"/></a>
  <a><img src="https://img.shields.io/badge/iOS-17.5+-critical" alt="iOS"/></a>
  <a><img src="https://img.shields.io/badge/pod-1.15.2-brightgreen" alt="CocoaPods"/></a>
  <a><img src="https://img.shields.io/github/actions/workflow/status/295060456/JobsSwiftBaseConfigDemo/ci.yml?branch=main" alt="Build Status"/></a>
  <a href="https://github.com/295060456/JobsSwiftBaseConfigDemo"><img src="https://img.shields.io/github/license/295060456/JobsSwiftBaseConfigDemo?style=flat&color=success" alt="License"/></a>
  <a><img src="https://img.shields.io/github/languages/top/295060456/JobsSwiftBaseConfigDemo?color=blueviolet" alt="Top Language"/></a>
  <a href="https://github.com/295060456/JobsSwiftBaseConfigDemo/stargazers"><img src="https://img.shields.io/github/stars/295060456/JobsSwiftBaseConfigDemo?style=flat-square&color=yellow" alt="Stars"/></a>
  <a href="https://github.com/295060456/JobsSwiftBaseConfigDemo/network"><img src="https://img.shields.io/github/forks/295060456/JobsSwiftBaseConfigDemo?style=flat-square&color=blue" alt="Forks"/></a>
  <a><img src="https://img.shields.io/github/issues/295060456/JobsSwiftBaseConfigDemo?color=important" alt="Issues"/></a>
  <a><img src="https://img.shields.io/github/last-commit/295060456/JobsSwiftBaseConfigDemo?color=ff69b4" alt="Last Commit"/></a>
  <a><img src="https://img.shields.io/github/languages/code-size/295060456/JobsSwiftBaseConfigDemo" alt="Code Size"/></a>
</p>

[toc]

当前总行数：

## 🔥<font id=前言>前言</font>

> 温馨提示🔔：本文较长，需要⏬下载到本地以后，方能完整阅读。推荐阅读器👉[**Typora**](https://typora.io/)

* **工欲善其事必先利其器**
* **站在巨人的肩膀上，才能看得更远**
* **面向信仰编程**

## 一、🎯项目白皮书 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 程序员是一个高消耗的职业，除了日常基本的业务开发以外，新事物的不断涌现也需要持续性的学习，所以是一件非常消耗精力的事；而且由于长期的高压、高情绪、熬夜，**会打乱人体内正常的内分泌节奏**，大概率也会逐渐的引发各种职业疾病。业内普遍认为程序员的**黄金年龄在25～35周岁**。那么，还是希望，在我们（亦或者是暂时性的）离开这个行业的时候，一定要为自己或者后人，留下点什么，算是这么多年的一个工作总结。此外，能最大化的辅助人，帮助其在极短的时间内去：<u>回忆/上手/学习/实验</u>这个编程语言下的工程项目。所以，此项目就一定是要结合商业需求去务实拓展，解决当前痛点。

* 品控标准（只能严格的保证编译器正常，而不能完全保证运行时的不出错）
  * 一定要保证这个工程的成功编译通过，方便以后项目直接进行引用，乃至开新版本
  * <font color=blue>**示例Demo可能因为相关Api的升级，没有及时的覆盖处理，可能会出现闪退。修复即可**</font>
* 自此以后，所有新开的项目都可以根据这个**根项目**来进行统一的调配和使用
  * 将它作为所有项目的母版和基类，最大限度的做到全局的统一
  * 日积月累的记录一些平时生产生活中萌发的一些优秀的想法、灵光一现的创意。包括但不仅限于：<u>语法糖的封装</u>、<u>方法的调用</u>，<u>第三方的选用</u>、以及一些心得体会
* 作为某些代码**实践靶场**，在实际开发过程中，是非常有必要的
  * 为我们快速且稳定的复现一些业务场景，作为代码实验室🧪，而搭建的一个平台
* 作为代码笔记，记录一些常用的代码，方便查阅
  * 主要形式是可以运行的代码 + 文字性叙述 + 图文混编讲解
  * 作为学习的资料，可以快速了解到一些常用的知识，大幅**降低学习成本**
  * 作为其他项目的参考，可以快速的了解到项目的架构，代码规范，以及一些设计模式
  * 这么一些优秀的成果，其来源不仅仅是来自于作者本身的持续付出与积累。更是这个领域大家庭中各路优秀作者的智慧结晶

## 二、👥第三方管理 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1、第三方管理 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

* Mac OS 15 以后，苹果采取了更加严格的权限写入机制。新**swift**项目如果要利用[**`Cocoapod`**](https://cocoapods.org/)来集成第三方，就比如在**xcode**里面做如下设置，否则编译失败：`TARGETS`->`Build Settings`->`ENABLE_USER_SCRIPT_SANDBOXING`-><font color=red>`NO`</font>

  ![image-20250616173410872](./assets/image-20250616173410872.png)

  [**脚本处理**](./【MacOS】⚙️双击禁用沙盒保证Cocoapods构建流程.command)

  ```shell
  #!/bin/zsh
  
  print_green()  { echo "\033[0;32m$1\033[0m"; }
  print_red()    { echo "\033[0;31m$1\033[0m"; }
  print_yellow() { echo "\033[0;33m$1\033[0m"; }
  
  print_green "🛠️ 脚本功能："
  echo "1️⃣ 自动识别 Flutter 或原生 iOS 工程"
  echo "2️⃣ 自动定位 Xcode 工程（.xcodeproj）文件"
  echo "3️⃣ 修改 ENABLE_USER_SCRIPT_SANDBOXING = NO，防止 CocoaPods 构建失败"
  echo ""
  
  SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
  XCODEPROJ=""
  
  # 尝试自动识别 Flutter / iOS 工程路径
  if [[ -d "$SCRIPT_DIR/ios" && -d "$SCRIPT_DIR/lib" ]]; then
    print_green "📦 检测到 Flutter 工程，进入 ios 子目录查找 Xcode 工程..."
    PROJECT_DIR="$SCRIPT_DIR/ios"
  else
    print_green "📱 尝试在当前目录查找原生 iOS 工程..."
    PROJECT_DIR="$SCRIPT_DIR"
  fi
  
  # 自动寻找 .xcodeproj
  XCODEPROJ=$(find "$PROJECT_DIR" -maxdepth 1 -name "*.xcodeproj" | head -n 1)
  
  # 如果找不到，就让用户手动拖入
  if [[ -z "$XCODEPROJ" ]]; then
    print_red "❌ 未自动找到 .xcodeproj 文件"
    echo ""
    read "?👉 请手动拖入你的 .xcodeproj 工程文件，然后按回车：" XCODEPROJ
    XCODEPROJ=${XCODEPROJ%\"}
    XCODEPROJ=${XCODEPROJ#\"}
  fi
  
  # 校验路径有效性
  PBXPROJ_PATH="$XCODEPROJ/project.pbxproj"
  if [[ ! -f "$PBXPROJ_PATH" ]]; then
    print_red "❌ 找不到 project.pbxproj 文件，请确认路径正确"
    exit 1
  fi
  
  print_yellow "📂 目标工程：$XCODEPROJ"
  print_green  "🔍 正在查找 ENABLE_USER_SCRIPT_SANDBOXING 设置..."
  
  # ✅ 若已存在，则替换为 NO
  grep -q "ENABLE_USER_SCRIPT_SANDBOXING" "$PBXPROJ_PATH"
  if [[ $? -eq 0 ]]; then
    print_green "✅ 已找到 ENABLE_USER_SCRIPT_SANDBOXING，正在替换为 NO..."
    sed -i '' 's/ENABLE_USER_SCRIPT_SANDBOXING = YES;/ENABLE_USER_SCRIPT_SANDBOXING = NO;/g' "$PBXPROJ_PATH"
    sed -i '' 's/ENABLE_USER_SCRIPT_SANDBOXING = YES/ENABLE_USER_SCRIPT_SANDBOXING = NO/g' "$PBXPROJ_PATH"
  else
    print_green "➕ 未显式设置，添加 ENABLE_USER_SCRIPT_SANDBOXING = NO 到所有 buildSettings..."
    sed -i '' '/buildSettings = {/a\
  \        ENABLE_USER_SCRIPT_SANDBOXING = NO;
  ' "$PBXPROJ_PATH"
  fi
  
  print_green "🎉 修改完成！已将 ENABLE_USER_SCRIPT_SANDBOXING 设置为 NO"

* <font color=red>**S**</font>wift <font color=red>**P**</font>ackage <font color=red>**M**</font>anager

  <div style="text-align: center;">
    <img src="./assets/image-20250616173604040.png" alt="image-1" style="width:30%; display:inline-block; vertical-align: top;" />
    <img src="./assets/image-20250616174404275.png" alt="image-2" style="width:65%; display:inline-block; vertical-align: top;" />
  </div>

### 2、适用于[Swift](https://developer.apple.com/swift/) 的第三方框架 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 2.1、[**DeviceKit**](https://github.com/devicekit/DeviceKit)

#### 2.2、[**HandyJSON**](https://github.com/alibaba/HandyJSON)

> 1、阿里巴巴开发
>
> 2、 **[Swift](https://developer.apple.com/swift/) 的 JSON 与模型映射库**
>
> 3、**简化 [Swift](https://developer.apple.com/swift/)  与 JSON 数据之间的序列化 / 反序列化过程**，避免传统方式下大量手写 `Codable`、`init(from:)` 或者 `Mappable` 的模板化代码
>
> 4、[**Swift**](https://developer.apple.com/swift/).[**Codable**](https://developer.apple.com/documentation/swift/codable) 🆚 [**HandyJSON**](https://github.com/alibaba/HandyJSON)
>
> ​	4.1、**Codable** 是苹果官方的，类型安全，但需要写 `CodingKeys`，代码量较大。适合 **严格的数据结构、编译期安全** 的项目。
>
> ​	4.2、**HandyJSON** 偏动态映射，更“自动化”，开发效率高，但类型安全性稍差（运行期做解析）。适合 **快速开发 / 需求变动大的场景**。
* 基本用法

  *  **JSON** ↔️ 模型

    定义模型

    ```swift
    import HandyJSON
    
    struct User: HandyJSON {
        var id: Int?
        var name: String?
        var age: Int?
    }
    ```

    JSON → 模型

    ```swift
    let json = "{\"id\":123, \"name\":\"Jobs\", \"age\":18}"
    if let user = User.deserialize(from: json) {
        print(user.name ?? "")  // 输出 "Jobs"
    }
    ```

    模型 → JSON

    ```swift
    let user = User(id: 123, name: "Jobs", age: 18)
    let jsonString = user.toJSONString()
    print(jsonString ?? "")
    ```
    
  * 枚举 + `HandyJSONEnum`： [**HandyJSON**](https://github.com/alibaba/HandyJSON) 对 **枚举序列化 / 反序列化** 的支持

    ```swift
    /**
     让枚举（必须是 原始值枚举，比如 Int 或 String）可以直接和 JSON 中的原始值互转。
     例如 JSON 返回 "status": 2，可以直接映射到 JXLoginStatus.normal_login。
     反过来，枚举转 JSON 时会自动输出原始值。
     */
    enum JXLoginStatus: Int, HandyJSONEnum {
        case didnot_login = 1
        case normal_login = 2
    }
    ```

  
  ### 2.3、[**SnapKit**](https://github.com/SnapKit/SnapKit)
  
  * 安装
  
    * Cocoapods
  
      ```ruby
      pod 'SnapKit'
      ```
  
    * Swift Package Manager
  
      > Xcode → File → Add Packages → 输入：
  
      ```
      https://github.com/SnapKit/SnapKit
      ```
    
  * 导入
  
    ```swift
    import SnapKit
    ```
  
  * 创建视图并添加约束
    
    > 先加后用
    
    ```swift
    let box = UIView()
    box.backgroundColor = .red
    view.addSubview(box)
    
    box.snp.makeConstraints { make in
        make.center.equalToSuperview()    // 居中
        make.width.height.equalTo(100)    // 宽高 = 100
    }
    ```
    
  * 常用约束写法
    
    * 相对父视图
    
      ```swift
      make.top.equalToSuperview().offset(20)      // 距离父视图顶部 20
      make.left.equalToSuperview().offset(15)     // 左边距 15
      make.right.equalToSuperview().inset(15)     // 右边距 15（inset = -offset）
      make.bottom.equalToSuperview().offset(-20)  // 底边距 20
      ```
    
    * 相对其它视图
    
      ```swift
      make.top.equalTo(titleLabel.snp.bottom).offset(10)  // 距离 titleLabel 底部 10
      make.left.equalTo(icon.snp.right).offset(8)         // 距离 icon 右边 8
      ```
    
    * 固定大小
    
      ```swift
      make.width.equalTo(120)
      make.height.equalTo(50)
      ```
    
    * 宽高比
    
      ```swift
      make.width.equalTo(view.snp.height).multipliedBy(0.5) // 宽 = 高 * 0.5
      ```
    
    * 居中
    
      ```swift
      make.center.equalToSuperview()     // 完全居中
      make.centerX.equalToSuperview()    // 横向居中
      make.centerY.equalToSuperview()    // 纵向居中
      ```
    
  * 更新 / 重新设置约束
    
    * 更新（`updateConstraints`）
    
      > 适合要修改部分约束的情况
    
      ```swift
      box.snp.updateConstraints { make in
          make.width.equalTo(200)   // 原来100 → 更新为200
      }
      ```
    
    * 重新设置（`remakeConstraints`）
    
      > 会先移除旧约束，再重新添加
    
      ```swift
      box.snp.remakeConstraints { make in
          make.center.equalToSuperview()
          make.size.equalTo(CGSize(width: 50, height: 50))
      }
      ```
    
  * 高级用法 
    
    * 优先级
    
      ```swift
      make.width.lessThanOrEqualTo(300).priority(.high)
      ```
    
    * SafeArea
    
      ```swift
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
      ```
    
    * 链式多条件
    
      ```swift
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15))
      ```
  
  ###  2.4、[**Alamofire**](https://github.com/Alamofire/Alamofire)
  
  
  
  



## 三、代码讲解 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1、⛓️链式调用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

* `UILabel`

  ```swift
  let label = UILabel()
     .byFont(.systemFont(ofSize: 16))
     .byTextColor(.black)
     .byText("目录".localized())
     .byTextAlignment(.center)
     .makeLabelByShowingType(.oneLineTruncatingTail)
     .bgImage(UIImage(named: "bg_pattern"))
     .byNextText(" → More")
  ```

* TODO

### 2、📏全局比例尺 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

* 实现

  ```swift
  import UIKit
  
  // MARK: - 核心比例器
  public enum JXScale {
      private static var designW: CGFloat = 375
      private static var designH: CGFloat = 812
      private static var useSafeArea: Bool = false
      
      public static func setup(designWidth: CGFloat, designHeight: CGFloat, useSafeArea: Bool = false) {
          self.designW = designWidth
          self.designH = designHeight
          self.useSafeArea = useSafeArea
      }
      
      private static var screenSize: CGSize {
          guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
              return UIScreen.main.bounds.size
          }
          if useSafeArea {
              let insets = window.safeAreaInsets
              return CGSize(
                  width: max(0, window.bounds.width - (insets.left + insets.right)),
                  height: max(0, window.bounds.height - (insets.top + insets.bottom))
              )
          } else {
              return window.bounds.size
          }
      }
      
      public static var x: CGFloat { screenSize.width / designW }
      public static var y: CGFloat { screenSize.height / designH }
  }
  
  // MARK: - 扩展 Int / CGFloat
  public extension BinaryInteger {
      var w: CGFloat { CGFloat(self) * JXScale.x }
      var h: CGFloat { CGFloat(self) * JXScale.y }
      var fz: CGFloat { CGFloat(self) * JXScale.x }   // 字体缩放，默认跟随 X
  }
  
  public extension BinaryFloatingPoint {
      var w: CGFloat { CGFloat(self) * JXScale.x }
      var h: CGFloat { CGFloat(self) * JXScale.y }
      var fz: CGFloat { CGFloat(self) * JXScale.x }
  }
  ```

* 入口配置

  ```swift
  import UIKit
  
  @main
  class AppDelegate: UIResponder, UIApplicationDelegate {
  
      func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {
          JXScale.setup(designWidth: 375, designHeight: 812, useSafeArea: false)
          return true
      }
  
      // MARK: UISceneSession Lifecycle
      func application(
          _ application: UIApplication,
          configurationForConnecting connectingSceneSession: UISceneSession,
          options: UIScene.ConnectionOptions
      ) -> UISceneConfiguration {
          return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
      }
  }
  ```

* 调用

  ```swift
  CGRect(x: 20.w, y: 100.h, width: 200.w, height: 40.h)
  ```

## 四、<font color=red>**F**</font> <font color=green>**A**</font> <font color=blue>**Q**</font> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1、注解

- `@available(...)` / `@unavailable(...)`

  > 控制平台/版本可用性、弃用信息

  ```swift
  @available(iOS 14, *) 
  func foo() {}
  
  @available(*, deprecated, message: "Use newFoo()")
  func oldFoo() {}
  
  @unavailable(iOS, message: "Not on iOS")
  func macOnly() {}

- `@main` 指定程序入口

  > 取代旧的 `@UIApplicationMain` / `@NSApplicationMain`

  ```swift
  @main
  struct AppMain {
    static func main() { /* ... */ }
  }
  ```

- `@inlinable` / `@usableFromInline`

  > 跨模块内联/符号可见性微控（发布库时常用）

  ```swift
  @inlinable public func add(_ a:Int,_ b:Int)->Int { a+b }
  @usableFromInline internal let cache = ...
  ```
  
- `@frozen`

  > 冻结 `enum` 的布局，保证 ABI 稳定（库作者用）

  ```swift
  @frozen public enum ColorSpace { case srgb, displayP3 }
  ```

- `@discardableResult`

  > 允许丢弃返回值（链式 API 常用）

  ```swift
  @discardableResult
  func setTitle(_ s:String) -> Self { /* ... */ return self }
  ```

- `@escaping`

  > 标记逃逸闭包参数

  ```swift
  func asyncOp(_ block: @escaping ()->Void) { /* store & call later */ }
  ```

- `@autoclosure`

  > 调用端可省略 `{}` 延迟求值

  ```swift
  func assert(_ cond: @autoclosure ()->Bool) {}
  assert(1 < 2)   // 等价于 { 1 < 2 }
  ```

- `@Sendable`

  > 并发安全闭包（跨 actor/线程）

  ```swift
  func run(_ job: @Sendable ()->Void) {}
  ```

- `@MainActor` / 自定义 `@globalActor`

  > 将函数/类型限定在主线程或某个 actor 上

  ```swift
  @MainActor
  class ViewModel {
    func updateUI() {}
  }
  ```

- `@preconcurrency`

  > 为旧接口提供向后兼容的并发注释（迁移期会见到）

- `@objc` / `@objcMembers` / `@nonobjc`

  > 暴露/隐藏给 Objective-C 运行时（Selector、KVC/KVO、IB 需要）

  ```swift
  @objcMembers class Foo: NSObject {
    func bar() {}          // 全部默认 @objc
    @nonobjc func swiftOnly() {}
  }
  ```

- `@warn_unqualified_access`

  > 未加类型前缀调用时产生警告，逼调用方加前缀，避免 API 名称冲突

  ```swift
  @warn_unqualified_access
  func ambiguous() {}
  ```

- `@dynamicMemberLookup` & `@dynamicCallable`

  > 让类型支持 `obj.someName` 动态解析或像函数一样被“调用”

  ```swift
  @dynamicMemberLookup
  struct JSON {
    subscript(dynamicMember key: String) -> JSON { /* ... */ JSON() }
  }
  ```

- `@resultBuilder`

  > SwiftUI 等 DSL 背后的机制。你用到的多是框架提供的具体 builder

  ```swift
  @resultBuilder
  struct HTMLBuilder { /* ... */ }
  ```

- `@testable import ModuleName`

  > 允许测试访问目标模块的 internal 成员

- `@IBAction` / `@IBOutlet`

  > 连接 storyboard/xib

  ```swift
  @IBAction func didTap(_ sender: UIButton) {}
  @IBOutlet weak var titleLabel: UILabel!
  ```

- `@IBInspectable` / `@IBDesignable`

  > 在 IB 可编辑/实时渲染自定义视图属性

  ```swift
  @IBDesignable
  class CardView: UIView {
    @IBInspectable var corner: CGFloat = 8
  }
  ```

- `@NSManaged`

  > Core Data 动态解析属性/方法（不需要自己实现存取器）

  ```swift
  class User: NSManagedObject {
    @NSManaged var name: String
  }
  ```

- `@NSCopying`

  > 属性赋值时自动拷贝（要求值类型实现 `NSCopying`）

  ```swift
  class Foo: NSObject {
    @NSCopying var path: NSString = ""
  }
  ```

- `@State` / `@Binding` / `@StateObject` / `@ObservedObject`/`@Environment` / `@EnvironmentObject`/`@AppStorage` / `@SceneStorage` / `@FocusState`

  ```swift
  struct Counter: View {
    @State private var count = 0
    var body: some View { Text("\(count)") }
  }
  ```

- `@Published`

  ```swift
  class VM: ObservableObject {
    @Published var name = ""
  }
  ```

- `@resultBuilder`

- `@ViewBuilder`

- `@SceneBuilder`

- `@ToolbarContentBuilder`

- `@CommandsBuilder`

- `@LibraryContentBuilder`




### 2、`joined()`

* 正常拼接

  ```Swift
  let words = ["Hello", "World", "Swift"]
  
  let sentence = words.joined()
  print(sentence)   // HelloWorldSwift
  ```

* 指定拼接时的分隔符

  ```Swift
  let words = ["Hello", "World", "Swift"]
  
  let sentence = words.joined(separator: " ")
  print(sentence)   // Hello World Swift
  ```

  



<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的👉点我回到首页</a>
