import SwiftUI

@main
struct AIPhotoClassifierApp: App {
    @StateObject private var authService = AuthenticationService.shared

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView {
                    authService.isAuthenticated = true
                }
            }
        }
    }
}
