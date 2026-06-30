import Testing
@testable import AI课堂

struct PromptCanvasDraftTests {
    @Test
    func draftRequiresFieldsInOrderAndBuildsPromptWhenComplete() {
        var draft = PromptCanvasDraft()

        #expect(draft.canSelect(.seed))
        #expect(!draft.canSelect(.theme))
        #expect(draft.prompt == nil)

        draft.selectSeed(PromptSeedInput(plot: "小鹿在森林里找到发光地图", protagonist: .girl, ageRange: .sixToEight))

        #expect(draft.canSelect(.theme))
        #expect(!draft.canSelect(.style))

        draft.select("冒险", for: .theme)
        draft.select("勇气", for: .value)
        draft.select("水彩童话", for: .style)

        #expect(draft.isComplete)
        #expect(draft.completedFields == [.seed, .theme, .value, .style])
        #expect(draft.value(for: .seed)?.contains("小鹿在森林里找到发光地图") == true)
        #expect(draft.prompt == CreationPrompt(
            title: "小鹿在森林里找到发光地图",
            subject: "主题：冒险；种子：小鹿在森林里找到发光地图；主角：女孩；年龄：6～8岁",
            style: "水彩童话",
            mood: "勇气"
        ))
    }

    @Test
    func seedRequiresStoryPlot() {
        var draft = PromptCanvasDraft()

        draft.selectSeed(PromptSeedInput(plot: "   ", protagonist: .boy, ageRange: .fourToFive))

        #expect(draft.value(for: .seed) == nil)
        #expect(!draft.canSelect(.theme))
    }

    @Test
    func selectingFieldAgainUpdatesValueWithoutChangingOrder() {
        var draft = PromptCanvasDraft()

        draft.selectSeed(PromptSeedInput(plot: "第一版剧情", protagonist: .unspecified, ageRange: .nineToTwelve))
        draft.selectSeed(PromptSeedInput(plot: "新的剧情", protagonist: .boy, ageRange: .nineToTwelve))

        #expect(draft.value(for: .seed)?.contains("新的剧情") == true)
        #expect(draft.completedFields == [.seed])
    }

    @Test
    func canvasFieldsExposeKidFriendlyPresetOptions() {
        #expect(PromptCanvasField.allCases == [.seed, .theme, .value, .style])
        #expect(PromptCanvasField.theme.options.map(\.title) == ["冒险", "友谊", "家庭", "自然", "魔法", "动物", "太空", "海洋"])
        #expect(PromptCanvasField.value.options.map(\.title) == ["勇气", "善良", "诚实", "坚持", "分享", "尊重", "创造力", "感恩"])
        #expect(PromptCanvasField.style.options.map(\.title) == ["温馨卡通", "水彩童话", "国风绘本", "3D皮克斯"])
    }
}
