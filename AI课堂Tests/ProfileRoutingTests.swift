import Testing
@testable import AI课堂

@MainActor
struct ProfileRoutingTests {
    @Test
    func allPrimaryTabsAreAvailable() {
        let tabs = AppTab.allCases.map(\.title)

        #expect(tabs == ["AI朋友", "AI创作", "广场", "我的"])
    }

    @Test
    func recentFriendsReturnsLatestOpenedFirst() {
        let state = AppState.preview
        let first = state.friends[0]
        let second = state.friends[1]

        state.openFriend(first)
        state.openFriend(second)

        #expect(state.recentFriends.map(\.id) == [second.id, first.id])
    }

    @Test
    func voiceSettingsUpdatePersistsInState() {
        let state = AppState.preview

        state.voiceSettings.isNarrationEnabled = false
        state.voiceSettings.speed = .fast
        state.voiceSettings.tone = .calm

        #expect(state.voiceSettings.isNarrationEnabled == false)
        #expect(state.voiceSettings.speed == .fast)
        #expect(state.voiceSettings.tone == .calm)
    }
}
