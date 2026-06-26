import Foundation
import SwiftUI

struct CreationProject: Identifiable, Equatable, Hashable {
    enum Status: String, Equatable, Hashable {
        case draft
        case saved
        case published
    }

    enum Origin: Equatable, Hashable {
        case manual
        case friend(UUID)
    }

    let id: UUID
    var type: CreationType.Kind
    var title: String
    var previewText: String
    var authorName: String
    var coverSymbol: String
    var status: Status
    var origin: Origin
    var isPublished: Bool
    var likeCount: Int
    var rating: Double
    var userRating: Int?
    var isLiked = false
    var prompt: CreationPrompt? = nil
    var updatedAt: Date = .now
}

extension CreationProject {
    static func generated(type: CreationType.Kind, prompt: CreationPrompt, author: String) -> CreationProject {
        CreationProject(
            id: UUID(),
            type: type,
            title: prompt.title,
            previewText: type.previewText(for: prompt),
            authorName: author,
            coverSymbol: type.defaultCoverSymbol,
            status: .saved,
            origin: .manual,
            isPublished: false,
            likeCount: 0,
            rating: 0,
            userRating: nil,
            prompt: prompt
        )
    }
}

extension CreationProject.Status {
    var displayTitle: String {
        switch self {
        case .draft:
            return "草稿"
        case .saved:
            return "已保存"
        case .published:
            return "已发布"
        }
    }

    var tintColor: Color {
        switch self {
        case .draft:
            return Color(red: 0.93, green: 0.63, blue: 0.24)
        case .saved:
            return Color(red: 0.31, green: 0.66, blue: 0.53)
        case .published:
            return Color(red: 0.36, green: 0.53, blue: 0.95)
        }
    }
}

extension CreationProject.Origin {
    func displayTitle(in appState: AppState) -> String {
        switch self {
        case .manual:
            return "手动创作"
        case let .friend(friendID):
            let friendName = appState.friends.first(where: { $0.id == friendID })?.name ?? "AI朋友"
            return "\(friendName)发起"
        }
    }
}

private extension CreationType.Kind {
    func previewText(for prompt: CreationPrompt) -> String {
        let subject = prompt.subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let style = prompt.style.trimmingCharacters(in: .whitespacesAndNewlines)
        let mood = prompt.mood.trimmingCharacters(in: .whitespacesAndNewlines)

        switch self {
        case .story:
            return "围绕\(subject)展开的\(style.isEmpty ? "创意" : style)故事，整体气质是\(mood.isEmpty ? "有想象力" : mood)。"
        case .drawing:
            return "一幅关于\(subject)的\(style.isEmpty ? "原创" : style)图画，画面氛围偏\(mood.isEmpty ? "明亮" : mood)。"
        case .music:
            return "一段以\(subject)为灵感的\(style.isEmpty ? "原创" : style)旋律，听感偏\(mood.isEmpty ? "轻快" : mood)。"
        case .animation:
            return "一个关于\(subject)的\(style.isEmpty ? "原创" : style)动画提案，整体节奏偏\(mood.isEmpty ? "生动" : mood)。"
        case .game:
            return "一个围绕\(subject)设计的\(style.isEmpty ? "创意" : style)小游戏方案，体验感偏\(mood.isEmpty ? "好玩" : mood)。"
        case .report:
            return "一份关于\(subject)的\(style.isEmpty ? "课堂" : style)报告草稿，表达方式偏\(mood.isEmpty ? "清晰" : mood)。"
        }
    }
}
