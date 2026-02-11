import Foundation
import SwiftUI

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var thinkingEnabled = true
    @Published var showThinking = false

    init() {
        loadChatHistory()
    }

    func loadChatHistory() {
        do {
            messages = try StorageService.shared.loadChatHistory()
        } catch {
            print("Failed to load chat history: \(error)")
        }
    }

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = AIMessage(
            content: inputText,
            isFromUser: true
        )

        messages.append(userMessage)
        let currentInput = inputText
        inputText = ""

        isLoading = true
        defer { isLoading = false }

        do {
            let (response, thinking) = try await ClaudeAPIService.shared.chat(
                message: currentInput,
                history: messages,
                thinkingEnabled: thinkingEnabled
            )

            let aiMessage = AIMessage(
                content: response,
                isFromUser: false,
                thinkingContent: thinking
            )

            messages.append(aiMessage)
            saveChatHistory()

        } catch {
            let errorMessage = AIMessage(
                content: "抱歉,发生错误: \(error.localizedDescription)",
                isFromUser: false
            )
            messages.append(errorMessage)
        }
    }

    func clearHistory() {
        messages.removeAll()
        do {
            try StorageService.shared.clearChatHistory()
        } catch {
            print("Failed to clear chat history: \(error)")
        }
    }

    private func saveChatHistory() {
        do {
            try StorageService.shared.saveChatHistory(messages)
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
}
