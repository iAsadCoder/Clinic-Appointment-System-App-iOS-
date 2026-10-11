import SwiftUI

enum AppPhase {
    case splash, landing, login, authenticated
}

struct ContentView: View {
    @State private var phase: AppPhase = .splash
    @State private var currentRole: UserRole = .patient
    @State private var currentUserId: Int = 1

    var body: some View {
        Group {
            switch phase {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) { phase = .landing }
                }
            case .landing:
                LandingView {
                    withAnimation(.easeInOut(duration: 0.4)) { phase = .login }
                }
            case .login:
                LoginView { role, userId in
                    currentRole = role
                    currentUserId = userId
                    withAnimation(.easeInOut(duration: 0.35)) { phase = .authenticated }
                }
            case .authenticated:
                RolePortalView(role: currentRole, userId: currentUserId) {
                    withAnimation(.easeInOut(duration: 0.3)) { phase = .login }
                }
            }
        }
        .environmentObject(MockDataService.shared)
    }
}

#Preview {
    ContentView()
}
