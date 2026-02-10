import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAuthenticating = false

    var onAuthenticated: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appPrimary, Color.appSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // App Icon
                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)

                Text("AI Photo Classifier")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("智能图片分类管理")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                // Authentication Button
                VStack(spacing: 15) {
                    Button(action: authenticate) {
                        HStack {
                            Image(systemName: getBiometryIcon())
                                .font(.title2)

                            Text("使用\(authService.getBiometryTypeString())解锁")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.appPrimary)
                        .cornerRadius(15)
                    }
                    .disabled(isAuthenticating)

                    if isAuthenticating {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .alert("认证失败", isPresented: $showError) {
            Button("重试", action: authenticate)
            Button("取消", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Auto-trigger authentication on appear
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                authenticate()
            }
        }
    }

    private func authenticate() {
        isAuthenticating = true

        Task {
            do {
                let success = try await authService.authenticateUser()
                isAuthenticating = false

                if success {
                    onAuthenticated()
                } else {
                    errorMessage = "认证失败,请重试"
                    showError = true
                }
            } catch {
                isAuthenticating = false
                errorMessage = getErrorMessage(error)
                showError = true
            }
        }
    }

    private func getBiometryIcon() -> String {
        switch authService.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "lock.fill"
        }
    }

    private func getErrorMessage(_ error: Error) -> String {
        if let authError = error as? AuthenticationError {
            switch authError {
            case .cancelled:
                return "认证已取消"
            case .failed:
                return "认证失败"
            case .biometryNotAvailable:
                return "生物识别不可用"
            case .biometryNotEnrolled:
                return "未设置生物识别"
            case .passcodeNotSet:
                return "未设置设备密码"
            default:
                return "认证错误"
            }
        }
        return error.localizedDescription
    }
}
