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

// MARK: - OpenAI兼容格式请求体
struct OpenAIChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let max_tokens: Int
    let stream: Bool = false

    struct ChatMessage: Encodable {
        let role: String
        let content: MessageContent

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(role, forKey: .role)
            switch content {
            case .text(let text):
                try container.encode(text, forKey: .content)
            case .parts(let parts):
                try container.encode(parts, forKey: .content)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case role, content
        }
    }

    enum MessageContent {
        case text(String)
        case parts([ContentPart])
    }

    struct ContentPart: Encodable {
        let type: String
        let text: String?
        let image_url: ImageURL?

        struct ImageURL: Encodable {
            let url: String
        }

        static func textPart(_ text: String) -> ContentPart {
            ContentPart(type: "text", text: text, image_url: nil)
        }

        static func imagePart(base64Data: String, mediaType: String = "image/jpeg") -> ContentPart {
            ContentPart(
                type: "image_url",
                text: nil,
                image_url: ImageURL(url: "data:\(mediaType);base64,\(base64Data)")
            )
        }
    }
}

// MARK: - OpenAI兼容格式响应体
struct OpenAIChatResponse: Decodable {
    let id: String?
    let choices: [Choice]

    struct Choice: Decodable {
        let message: ResponseMessage
    }

    struct ResponseMessage: Decodable {
        let role: String?
        let content: String?
        let reasoning_content: String?
    }
}
