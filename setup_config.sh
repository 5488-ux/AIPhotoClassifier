#!/bin/bash

# AI Photo Classifier - 配置安装脚本
# 此脚本帮助您设置API密钥配置

echo "🔧 AI Photo Classifier - API配置设置"
echo "===================================="
echo ""

# 检查Config.plist是否存在
if [ ! -f "AIPhotoClassifier/Config.plist" ]; then
    echo "📝 创建Config.plist从模板..."
    cp AIPhotoClassifier/Config.plist.example AIPhotoClassifier/Config.plist
    echo "✅ Config.plist 已创建"
    echo ""
    echo "⚠️  请编辑 AIPhotoClassifier/Config.plist 并填写你的API密钥！"
    echo ""
else
    echo "✅ Config.plist 已存在"
    echo ""
fi

# 在Xcode项目中添加文件的提示
echo "📱 下一步：在Xcode中添加文件"
echo "===================================="
echo ""
echo "1. 打开 Xcode"
echo "2. 打开 AIPhotoClassifier.xcodeproj"
echo "3. 如果项目中没有以下文件，请手动添加："
echo "   - AIPhotoClassifier/Utilities/APIConfig.swift"
echo "   - AIPhotoClassifier/Config.plist"
echo ""
echo "添加方法："
echo "  a. 右键点击 'Utilities' 文件夹"
echo "  b. 选择 'Add Files to AIPhotoClassifier...'"
echo "  c. 选择对应文件"
echo "  d. 确保 'Add to targets' 勾选了 AIPhotoClassifier"
echo ""
echo "✅ 完成后即可构建运行！"
echo ""

# 显示Config.plist当前内容（隐藏API密钥）
if [ -f "AIPhotoClassifier/Config.plist" ]; then
    echo "📄 当前配置："
    API_KEY=$(grep -A1 "APIKey" AIPhotoClassifier/Config.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>/\1/')
    if [[ $API_KEY == sk-* ]]; then
        echo "  API密钥: ${API_KEY:0:10}...${API_KEY: -10} ✅"
    else
        echo "  API密钥: ❌ 未配置或格式错误"
    fi
    echo ""
fi

echo "📚 更多信息请查看: API_CONFIG_README.md"
