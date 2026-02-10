# 🚀 快速开始指南

这是一个5分钟快速开始指南,帮助你快速运行项目。

## ⚡ 最快路径

### 方法1: 使用Xcode(推荐)

```bash
# 1. 克隆或下载项目
cd AIPhotoClassifier

# 2. 打开Xcode
open -a Xcode

# 3. 在Xcode中:
#    File → New → Project → iOS → App
#    位置选择项目父目录,名称填: AIPhotoClassifier
#    选择Merge合并现有文件

# 4. 添加所有源文件到项目
#    右键项目 → Add Files to "AIPhotoClassifier"
#    选择所有文件夹并勾选 "Create groups"

# 5. 按 ⌘R 运行
```

### 方法2: 命令行创建项目(适合有经验的开发者)

```bash
# 注意: Xcode项目最好通过GUI创建
# 以下仅供参考,实际操作请使用Xcode

# 检查Xcode版本
xcodebuild -version

# 创建workspace(可选)
# 建议直接使用Xcode GUI
```

## 📋 前置检查清单

在开始之前,确保你有:

- ✅ macOS 13.0+
- ✅ Xcode 15.0+
- ✅ iOS 16.0+ 设备或模拟器
- ✅ 基本的Swift/SwiftUI知识
- ✅ 网络连接(用于AI功能)

## 🎯 核心文件说明

### 必读文件
1. **README.md** - 项目概述和功能介绍
2. **SETUP_GUIDE.md** - 详细设置步骤
3. **IMPLEMENTATION_NOTES.md** - 技术实现细节

### 关键代码文件
```
App/
  └── AIPhotoClassifierApp.swift  ← 应用入口点(@main)

Services/
  ├── ClaudeAPIService.swift      ← AI核心功能
  ├── AuthenticationService.swift ← Face ID认证
  └── EncryptionService.swift     ← 加密功能

Views/
  ├── MainTabView.swift           ← 主界面
  └── Auth/AuthenticationView.swift ← 登录界面
```

## 🔑 API密钥配置

**重要**: 当前API密钥硬编码在 `Utilities/Constants.swift` 中:

```swift
struct API {
    static let key = "sk-aDNu..." // ⚠️ 已硬编码
}
```

**生产环境建议**:
1. 使用环境变量
2. 创建Config.xcconfig文件(不提交到Git)
3. 使用后端代理服务

## 🏃‍♂️ 运行步骤

### 在模拟器中运行

1. **打开项目**
   ```bash
   open AIPhotoClassifier.xcodeproj
   ```

2. **选择模拟器**
   - 顶部选择: iPhone 14 Pro (或更新)
   - 确保选择iOS 16.0+

3. **运行项目**
   - 快捷键: `⌘R`
   - 或点击左上角播放按钮

4. **模拟Face ID**
   - `Features` → `Face ID` → `Enrolled`
   - `Features` → `Face ID` → `Matching Face`

### 在真机上运行

1. **连接设备**
   - USB连接iPhone
   - 信任电脑

2. **配置签名**
   - 项目设置 → Signing & Capabilities
   - 选择你的Team
   - 勾选 "Automatically manage signing"

3. **运行**
   - 选择你的设备
   - 按 `⌘R`
   - 首次运行需在设备上信任开发者

## 🧪 快速测试

### 测试认证功能
1. 启动应用
2. 应该看到Face ID认证界面
3. 模拟器: 菜单选择 Matching Face
4. 真机: 直接使用Face ID

### 测试图片上传
1. 进入主页
2. 点击右上角 `+` 按钮
3. 选择 "上传图片"
4. 选择几张测试图片
5. 等待AI分析(30-60秒)
6. 查看自动创建的收藏夹

### 测试AI聊天
1. 点击右下角悬浮按钮
2. 拖动测试是否可移动
3. 点击打开聊天界面
4. 发送消息测试

## ⚠️ 常见问题快速解决

### 编译错误
```
错误: Cannot find 'XXX' in scope
解决: 确保所有文件都添加到项目Target中
     右键文件 → Target Membership → 勾选AIPhotoClassifier
```

### Face ID不工作
```
模拟器: Features → Face ID → Enrolled
真机: 确保设备已设置Face ID
```

### 照片权限问题
```
Info.plist中添加:
NSPhotoLibraryUsageDescription
NSPhotoLibraryAddUsageDescription
```

### API调用失败
```
检查:
1. 网络连接
2. API密钥是否正确
3. 查看Xcode Console错误信息
```

## 📱 功能演示流程

### 完整用户流程(5分钟)

1. **启动** → Face ID认证
2. **主页** → 点击上传图片
3. **选择** → 选择5-10张不同类型照片
4. **等待** → AI自动分类(显示进度)
5. **查看** → 自动创建的收藏夹
6. **进入** → 点击收藏夹查看照片
7. **加密** → 设置收藏夹密码
8. **聊天** → 点击AI悬浮窗
9. **对话** → 测试AI回复

## 🎨 自定义配置

### 修改AI模型
```swift
// Constants.swift
struct API {
    static let model = "claude-haiku-4-5-20251001"
    // 改为: "claude-sonnet-4-5-20250929"
}
```

### 修改主题颜色
```swift
// Extensions.swift
extension Color {
    static let appPrimary = Color.blue    // 改为你喜欢的颜色
    static let appSecondary = Color.purple
}
```

### 修改回复字数限制
```swift
// Constants.swift
struct API {
    static let maxTokens = 300  // ~200字
    // 改为: 500 约350字
}
```

## 📊 项目状态检查

运行以下命令检查项目状态:

```bash
# 检查文件结构
find AIPhotoClassifier -name "*.swift" | wc -l
# 应该显示约20+个Swift文件

# 检查Git状态
git status

# 查看项目大小
du -sh AIPhotoClassifier
```

## 🔄 后续步骤

完成快速开始后:

1. ✅ 阅读 `SETUP_GUIDE.md` 了解详细配置
2. ✅ 阅读 `IMPLEMENTATION_NOTES.md` 理解架构
3. ✅ 查看代码注释学习实现细节
4. ✅ 尝试修改和扩展功能
5. ✅ 提交到自己的GitHub仓库

## 💡 开发技巧

### 使用Xcode快捷键
```
⌘B          - 构建
⌘R          - 运行
⌘.          - 停止
⌘/          - 注释/取消注释
⌘⇧F         - 全局搜索
⌘⌥[         - 上移代码行
⌘⌥]         - 下移代码行
```

### 启用SwiftUI预览
在View文件底部添加:
```swift
#Preview {
    YourView()
}
```

### 查看Console输出
- `⌘⇧Y` 打开/关闭控制台
- 查看print()输出和错误信息

## 🆘 需要帮助?

- 📖 查看 README.md
- 📘 查看 SETUP_GUIDE.md
- 📕 查看 IMPLEMENTATION_NOTES.md
- 🐛 提交GitHub Issue
- 💬 查看代码注释

## ✨ 完成!

如果你成功运行了应用并测试了基本功能,恭喜你!

接下来可以:
- 🔨 尝试修改UI
- 🎨 自定义主题
- 🚀 添加新功能
- 📦 打包发布

**祝你开发愉快!** 🎉
