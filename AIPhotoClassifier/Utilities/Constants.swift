import Foundation

struct Constants {
    // MARK: - API Configuration (aicanapi.com proxy, OpenAI-compatible)
    struct API {
        static let key = "sk-QsO7ItVSm4R5wbFgWrGxHOpkiaHGhPRZoKg34oyNtFbnN3Zj"
        static let baseURL = "https://aicanapi.com/v1/chat/completions"
        static let model = "claude-3-5-haiku-20241022"
        static let thinkingModel = "claude-3-5-haiku-20241022"
        static let maxTokens = 300
        static let maxContextMessages = 20
        static let systemPrompt = "你是 AI Photo Classifier 的智能助手，帮助用户管理和分类照片。用中文回答，简洁友好。"

        // Video generation
        static let videoURL = "https://aicanapi.com/v1/video/generations"
        static let videoModel = "grok-video-3"
    }

    // MARK: - App Configuration
    struct App {
        static let bundleIdentifier = "com.aiphoto.classifier"
        static let appName = "AI Photo Classifier"
        static let minimumIOSVersion = "16.0"
    }

    // MARK: - Encryption
    struct Encryption {
        static let keychainService = "com.aiphoto.classifier.encryption"
        static let masterKeyIdentifier = "masterEncryptionKey"
    }

    // MARK: - Authentication
    struct Auth {
        static let faceIDReason = "需要验证身份以访问应用"
        static let albumPasswordReason = "请输入收藏夹密码"
    }

    // MARK: - UI Constants
    struct UI {
        static let floatingButtonSize: CGFloat = 60
        static let albumGridColumns = 2
        static let thumbnailSize: CGFloat = 150
        static let maxChatMessageLength = 200
    }

    // MARK: - Image Classification
    struct Classification {
        static let defaultCategories = ["人物", "风景", "美食", "宠物", "文档", "截图", "其他"]
        static let classificationPrompt = """
        分析这些图片的内容,将它们分类到合适的收藏夹。
        返回JSON格式: {"categories": {"风景": [0,2], "美食": [1,3]}}
        可能的分类包括:人物、风景、美食、宠物、文档、截图等。
        如果发现新类别,可以创建新分类。
        只返回JSON,不要包含其他文字说明。
        """
    }
}
