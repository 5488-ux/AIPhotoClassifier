import Foundation

/// API配置管理 - 从本地配置文件读取敏感信息
struct APIConfig {
    /// 从Config.plist读取API密钥
    static var apiKey: String {
        if let key = readConfigValue(for: "APIKey") {
            return key
        }
        // 如果没有配置文件，使用默认值（需要用户自行配置）
        fatalError("❌ API密钥未配置！请在Config.plist中设置APIKey")
    }

    /// 从Config.plist读取API基础URL
    static var baseURL: String {
        if let url = readConfigValue(for: "APIBaseURL") {
            return url
        }
        return "https://aicanapi.com/v1/messages"
    }

    /// 读取配置文件中的值
    private static func readConfigValue(for key: String) -> String? {
        // 尝试从主Bundle读取Config.plist
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let value = dict[key] as? String {
            return value
        }
        return nil
    }
}
