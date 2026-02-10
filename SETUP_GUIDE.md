# AI Photo Classifier - 设置指南

## 📝 项目创建步骤

由于Xcode项目文件(.xcodeproj)是二进制格式且非常复杂,需要通过Xcode GUI创建。请按以下步骤操作:

### 第一步: 创建Xcode项目

1. **打开Xcode**
   - 启动Xcode 15.0或更高版本

2. **创建新项目**
   - 选择 `File` > `New` > `Project`
   - 选择 `iOS` > `App`
   - 点击 `Next`

3. **配置项目**
   ```
   Product Name: AIPhotoClassifier
   Team: 选择你的开发团队(或None)
   Organization Identifier: com.aiphoto
   Bundle Identifier: com.aiphoto.classifier
   Interface: SwiftUI
   Language: Swift
   Storage: None (我们会手动使用Core Data)
   勾选: Include Tests (可选)
   ```
   - 点击 `Next`

4. **选择保存位置**
   - 浏览到已经存在的项目文件夹
   - **重要**: 选择 `AIPhotoClassifier` 文件夹的**父目录**
   - Xcode会提示该文件夹已存在,选择 `Merge` 合并

### 第二步: 配置项目文件

1. **删除Xcode自动创建的文件**
   - 删除 `ContentView.swift` (我们已有自己的Views)
   - 删除自动创建的 `AIPhotoClassifierApp.swift` (如果重复)
   - 保留 `Assets.xcassets`

2. **添加现有文件到项目**
   - 在Project Navigator中右键点击 `AIPhotoClassifier` 组
   - 选择 `Add Files to "AIPhotoClassifier"...`
   - 选择以下文件夹(勾选 "Create groups"):
     ```
     ✓ App/
     ✓ Models/
     ✓ Services/
     ✓ Views/
     ✓ ViewModels/
     ✓ Utilities/
     ```
   - 确保勾选 "Copy items if needed"
   - 点击 `Add`

3. **配置Info.plist**
   - 在Project Navigator中找到 `Info.plist`
   - 如果Xcode自动创建了新的,删除它
   - 添加我们的 `Resources/Info.plist`:
     - 右键 `AIPhotoClassifier` > `Add Files...`
     - 选择 `AIPhotoClassifier/Resources/Info.plist`
   - 或者在项目设置中手动添加以下权限:
     ```
     Privacy - Face ID Usage Description
     Privacy - Photo Library Usage Description
     Privacy - Photo Library Additions Usage Description
     ```

4. **配置项目设置**
   - 点击项目根节点 `AIPhotoClassifier`
   - 选择 `TARGETS` > `AIPhotoClassifier`

   **General设置**:
   ```
   Display Name: AI Photo Classifier
   Bundle Identifier: com.aiphoto.classifier
   Version: 1.0.0
   Build: 1
   Minimum Deployments: iOS 16.0
   ```

   **Signing & Capabilities**:
   ```
   - 勾选 "Automatically manage signing"
   - 选择你的Team
   - 或者取消自动签名用于开发
   ```

   **Build Settings**:
   ```
   - Swift Language Version: Swift 5
   - iOS Deployment Target: 16.0
   ```

   **Info**:
   - 确保 Custom iOS Target Properties 指向正确的Info.plist

5. **添加Capabilities**
   - 在 `Signing & Capabilities` 标签
   - 点击 `+ Capability`
   - 添加以下能力:
     - ☑️ **Keychain Sharing** (用于加密密钥存储)
     - ☑️ **Background Modes** (可选,用于后台任务)

### 第三步: 验证项目结构

确保Project Navigator中的文件结构如下:

```
AIPhotoClassifier/
├── AIPhotoClassifier/
│   ├── App/
│   │   └── AIPhotoClassifierApp.swift
│   ├── Models/
│   │   ├── Photo.swift
│   │   ├── Album.swift
│   │   └── AIMessage.swift
│   ├── Services/
│   │   ├── ClaudeAPIService.swift
│   │   ├── EncryptionService.swift
│   │   ├── AuthenticationService.swift
│   │   ├── StorageService.swift
│   │   └── ImageClassificationService.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── Home/
│   │   ├── Profile/
│   │   ├── AIChat/
│   │   └── Auth/
│   ├── ViewModels/
│   ├── Utilities/
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── Info.plist
│   └── Preview Content/
├── AIPhotoClassifierTests/ (可选)
└── AIPhotoClassifier.xcodeproj
```

### 第四步: 配置App Entry Point

1. **设置主App文件**
   - 打开 `AIPhotoClassifierApp.swift`
   - 确保有 `@main` 标记
   - 项目设置中 `General` > `Main Interface` 应该为空(SwiftUI不需要)

2. **配置Asset Catalog**
   - 在 `Assets.xcassets` 中可以添加:
     - App Icon (1024x1024)
     - 颜色集
     - 图片资源

### 第五步: 构建和运行

1. **选择模拟器**
   - 在Xcode顶部选择目标设备
   - 推荐: iPhone 14 Pro 或更新(支持Face ID)

2. **构建项目**
   ```
   快捷键: ⌘B (Command + B)
   ```
   - 检查是否有编译错误
   - 解决所有警告和错误

3. **运行项目**
   ```
   快捷键: ⌘R (Command + R)
   ```
   - 首次运行需要授权照片访问
   - 模拟器中Face ID需要在菜单中模拟

### 第六步: 真机测试(可选)

1. **连接iOS设备**
   - 使用USB线连接iPhone
   - 在设备上信任此电脑

2. **配置签名**
   - 在Xcode中选择你的Team
   - 确保Bundle ID唯一

3. **运行到真机**
   - 选择连接的设备
   - 点击运行
   - 首次运行需要在设备上信任开发者

4. **测试Face ID**
   - 真机才能测试Face ID功能
   - 确保设备已设置Face ID

## 🔧 常见问题

### Q1: 编译错误 "Cannot find type 'XXX' in scope"
**解决**:
- 确保所有文件都已添加到项目Target
- 检查文件的 Target Membership (在File Inspector中)

### Q2: Info.plist权限未生效
**解决**:
- 在项目设置的 `Info` 标签中手动添加
- 或确保Custom iOS Target Properties路径正确

### Q3: Face ID在模拟器上无法测试
**解决**:
- 使用真机测试
- 或在模拟器菜单 `Features` > `Face ID` > `Enrolled` 并模拟成功/失败

### Q4: 无法访问照片库
**解决**:
- 确保Info.plist中有 `NSPhotoLibraryUsageDescription`
- 重新安装应用并授权

### Q5: API调用失败
**解决**:
- 检查网络连接
- 验证API密钥是否正确
- 查看Xcode控制台的错误信息

## 📱 模拟器Face ID设置

由于模拟器没有真实的Face ID硬件,需要手动模拟:

1. **启用Face ID**
   - `Features` > `Face ID` > `Enrolled`

2. **模拟认证**
   - 成功: `Features` > `Face ID` > `Matching Face`
   - 失败: `Features` > `Face ID` > `Non-matching Face`

## 🚀 快速开发技巧

### 使用Xcode Preview
在SwiftUI文件底部添加:
```swift
#Preview {
    HomeView()
}
```

### 调试技巧
- 使用 `print()` 输出调试信息
- 使用断点 (点击行号左侧)
- 查看 `Console` 输出

### 热重载
- SwiftUI支持实时预览
- 修改代码后自动刷新Canvas

## 📚 后续开发

1. **添加单元测试**
   - 在 `AIPhotoClassifierTests` 中添加测试

2. **添加UI测试**
   - 在 `AIPhotoClassifierUITests` 中添加UI测试

3. **性能优化**
   - 使用Instruments分析性能
   - 优化图片加载和加密

4. **国际化**
   - 添加多语言支持
   - 使用 `Localizable.strings`

## 🎯 完成检查清单

- [ ] Xcode项目创建成功
- [ ] 所有源文件已添加到项目
- [ ] Info.plist配置正确
- [ ] 项目可以成功编译
- [ ] 模拟器可以运行
- [ ] Face ID认证流程正常
- [ ] 照片上传功能正常
- [ ] AI分类功能正常
- [ ] 收藏夹加密功能正常
- [ ] AI聊天功能正常

---

**需要帮助?**
- 查看Xcode官方文档
- 查看项目README.md
- 提交GitHub Issue
