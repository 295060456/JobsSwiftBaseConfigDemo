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

## 二、👥第三方 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1、第三方管理 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

* **Mac OS 15** 以后，苹果采取了更加严格的权限写入机制。新**swift**项目如果要利用[**`Cocoapod`**](https://cocoapods.org/)来集成第三方，就比如在**xcode**里面做如下设置，否则编译失败：`TARGETS`->`Build Settings`->`ENABLE_USER_SCRIPT_SANDBOXING`-><font color=red>`NO`</font>

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

#### 2.1、[**DeviceKit**](https://github.com/devicekit/DeviceKit) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

#### 2.2、[**HandyJSON**](https://github.com/alibaba/HandyJSON) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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

#### 2.3、[**SnapKit**](https://github.com/SnapKit/SnapKit) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

  * 安装
  
    * Cocoapods
    
      > 在 `Podfile` 中添加：
    
      ```ruby
      pod 'SnapKit'
      ```
    
    * Swift Package Manager
    
      > Xcode → File → Add Packages Dependency → 输入：
    
      ```url
      https://github.com/SnapKit/SnapKit
      ```
    
  * 导入
  
    ```swift
    import SnapKit
    ```
  
  * 调用
    
    * 创建视图并添加约束
    
      > 先加后用
      >
      > ```swift
      > let box = UIView()
      > box.backgroundColor = .red
      > view.addSubview(box)
      > 
      > box.snp.makeConstraints { make in
      >     make.center.equalToSuperview()    // 居中
      >     make.width.height.equalTo(100)    // 宽高 = 100
      > }
      > ```
    
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
    
      * 更新约束（`updateConstraints`）

        > 适合要修改部分约束的情况

        ```swift
        box.snp.updateConstraints { make in
            make.width.equalTo(200)   // 原来100 → 更新为200
        }
        ```

      * 重新设置约束（`remakeConstraints`）

        > 会先移除旧约束，再重新添加

        ```swift
        box.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        ```
      
      * 高级用法@优先级

        ```swift
        make.width.lessThanOrEqualTo(300).priority(.high)
        ```

      * 高级用法@SafeArea

        ```swift
        make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        ```

      * 高级用法@链式多条件

        ```swift
        make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15))
        ```

#### 2.4、[**Alamofire**](https://github.com/Alamofire/Alamofire) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> **Alamofire** 是 Swift 社区最流行的 **网络请求库**，基于 **URLSession** 封装，简化了 HTTP 请求、响应处理、JSON 解析、文件上传下载等操作。
>  它的特点是：
>
> - 语法简洁，链式调用
> - 内置 JSON/Plist 参数编码与解析
> - 支持上传/下载（含进度回调）
> - 支持认证（Basic Auth、OAuth Bearer Token 等）
> - 集成了网络请求队列、响应序列化、错误处理等常见功能
>
> 在 iOS 开发中，它相当于 Objective-C 时代的 **AFNetworking** 的 Swift 替代。

* 安装
  
    * CocoaPods
    
      > 在 `Podfile` 中添加：
    
      ```ruby
      pod 'Alamofire'
      ```
    
    * Swift Package Manager
    
      > Xcode → File → Add Packages Dependency → 输入：
    
      ```url
      https://github.com/Alamofire/Alamofire.git
      ```
    
* 导入
  
    ```swift
  import Alamofire
  ```
  
* 调用
  
    * GET 请求
    
      ```swift
      import Alamofire
      
      AF.request("https://api.example.com/users").response { response in
          debugPrint(response)
      }
      ```
    
    * GET + JSON 解析
    
      ```swift
      AF.request("https://api.example.com/users")
          .responseJSON { response in
              switch response.result {
              case .success(let value):
                  print("返回 JSON: \(value)")
              case .failure(let error):
                  print("请求失败: \(error)")
              }
          }
      ```
    
    * POST 请求（带参数）
    
      ```swift
      let params: [String: Any] = [
          "username": "jobs",
          "password": "123456"
      ]
      
      AF.request("https://api.example.com/login",
                 method: .post,
                 parameters: params,
                 encoding: JSONEncoding.default)
          .responseJSON { response in
              print(response)
          }
      ```
    
    * 文件上传
    
      ```swift
      AF.upload(multipartFormData: { formData in
          formData.append(Data("jobs".utf8), withName: "username")
          formData.append(URL(fileURLWithPath: "/path/to/file.png"), withName: "file")
      }, to: "https://api.example.com/upload")
      .responseJSON { response in
          print(response)
      }
      ```
    
    * 文件下载
    
      ```swift
      let destination: DownloadRequest.Destination = { _, _ in
          let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
          let fileURL = documentsURL.appendingPathComponent("file.zip")
      
          return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
      }
      
      AF.download("https://example.com/file.zip", to: destination)
          .downloadProgress { progress in
              print("下载进度: \(progress.fractionCompleted)")
          }
          .response { response in
              print("下载完成: \(response.fileURL)")
          }
      
      ```
    
    * 全局配置（比如统一 Header、超时设置）
    
      ```swift
      let configuration = URLSessionConfiguration.default
      configuration.timeoutIntervalForRequest = 30
      
      let session = Session(configuration: configuration)
      
      session.request("https://api.example.com/data").responseJSON { response in
          print(response)
      }
      ```
    
    * 链式调用
    
      ```swift
      AF.request("https://api.example.com/user")
          .validate(statusCode: 200..<300)
          .responseDecodable(of: User.self) { response in
              switch response.result {
              case .success(let user):
                  print("用户数据: \(user)")
              case .failure(let error):
                  print("错误: \(error)")
              }
          }

#### 2.5、[**Moya**](https://github.com/Moya/Moya) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> - **定位**：[**Moya**](https://github.com/Moya/Moya) 是一个 **网络抽象层**（Networking Abstraction Layer）。
> - **底层**：它基于 [**Alamofire**](https://github.com/Alamofire/Alamofire) 实现请求发送，但对业务开发者屏蔽了繁琐的配置。
> - **核心思想**：用 **枚举（enum）+ 协议（TargetType）** 来定义接口。
>
> 这样做的好处：
>
> 1. **接口集中管理**：所有 API 路径、参数、请求方式写在一个地方，清晰可维护。
> 2. **避免魔法字符串**：不需要在代码里到处拼接 URL、HTTP 方法。
> 3. **更适合多人协作**：规范化 API 层，降低出错率。

* 安装
  
    * CocoaPods
    
      > 在 `Podfile` 中添加：
    
      ```ruby
      pod 'Moya'
      ```
    
    * Swift Package Manager
    
      > Xcode → File → Add Packages Dependency → 输入：
    
      ```url
      https://github.com/Moya/Moya.git
      ```
    
* 导入
  
    ```swift
  import Moya
  ```

* 调用

  * 定义 API 枚举

    ```swift
    enum MyService {
        case getUser(id: Int)
        case createUser(name: String, age: Int)
    }
    
    // 遵循 TargetType 协议
    extension MyService: TargetType {
        var baseURL: URL { URL(string: "https://api.example.com")! }
    
        var path: String {
            switch self {
            case .getUser(let id):
                return "/user/\(id)"
            case .createUser:
                return "/user"
            }
        }
    
        var method: Moya.Method {
            switch self {
            case .getUser:
                return .get
            case .createUser:
                return .post
            }
        }
    
        var task: Task {
            switch self {
            case .getUser:
                return .requestPlain
            case .createUser(let name, let age):
                return .requestParameters(parameters: ["name": name, "age": age],
                                          encoding: JSONEncoding.default)
            }
        }
    
        var headers: [String: String]? {
            ["Content-Type": "application/json"]
        }
    }
    ```

  * 创建 Provider

    ```swift
    let provider = MoyaProvider<MyService>()
    ```

  * 发送请求

    ```swift
    // GET
    provider.request(.getUser(id: 1)) { result in
        switch result {
        case .success(let response):
            print("返回: \(response.data)")
        case .failure(let error):
            print("错误: \(error)")
        }
    }
    
    // POST
    provider.request(.createUser(name: "Jobs", age: 18)) { result in
        switch result {
        case .success(let response):
            print("创建成功: \(response.data)")
        case .failure(let error):
            print("失败: \(error)")
        }
    }
    ```

  * 插件机制（可以拦截请求/响应，例如统一打印日志、添加 token）

    ```swift
    final class NetworkLogger: PluginType {
        func willSend(_ request: RequestType, target: TargetType) {
            print("➡️ 请求: \(request.request?.url?.absoluteString ?? "")")
        }
    
        func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
            print("⬅️ 响应: \(result)")
        }
    }
    
    let provider = MoyaProvider<MyService>(plugins: [NetworkLogger()])
    ```

  * 响应模型解析

    ```swift
    provider.request(.getUser(id: 1)) { result in
        switch result {
        case .success(let response):
            do {
                let user = try JSONDecoder().decode(User.self, from: response.data)
                print("用户: \(user)")
            } catch {
                print("解析失败: \(error)")
            }
        case .failure(let error):
            print("请求错误: \(error)")
        }
    }
    ```

  * **Stub（模拟数据）**：适合写单元测试或本地开发

    ```swift
    let stubProvider = MoyaProvider<MyService>(stubClosure: MoyaProvider.immediatelyStub)
    stubProvider.request(.getUser(id: 1)) { result in
        print(result)
    }
    ```

#### 2.6、[**RxSwift**](https://github.com/ReactiveX/RxSwift) <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> **最小依赖**：只用 `RxSwift`。
>
> **MVVM 开发**：通常 `RxSwift + RxCocoa + RxRelay` 一起用。
>
> ✅ **优点**
>
> - 统一事件流（UI、网络、通知、定时器等）
> - 代码声明式，可读性好
> - 天然适合 MVVM 架构
>
> ⚠️ **缺点**
>
> - 学习曲线陡峭（操作符多）
> - 调试不直观（需要习惯事件流思维）
> - 不注意释放可能导致 **内存泄漏**

* 安装
  
    * CocoaPods
    
      > 在 `Podfile` 中添加：
    
      ```ruby
      # 核心库
      pod 'RxSwift', # 核心
      pod 'RxCocoa', # UI 绑定：UIKit、AppKit 的扩展
      pod 'RxRelay', # 安全替代 Variable，常用于 ViewModel
      ```
    
    * Swift Package Manager
    
      > Xcode → File → Add Packages Dependency → 输入：
    
      ```url
      https://github.com/ReactiveX/RxSwift.git
      ```
    
* 导入
  
    ```swift
  import RxSwift    // 核心 Observable / Observer / Disposable
  import RxCocoa    // UI 控件绑定（如 textField.rx.text、button.rx.tap）
  import RxRelay    // BehaviorRelay / PublishRelay
  ```
  
* 调用
  
    > **按钮**：`tap.throttle + withLatestFrom(最新输入)`
  >
  > **输入**：`debounce + distinctUntilChanged + filter`
  >
  > **UI 绑定**：尽量用 `Driver/Signal`（主线程、无 error、共享）
  >
  > **监听**：`NotificationCenter.default.rx.notification(name[, object])`
  >
  > **解析**：`compactMap` 安全取 `userInfo`
  >
  > **性能**：`debounce/throttle/distinctUntilChanged/share(replay:)`
  >
  > **释放**：`disposed(by: bag)` 即可，无需 `removeObserver`
  
  * 按钮防连点（节流）
  
    ```swift
    loginBtn.rx.tap
        .throttle(.milliseconds(500), scheduler: MainScheduler.instance) // 500ms 内只认第一次
        .withLatestFrom(Observable.combineLatest(vm.username, vm.password)) // 点一下带最新输入
        .subscribe(onNext: { (u, p) in
            // do login(u, p)
        })
        .disposed(by: bag)
    ```
  
  * 输入框实时校验（长度/邮箱等）
  
    ```swift
    let usernameValid = usernameTF.rx.text.orEmpty
        .map { $0.count >= 3 }
        .distinctUntilChanged()
        .share(replay: 1)
    
    let passwordValid = passwordTF.rx.text.orEmpty
        .map { $0.count >= 6 }
        .distinctUntilChanged()
        .share(replay: 1)
    
    // 邮箱示例（可选）
    let emailValid = usernameTF.rx.text.orEmpty
        .map { text in
            let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
            return text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        }
        .share(replay: 1)
    ```
  
  * 启用按钮 + 视觉态
  
    ```swift
    Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
        .bind(to: loginBtn.rx.isEnabled)
        .disposed(by: bag)
    
    Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
        .map { $0 ? 1.0 : 0.5 }
        .bind(to: loginBtn.rx.alpha)
        .disposed(by: bag)
    ```
  
  * 搜索输入：去抖 + 去重 + 非空
  
    ```swift
    let searchText = searchTF.rx.text.orEmpty
        .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 停止输入300ms再发
        .distinctUntilChanged()
        .filter { !$0.isEmpty } // 过滤空串
        .share(replay: 1)
    
    searchText
        .subscribe(onNext: { query in
            // fire search(query)
        })
        .disposed(by: bag)
    ```
  
  * 限制最大长度（回写 UI）
  
    ```swift
    let limitedPwd = passwordTF.rx.text.orEmpty
        .map { String($0.prefix(20)) } // 最多 20 位
        .share(replay: 1)
    
    limitedPwd
        .bind(to: passwordTF.rx.text)
        .disposed(by: bag)
    ```
  
  * Return 键行为（下一步 / 提交）
  
    ```swift
    // 用户名回车 -> 焦点移到密码
    usernameTF.rx.controlEvent(.editingDidEndOnExit)
        .subscribe(onNext: { [weak self] in self?.passwordTF.becomeFirstResponder() })
        .disposed(by: bag)
    
    // 密码回车 -> 触发登录（带最新输入）
    passwordTF.rx.controlEvent(.editingDidEndOnExit)
        .withLatestFrom(Observable.combineLatest(vm.username, vm.password))
        .subscribe(onNext: { (u, p) in
            // do login(u, p)
        })
        .disposed(by: bag)
    ```
  
  * 用 Driver 做 UI 绑定（推荐）
  
    ```swift
    let canLogin = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
        .asDriver(onErrorJustReturn: false)
    
    canLogin
        .drive(loginBtn.rx.isEnabled)
        .disposed(by: bag)
    
    canLogin
        .map { $0 ? 1.0 : 0.5 }
        .drive(loginBtn.rx.alpha)
        .disposed(by: bag)
    ```
  
  * 实战最小组合（按钮点击 + 最新值 + 节流）
  
    ```swift
    let creds = Observable.combineLatest(usernameTF.rx.text.orEmpty,
                                         passwordTF.rx.text.orEmpty) { ($0, $1) }
        .share(replay: 1)
    
    loginBtn.rx.tap
        .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
        .withLatestFrom(creds)
        .subscribe(onNext: { (u, p) in
            // do login(u, p)
        })
        .disposed(by: bag)
    ```
  
  * 监听系统通知（NotificationCenter → Rx）
  
    ```swift
    import RxSwift
    import RxCocoa
    
    let bag = DisposeBag()
    
    NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
        .subscribe(onNext: { _ in
            print("app 回到前台")
        })
        .disposed(by: bag)
    ```
  
  * 监听 + 取 `userInfo`（安全解包）
  
    ```swift
    extension Notification.Name {
        static let loginStateChanged = Notification.Name("loginStateChanged")
    }
    
    // 监听
    NotificationCenter.default.rx.notification(.loginStateChanged)
        .compactMap { $0.userInfo?["isLogin"] as? Bool }
        .distinctUntilChanged()
        .subscribe(onNext: { isLogin in
            print("登录态：\(isLogin)")
        })
        .disposed(by: bag)
    
    // 发送
    NotificationCenter.default.post(name: .loginStateChanged, object: nil, userInfo: ["isLogin": true])
    ```
  
  * 键盘通知：拿高度 & 动画时长（实战常用）
  
    ```swift
    let willChange = NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
    
    let keyboardInfo = willChange
        .compactMap { note -> (height: CGFloat, duration: TimeInterval) in
            let endFrame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
            return (height: endFrame.height, duration: duration)
        }
        .share(replay: 1)
    
    keyboardInfo
        .subscribe(onNext: { info in
            // 调整底部约束 / contentInset
            // self.bottomConstraint.constant = info.height
            // UIView.animate(withDuration: info.duration) { self.view.layoutIfNeeded() }
        })
        .disposed(by: bag)
    ```
  
  * 搭配 `Driver`（主线程、无 error，用于驱动 UI）
  
    ```swift
    let becameActiveDriver: Driver<Void> =
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .asDriver(onErrorDriveWith: .empty())
    
    becameActiveDriver
        .drive(onNext: { print("刷新 UI") })
        .disposed(by: bag)
    ```
  
  * 过滤指定对象的通知（`object:`）
  
    ```swift
    let object = someObject
    
    NotificationCenter.default.rx.notification(.someName, object: object)
        .subscribe(onNext: { _ in print("只响应这个 object 的通知") })
        .disposed(by: bag)
    ```
  
  * throttle / debounce（通知风暴去抖）
  
    ```swift
    NotificationCenter.default.rx.notification(.NSManagedObjectContextDidSave)
        .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
        .subscribe(onNext: { _ in
            // 合并短时间内的多次变更
        })
        .disposed(by: bag)
    ```
  
  * 生命周期通知（常用清单）
  
    ```swift
    NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
    NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
    NotificationCenter.default.rx.notification(UIApplication.didReceiveMemoryWarningNotification)
    ```
  
  * 通知更适合**跨模块/系统级广播**；模块内通信优先 `Relay/Subject`。
  
    > **同模块/同层内**传播事件：用 `PublishRelay` / `BehaviorRelay` 比通知更类型安全、可测试。
  
    ```swift
    let evt = PublishRelay<Void>()
    evt.accept(())          // 发送
    evt.asSignal()          // 给 UI 绑定
    ```
  
    

## 三、💻代码讲解 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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

* `UIBUtton`

* `UITableView`

* `UICollectionView`

* `UIImageView`

* 

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

### 3、避免从 XIB/Storyboard 初始化 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```swift
required init?(coder: NSCoder) {
    fatalError()
}
```



## 四、<font color=red>**F**</font> <font color=green>**A**</font> <font color=blue>**Q**</font> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1、注解 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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

- `@unchecked`

  > 它是 **[Swift](https://developer.apple.com/swift/) 的一个属性修饰符**，目前主要和 **协议 `Sendable`** 结合使用
  >
  > 本质就是 [**Swift**](https://developer.apple.com/swift/) 提供的一个 **安全逃生口**

  ```swift
  /// 跳过编译器的并发安全检查，由开发者自己保证。
  @unchecked Sendable
  ```

  * 背景：并发安全检查

    > 从 [**Swift**](https://developer.apple.com/swift/) 5.5 引入并发（`async/await`、`Task` 等）开始，苹果为了防止 **数据竞争**，提出了一个协议：
    >
    > ```swift
    > protocol Sendable { }
    > ```
    >
    > 一个类型如果要在 **多线程 / 并发任务** 中安全传递，就必须是 `Sendable`
    >
    > - 值类型（`struct`，内部全是 `Sendable` 成员） → 自动符合 `Sendable`。
    > - 引用类型（`class`） → 默认 **不是 `Sendable`**，因为引用可能被多线程同时访问，造成数据竞争。

- `@resultBuilder`

- `@ViewBuilder`

- `@SceneBuilder`

- `@ToolbarContentBuilder`

- `@CommandsBuilder`

- `@LibraryContentBuilder`


### 2、`joined()` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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
