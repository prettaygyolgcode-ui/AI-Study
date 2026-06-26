import Foundation

struct MockSeed {
    let user: UserProfile
    let friends: [AIFriend]
    let creationTypes: [CreationType]
    let projects: [CreationProject]
    let tasks: [ClassroomTask]
    let voiceSettings: VoiceSettings

    static func make() -> MockSeed {
        let user = UserProfile(
            id: UUID(),
            nickname: "小宇",
            parentPhoneNumber: "13800138000",
            classroomName: "AI创作课"
        )

        let creationTypes: [CreationType] = [
            CreationType(id: .story, kind: .story, name: "故事卡", subtitle: "写一个有趣故事", icon: "book.closed.fill", accentName: "Story"),
            CreationType(id: .drawing, kind: .drawing, name: "图画卡", subtitle: "画一张想象中的画", icon: "paintpalette.fill", accentName: "Drawing"),
            CreationType(id: .music, kind: .music, name: "音乐卡", subtitle: "做一段旋律", icon: "music.note", accentName: "Music"),
            CreationType(id: .animation, kind: .animation, name: "动画卡", subtitle: "做一个会动的故事", icon: "sparkles.tv.fill", accentName: "Animation"),
            CreationType(id: .game, kind: .game, name: "游戏卡", subtitle: "设计一个小游戏", icon: "gamecontroller.fill", accentName: "Game"),
            CreationType(id: .report, kind: .report, name: "报告卡", subtitle: "整理学习报告", icon: "doc.text.fill", accentName: "Report")
        ]

        let friends: [AIFriend] = [
            AIFriend(id: UUID(), name: "故事伙伴", subtitle: "陪你编故事", emoji: "📚", tags: ["会讲故事", "会想主角"], welcomeMessage: "今天想写一个什么样的故事？", quickActions: [
                FriendQuickAction(id: UUID(), title: "创作故事", kind: .story),
                FriendQuickAction(id: UUID(), title: "做课堂报告", kind: .report)
            ]),
            AIFriend(id: UUID(), name: "音乐伙伴", subtitle: "陪你做旋律", emoji: "🎵", tags: ["会编音乐", "会找节奏"], welcomeMessage: "我们来做一段你喜欢的音乐吧。", quickActions: [
                FriendQuickAction(id: UUID(), title: "创作音乐", kind: .music),
                FriendQuickAction(id: UUID(), title: "做动画配乐", kind: .animation)
            ]),
            AIFriend(id: UUID(), name: "科学伙伴", subtitle: "陪你做探索", emoji: "🔬", tags: ["会做实验", "会讲原理"], welcomeMessage: "想研究什么科学问题？", quickActions: [
                FriendQuickAction(id: UUID(), title: "做课堂报告", kind: .report),
                FriendQuickAction(id: UUID(), title: "画一张科学图", kind: .drawing)
            ]),
            AIFriend(id: UUID(), name: "画画伙伴", subtitle: "陪你画画", emoji: "🎨", tags: ["会画图", "会搭颜色"], welcomeMessage: "告诉我你想画什么画面。", quickActions: [
                FriendQuickAction(id: UUID(), title: "创作图画", kind: .drawing),
                FriendQuickAction(id: UUID(), title: "做一个动画", kind: .animation)
            ]),
            AIFriend(id: UUID(), name: "游戏伙伴", subtitle: "陪你做游戏", emoji: "🎮", tags: ["会想玩法", "会写规则"], welcomeMessage: "我们来设计一个小游戏吧。", quickActions: [
                FriendQuickAction(id: UUID(), title: "设计游戏", kind: .game),
                FriendQuickAction(id: UUID(), title: "先写故事背景", kind: .story)
            ]),
            AIFriend(id: UUID(), name: "探索伙伴", subtitle: "陪你发现世界", emoji: "🧭", tags: ["会提问题", "会找灵感"], welcomeMessage: "今天你最想探索什么？", quickActions: [
                FriendQuickAction(id: UUID(), title: "开始探索报告", kind: .report),
                FriendQuickAction(id: UUID(), title: "画一张发现地图", kind: .drawing)
            ])
        ]

        let projects: [CreationProject] = [
            CreationProject(id: UUID(), type: .story, title: "月球猫历险记", previewText: "一只会发光的小猫在月球上找到了秘密花园。", authorName: user.nickname, coverSymbol: "🌙", status: .published, origin: .manual, isPublished: true, likeCount: 26, rating: 4.7, userRating: nil),
            CreationProject(id: UUID(), type: .drawing, title: "海底机器人", previewText: "一台会发光的机器人正在海底采集珊瑚样本。", authorName: user.nickname, coverSymbol: "🤖", status: .published, origin: .manual, isPublished: true, likeCount: 18, rating: 4.5, userRating: nil),
            CreationProject(id: UUID(), type: .music, title: "星空进行曲", previewText: "节奏轻快，像在太空中飞行。", authorName: user.nickname, coverSymbol: "✨", status: .saved, origin: .manual, isPublished: false, likeCount: 8, rating: 4.2, userRating: nil),
            CreationProject(id: UUID(), type: .animation, title: "纸飞机飞向云端", previewText: "纸飞机穿过云层，遇见会说话的小鸟。", authorName: user.nickname, coverSymbol: "☁️", status: .saved, origin: .manual, isPublished: false, likeCount: 5, rating: 4.1, userRating: nil),
            CreationProject(id: UUID(), type: .game, title: "彩虹闯关", previewText: "沿着彩虹跳跳跳，收集星星通关。", authorName: user.nickname, coverSymbol: "🌈", status: .published, origin: .manual, isPublished: true, likeCount: 34, rating: 4.8, userRating: nil),
            CreationProject(id: UUID(), type: .report, title: "火山小报告", previewText: "介绍火山喷发的原因和观察笔记。", authorName: user.nickname, coverSymbol: "🌋", status: .saved, origin: .manual, isPublished: false, likeCount: 3, rating: 4.0, userRating: nil),
            CreationProject(id: UUID(), type: .story, title: "风筝镇的夏天", previewText: "风一吹，整座小镇的风筝都醒来了。", authorName: user.nickname, coverSymbol: "🪁", status: .draft, origin: .manual, isPublished: false, likeCount: 0, rating: 0, userRating: nil),
            CreationProject(id: UUID(), type: .drawing, title: "糖果森林", previewText: "一片长满糖果树的森林，地上是软软的棉花糖。", authorName: user.nickname, coverSymbol: "🍭", status: .published, origin: .manual, isPublished: true, likeCount: 22, rating: 4.6, userRating: nil)
        ]

        let tasks: [ClassroomTask] = [
            ClassroomTask(id: UUID(), title: "编一个睡前故事", detail: "围绕勇气主题创作一篇短故事。", status: .notStarted, recommendedType: .story),
            ClassroomTask(id: UUID(), title: "画出未来教室", detail: "用图画展示你心中的未来课堂。", status: .inProgress, recommendedType: .drawing),
            ClassroomTask(id: UUID(), title: "整理一次科学观察", detail: "把实验现象整理成课堂报告。", status: .completed, recommendedType: .report)
        ]

        let voiceSettings = VoiceSettings(isNarrationEnabled: true, speed: .normal, tone: .bright)

        return MockSeed(
            user: user,
            friends: friends,
            creationTypes: creationTypes,
            projects: projects,
            tasks: tasks,
            voiceSettings: voiceSettings
        )
    }
}
