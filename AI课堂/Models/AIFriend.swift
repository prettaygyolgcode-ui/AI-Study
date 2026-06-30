import Foundation

struct AIFriend: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let emoji: String
    let tags: [String]
    let welcomeMessage: String
    let quickActions: [FriendQuickAction]
    var isClassroomAssigned = false
    var assignmentNote: String?
}
