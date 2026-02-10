# 🔒 API密钥配置说明

为了保护API密钥不泄露到GitHub，本项目使用本地配置文件。

## 📋 首次配置步骤

### 1. 复制配置模板

```bash
cd AIPhotoClassifier
cp Config.plist.example Config.plist
```

### 2. 编辑Config.plist

在Xcode中打开 `Config.plist`，或用文本编辑器修改：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>APIKey</key>
    <string>你的真实API密钥</string>
    <key>APIBaseURL</key>
    <string>https://aicanapi.com/v1/messages</string>
</dict>
</plist>
```

### 3. 填写你的API密钥

将 `APIKey` 的值替换为你的真实密钥。

### 4. 运行应用

现在可以正常编译运行，API密钥会从 `Config.plist` 读取。

---

## ✅ 安全保障

- ✅ `Config.plist` 已添加到 `.gitignore`，不会上传到GitHub
- ✅ `Config.plist.example` 是公开的模板（不含真实密钥）
- ✅ API密钥只存在于你本地的 `Config.plist` 文件中

---

## 🔄 更新API密钥

只需修改 `Config.plist` 中的值，重新编译即可。

---

## ⚠️ 注意事项

1. **不要删除** `Config.plist.example` - 这是给其他开发者的模板
2. **不要提交** `Config.plist` 到Git - 已经在 `.gitignore` 中排除
3. **定期更换** API密钥以提高安全性

---

## 🛠️ 故障排除

### 错误: "API密钥未配置"

确保：
1. `Config.plist` 文件存在于 `AIPhotoClassifier/` 目录下
2. 文件已添加到Xcode项目中（在左侧文件列表可见）
3. APIKey的值不为空

### 如何添加Config.plist到Xcode项目

1. 在Xcode中右键点击 `AIPhotoClassifier` 文件夹
2. 选择 "Add Files to AIPhotoClassifier..."
3. 选择 `Config.plist` 文件
4. 确保 "Copy items if needed" 未勾选
5. 确保 "Add to targets" 中勾选了 `AIPhotoClassifier`
