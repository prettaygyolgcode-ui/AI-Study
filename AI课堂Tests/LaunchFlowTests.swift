import Testing
@testable import AI课堂

struct LaunchFlowTests {
    @Test
    func routeShowsSplashBeforeAnyAuthDecision() {
        #expect(LaunchFlow.route(hasFinishedSplash: false, isLoggedIn: false) == .splash)
        #expect(LaunchFlow.route(hasFinishedSplash: false, isLoggedIn: true) == .splash)
    }

    @Test
    func routeShowsLoginAfterSplashWhenLoggedOut() {
        #expect(LaunchFlow.route(hasFinishedSplash: true, isLoggedIn: false) == .login)
    }

    @Test
    func routeShowsHomeAfterSplashWhenLoggedIn() {
        #expect(LaunchFlow.route(hasFinishedSplash: true, isLoggedIn: true) == .home)
    }
}
