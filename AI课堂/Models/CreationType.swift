import Foundation
import SwiftUI

struct CreationType: Identifiable, Equatable, Hashable {
    enum Kind: String, CaseIterable, Identifiable {
        case story
        case drawing
        case music
        case animation
        case game

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
        }
    }
}
