import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message, showThinking: viewModel.showThinking)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding(.horizontal)

                                    Text("AI正在思考...")
                                        .foregroundColor(.secondary)
                                        .font(.caption)

                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()

                // Input Area
                HStack(spacing: 12) {
                    TextField("输入消息...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .focused($isInputFocused)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.inputText.isEmpty ? .gray : .appPrimary)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color.appSecondaryBackground)
            }
            .navigationTitle("AI 助手")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
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
        .onAppear {
            isInputFocused = true
        }
    }

    private func sendMessage() {
        Task {
            await viewModel.sendMessage()
        }
    }
}
