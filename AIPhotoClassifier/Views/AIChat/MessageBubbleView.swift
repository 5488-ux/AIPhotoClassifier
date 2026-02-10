import SwiftUI

struct MessageBubbleView: View {
    let message: AIMessage
    let showThinking: Bool

    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
            // Thinking content (if available and enabled)
            if !message.isFromUser,
               showThinking,
               let thinking = message.thinkingContent,
               !thinking.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "brain")
                            .font(.caption)
                        Text("思考过程")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.secondary)

                    Text(thinking)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            }

            // Message bubble
            HStack {
                if message.isFromUser {
                    Spacer(minLength: 50)
                }

                VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(message.isFromUser ? .white : .primary)
                        .padding(12)
                        .background(
                            message.isFromUser ?
                            Color.appPrimary :
                            Color.appSecondaryBackground
                        )
                        .cornerRadius(16)

                    Text(message.timestamp.formatted())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isFromUser ? .trailing : .leading)

                if !message.isFromUser {
                    Spacer(minLength: 50)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isFromUser ? .trailing : .leading)
    }
}
