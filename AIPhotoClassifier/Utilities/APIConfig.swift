import Foundation

/// API配置管理 - 从本地配置文件读取敏感信息
struct APIConfig {
    /// 从Config.plist读取API密钥，未配置时回退到Constants中的默认值
    static var apiKey: String {
        if let key = readConfigValue(for: "APIKey") {
            return key
        }
        return Constants.API.key
    }

    /// 从Config.plist读取API基础URL
    static var baseURL: String {
        if let url = readConfigValue(for: "APIBaseURL") {
            return url
        }
        return "https://aicanapi.com/v1/chat/completions"
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
