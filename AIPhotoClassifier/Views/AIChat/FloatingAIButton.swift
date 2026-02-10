import SwiftUI

struct FloatingAIButton: View {
    @Binding var position: CGPoint
    @Binding var showChat: Bool

    @State private var isDragging = false
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.appPrimary, Color.appSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: Constants.UI.floatingButtonSize, height: Constants.UI.floatingButtonSize)
            .overlay {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .position(
                x: position.x + dragOffset.width,
                y: position.y + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        // Update position when drag ends
                        let newX = position.x + value.translation.width
                        let newY = position.y + value.translation.height

                        // Keep within screen bounds
                        let screenBounds = UIScreen.main.bounds
                        let buttonRadius = Constants.UI.floatingButtonSize / 2

                        position.x = max(buttonRadius, min(newX, screenBounds.width - buttonRadius))
                        position.y = max(buttonRadius, min(newY, screenBounds.height - buttonRadius))
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        if !isDragging {
                            showChat = true
                        }
                    }
            )
            .animation(.spring(), value: position)
    }
}
