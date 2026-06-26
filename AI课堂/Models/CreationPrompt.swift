import Foundation

struct CreationPrompt: Equatable, Hashable {
    var title: String
    var subject: String
    var style: String
    var mood: String

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
