import Foundation
import LocalAuthentication

enum AuthenticationError: Error {
    case notAvailable
    case failed
    case cancelled
    case fallback
    case systemCancel
    case passcodeNotSet
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
}

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published var isAuthenticated = false
    @Published var biometryType: LABiometryType = .none

    private init() {
        checkBiometryType()
    }

    // MARK: - Check Biometry Availability
    func checkBiometryType() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometryType = context.biometryType
        }
    }

    // MARK: - Authenticate User
    func authenticateUser() async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check if biometry is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback to device passcode
            return try await authenticateWithPasscode()
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: Constants.Auth.faceIDReason
            )

            DispatchQueue.main.async {
                self.isAuthenticated = success
            }

            return success
        } catch let laError as LAError {
            throw mapLAError(laError)
        }
    }

    // MARK: - Authenticate with Passcode
    func authenticateWithPasscode() async throws -> Bool {
        let context = LAContext()

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: Constants.Auth.faceIDReason
            )

            DispatchQueue.main.async {
                self.isAuthenticated = success
            }

            return success
        } catch let laError as LAError {
            throw mapLAError(laError)
        }
    }

    // MARK: - Logout
    func logout() {
        isAuthenticated = false
    }

    // MARK: - Helper Methods
    private func mapLAError(_ error: LAError) -> AuthenticationError {
        switch error.code {
        case .authenticationFailed:
            return .failed
        case .userCancel:
            return .cancelled
        case .userFallback:
            return .fallback
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .biometryNotAvailable:
            return .biometryNotAvailable
        case .biometryNotEnrolled:
            return .biometryNotEnrolled
        case .biometryLockout:
            return .biometryLockout
        default:
            return .failed
        }
    }

    func getBiometryTypeString() -> String {
        switch biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "密码"
        @unknown default:
            return "生物识别"
        }
    }
}
