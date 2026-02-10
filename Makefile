# AIPhotoClassifier Makefile
#
# 常用命令:
#   make build      - 编译项目 (不签名)
#   make archive    - 创建 Archive
#   make ipa        - 打包无签名 IPA
#   make ipa-signed - 打包签名 IPA (需要证书)
#   make clean      - 清理构建产物

PROJECT = AIPhotoClassifier
SCHEME  = AIPhotoClassifier
SDK     = iphoneos
CONFIG  = Release
BUILD_DIR = build

.PHONY: all build archive ipa ipa-signed clean help

help: ## 显示帮助信息
	@echo "AIPhotoClassifier 构建命令:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

build: ## 编译项目 (无签名)
	xcodebuild clean build \
		-project $(PROJECT).xcodeproj \
		-scheme $(SCHEME) \
		-sdk $(SDK) \
		-configuration $(CONFIG) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

archive: ## 创建 .xcarchive
	@mkdir -p $(BUILD_DIR)
	xcodebuild archive \
		-project $(PROJECT).xcodeproj \
		-scheme $(SCHEME) \
		-archivePath $(BUILD_DIR)/$(PROJECT).xcarchive \
		-sdk $(SDK) \
		-configuration $(CONFIG) \
		-destination 'generic/platform=iOS' \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO

ipa: ## 打包无签名 IPA (用于测试/侧载)
	./scripts/build_ipa.sh

ipa-signed: ## 打包签名 IPA (需要 TEAM_ID)
ifndef TEAM_ID
	$(error 请设置 TEAM_ID, 例如: make ipa-signed TEAM_ID=ABCDE12345)
endif
	./scripts/build_ipa.sh --signed --team-id $(TEAM_ID)

ipa-adhoc: ## 打包 Ad Hoc IPA
ifndef TEAM_ID
	$(error 请设置 TEAM_ID, 例如: make ipa-adhoc TEAM_ID=ABCDE12345)
endif
	./scripts/build_ipa.sh --signed --team-id $(TEAM_ID) --export-method ad-hoc

ipa-appstore: ## 打包 App Store IPA
ifndef TEAM_ID
	$(error 请设置 TEAM_ID, 例如: make ipa-appstore TEAM_ID=ABCDE12345)
endif
	./scripts/build_ipa.sh --signed --team-id $(TEAM_ID) --export-method app-store

clean: ## 清理所有构建产物
	@echo "清理构建目录..."
	rm -rf $(BUILD_DIR)
	xcodebuild clean \
		-project $(PROJECT).xcodeproj \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-quiet 2>/dev/null || true
	@echo "清理完成"
