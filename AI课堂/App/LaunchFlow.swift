import Foundation

enum LaunchRoute: Equatable {
    case splash
    case login
    case home
}

enum LaunchFlow {
    static func route(hasFinishedSplash: Bool, isLoggedIn: Bool) -> LaunchRoute {
        guard hasFinishedSplash else { return .splash }
        return isLoggedIn ? .home : .login
    }
}
