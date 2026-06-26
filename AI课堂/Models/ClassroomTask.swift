import Foundation

struct ClassroomTask: Identifiable, Equatable {
    enum Status: String, Equatable {
        case notStarted
        case inProgress
        case completed
    }

    let id: UUID
    var title: String
    var detail: String
    var status: Status
    var recommendedType: CreationType.Kind
}
