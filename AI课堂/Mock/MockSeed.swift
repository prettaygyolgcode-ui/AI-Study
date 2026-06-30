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
            nickname: "同学",
            parentPhoneNumber: "",
            classroomName: "AI课堂"
        )

        let creationTypes: [CreationType] = [
            CreationType(id: .story, kind: .story, name: "故事卡", subtitle: "写一个有趣故事", icon: "book.closed.fill", accentName: "Story"),
            CreationType(id: .drawing, kind: .drawing, name: "图画卡", subtitle: "画一张想象中的画", icon: "paintpalette.fill", accentName: "Drawing"),
            CreationType(id: .music, kind: .music, name: "音乐卡", subtitle: "做一段旋律", icon: "music.note", accentName: "Music"),
            CreationType(id: .animation, kind: .animation, name: "动画卡", subtitle: "做一个会动的故事", icon: "sparkles.tv.fill", accentName: "Animation"),
            CreationType(id: .game, kind: .game, name: "游戏卡", subtitle: "设计一个小游戏", icon: "gamecontroller.fill", accentName: "Game")
        ]

        let friends: [AIFriend] = [
            AIFriend(id: MockFriendIDs.story, name: "故事伙伴", subtitle: "陪你编故事", emoji: "📚", tags: ["会讲故事", "会想主角"], welcomeMessage: "今天想写一个什么样的故事？", quickActions: [
                FriendQuickAction(id: UUID(), title: "创作故事", kind: .story),
                FriendQuickAction(id: UUID(), title: "做故事动画", kind: .animation)
            ], isClassroomAssigned: true),
            AIFriend(id: MockFriendIDs.music, name: "音乐伙伴", subtitle: "陪你做旋律", emoji: "🎵", tags: ["会编音乐", "会找节奏"], welcomeMessage: "我们来做一段你喜欢的音乐吧。", quickActions: [
                FriendQuickAction(id: UUID(), title: "创作音乐", kind: .music),
                FriendQuickAction(id: UUID(), title: "做动画配乐", kind: .animation)
            ], isClassroomAssigned: true),
            AIFriend(id: MockFriendIDs.science, name: "科学伙伴", subtitle: "陪你做探索", emoji: "🔬", tags: ["会做实验", "会讲原理"], welcomeMessage: "想研究什么科学问题？", quickActions: [
                FriendQuickAction(id: UUID(), title: "画一张科学图", kind: .drawing),
                FriendQuickAction(id: UUID(), title: "设计实验游戏", kind: .game)
            ], isClassroomAssigned: true),
            AIFriend(id: MockFriendIDs.drawing, name: "画画伙伴", subtitle: "陪你画画", emoji: "🎨", tags: ["会画图", "会搭颜色"], welcomeMessage: "告诉我你想画什么画面。", quickActions: [
                FriendQuickAction(id: UUID(), title: "创作图画", kind: .drawing),
                FriendQuickAction(id: UUID(), title: "做一个动画", kind: .animation)
            ], isClassroomAssigned: true),
            AIFriend(id: MockFriendIDs.game, name: "游戏伙伴", subtitle: "陪你做游戏", emoji: "🎮", tags: ["会想玩法", "会写规则"], welcomeMessage: "我们来设计一个小游戏吧。", quickActions: [
                FriendQuickAction(id: UUID(), title: "设计游戏", kind: .game),
                FriendQuickAction(id: UUID(), title: "先写故事背景", kind: .story)
            ], isClassroomAssigned: true),
            AIFriend(id: MockFriendIDs.explore, name: "探索伙伴", subtitle: "陪你发现世界", emoji: "🧭", tags: ["会提问题", "会找灵感"], welcomeMessage: "今天你最想探索什么？", quickActions: [
                FriendQuickAction(id: UUID(), title: "写探索故事", kind: .story),
                FriendQuickAction(id: UUID(), title: "画一张发现地图", kind: .drawing)
            ], isClassroomAssigned: true)
        ]

        let projects: [CreationProject] = []
        let tasks: [ClassroomTask] = []

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

private enum MockFriendIDs {
    static let story = UUID(uuidString: "12F2D8B8-011C-4A10-9F85-3B9B8C8B3D01")!
    static let music = UUID(uuidString: "D87551D5-C2D2-44E8-9168-F9B15D7CF102")!
    static let science = UUID(uuidString: "D9700310-4107-4996-BD40-61B91001B35C")!
    static let drawing = UUID(uuidString: "9C62FA49-EA5D-48DB-9078-54CE4D0979B7")!
    static let game = UUID(uuidString: "4AF3D8E7-BC5B-4876-A349-90DF102781B9")!
    static let explore = UUID(uuidString: "E5EAB1F8-338F-4498-AE77-A281C458D55D")!
}
