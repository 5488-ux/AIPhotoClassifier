import SwiftUI

struct MessageBubbleView: View {
    let message: AIMessage
    let showThinking: Bool

    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
            // Thinking content
            if !message.isFromUser,
               showThinking,
               let thinking = message.thinkingContent,
               !thinking.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("思考过程", systemImage: "brain")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(thinking)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            }

            // Message bubble
            HStack {
                if message.isFromUser { Spacer(minLength: 50) }

                VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundStyle(message.isFromUser ? .white : .primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            message.isFromUser ?
                            AnyShapeStyle(LinearGradient(colors: [.appPrimary, .appSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                            AnyShapeStyle(Color(.systemGray6))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    Text(message.timestamp.formattedString())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isFromUser ? .trailing : .leading)

                if !message.isFromUser { Spacer(minLength: 50) }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isFromUser ? .trailing : .leading)
    }
}
