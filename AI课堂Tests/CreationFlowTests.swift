import Testing
@testable import AI课堂

@MainActor
struct CreationFlowTests {
    @Test
    func selectingFriendMarksItRecentlyUsed() {
        let state = AppState.preview
        let friend = state.friends[0]

        state.openFriend(friend)

        #expect(state.recentFriendIDs.first == friend.id)
    }

    @Test
    func friendQuickActionCreatesDraftProject() {
        let state = AppState.preview
        let friend = state.friends[0]

        let project = state.makeDraftFromFriend(friend, type: .story)

        #expect(project.type == .story)
        #expect(project.origin == .friend(friend.id))
        #expect(project.status == .draft)
        #expect(state.projects.first?.id == project.id)
    }

    @Test
    func submittingFormCreatesPendingReviewProject() {
        let state = AppState.preview
        let prompt = CreationPrompt(
            title: "太空冒险",
            subject: "小宇航员和月球猫",
            style: "科幻",
            mood: "勇敢"
        )

        let project = state.generateProject(type: .story, prompt: prompt)

        #expect(project.status == .pendingReview)
        #expect(project.title == "太空冒险")
        #expect(project.prompt == prompt)
        #expect(state.projects.first?.title == "太空冒险")
    }

    @Test
    func publishProjectMakesItVisibleInPlaza() {
        let state = AppState.preview
        let prompt = CreationPrompt(
            title: "未来火车站",
            subject: "会飞的列车",
            style: "明亮",
            mood: "兴奋"
        )
        let project = state.generateProject(type: .drawing, prompt: prompt)

        state.publishProject(id: project.id)

        #expect(state.project(id: project.id)?.isPublished == true)
        #expect(state.project(id: project.id)?.status == .published)
        #expect(state.plazaProjects.contains { $0.id == project.id })
    }

    @Test
    func deletingProjectRemovesItFromCreationsAndPlaza() {
        let state = AppState.preview
        let project = state.generateProject(
            type: .story,
            prompt: CreationPrompt(title: "待删除作品", subject: "主题", style: "风格", mood: "感受")
        )
        state.publishProject(id: project.id)

        state.deleteProject(id: project.id)

        #expect(state.project(id: project.id) == nil)
        #expect(!state.plazaProjects.contains { $0.id == project.id })
    }
}
