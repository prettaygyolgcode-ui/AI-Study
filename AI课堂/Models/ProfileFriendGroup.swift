import Foundation

struct ProfileFriendGroup: Identifiable, Equatable {
    enum Kind: String, CaseIterable, Identifiable {
        case classroom
        case favorites
        case recent

        var id: String { rawValue }
    }

    let kind: Kind
    let title: String
    let emptyMessage: String
    let friends: [AIFriend]

    var id: Kind { kind }
}
