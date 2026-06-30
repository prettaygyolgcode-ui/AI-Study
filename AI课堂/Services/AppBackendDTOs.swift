import Foundation

struct ApiResponseDTO<DataPayload: Decodable>: Decodable {
    let code: String
    let message: String
    let data: DataPayload
}

struct PageDTO<Item: Decodable>: Decodable {
    let items: [Item]
    let page: Int
    let pageSize: Int
    let total: Int
}

struct EmptyMessageDTO: Decodable {
    let message: String
}

struct LoginRequestDTO: Encodable {
    let phone: String
    let code: String
}

struct LoginResponseDTO: Decodable {
    let token: String
    let role: String
    let displayName: String
}

struct AppBootstrapDTO: Decodable {
    let appName: String
    let userNickname: String
    let aiFriends: [BackendAiFriendDTO]
    let creationCards: [BackendCreationCardDTO]
    let parentControl: BackendParentControlDTO

    func clientConfiguration() -> AppBackendConfiguration {
        AppBackendConfiguration(
            friends: aiFriends.compactMap(\.clientFriend),
            creationTypes: creationCards.compactMap(\.clientCreationType),
            parentSettings: parentControl.clientParentSettings
        )
    }
}

struct BackendAiFriendDTO: Decodable, Equatable {
    let id: UUID
    let name: String
    let icon: String
    let description: String
    let rolePrompt: String
    let status: String

    var clientFriend: AIFriend? {
        guard status == "ACTIVE" else { return nil }

        let kind = inferredCreationKind
        let quickActions = kind.map {
            [FriendQuickAction(id: UUID(), title: "创作\($0.outputName)", kind: $0)]
        } ?? []

        return AIFriend(
            id: id,
            name: name,
            subtitle: description,
            emoji: icon.backendEmoji,
            tags: ["课堂指定", "后台下发"],
            welcomeMessage: description,
            quickActions: quickActions,
            isClassroomAssigned: true,
            assignmentNote: "由后台配置下发"
        )
    }

    private var inferredCreationKind: CreationType.Kind? {
        if name.contains("故事") { return .story }
        if name.contains("音乐") { return .music }
        if name.contains("科学") || name.contains("画") { return .drawing }
        if name.contains("游戏") { return .game }
        return nil
    }
}

struct BackendCreationCardDTO: Decodable, Equatable {
    let id: UUID
    let type: String
    let name: String
    let icon: String
    let promptTemplate: String
    let status: String

    var clientCreationType: CreationType? {
        guard status == "ACTIVE", let kind = CreationType.Kind(rawValue: type) else { return nil }

        return CreationType(
            id: kind,
            kind: kind,
            name: name,
            subtitle: promptTemplate,
            icon: icon,
            accentName: kind.backendAccentName
        )
    }
}

struct BackendParentControlDTO: Decodable, Equatable {
    let computeBudgetLimit: Int
    let dailyMinutesLimit: Int
    let allowPublicPublishing: Bool
    let autoNarrationEnabled: Bool
    let voiceInputEnabled: Bool

    var clientParentSettings: ParentSettings {
        ParentSettings(
            computeBudgetLimit: computeBudgetLimit,
            dailyMinutesLimit: dailyMinutesLimit,
            enabledAIFeatures: Set(AIFeaturePermission.allCases),
            allowPublicPublishing: allowPublicPublishing,
            isAutoNarrationEnabled: autoNarrationEnabled,
            isVoiceInputEnabled: voiceInputEnabled,
            isPublicWorksEnabled: allowPublicPublishing
        )
    }
}

struct BackendWorkDTO: Decodable, Equatable {
    let id: UUID
    let type: String
    let title: String
    let authorName: String
    let status: String
    let published: Bool
    let recommended: Bool
    let likeCount: Int
    let score: Double

    var plazaProject: CreationProject? {
        guard published, status == "PUBLISHED", let kind = CreationType.Kind(rawValue: type) else {
            return nil
        }

        return CreationProject(
            id: id,
            type: kind,
            title: title,
            previewText: "这是一份已通过后台审核的\(kind.outputName)作品。",
            authorName: authorName,
            coverSymbol: kind.defaultCoverSymbol,
            status: .published,
            origin: .manual,
            isPublished: true,
            likeCount: likeCount,
            rating: score
        )
    }
}

struct CreateBackendWorkRequest: Encodable {
    let type: String
    let title: String
    let authorName: String

    init(project: CreationProject) {
        type = project.type.rawValue
        title = project.title
        authorName = project.authorName
    }
}

private extension String {
    var backendEmoji: String {
        switch self {
        case "book.closed.fill", "book.fill":
            return "📚"
        case "atom":
            return "🔬"
        case "paintpalette.fill":
            return "🎨"
        case "music.note":
            return "🎵"
        case "gamecontroller.fill":
            return "🎮"
        case "sparkles.tv.fill", "video.fill":
            return "🎬"
        case "safari.fill", "location.north.fill", "map.fill":
            return "🧭"
        default:
            return "✨"
        }
    }
}

private extension CreationType.Kind {
    var backendAccentName: String {
        switch self {
        case .story:
            return "Story"
        case .drawing:
            return "Drawing"
        case .music:
            return "Music"
        case .animation:
            return "Animation"
        case .game:
            return "Game"
        }
    }
}
