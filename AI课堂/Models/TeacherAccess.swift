import Foundation

struct TeacherAccess: Equatable {
    var isAuthorized = false
    var teacherName = ""
    var classroomName = ""

    var statusText: String {
        isAuthorized ? "已开通" : "未开通"
    }
}
