# ================================== Podfile ==================================
# 统一统计开关：关掉 CocoaPods 统计上报
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# iOS 最低系统版本
platform :ios, '13.0'

# CocoaPods 源
source 'https://cdn.cocoapods.org/'

# 统一使用静态库，避免一堆动态库/符号冲突
use_frameworks! :linkage => :static

# 压制三方库的编译警告，自己仓库想要严格可以单独开
inhibit_all_warnings!

# ================================== 公共方法区域 ==================================
# 预留一个钩子，给 Podfile.deps 里的 target 调用
# 你之前在 Podfile.deps 里写了 cocoPodsConfig；即使它现在是空的，也先声明避免报错
def cocoPodsConfig
  # 你可以在这里面后续加：
  # pod 'xxx'
  # 或者自定义 script phases 等
end

# ================================== 加载拆分出来的依赖定义 ==================================
# 这里我们固定认为你把大块内容（swiftAppCommon、debugPods、target ...）放在同目录下的 Podfile.deps
deps_path = File.join(__dir__, 'Podfile.deps')

unless File.exist?(deps_path)
  raise "[Podfile] ❌ 找不到 #{deps_path}，请确认 Podfile.deps 存在于工程根目录"
end

# 把 Podfile.deps 里的内容直接在当前上下文执行
# 这样里面的 def swiftAppCommon / def debugPods / target ... 都会生效
instance_eval(File.read(deps_path), deps_path, 1)

# ================================== post_install 钩子 ==================================
post_install do |installer|
  # -------- 1. 宿主 App 工程 build settings 统一修正 --------
  # aggregate_targets = “宿主工程里每个使用 Pod 的 target 的聚合 target”
  installer.aggregate_targets.each do |agg|
    user_project = agg.user_project

    user_project.native_targets.each do |t|
      t.build_configurations.each do |config|
        # 统一关闭 ENABLE_USER_SCRIPT_SANDBOXING
        # 规避运行脚本阶段被沙箱拦截的问题
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'

        # 强行统一最低系统版本，别让有的 target 自己掉到 12 / 11
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end

    # 保存宿主工程 .xcodeproj
    user_project.save
  end

  # -------- 2. Pods 工程也统一最低版本，避免第三方自己写了更低导致报 deprecated API / 编译警告 --------
  pods_project = installer.pods_project
  pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end

  # -------- 3. 把 Podfile.deps 显示到 Xcode 的 Pods 分组里，并强制识别成 Ruby --------
  main_group   = pods_project.main_group
  deps_relpath = '../Podfile.deps' # 这是相对 Pods.xcodeproj 的路径

  # 3.1 新建或复用文件引用
  file_ref = main_group.find_file_by_path(deps_relpath)
  unless file_ref
    file_ref = main_group.new_file(deps_relpath)
  end

  # 3.2 关键：告诉 Xcode 这个其实是 Ruby 脚本，不是普通 txt
  # 这样它会走 Ruby 的语法高亮（关键字变红）
  if file_ref.respond_to?(:explicit_file_type=)
    file_ref.explicit_file_type = 'text.script.ruby'
    # 等价 fileRef.setExplicitFileType_ 在旧 API，下同
  end

  # 3.3 保存 Pods 工程
  pods_project.save
end
