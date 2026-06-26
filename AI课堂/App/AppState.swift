import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: UserProfile
    @Published var friends: [AIFriend]
    @Published var creationTypes: [CreationType]
    @Published var projects: [CreationProject]
    @Published var tasks: [ClassroomTask]
    @Published var voiceSettings: VoiceSettings
    @Published var recentFriendIDs: [UUID]

    init(
        isLoggedIn: Bool = false,
        user: UserProfile,
        friends: [AIFriend],
        creationTypes: [CreationType],
        projects: [CreationProject],
        tasks: [ClassroomTask],
        voiceSettings: VoiceSettings,
        recentFriendIDs: [UUID] = []
    ) {
        self.isLoggedIn = isLoggedIn
        self.user = user
        self.friends = friends
        self.creationTypes = creationTypes
        self.projects = projects
        self.tasks = tasks
        self.voiceSettings = voiceSettings
        self.recentFriendIDs = recentFriendIDs
    }

    static var preview: AppState {
        let seed = MockSeed.make()
        return AppState(
            user: seed.user,
            friends: seed.friends,
            creationTypes: seed.creationTypes,
            projects: seed.projects,
            tasks: seed.tasks,
            voiceSettings: seed.voiceSettings
        )
    }

    var plazaProjects: [CreationProject] {
        projects.filter(\.isPublished)
    }

    var recentFriends: [AIFriend] {
        recentFriendIDs.compactMap { friendID in
            friends.first { $0.id == friendID }
        }
    }

    func project(id: UUID) -> CreationProject? {
        projects.first(where: { $0.id == id })
    }

    func plazaProjectsFiltered(by kind: CreationType.Kind?, sort: PlazaSort) -> [CreationProject] {
        let filtered = plazaProjects.filter { project in
            kind == nil || project.type == kind
        }

        switch sort {
        case .recommended:
            return filtered
        case .hot:
            return filtered.sorted { lhs, rhs in
                if lhs.likeCount == rhs.likeCount {
                    return lhs.rating > rhs.rating
                }
                return lhs.likeCount > rhs.likeCount
            }
        }
    }

    func openFriend(_ friend: AIFriend) {
        recentFriendIDs.removeAll { $0 == friend.id }
        recentFriendIDs.insert(friend.id, at: 0)
    }

    func makeDraftFromFriend(_ friend: AIFriend, type: CreationType.Kind) -> CreationProject {
        openFriend(friend)

        let typeName = creationTypes.first(where: { $0.kind == type })?.name ?? "创作"
        let project = CreationProject(
            id: UUID(),
            type: type,
            title: "\(friend.name)的\(typeName)",
            previewText: "这是从 \(friend.name) 发起的一份新草稿，你可以继续完善它。",
            authorName: user.nickname,
            coverSymbol: friend.emoji,
            status: .draft,
            origin: .friend(friend.id),
            isPublished: false,
            likeCount: 0,
            rating: 0,
            userRating: nil
        )

        projects.insert(project, at: 0)
        return project
    }

    func generateProject(type: CreationType.Kind, prompt: CreationPrompt) -> CreationProject {
        let project = CreationProject.generated(type: type, prompt: prompt, author: user.nickname)
        projects.insert(project, at: 0)
        return project
    }

    func saveProject(id: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == id }) else { return }
        projects[index].status = .saved
        projects[index].updatedAt = .now
    }

    func publishProject(id: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == id }) else { return }
        projects[index].isPublished = true
        projects[index].status = .published
        projects[index].updatedAt = .now
    }

    func toggleLike(projectID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].isLiked.toggle()
        projects[index].likeCount += projects[index].isLiked ? 1 : -1
        projects[index].likeCount = max(0, projects[index].likeCount)
    }

    func rate(projectID: UUID, value: Int) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].userRating = min(max(value, 1), 5)
    }

    func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
    }
}
