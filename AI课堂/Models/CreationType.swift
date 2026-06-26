import Foundation
import SwiftUI

struct CreationType: Identifiable, Equatable, Hashable {
    enum Kind: String, CaseIterable, Identifiable {
        case story
        case drawing
        case music
        case animation
        case game
        case report

        var id: String { rawValue }
    }

    let id: Kind
    let kind: Kind
    let name: String
    let subtitle: String
    let icon: String
    let accentName: String
}

extension CreationType.Kind {
    var outputName: String {
        switch self {
        case .story:
            return "故事"
        case .drawing:
            return "图画"
        case .music:
            return "音乐"
        case .animation:
            return "动画"
        case .game:
            return "游戏"
        case .report:
            return "报告"
        }
    }

    var formTitle: String {
        switch self {
        case .story:
            return "先想主角和冒险"
        case .drawing:
            return "先想画面和颜色"
        case .music:
            return "先想旋律和节奏"
        case .animation:
            return "先想角色和动作"
        case .game:
            return "先想规则和目标"
        case .report:
            return "先想主题和观察结论"
        }
    }

    var formHint: String {
        switch self {
        case .story:
            return "标题和主题填清楚后，就能快速生成一个可继续完善的故事草稿。"
        case .drawing:
            return "描述你想画的场景、风格和感受，先生成一张图画作品卡。"
        case .music:
            return "告诉它你喜欢的音乐气质，先生成一段可以继续扩展的音乐作品。"
        case .animation:
            return "把剧情、画风和情绪说清楚，先拼出一个动画创意原型。"
        case .game:
            return "写下玩法和氛围，先得到一个可以继续完善的游戏方案。"
        case .report:
            return "说明主题和观察重点，先得到一个条理清晰的课堂报告草稿。"
        }
    }

    var defaultCoverSymbol: String {
        switch self {
        case .story:
            return "📚"
        case .drawing:
            return "🎨"
        case .music:
            return "🎵"
        case .animation:
            return "🎬"
        case .game:
            return "🎮"
        case .report:
            return "📝"
        }
    }

    var sampleSuggestions: [String] {
        switch self {
        case .story:
            return ["月球冒险", "会说话的小猫", "勇敢", "科幻"]
        case .drawing:
            return ["海底城市", "彩色铅笔风", "明亮", "未来教室"]
        case .music:
            return ["星空夜曲", "轻快", "钢琴", "勇气"]
        case .animation:
            return ["纸飞机旅行", "童话", "温暖", "会飞的书包"]
        case .game:
            return ["彩虹跑酷", "闯关", "兴奋", "收集星星"]
        case .report:
            return ["火山观察", "科学记录", "清晰", "课堂实验"]
        }
    }
}

extension CreationType {
    var tintColor: Color {
        switch kind {
        case .story:
            return Color(red: 0.98, green: 0.55, blue: 0.42)
        case .drawing:
            return Color(red: 0.34, green: 0.72, blue: 0.63)
        case .music:
            return Color(red: 0.98, green: 0.73, blue: 0.27)
        case .animation:
            return Color(red: 0.44, green: 0.63, blue: 0.98)
        case .game:
            return Color(red: 0.86, green: 0.45, blue: 0.86)
        case .report:
            return Color(red: 0.47, green: 0.57, blue: 0.72)
        }
    }
}
