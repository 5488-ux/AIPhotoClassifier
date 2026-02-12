import Foundation
import UIKit

enum ClaudeAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的API地址"
        case .invalidResponse: return "无效的响应"
        case .networkError(let error): return "网络错误: \(error.localizedDescription)"
        case .decodingError(let error): return "解析错误: \(error)"
        case .apiError(let msg): return "API错误: \(msg)"
        case .emptyResponse: return "AI返回了空回复"
        }
    }
}

class ClaudeAPIService {
    static let shared = ClaudeAPIService()

    private init() {}

    // MARK: - Image Analysis for Classification
    func analyzeImages(_ images: [UIImage]) async throws -> [String: [Int]] {
        var parts: [OpenAIChatRequest.ContentPart] = []

        for image in images {
            if let base64 = image.toBase64() {
                parts.append(.imagePart(base64Data: base64))
            }
        }

        parts.append(.textPart(Constants.Classification.classificationPrompt))

        let messages: [OpenAIChatRequest.ChatMessage] = [
            .init(role: "user", content: .parts(parts))
        ]

        let request = OpenAIChatRequest(
            model: Constants.API.model,
            messages: messages,
            max_tokens: 1024
        )

        let response = try await sendRequest(request)
        guard let text = response.choices.first?.message.content, !text.isEmpty else {
            throw ClaudeAPIError.emptyResponse
        }

        return try parseClassificationResponse(text)
    }

    // MARK: - Chat Function (with conversation history)
    func chat(messages history: [AIMessage], thinkingEnabled: Bool = false) async throws -> (response: String, thinking: String?) {
        let model = thinkingEnabled ? Constants.API.thinkingModel : Constants.API.model

        // Build messages: system + last N messages
        var chatMessages: [OpenAIChatRequest.ChatMessage] = [
            .init(role: "system", content: .text(Constants.API.systemPrompt))
        ]

        let recentMessages = history.suffix(Constants.API.maxContextMessages)
        for msg in recentMessages {
            let role = msg.isFromUser ? "user" : "assistant"
            chatMessages.append(.init(role: role, content: .text(msg.content)))
        }

        let request = OpenAIChatRequest(
            model: model,
            messages: chatMessages,
            max_tokens: Constants.API.maxTokens
        )

        let response = try await sendRequest(request)

        guard let choice = response.choices.first else {
            throw ClaudeAPIError.emptyResponse
        }

        let textContent = choice.message.content ?? ""
        let thinkingContent = choice.message.reasoning_content

        return (textContent, thinkingContent)
    }

    // MARK: - Private Methods
    private func sendRequest(_ request: OpenAIChatRequest) async throws -> OpenAIChatResponse {
        guard let url = URL(string: Constants.API.baseURL) else {
            throw ClaudeAPIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(Constants.API.key)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60

        urlRequest.httpBody = try JSONEncoder().encode(request)

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeAPIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ClaudeAPIError.apiError("HTTP \(httpResponse.statusCode): \(errorBody)")
            }

            return try JSONDecoder().decode(OpenAIChatResponse.self, from: data)

        } catch let error as DecodingError {
            throw ClaudeAPIError.decodingError(error)
        } catch let error as ClaudeAPIError {
            throw error
        } catch {
            throw ClaudeAPIError.networkError(error)
        }
    }

    private func parseClassificationResponse(_ jsonString: String) throws -> [String: [Int]] {
        // Try to extract JSON from response
        var toParse = jsonString

        // Strip markdown code fences if present
        if let range = toParse.range(of: "```json") {
            toParse = String(toParse[range.upperBound...])
            if let endRange = toParse.range(of: "```") {
                toParse = String(toParse[..<endRange.lowerBound])
            }
        } else if let range = toParse.range(of: "```") {
            toParse = String(toParse[range.upperBound...])
            if let endRange = toParse.range(of: "```") {
                toParse = String(toParse[..<endRange.lowerBound])
            }
        }

        // Try direct JSON parse first
        let trimmed = toParse.trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = trimmed.data(using: .utf8) {
            struct ClassificationResult: Codable {
                let categories: [String: [Int]]
            }
            if let result = try? JSONDecoder().decode(ClassificationResult.self, from: data) {
                return result.categories
            }
        }

        // Fallback: regex extract
        let pattern = "\\{[\\s\\S]*\"categories\"[\\s\\S]*\\}"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let nsString = jsonString as NSString
        let matches = regex.matches(in: jsonString, options: [], range: NSRange(location: 0, length: nsString.length))

        guard let match = matches.first else {
            throw ClaudeAPIError.invalidResponse
        }

        let jsonSubstring = nsString.substring(with: match.range)
        guard let data = jsonSubstring.data(using: .utf8) else {
            throw ClaudeAPIError.invalidResponse
        }

        struct ClassificationResult: Codable {
            let categories: [String: [Int]]
        }

        let result = try JSONDecoder().decode(ClassificationResult.self, from: data)
        return result.categories
    }
}
