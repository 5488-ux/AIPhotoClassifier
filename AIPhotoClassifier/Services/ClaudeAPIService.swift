import Foundation
import UIKit

enum ClaudeAPIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
}

class ClaudeAPIService {
    static let shared = ClaudeAPIService()

    private init() {}

    // MARK: - Image Analysis for Classification
    func analyzeImages(_ images: [UIImage]) async throws -> [String: [Int]] {
        let imageContents = images.compactMap { image -> ClaudeAPIRequest.Content? in
            guard let base64 = image.toBase64() else { return nil }
            return ClaudeAPIRequest.Content(
                type: "image",
                text: nil,
                source: ClaudeAPIRequest.Content.ImageSource(
                    type: "base64",
                    mediaType: "image/jpeg",
                    data: base64
                )
            )
        }

        var contents = imageContents
        contents.append(ClaudeAPIRequest.Content(
            type: "text",
            text: Constants.Classification.classificationPrompt,
            source: nil
        ))

        let request = ClaudeAPIRequest(
            model: Constants.API.model,
            maxTokens: 1024,
            messages: [
                ClaudeAPIRequest.Message(role: "user", content: contents)
            ],
            thinkingConfig: ClaudeAPIRequest.ThinkingConfig(
                type: "enabled",
                budget_tokens: 2000
            )
        )

        let response = try await sendRequest(request)

        // Parse JSON response
        guard let textContent = response.content.first(where: { $0.type == "text" })?.text else {
            throw ClaudeAPIError.invalidResponse
        }

        return try parseClassificationResponse(textContent)
    }

    // MARK: - Chat Function
    func chat(message: String, thinkingEnabled: Bool = false) async throws -> (response: String, thinking: String?) {
        let content = ClaudeAPIRequest.Content(
            type: "text",
            text: message,
            source: nil
        )

        let thinkingConfig = thinkingEnabled ? ClaudeAPIRequest.ThinkingConfig(
            type: "enabled",
            budget_tokens: 1000
        ) : nil

        let request = ClaudeAPIRequest(
            model: Constants.API.model,
            maxTokens: Constants.API.maxTokens,
            messages: [
                ClaudeAPIRequest.Message(role: "user", content: [content])
            ],
            thinkingConfig: thinkingConfig
        )

        let response = try await sendRequest(request)

        let textContent = response.content.first(where: { $0.type == "text" })?.text ?? ""
        let thinkingContent = response.content.first(where: { $0.type == "thinking" })?.thinking

        return (textContent, thinkingContent)
    }

    // MARK: - Private Methods
    private func sendRequest(_ request: ClaudeAPIRequest) async throws -> ClaudeAPIResponse {
        guard let url = URL(string: Constants.API.baseURL) else {
            throw ClaudeAPIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(Constants.API.key, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue(Constants.API.apiVersion, forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
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
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(ClaudeAPIResponse.self, from: data)

        } catch let error as DecodingError {
            throw ClaudeAPIError.decodingError(error)
        } catch let error as ClaudeAPIError {
            throw error
        } catch {
            throw ClaudeAPIError.networkError(error)
        }
    }

    private func parseClassificationResponse(_ jsonString: String) throws -> [String: [Int]] {
        // Extract JSON from response (in case there's extra text)
        let pattern = "\\{[^}]*\"categories\"[^}]*\\}"
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
