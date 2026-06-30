import Testing
@testable import AI课堂

@MainActor
struct PlazaInteractionTests {
    @Test
    func filteringPlazaByTypeReturnsOnlySelectedType() {
        let state = AppState.preview
        publishProject(state: state, type: .story, title: "故事作品")
        publishProject(state: state, type: .drawing, title: "图画作品")

        let stories = state.plazaProjectsFiltered(by: .story, sort: .recommended)

        #expect(!stories.isEmpty)
        #expect(stories.allSatisfy { $0.type == .story })
    }

    @Test
    func hotSortOrdersPlazaByLikeCountDescending() {
        let state = AppState.preview
        let first = publishProject(state: state, type: .story, title: "第一个作品")
        let second = publishProject(state: state, type: .drawing, title: "第二个作品")

        state.projects[state.projects.firstIndex(where: { $0.id == first.id })!].likeCount = 1
        state.projects[state.projects.firstIndex(where: { $0.id == second.id })!].likeCount = 2

        let hotProjects = state.plazaProjectsFiltered(by: nil, sort: .hot)

        #expect(hotProjects.count >= 2)
        #expect(zip(hotProjects, hotProjects.dropFirst()).allSatisfy { current, next in
            current.likeCount >= next.likeCount
        })
    }

    @Test
    func togglingLikeAddsAndRemovesOneLike() {
        let state = AppState.preview
        let project = publishProject(state: state, type: .game, title: "可点赞作品")
        let originalLikeCount = project.likeCount

        state.toggleLike(projectID: project.id)
        #expect(state.project(id: project.id)?.isLiked == true)
        #expect(state.project(id: project.id)?.likeCount == originalLikeCount + 1)

        state.toggleLike(projectID: project.id)
        #expect(state.project(id: project.id)?.isLiked == false)
        #expect(state.project(id: project.id)?.likeCount == originalLikeCount)
    }

    @Test
    func publishedProjectKeepsReadOnlyScore() {
        let state = AppState.preview
        let project = publishProject(state: state, type: .animation, title: "有分数作品")

        state.projects[state.projects.firstIndex(where: { $0.id == project.id })!].rating = 4.6

        #expect(state.project(id: project.id)?.rating == 4.6)
    }

    private func publishProject(state: AppState, type: CreationType.Kind, title: String) -> CreationProject {
        let project = state.generateProject(
            type: type,
            prompt: CreationPrompt(title: title, subject: "主题", style: "风格", mood: "感受")
        )
        state.publishProject(id: project.id)
        return state.project(id: project.id)!
    }
}
