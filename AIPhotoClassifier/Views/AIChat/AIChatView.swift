import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message, showThinking: viewModel.showThinking)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                HStack(spacing: 10) {
                                    ProgressView()
                                    Text("AI 正在思考...")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                HStack(spacing: 10) {
                    TextField("输入消息...", text: $viewModel.inputText, axis: .vertical)
                        .lineLimit(1...5)
                        .focused($isInputFocused)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.bar)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(viewModel.inputText.isEmpty ? .gray : .appPrimary)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("AI 助手")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("显示思考过程", isOn: $viewModel.showThinking)
                        Toggle("启用思考模式", isOn: $viewModel.thinkingEnabled)
                        Divider()
                        Button(role: .destructive, action: viewModel.clearHistory) {
                            Label("清空历史", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear { isInputFocused = true }
    }

    private func sendMessage() {
        Task { await viewModel.sendMessage() }
    }
}
