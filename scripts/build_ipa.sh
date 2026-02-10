#!/bin/bash
#
# AIPhotoClassifier IPA 打包脚本
#
# 用法:
#   ./scripts/build_ipa.sh                    # 无签名打包 (用于测试)
#   ./scripts/build_ipa.sh --signed           # 签名打包 (需要证书)
#   ./scripts/build_ipa.sh --export-method ad-hoc  # 指定导出方式
#
# 环境要求:
#   - macOS 系统
#   - Xcode 15.0+
#   - 签名打包需要有效的开发者证书和 Provisioning Profile
#

set -euo pipefail

# ============================
# 配置
# ============================
PROJECT_NAME="AIPhotoClassifier"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"
SCHEME="${PROJECT_NAME}"
BUNDLE_ID="com.aiphoto.classifier"
CONFIGURATION="Release"
SDK="iphoneos"

BUILD_DIR="${PROJECT_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/ipa"
IPA_PATH="${EXPORT_PATH}/${PROJECT_NAME}.ipa"

# 默认参数
SIGNED=false
EXPORT_METHOD="development"
TEAM_ID=""
CLEAN=true

# ============================
# 颜色输出
# ============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================
# 参数解析
# ============================
while [[ $# -gt 0 ]]; do
    case $1 in
        --signed)
            SIGNED=true
            shift
            ;;
        --export-method)
            EXPORT_METHOD="$2"
            shift 2
            ;;
        --team-id)
            TEAM_ID="$2"
            shift 2
            ;;
        --no-clean)
            CLEAN=false
            shift
            ;;
        --help|-h)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --signed              启用代码签名 (默认: 无签名)"
            echo "  --export-method TYPE  导出方式: development, ad-hoc, enterprise, app-store"
            echo "                        (默认: development)"
            echo "  --team-id ID          Apple Team ID"
            echo "  --no-clean            跳过 clean 步骤"
            echo "  -h, --help            显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                          # 无签名打包"
            echo "  $0 --signed --team-id ABC   # 签名打包"
            echo "  $0 --signed --export-method ad-hoc  # Ad Hoc 分发"
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            exit 1
            ;;
    esac
done

# ============================
# 环境检查
# ============================
check_environment() {
    log_info "检查构建环境..."

    # 检查 macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "此脚本必须在 macOS 上运行"
        exit 1
    fi

    # 检查 xcodebuild
    if ! command -v xcodebuild &>/dev/null; then
        log_error "未找到 xcodebuild，请安装 Xcode"
        exit 1
    fi

    # 显示 Xcode 版本
    XCODE_VERSION=$(xcodebuild -version | head -1)
    log_info "Xcode 版本: ${XCODE_VERSION}"

    # 检查项目文件
    if [ ! -d "${PROJECT_FILE}" ]; then
        log_error "未找到项目文件: ${PROJECT_FILE}"
        exit 1
    fi

    log_ok "环境检查通过"
}

# ============================
# 清理
# ============================
clean_build() {
    if [ "$CLEAN" = true ]; then
        log_info "清理构建目录..."
        rm -rf "${BUILD_DIR}"
        mkdir -p "${BUILD_DIR}"
        mkdir -p "${EXPORT_PATH}"

        xcodebuild clean \
            -project "${PROJECT_FILE}" \
            -scheme "${SCHEME}" \
            -configuration "${CONFIGURATION}" \
            -quiet

        log_ok "清理完成"
    else
        mkdir -p "${BUILD_DIR}"
        mkdir -p "${EXPORT_PATH}"
    fi
}

# ============================
# 构建 Archive
# ============================
build_archive() {
    log_info "开始构建 Archive..."
    log_info "  项目: ${PROJECT_NAME}"
    log_info "  Scheme: ${SCHEME}"
    log_info "  配置: ${CONFIGURATION}"
    log_info "  签名: $([ "$SIGNED" = true ] && echo "是" || echo "否")"

    local SIGNING_ARGS=""
    if [ "$SIGNED" = true ]; then
        SIGNING_ARGS="CODE_SIGN_STYLE=Automatic"
        if [ -n "$TEAM_ID" ]; then
            SIGNING_ARGS="${SIGNING_ARGS} DEVELOPMENT_TEAM=${TEAM_ID}"
        fi
    else
        SIGNING_ARGS="CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO"
    fi

    xcodebuild archive \
        -project "${PROJECT_FILE}" \
        -scheme "${SCHEME}" \
        -archivePath "${ARCHIVE_PATH}" \
        -sdk "${SDK}" \
        -configuration "${CONFIGURATION}" \
        -destination 'generic/platform=iOS' \
        ${SIGNING_ARGS} \
        | tee "${BUILD_DIR}/archive.log" \
        | grep -E '(error:|warning:|BUILD|ARCHIVE)'

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        log_error "Archive 构建失败，查看日志: ${BUILD_DIR}/archive.log"
        exit 1
    fi

    log_ok "Archive 构建成功: ${ARCHIVE_PATH}"
}

# ============================
# 生成 ExportOptions.plist
# ============================
generate_export_options() {
    local EXPORT_OPTIONS_PATH="${BUILD_DIR}/ExportOptions.plist"

    log_info "生成 ExportOptions.plist (method: ${EXPORT_METHOD})..."

    if [ "$SIGNED" = true ]; then
        cat > "${EXPORT_OPTIONS_PATH}" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>${EXPORT_METHOD}</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>uploadSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
PLIST
    else
        cat > "${EXPORT_OPTIONS_PATH}" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
PLIST
    fi

    echo "${EXPORT_OPTIONS_PATH}"
}

# ============================
# 导出 IPA
# ============================
export_ipa() {
    log_info "导出 IPA..."

    local EXPORT_OPTIONS_PATH
    EXPORT_OPTIONS_PATH=$(generate_export_options)

    if [ "$SIGNED" = true ]; then
        xcodebuild -exportArchive \
            -archivePath "${ARCHIVE_PATH}" \
            -exportPath "${EXPORT_PATH}" \
            -exportOptionsPlist "${EXPORT_OPTIONS_PATH}" \
            | tee "${BUILD_DIR}/export.log" \
            | grep -E '(error:|warning:|Export)'

        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            log_error "IPA 导出失败，查看日志: ${BUILD_DIR}/export.log"
            exit 1
        fi
    else
        # 无签名方式: 手动从 .xcarchive 创建 .ipa
        log_info "使用无签名方式创建 IPA..."
        create_unsigned_ipa
    fi

    if [ -f "${IPA_PATH}" ]; then
        local IPA_SIZE
        IPA_SIZE=$(du -h "${IPA_PATH}" | cut -f1)
        log_ok "IPA 已生成: ${IPA_PATH} (${IPA_SIZE})"
    else
        # 查找可能的 IPA 文件
        local FOUND_IPA
        FOUND_IPA=$(find "${EXPORT_PATH}" -name "*.ipa" -print -quit 2>/dev/null || true)
        if [ -n "$FOUND_IPA" ]; then
            local IPA_SIZE
            IPA_SIZE=$(du -h "${FOUND_IPA}" | cut -f1)
            log_ok "IPA 已生成: ${FOUND_IPA} (${IPA_SIZE})"
        else
            log_warn "未找到 IPA 文件"
        fi
    fi
}

# ============================
# 无签名 IPA 创建
# ============================
create_unsigned_ipa() {
    local APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"

    if [ ! -d "${APP_PATH}" ]; then
        log_error "未找到 .app: ${APP_PATH}"
        log_info "尝试查找 .app 文件..."
        find "${ARCHIVE_PATH}" -name "*.app" -type d 2>/dev/null
        exit 1
    fi

    log_info "从 .xcarchive 创建无签名 IPA..."

    # 创建 Payload 目录
    local PAYLOAD_DIR="${BUILD_DIR}/Payload"
    rm -rf "${PAYLOAD_DIR}"
    mkdir -p "${PAYLOAD_DIR}"

    # 复制 .app 到 Payload
    cp -R "${APP_PATH}" "${PAYLOAD_DIR}/"

    # 压缩为 .ipa
    cd "${BUILD_DIR}"
    zip -r -q "${IPA_PATH}" Payload/
    cd "${PROJECT_DIR}"

    # 清理
    rm -rf "${PAYLOAD_DIR}"

    if [ -f "${IPA_PATH}" ]; then
        log_ok "无签名 IPA 创建成功"
    else
        log_error "IPA 创建失败"
        exit 1
    fi
}

# ============================
# 构建摘要
# ============================
print_summary() {
    echo ""
    echo "========================================"
    echo "  AIPhotoClassifier 打包完成"
    echo "========================================"
    echo ""
    echo "  Bundle ID:   ${BUNDLE_ID}"
    echo "  配置:        ${CONFIGURATION}"
    echo "  签名:        $([ "$SIGNED" = true ] && echo "已签名 (${EXPORT_METHOD})" || echo "无签名")"
    echo ""
    echo "  Archive:     ${ARCHIVE_PATH}"

    local FOUND_IPA
    FOUND_IPA=$(find "${EXPORT_PATH}" -name "*.ipa" -print -quit 2>/dev/null || true)
    if [ -n "$FOUND_IPA" ]; then
        local IPA_SIZE
        IPA_SIZE=$(du -h "${FOUND_IPA}" | cut -f1)
        echo "  IPA:         ${FOUND_IPA} (${IPA_SIZE})"
    fi

    echo ""

    if [ "$SIGNED" = false ]; then
        echo "  [提示] 无签名 IPA 可用于以下场景:"
        echo "    - 模拟器测试"
        echo "    - 通过 AltStore / Sideloadly 安装到设备"
        echo "    - 重签名后安装"
        echo ""
        echo "  如需签名打包，请运行:"
        echo "    $0 --signed --team-id YOUR_TEAM_ID"
    else
        echo "  安装方式:"
        echo "    1. Xcode: Window -> Devices -> 拖入 IPA"
        echo "    2. Apple Configurator 2"
        echo "    3. AltStore / Sideloadly"
        if [ "$EXPORT_METHOD" = "app-store" ]; then
            echo "    4. 通过 Transporter 上传到 App Store Connect"
        fi
    fi

    echo ""
    echo "========================================"
}

# ============================
# 主流程
# ============================
main() {
    echo ""
    log_info "=============================="
    log_info " AIPhotoClassifier IPA 打包"
    log_info "=============================="
    echo ""

    check_environment
    clean_build
    build_archive
    export_ipa
    print_summary
}

main
