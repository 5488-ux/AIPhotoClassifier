import Foundation

struct Constants {
    // MARK: - Claude API Configuration
    struct API {
        static let key = "sk-aDNuLw9dfI77QFy3pTT8Hehtkg26VnaydPC9Rpvpm6a29UF1"
        static let model = "claude-haiku-4-5-20251001"
        static let baseURL = "https://api.anthropic.com/v1/messages"
        static let apiVersion = "2023-06-01"
        static let maxTokens = 300 // ~200 words
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
