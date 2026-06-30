import Testing
@testable import AI课堂

@MainActor
struct AppStateTests {
    @Test
    func bootstrapLoadsPrototypeConfigurationWithoutSeededUserContent() {
        let state = AppState.preview

        #expect(state.friends.count == 6)
        #expect(state.creationTypes.count == 5)
        #expect(!state.creationTypes.contains { $0.kind.rawValue == "report" })
        #expect(state.projects.isEmpty)
        #expect(state.plazaProjects.isEmpty)
        #expect(state.tasks.isEmpty)
        #expect(state.isLoggedIn == false)
    }
}
