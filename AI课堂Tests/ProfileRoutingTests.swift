import Testing
@testable import AI课堂

struct ProfileRoutingTests {
    @Test
    func allPrimaryTabsAreAvailable() {
        let tabs = AppTab.allCases.map(\.title)

        #expect(tabs == ["AI朋友", "AI创作", "广场", "我的"])
    }
}
