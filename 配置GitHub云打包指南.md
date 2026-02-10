# GitHub Actions 云端自动打包IPA指南

## 📋 准备工作

### 需要准备的材料

1. **Apple Developer账号** ($99/年)
   - 免费账号也可以，但IPA只能用7天

2. **开发者证书** (.p12文件)
3. **Provisioning Profile** (.mobileprovision文件)
4. **证书密码**

---

## 🔑 第一步: 导出证书

### 在Mac上操作

1. **打开钥匙串访问**
   ```bash
   open /Applications/Utilities/Keychain\ Access.app
   ```

2. **找到证书**
   - 在"登录"钥匙串中
   - 找到"Apple Development"或"Apple Distribution"证书
   - 展开证书，会看到私钥

3. **导出为P12**
   - 右键证书 → 导出
   - 文件格式：个人信息交换 (.p12)
   - 保存为：`Certificates.p12`
   - **设置密码**（记住这个密码）

### 如果没有证书

```bash
# 在Xcode中创建
# 1. 打开项目
open AIPhotoClassifier.xcodeproj

# 2. 选择项目 → Signing & Capabilities
# 3. Team: 选择你的Apple ID
# 4. Xcode会自动创建证书
```

---

## 📱 第二步: 下载Provisioning Profile

### 方法1: 在Apple Developer网站

1. 访问: https://developer.apple.com/account/resources/profiles/list
2. 点击 **+** 创建新Profile
3. 选择 **iOS App Development** 或 **Ad Hoc**
4. 选择App ID: `com.aiphoto.classifier`
5. 选择证书
6. 选择设备（Ad Hoc需要）
7. 下载 `.mobileprovision` 文件

### 方法2: 在Xcode中

```bash
# 1. Xcode → Preferences → Accounts
# 2. 选择你的Apple ID
# 3. Download Manual Profiles
# 4. 在 ~/Library/MobileDevice/Provisioning Profiles/ 找到文件
```

---

## 🔐 第三步: 转换为Base64

在Mac终端中运行：

```bash
# 转换证书
base64 -i Certificates.p12 -o cert.txt

# 转换Provisioning Profile
base64 -i YourProfile.mobileprovision -o profile.txt
```

复制 `cert.txt` 和 `profile.txt` 的内容，稍后用。

---

## ⚙️ 第四步: 配置GitHub Secrets

1. **访问仓库设置**
   ```
   https://github.com/5488-ux/AIPhotoClassifier/settings/secrets/actions
   ```

2. **点击 "New repository secret"**

3. **添加以下Secrets**:

   | Name | Value | 说明 |
   |------|-------|------|
   | `CERTIFICATES_P12` | cert.txt的内容 | Base64编码的证书 |
   | `CERTIFICATES_P12_PASSWORD` | 你的密码 | P12证书密码 |
   | `PROVISIONING_PROFILE` | profile.txt的内容 | Base64编码的Profile |
   | `KEYCHAIN_PASSWORD` | 随机密码 | 临时钥匙串密码 |
   | `TEAM_ID` | 你的Team ID | 在developer.apple.com查看 |

### 如何找到Team ID

访问: https://developer.apple.com/account
在右上角显示你的Team ID（10位字符）

---

## 📝 第五步: 更新GitHub Actions配置

我来帮你创建新的workflow配置：

