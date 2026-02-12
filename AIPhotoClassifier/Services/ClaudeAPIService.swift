import Foundation
import UIKit

enum ClaudeAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的 URL"
        case .invalidResponse: return "无效的响应"
        case .networkError(let error): return "网络错误: \(error.localizedDescription)"
        case .decodingError(let error): return "解析错误: \(error.localizedDescription)"
        case .apiError(let msg): return "API 错误: \(msg)"
        }
    }
}

class ClaudeAPIService {
    static let shared = ClaudeAPIService()

    private init() {}

    // MARK: - Chat (with message history context)

    func chat(
        message: String,
        history: [AIMessage] = [],
        thinkingEnabled: Bool = false
    ) async throws -> (response: String, thinking: String?) {

        let model = thinkingEnabled ? Constants.API.thinkingModel : Constants.API.model

        // Build messages: system + last N history + current user message
        var chatMessages: [ChatCompletionRequest.ChatMessage] = []

        // System prompt
        chatMessages.append(ChatCompletionRequest.ChatMessage(
            role: "system",
            content: .text(Constants.API.systemPrompt)
        ))

        // Recent history (last 20 messages)
        let recentHistory = history.suffix(Constants.API.maxContextMessages)
        for msg in recentHistory {
            chatMessages.append(ChatCompletionRequest.ChatMessage(
                role: msg.isFromUser ? "user" : "assistant",
                content: .text(msg.content)
            ))
        }

        // Current user message
        chatMessages.append(ChatCompletionRequest.ChatMessage(
            role: "user",
            content: .text(message)
        ))

        let request = ChatCompletionRequest(
            model: model,
            messages: chatMessages,
            maxTokens: Constants.API.maxTokens,
            stream: false
        )

        let response = try await sendChatRequest(request)

        let textContent = response.choices?.first?.message.content ?? ""
        let thinkingContent = response.choices?.first?.message.reasoningContent

        return (textContent, thinkingContent)
    }

    // MARK: - Image Analysis for Classification

    func analyzeImages(_ images: [UIImage]) async throws -> [String: [Int]] {
        // Build image content parts
        var parts: [ChatCompletionRequest.ContentPart] = []

        for image in images {
            guard let base64 = image.toBase64() else { continue }
            parts.append(ChatCompletionRequest.ContentPart(
                type: "image_url",
                text: nil,
                imageUrl: ChatCompletionRequest.ImageURL(
                    url: "data:image/jpeg;base64,\(base64)"
                )
            ))
        }

        // Add text instruction
        parts.append(ChatCompletionRequest.ContentPart(
            type: "text",
            text: Constants.Classification.classificationPrompt,
            imageUrl: nil
        ))

        let chatMessages: [ChatCompletionRequest.ChatMessage] = [
            ChatCompletionRequest.ChatMessage(
                role: "system",
                content: .text("你是一个图片分类助手，只返回JSON格式结果。")
            ),
            ChatCompletionRequest.ChatMessage(
                role: "user",
                content: .parts(parts)
            )
        ]

        let request = ChatCompletionRequest(
            model: Constants.API.model,
            messages: chatMessages,
            maxTokens: 1024,
            stream: false
        )

        let response = try await sendChatRequest(request)

        guard let textContent = response.choices?.first?.message.content, !textContent.isEmpty else {
            throw ClaudeAPIError.invalidResponse
        }

        return try parseClassificationResponse(textContent)
    }

    // MARK: - Video Generation

    func generateVideo(prompt: String) async throws -> String {
        guard let url = URL(string: Constants.API.videoURL) else {
            throw ClaudeAPIError.invalidURL
        }

        let videoRequest = VideoGenerationRequest(
            model: Constants.API.videoModel,
            prompt: prompt
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(Constants.API.key)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 120

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(videoRequest)

        let (data, httpResponse) = try await URLSession.shared.data(for: urlRequest)

        guard let response = httpResponse as? HTTPURLResponse else {
            throw ClaudeAPIError.invalidResponse
        }

        if response.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ClaudeAPIError.apiError("HTTP \(response.statusCode): \(errorMessage)")
        }

        let videoResponse = try JSONDecoder().decode(VideoGenerationResponse.self, from: data)

        if let error = videoResponse.error {
            throw ClaudeAPIError.apiError(error.message ?? "Video generation failed")
        }

        guard let videoURL = videoResponse.data?.first?.url else {
            throw ClaudeAPIError.invalidResponse
        }

        return videoURL
    }

    // MARK: - Private: Send Chat Completion Request

    private func sendChatRequest(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        guard let url = URL(string: Constants.API.baseURL) else {
            throw ClaudeAPIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(Constants.API.key)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 60

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeAPIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ClaudeAPIError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
            }

            let decoder = JSONDecoder()
            let chatResponse = try decoder.decode(ChatCompletionResponse.self, from: data)

            // Check for API-level error
            if let error = chatResponse.error {
                throw ClaudeAPIError.apiError(error.message ?? "Unknown API error")
            }

            return chatResponse

        } catch let error as DecodingError {
            throw ClaudeAPIError.decodingError(error)
        } catch let error as ClaudeAPIError {
            throw error
        } catch {
            throw ClaudeAPIError.networkError(error)
        }
    }

    // MARK: - Private: Parse Classification Response

    private func parseClassificationResponse(_ jsonString: String) throws -> [String: [Int]] {
        // Extract JSON from response (handle markdown code blocks)
        let cleanJSON = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Try direct parse first
        if let data = cleanJSON.data(using: .utf8) {
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
        let nsString = cleanJSON as NSString
        let matches = regex.matches(in: cleanJSON, options: [], range: NSRange(location: 0, length: nsString.length))

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
