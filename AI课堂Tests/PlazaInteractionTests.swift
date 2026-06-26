import Testing
@testable import AI课堂

@MainActor
struct PlazaInteractionTests {
    @Test
    func filteringPlazaByTypeReturnsOnlySelectedType() {
        let state = AppState.preview

        let stories = state.plazaProjectsFiltered(by: .story, sort: .recommended)

        #expect(!stories.isEmpty)
        #expect(stories.allSatisfy { $0.type == .story })
    }

    @Test
    func hotSortOrdersPlazaByLikeCountDescending() {
        let state = AppState.preview

        let hotProjects = state.plazaProjectsFiltered(by: nil, sort: .hot)

        #expect(hotProjects.count >= 2)
        #expect(zip(hotProjects, hotProjects.dropFirst()).allSatisfy { current, next in
            current.likeCount >= next.likeCount
        })
    }

    @Test
    func togglingLikeAddsAndRemovesOneLike() {
        let state = AppState.preview
        let project = state.plazaProjects[0]
        let originalLikeCount = project.likeCount

        state.toggleLike(projectID: project.id)
        #expect(state.project(id: project.id)?.isLiked == true)
        #expect(state.project(id: project.id)?.likeCount == originalLikeCount + 1)

        state.toggleLike(projectID: project.id)
        #expect(state.project(id: project.id)?.isLiked == false)
        #expect(state.project(id: project.id)?.likeCount == originalLikeCount)
    }

    @Test
    func ratingProjectStoresUserRating() {
        let state = AppState.preview
        let project = state.plazaProjects[0]

        state.rate(projectID: project.id, value: 4)

        #expect(state.project(id: project.id)?.userRating == 4)
    }
}
