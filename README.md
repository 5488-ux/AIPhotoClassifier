# AI Photo Classifier - iOS应用

一款使用Claude AI自动分类和管理照片的iOS原生应用。

## ✨ 功能特点

### 🤖 AI智能分类
- 使用Claude Vision API自动分析图片内容
- 智能创建收藏夹(风景、人物、美食、宠物等)
- 自动将照片归档到对应分类

### 🔐 多层级安全保护
- **应用层**: Face ID/Touch ID认证保护
- **收藏夹层**: 可为单个收藏夹设置密码
- **存储层**: 所有照片使用AES-256-GCM加密存储

### 💬 AI悬浮助手
- 可拖动的AI对话悬浮窗
- 支持Claude思考模式
- 回复限制在200字以内,简洁高效

### 📱 精美界面
- 采用SwiftUI构建的现代化界面
- 支持深色模式
- 流畅的动画效果

## 🛠️ 技术栈

- **开发语言**: Swift 5.9+
- **UI框架**: SwiftUI
- **AI服务**: Claude API (claude-haiku-4-5-20251001)
- **认证**: LocalAuthentication (Face ID/Touch ID)
- **数据存储**: Core Data + Keychain
- **加密**: CryptoKit (AES-256-GCM)
- **最低版本**: iOS 16.0+

## 📋 项目结构

```
AIPhotoClassifier/
├── App/                    # 应用入口
├── Models/                 # 数据模型
│   ├── Photo.swift
│   ├── Album.swift
│   └── AIMessage.swift
├── Services/               # 服务层
│   ├── ClaudeAPIService.swift
│   ├── EncryptionService.swift
│   ├── AuthenticationService.swift
│   ├── StorageService.swift
│   └── ImageClassificationService.swift
├── Views/                  # 视图层
│   ├── Home/              # 主页相关
│   ├── Profile/           # 个人页面
│   ├── AIChat/            # AI聊天
│   └── Auth/              # 认证
├── ViewModels/            # 视图模型
└── Utilities/             # 工具类
```

## 🚀 快速开始

### 前置要求

- macOS 13.0+
- Xcode 15.0+
- iOS 16.0+ 设备或模拟器
- Apple Developer账号(用于真机测试Face ID功能)

### 安装步骤

1. **克隆仓库**
```bash
git clone https://github.com/yourusername/AIPhotoClassifier.git
cd AIPhotoClassifier
```

2. **打开项目**
```bash
open AIPhotoClassifier.xcodeproj
```

3. **配置签名**
- 在Xcode中选择你的开发团队
- 修改Bundle Identifier(如果需要)

4. **运行项目**
- 选择目标设备(真机或模拟器)
- 点击运行按钮(⌘R)

### API密钥配置

**⚠️ 重要安全提示**: 当前代码中API密钥是硬编码的,仅供演示使用。在生产环境中,请使用以下方法之一:

1. **使用环境变量**:
   - 创建`Config.xcconfig`文件(不要提交到Git)
   - 在代码中读取配置

2. **使用Keychain**:
   - 将API密钥存储在iOS Keychain中
   - 首次运行时从用户输入或配置文件导入

3. **使用后端服务**:
   - 创建中间层API服务器
   - 移动端通过服务器调用Claude API

## 📱 使用说明

### 1. 首次启动
- 应用启动时会要求Face ID/Touch ID认证
- 首次使用需要授权访问照片库

### 2. 上传照片
- 点击主页右上角的"+"按钮
- 选择"上传图片"
- 选择多张照片
- AI将自动分析并创建收藏夹

### 3. 管理收藏夹
- 点击收藏夹查看照片
- 长按照片可进行操作
- 在设置中可为收藏夹设置密码

### 4. AI助手
- 点击屏幕右下角的悬浮按钮
- 可拖动到任意位置
- 点击展开聊天界面
- 支持启用思考模式

## 🔒 安全特性

### 三层加密保护

1. **应用层加密**
   - 使用Face ID/Touch ID认证
   - 未认证无法访问任何数据

2. **收藏夹加密**
   - 可为敏感收藏夹设置独立密码
   - 密码使用SHA-256哈希存储

3. **文件加密**
   - 所有照片使用AES-256-GCM加密
   - 加密密钥存储在iOS Keychain中
   - 即使设备被破解,文件也无法读取

## 🏗️ 构建与部署

### 本地构建

```bash
xcodebuild clean build \
  -project AIPhotoClassifier.xcodeproj \
  -scheme AIPhotoClassifier \
  -sdk iphoneos \
  -configuration Release
```

### GitHub Actions自动构建

项目已配置GitHub Actions工作流,每次push到main分支时会自动构建:

1. 构建项目
2. 创建Archive
3. 导出IPA(需要配置签名)
4. 上传Artifacts

**注意**: 由于没有签名证书,Actions构建的IPA无法直接安装。需要:
- 配置GitHub Secrets添加证书和Provisioning Profile
- 或者下载源码自行在Xcode中构建

### 侧载安装(无开发者账号)

1. 使用[AltStore](https://altstore.io/)
2. 使用[Sideloadly](https://sideloadly.io/)
3. 使用Xcode直接安装到设备

## 🧪 测试

### 功能测试清单

- [ ] Face ID认证
- [ ] 照片上传
- [ ] AI自动分类
- [ ] 收藏夹密码保护
- [ ] 照片加密/解密
- [ ] AI聊天功能
- [ ] 悬浮窗拖动
- [ ] 退出登录

### 性能测试

- 100张照片分类速度: 预计30-60秒
- 加密/解密性能: <100ms/张
- AI响应时间: <3秒

## 📄 许可证

MIT License - 详见[LICENSE](LICENSE)文件

## 🤝 贡献

欢迎提交Issue和Pull Request!

## 📞 联系方式

- 项目主页: [GitHub](https://github.com/yourusername/AIPhotoClassifier)
- Issue追踪: [GitHub Issues](https://github.com/yourusername/AIPhotoClassifier/issues)

## 🙏 致谢

- [Claude API](https://www.anthropic.com/) - 提供强大的AI能力
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - 现代化的UI框架

## ⚠️ 免责声明

本项目仅供学习和研究使用。请勿用于商业用途。使用本应用处理照片时,请确保遵守相关隐私法规。

---

**注意事项**:

1. **API密钥安全**: 代码中包含的API密钥仅供演示,请在生产环境中使用安全的密钥管理方案
2. **真机测试**: Face ID功能需要在真实iPhone设备上测试
3. **iOS版本**: 建议使用iOS 16.0或更高版本
4. **照片隐私**: 所有照片仅存储在本地设备,不会上传到服务器(除AI分析时)
