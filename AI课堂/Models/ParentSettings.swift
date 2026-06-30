import Foundation

enum AIFeaturePermission: String, CaseIterable, Identifiable, Hashable {
    case story
    case image
    case music
    case animation
    case game
    case video

    var id: String { rawValue }

    var title: String {
        switch self {
        case .story:
            return "故事"
        case .image:
            return "图画"
        case .music:
            return "音乐"
        case .animation:
            return "动画"
        case .game:
            return "游戏"
        case .video:
            return "视频"
        }
    }

    var icon: String {
        switch self {
        case .story:
            return "book.closed.fill"
        case .image:
            return "paintpalette.fill"
        case .music:
            return "music.note"
        case .animation:
            return "sparkles.tv.fill"
        case .game:
            return "gamecontroller.fill"
        case .video:
            return "video.fill"
        }
    }
}

struct ParentSettings: Equatable {
    var computeBudgetLimit = 100
    var dailyMinutesLimit = 60
    var enabledAIFeatures = Set(AIFeaturePermission.allCases)
    var allowPublicPublishing = true
    var isAutoNarrationEnabled = true
    var isVoiceInputEnabled = true
    var isPublicWorksEnabled = true
}
