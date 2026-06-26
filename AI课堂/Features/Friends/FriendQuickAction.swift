import Foundation

struct FriendQuickAction: Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let kind: CreationType.Kind
}
