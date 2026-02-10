import Foundation

struct AIMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var thinkingContent: String?

    init(id: UUID = UUID(),
         content: String,
         isFromUser: Bool,
         timestamp: Date = Date(),
         thinkingContent: String? = nil) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.thinkingContent = thinkingContent
    }
}

struct ClaudeAPIRequest: Codable {
    let model: String
    let maxTokens: Int
    let messages: [Message]
    let thinkingConfig: ThinkingConfig?

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
        case thinkingConfig = "thinking"
    }

    struct Message: Codable {
        let role: String
        let content: [Content]
    }

    struct Content: Codable {
        let type: String
        let text: String?
        let source: ImageSource?

        struct ImageSource: Codable {
            let type: String
            let mediaType: String
            let data: String

            enum CodingKeys: String, CodingKey {
                case type
                case mediaType = "media_type"
                case data
            }
        }
    }

    struct ThinkingConfig: Codable {
        let type: String
        let budget_tokens: Int
    }
}

struct ClaudeAPIResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let model: String
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model
        case stopReason = "stop_reason"
    }

    struct ContentBlock: Codable {
        let type: String
        let text: String?
        let thinking: String?
    }
}
