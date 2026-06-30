import Foundation

enum TeacherAgeBand: String, CaseIterable, Identifiable, Hashable {
    case age2to3
    case age4to5
    case age6to8
    case age9to12

    var id: String { rawValue }

    var title: String {
        switch self {
        case .age2to3:
            return "2-3岁"
        case .age4to5:
            return "4-5岁"
        case .age6to8:
            return "6-8岁"
        case .age9to12:
            return "9-12岁"
        }
    }
}

struct TeacherCourse: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var ageBand: TeacherAgeBand
    var durationMinutes: Int
    var progress: Double
    var uploadSource: String
}

struct StudentBinding: Identifiable, Equatable, Hashable {
    let id: UUID
    var studentName: String
    var parentPhoneNumber: String
    var completedTaskCount: Int
    var totalTaskCount: Int
}

struct TeacherClassroom: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var ageBand: TeacherAgeBand
    var studentBindings: [StudentBinding]
}

struct CoursePlaybackRecord: Identifiable, Equatable, Hashable {
    let id: UUID
    var courseTitle: String
    var classroomName: String
    var playedAt: Date
    var playedMinutes: Int
    var progress: Double
}

struct TeacherWorkspace: Equatable {
    var selectedAgeBand: TeacherAgeBand = .age6to8
    var courses: [TeacherCourse] = TeacherWorkspace.defaultCourses
    var classrooms: [TeacherClassroom] = []
    var playbackRecords: [CoursePlaybackRecord] = []
    var commentStylePhrases: [String] = ["先肯定亮点", "给一个具体建议", "语气温和鼓励"]
    var latestGeneratedComment = ""
}

extension TeacherWorkspace {
    static let defaultCourses: [TeacherCourse] = [
        TeacherCourse(
            id: UUID(uuidString: "2BDB4CE3-4F70-4D29-9A31-E56FC8800001")!,
            title: "小小故事种子",
            ageBand: .age2to3,
            durationMinutes: 12,
            progress: 0,
            uploadSource: "Web后台"
        ),
        TeacherCourse(
            id: UUID(uuidString: "2BDB4CE3-4F70-4D29-9A31-E56FC8800002")!,
            title: "颜色和情绪",
            ageBand: .age4to5,
            durationMinutes: 18,
            progress: 0,
            uploadSource: "Web后台"
        ),
        TeacherCourse(
            id: UUID(uuidString: "2BDB4CE3-4F70-4D29-9A31-E56FC8800003")!,
            title: "AI 绘本第一课",
            ageBand: .age6to8,
            durationMinutes: 25,
            progress: 0,
            uploadSource: "Web后台"
        ),
        TeacherCourse(
            id: UUID(uuidString: "2BDB4CE3-4F70-4D29-9A31-E56FC8800004")!,
            title: "创意项目表达",
            ageBand: .age9to12,
            durationMinutes: 35,
            progress: 0,
            uploadSource: "Web后台"
        )
    ]
}
