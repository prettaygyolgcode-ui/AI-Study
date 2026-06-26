import Testing
@testable import AI课堂

@MainActor
struct AppStateTests {
    @Test
    func bootstrapLoadsPhaseOneMockData() {
        let state = AppState.preview

        #expect(state.friends.count == 6)
        #expect(state.creationTypes.count == 6)
        #expect(state.projects.count >= 8)
        #expect(state.plazaProjects.count >= 4)
        #expect(state.tasks.count == 3)
        #expect(state.isLoggedIn == false)
    }
}
