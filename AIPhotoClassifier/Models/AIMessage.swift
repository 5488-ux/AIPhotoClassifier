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

// MARK: - OpenAI-Compatible API Models (aicanapi.com proxy)

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int?
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case model, messages, stream
        case maxTokens = "max_tokens"
    }

    struct ChatMessage: Codable {
        let role: String
        let content: ChatContent

        enum CodingKeys: String, CodingKey {
            case role, content
        }
    }

    /// content: plain string or array of content parts (for images)
    enum ChatContent: Codable {
        case text(String)
        case parts([ContentPart])

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let string):
                try container.encode(string)
            case .parts(let parts):
                try container.encode(parts)
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .text(string)
            } else if let parts = try? container.decode([ContentPart].self) {
                self = .parts(parts)
            } else {
                throw DecodingError.typeMismatch(
                    ChatContent.self,
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or [ContentPart]")
                )
            }
        }
    }

    struct ContentPart: Codable {
        let type: String
        let text: String?
        let imageUrl: ImageURL?

        enum CodingKeys: String, CodingKey {
            case type, text
            case imageUrl = "image_url"
        }
    }

    struct ImageURL: Codable {
        let url: String
    }
}

struct ChatCompletionResponse: Codable {
    let id: String?
    let object: String?
    let model: String?
    let choices: [Choice]?
    let usage: Usage?
    let error: APIError?

    struct Choice: Codable {
        let index: Int
        let message: ResponseMessage
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }

    struct ResponseMessage: Codable {
        let role: String?
        let content: String?
        let reasoningContent: String?

        enum CodingKeys: String, CodingKey {
            case role, content
            case reasoningContent = "reasoning_content"
        }
    }

    struct Usage: Codable {
        let promptTokens: Int?
        let completionTokens: Int?
        let totalTokens: Int?

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }

    struct APIError: Codable {
        let message: String?
        let type: String?
    }
}

// MARK: - Video Generation Models

struct VideoGenerationRequest: Codable {
    let model: String
    let prompt: String
}

struct VideoGenerationResponse: Codable {
    let id: String?
    let data: [VideoData]?
    let error: ChatCompletionResponse.APIError?

    struct VideoData: Codable {
        let url: String?
    }
}
