import Foundation

struct UserProfile: Identifiable, Equatable {
    let id: UUID
    var nickname: String
    var parentPhoneNumber: String
    var classroomName: String
}
