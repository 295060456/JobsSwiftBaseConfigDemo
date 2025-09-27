# Uncomment the next line to define a global platform for your project
# ❤️TARGETS->Build Settings->ENABLE_USER_SCRIPT_SANDBOXING->NO❤️
platform :ios, '13.0'   # ❤️ 顶层直接设 13.0，和 post_install 保持一致

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
  :deterministic_uuids => false,
  # ❤️ 暂时关掉 generate_multiple_pod_projects，避免 SnapKit 等 Swift-only 库 slice 异常
  # :generate_multiple_pod_projects => true,
  :disable_input_output_paths => true

inhibit_all_warnings!
# 用于指定你的 Pod 项目应使用静态库而不是动态库。
# 这个选项主要用于解决某些与动态库相关的兼容性和性能问题。
use_frameworks! :linkage => :static

# 全局 modular headers（和 use_frameworks! 不能同时使用）
#use_modular_headers!

# 几乎每个App都会用到的
def swiftAppCommon
  pod 'IQKeyboardManager'
  pod 'Alamofire', '~> 5.9'      # ❤️ 显式指定新版本
  pod 'Moya', :modular_headers => true
  pod 'SDWebImage'
  pod 'GKNavigationBarSwift'
  pod 'ReactiveSwift', '~> 6.7'  # ❤️ 新版本支持 arm64 模拟器
  pod 'lottie-ios'
  pod 'SnapKit', '~> 5.7'        # ❤️ 新版本支持 arm64 模拟器
  pod 'JXSegmentedView'
  pod "HTMLReader"
  pod 'KakaJSON'
  pod 'RxSwift'                  # 核心
  pod 'RxCocoa'                  # UI 绑定：UIKit、AppKit 的扩展
  pod 'RxRelay'                  # 安全替代 Variable，常用于 ViewModel
  pod 'NSObject+Rx'
end

# 调试框架
def debugPods
# pod 'Bugly'
# pod 'DoraemonKit'
# pod 'CocoaDebug'
# pod 'FLEX'
# pod 'JJException'
# pod 'FBRetainCycleDetector'
  #pod 'LookinServer', :configurations => ['Debug']
end

# 基础的公共配置
def cocoPodsConfig
  target 'JobsSwiftBaseConfigDemoTests' do
    inherit! :search_paths
  end
  target 'JobsSwiftBaseConfigDemoUITests' do
    inherit! :search_paths
  end

  pre_install do |installer|
    # 做一些安装之前的更改
  end

  post_install do |installer|
    require 'open3'
    is_apple_silicon = `uname -m`.strip == 'arm64'

    installer.pods_project.targets.each do |target|
      puts "!!!! #{target.name}"
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        # ✅ 只有 Apple Silicon 模拟器下才排除 arm64
        # ❗️改为：不排除（删除可能被其他地方写入的排除项），保证生成 arm64-apple-ios-simulator slice
        if is_apple_silicon
          config.build_settings.delete('EXCLUDED_ARCHS[sdk=iphonesimulator*]')  # ❤️ 关键修改
        end
      end
    end

    installer.pods_project.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      # ❗️同理：不排除 arm64 模拟器
      if is_apple_silicon
        config.build_settings.delete('EXCLUDED_ARCHS[sdk=iphonesimulator*]')    # ❤️ 关键修改
      end
    end
  end
end

# ❤️新工程需要修改这里❤️
target 'JobsSwiftBaseConfigDemo' do
  debugPods
  swiftAppCommon
  cocoPodsConfig
end
