# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

## 通过 Bundler 运行 CocoaPods 命令
## bundle exec pod update
#begin
#  require 'bundler/setup'
#  Bundler.setup(:default)
#  puts 'Bundler setup completed'
#  require 'cocoapods-downloader'
#  puts 'cocoapods-downloader plugin loaded'
#rescue LoadError => e
#  puts 'cocoapods-downloader plugin could not be loaded'
#  puts e.message
#end
#puts 'Podfile is being loaded...'
# 加速 CocoaPods 依赖下载的工具 https://github.com/CocoaPods/cocoapods-downloader
# 使用前提：gem install cocoapods-downloader
#plugin 'cocoapods-downloader', {
#  'https://github.com/CocoaPods/Specs.git' => [
#    'https://mirrors.aliyun.com/pods/specs.git',
#    'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git',
#    'https://mirrors.cloud.tencent.com/CocoaPods/Specs.git',
#    'https://mirrors.ustc.edu.cn/CocoaPods/Specs.git'
#  ]
#}

#plugin 'cocoapods-repo-update'

## 指明依赖库的来源地址
#source 'https://cdn.cocoapods.org/'
#source 'https://github.com/CocoaPods/Specs.git'# 使用官方默认地址（默认）
#source 'https://github.com/Artsy/Specs.git'# 使用其他来源地址

# 需要特别说明的：在 post_install 时，为了一些版本的兼容，需要遍历所有 target，调整一部分库的版本；但是如果开启了 generate_multiple_pod_projects 的话，由于项目结构的变化，installer.pod_targets 就没办法获得所有 pods 引入的 target 了
install! 'cocoapods',# install! 只走一次，多次使用只以最后一个标准执行
  :deterministic_uuids => false,# 【解决与私有库的冲突】用于控制生成的库的唯一标识符（UUID）是否是确定性的。UUID 是用于标识对象的唯一标识符，通常在构建软件时用于确保唯一性。当 deterministic_uuids 设置为 false 时，意味着 CocoaPods 将不会确保生成的库的 UUID 是确定性的。换句话说，每次构建时，生成的库的 UUID 可能会发生变化，即使源代码没有变化也可能如此。这可能会影响一些情况，例如在依赖库的版本控制方面。通常情况下，将 deterministic_uuids 设置为 true 会更安全，因为它可以确保每次构建生成的库都具有相同的 UUID，从而确保了可预测性和一致性。
  :generate_multiple_pod_projects => true,# ❤️可以让每个依赖都作为一个单独的项目引入（而不是文件夹的形式），大大增加了解析速度❤️；cocoapods 1.7 以后支持
  :disable_input_output_paths => true # 在 CocoaPods 中，disable_input_output_paths 是一个选项，用于控制是否禁用输入和输出路径。当设置为 true 时，这意味着 CocoaPods 将会禁用与输入和输出路径相关的功能或设置。通常情况下，禁用输入和输出路径可能会用于某些特定的构建环境或配置中，以确保在构建过程中不考虑或不使用指定的输入和输出路径。这可能是出于安全性、调试或其他特定需求的考虑。具体来说，当 disable_input_output_paths 设置为 true 时，可能会禁用与输入和输出路径相关的功能，例如对输入文件的读取、对输出文件的写入等操作。这样可以确保构建过程不受指定路径的影响。

platform :ios, '10.0'
inhibit_all_warnings!
# 用于指定你的 Pod 项目应使用静态库而不是动态库。
# 这个选项主要用于解决某些与动态库相关的兼容性和性能问题。
#use_frameworks! :linkage => :static

# 全局 modular headers（和 use_frameworks! 不能同时使用）
use_modular_headers!

# 几乎每个App都会用到的
def swiftAppCommon
  pod 'IQKeyboardManager' # https://github.com/hackiftekhar/IQKeyboardManager Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more.
  pod 'Alamofire' # https://github.com/Alamofire/Alamofire
  pod 'SDWebImage' # https://github.com/SDWebImage/SDWebImage
  pod 'GKNavigationBarSwift' # https://github.com/QuintGao/GKNavigationBarSwift
  pod 'ReactiveSwift' # https://github.com/ReactiveCocoa/ReactiveSwift
  pod 'lottie-ios' # https://github.com/airbnb/lottie-ios
  pod 'SnapKit' # https://github.com/SnapKit/SnapKit
  pod 'JXSegmentedView' # https://github.com/pujiaxin33/JXSegmentedView
  pod "HTMLReader" # https://github.com/nolanw/HTMLReader 处理 HTML 语法
  pod 'SDWebImage' # https://github.com/SDWebImage/SDWebImage
end
# 调试框架
def debugPods
# pod 'Bugly' # https://github.com/BuglyDevTeam 日志收集
# pod 'DoraemonKit' # https://github.com/didi/DoraemonKit 滴滴打车出的工具 NO_SMP
# pod 'CocoaDebug' # https://github.com/CocoaDebug/CocoaDebug NO_SMP
# pod 'FLEX'  # https://github.com/Flipboard/FLEX 调试界面相关插件 NO_SMP
# pod 'JJException' # https://github.com/jezzmemo/JJException 保护App,一般常见的问题不会导致闪退，增强App的健壮性，同时会将错误抛出来，根据每个App自身的日志渠道记录 NO_SMP
# pod 'FBRetainCycleDetector' # https://github.com/facebook/FBRetainCycleDetector
  #pod 'LookinServer', :configurations => ['Debug'] # https://lookin.work/
end

# 基础的公共配置
def cocoPodsConfig
  # ❤️新工程需要修改这里❤️
  target 'JobsSwiftBaseConfigDemoTests' do
    inherit! :search_paths # abstract! 指示当前的target是抽象的，因此不会直接链接Xcode target。与其相对应的是 inherit！
    # Pods for testing
  end
  # ❤️新工程需要修改这里❤️
  target 'JobsSwiftBaseConfigDemoUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  # 当我们下载完成，但是还没有安装之时，可以使用hook机制通过pre_install指定要做更改，更改完之后进入安装阶段。 格式如下：
  pre_install do |installer|
      # 做一些安装之前的更改
  end
  
  # 这个是cocoapods的一些配置,官网并没有太详细的说明,一般采取默认就好了,也就是不写.
  post_install do |installer|
    require 'open3'
    is_apple_silicon = false
    # 判断是否为 Apple Silicon
    stdout, _stderr, _status = Open3.capture3('uname -m')
    is_apple_silicon = stdout.strip == 'arm64'
    
    # 这段代码的作用是在 CocoaPods 安装完所有依赖库之后，遍历所有生成的 Xcode 项目的 targets，并为每个 target 设置特定的构建配置。
    # 具体来说，它在 post_install 钩子中执行，用于修改生成的项目的构建配置。
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
          # ✅ 只有 Apple Silicon 模拟器下才排除 arm64
          if is_apple_silicon
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
          end
        end
      end
    end
    # 遍历 CocoaPods 项目中的所有 targets，并为每个 target 设置特定的构建配置。
    # 具体来说，它是在 post_install 钩子中执行的，用于修改 Pods 项目的构建配置。
    installer.pods_project.targets.each do |target|
      # 用于在控制台输出每个 CocoaPods target 的名称。它通常放在 post_install 钩子中，用于调试或验证。
      puts "!!!! #{target.name}"
      # YTKNetwork 会集成 AFNetworking。而 AFNetworking 目前OC版本已经停更，且或许在某些场景下，需要修改 AFNetworking 源代码。
      # 所以，拉 YTKNetwork 的时候，需要排除 AFNetworking
#      if target.name == 'YTKNetwork'
#        target.dependencies.delete_if { |dependency| dependency.name == 'AFNetworking' }
#      end
      
      # 有时候，在 Podfile 中没有明确指定最低支持的 iOS 版本时，某些 Pods 可能默认使用较低版本的 IPHONEOS_DEPLOYMENT_TARGET。
      # 这可能导致构建时出现兼容性问题或警告。
      # 因此，通过在 post_install 钩子中统一设置所有 Pods 的 IPHONEOS_DEPLOYMENT_TARGET，可以确保所有依赖库使用一致的最低 iOS 版本，减少潜在的兼容性问题。
      # 在 CocoaPods 安装完所有依赖库之后，遍历每个 target 的构建配置，并将 IPHONEOS_DEPLOYMENT_TARGET 设置为 13.0。
      # 具体来说，它是在 post_install 钩子中执行的，这意味着它会在所有 Pods 安装完成之后、写入 Xcode 项目之前被调用。
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        # ✅ 只有 Apple Silicon 模拟器下才排除 arm64
        if is_apple_silicon
          config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
      end
    end
    # 这段代码的作用是在 CocoaPods 安装完所有依赖库之后，遍历 Pods 项目的所有构建配置，并设置 EXCLUDED_ARCHS 构建设置，以排除 arm64 架构。
    # 这通常是为了解决在模拟器上构建项目时遇到的 arm64 架构兼容性问题。
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      # ✅ 只有 Apple Silicon 模拟器下才排除 arm64
      if is_apple_silicon
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
  end
end
# ❤️新工程需要修改这里❤️
target 'JobsSwiftBaseConfigDemo' do
  # Pods for JobsSwiftBaseConfigDemo
  debugPods # 调试框架
  swiftAppCommon # 几乎每个App都会用到的
  cocoPodsConfig # 基础的公共配置
end
