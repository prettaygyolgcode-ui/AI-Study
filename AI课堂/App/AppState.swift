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
    @Published var parentSettings: ParentSettings
    @Published var teacherAccess: TeacherAccess
    @Published var teacherWorkspace: TeacherWorkspace
    @Published var backendSyncMessage: String?
    @Published var recentFriendIDs: [UUID] {
        didSet { persistLocalMemoryIfNeeded() }
    }
    @Published var favoriteFriendIDs: Set<UUID> {
        didSet { persistLocalMemoryIfNeeded() }
    }

    private let persistsLocalMemory: Bool
    private let backendClient: AppBackendClient?

    init(
        isLoggedIn: Bool = false,
        user: UserProfile,
        friends: [AIFriend],
        creationTypes: [CreationType],
        projects: [CreationProject],
        tasks: [ClassroomTask],
        voiceSettings: VoiceSettings,
        parentSettings: ParentSettings? = nil,
        teacherAccess: TeacherAccess? = nil,
        teacherWorkspace: TeacherWorkspace? = nil,
        recentFriendIDs: [UUID] = [],
        favoriteFriendIDs: Set<UUID> = [],
        persistsLocalMemory: Bool = false,
        backendClient: AppBackendClient? = nil
    ) {
        self.isLoggedIn = isLoggedIn
        self.user = user
        self.friends = friends
        self.creationTypes = creationTypes
        self.projects = projects
        self.tasks = tasks
        self.voiceSettings = voiceSettings
        self.parentSettings = parentSettings ?? ParentSettings()
        self.teacherAccess = teacherAccess ?? TeacherAccess()
        self.teacherWorkspace = teacherWorkspace ?? TeacherWorkspace()
        self.recentFriendIDs = recentFriendIDs
        self.favoriteFriendIDs = favoriteFriendIDs
        self.persistsLocalMemory = persistsLocalMemory
        self.backendClient = backendClient
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

    static var live: AppState {
        let seed = MockSeed.make()
        return AppState(
            user: seed.user,
            friends: seed.friends,
            creationTypes: seed.creationTypes,
            projects: seed.projects,
            tasks: seed.tasks,
            voiceSettings: seed.voiceSettings,
            recentFriendIDs: loadUUIDArray(forKey: recentFriendIDsKey),
            favoriteFriendIDs: Set(loadUUIDArray(forKey: favoriteFriendIDsKey)),
            persistsLocalMemory: true,
            backendClient: LiveAppBackendClient()
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

    var favoriteFriends: [AIFriend] {
        friends.filter { favoriteFriendIDs.contains($0.id) }
    }

    var classroomFriends: [AIFriend] {
        friends.filter(\.isClassroomAssigned)
    }

    var profileFriendGroups: [ProfileFriendGroup] {
        [
            ProfileFriendGroup(
                kind: .classroom,
                title: "课堂指定",
                emptyMessage: "老师指定的 AI 朋友会显示在这里。",
                friends: classroomFriends
            ),
            ProfileFriendGroup(
                kind: .favorites,
                title: "已收藏",
                emptyMessage: "进入伙伴对话页，点击右上角星星即可收藏。",
                friends: favoriteFriends
            ),
            ProfileFriendGroup(
                kind: .recent,
                title: "最近使用",
                emptyMessage: "点击任意 AI 朋友开始对话后，会显示在这里。",
                friends: recentFriends
            )
        ]
    }

    func project(id: UUID) -> CreationProject? {
        projects.first(where: { $0.id == id })
    }

    func projects(for status: CreationProject.Status) -> [CreationProject] {
        projects.filter { $0.status == status }
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

    func isFavorite(_ friend: AIFriend) -> Bool {
        favoriteFriendIDs.contains(friend.id)
    }

    func toggleFavorite(_ friend: AIFriend) {
        if favoriteFriendIDs.contains(friend.id) {
            favoriteFriendIDs.remove(friend.id)
        } else {
            favoriteFriendIDs.insert(friend.id)
        }
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
            rating: 0
        )

        projects.insert(project, at: 0)
        return project
    }

    func generateProject(type: CreationType.Kind, prompt: CreationPrompt) -> CreationProject {
        let project = CreationProject.generated(type: type, prompt: prompt, author: user.nickname)
        projects.insert(project, at: 0)
        return project
    }

    func requestBackendLoginCode(phoneNumber: String) async {
        guard let backendClient else { return }

        do {
            try await backendClient.sendLoginCode(phone: phoneNumber)
            backendSyncMessage = "验证码已发送"
        } catch {
            backendSyncMessage = "验证码发送失败，仍可使用本地验证码继续体验"
        }
    }

    func loginWithBackend(phoneNumber: String, code: String) async -> Bool {
        guard let backendClient else {
            return code == "123456"
        }

        do {
            let session = try await backendClient.login(phone: phoneNumber, code: code)
            user.parentPhoneNumber = phoneNumber
            user.nickname = session.displayName
            isLoggedIn = true
            backendSyncMessage = "已连接后台"
            await refreshBackendP0Content()
            return true
        } catch {
            backendSyncMessage = "后台登录失败"
            return false
        }
    }

    func refreshBackendP0Content() async {
        await refreshBackendBootstrap()
        await refreshBackendWorks()
    }

    func refreshBackendBootstrap() async {
        guard let backendClient else { return }

        do {
            let configuration = try await backendClient.fetchBootstrap()
            applyBackendConfiguration(configuration)
            backendSyncMessage = "课堂配置已从后台更新"
        } catch {
            backendSyncMessage = "后台配置暂时不可用，已保留本地内容"
        }
    }

    func refreshBackendWorks() async {
        guard let backendClient else { return }

        do {
            let remoteProjects = try await backendClient.fetchWorks().compactMap(\.plazaProject)
            mergeRemotePlazaProjects(remoteProjects)
            backendSyncMessage = "广场作品已从后台更新"
        } catch {
            backendSyncMessage = "广场暂时使用本地内容"
        }
    }

    func submitProjectToBackendIfPossible(_ project: CreationProject) async {
        guard let backendClient else { return }

        do {
            _ = try await backendClient.createWork(from: project)
            backendSyncMessage = "作品已提交后台审核"
        } catch {
            backendSyncMessage = "作品保存在本地，暂未提交后台"
        }
    }

    func saveProject(id: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == id }) else { return }
        projects[index].status = .pendingReview
        projects[index].updatedAt = .now
    }

    func requestProjectPublishing(id: UUID) {
        guard parentSettings.allowPublicPublishing, parentSettings.isPublicWorksEnabled else { return }
        saveProject(id: id)
    }

    func publishProject(id: UUID) {
        guard parentSettings.allowPublicPublishing, parentSettings.isPublicWorksEnabled else { return }
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

    func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
    }

    func verifyParentManagementPassword(_ password: String) -> Bool {
        password == "0000"
    }

    func authorizeTeacherPreview() {
        teacherAccess = TeacherAccess(isAuthorized: true, teacherName: "演示老师", classroomName: "客户端预览")
    }

    func teacherCourses(for ageBand: TeacherAgeBand) -> [TeacherCourse] {
        teacherWorkspace.courses.filter { $0.ageBand == ageBand }
    }

    func createTeacherClassroom(name: String, ageBand: TeacherAgeBand) -> TeacherClassroom {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let classroom = TeacherClassroom(
            id: UUID(),
            name: trimmedName.isEmpty ? "\(ageBand.title)班级" : trimmedName,
            ageBand: ageBand,
            studentBindings: []
        )
        teacherWorkspace.classrooms.insert(classroom, at: 0)
        return classroom
    }

    func bindStudent(parentPhoneNumber: String, studentName: String, to classroomID: UUID) {
        guard let index = teacherWorkspace.classrooms.firstIndex(where: { $0.id == classroomID }) else { return }

        let trimmedName = studentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = parentPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let binding = StudentBinding(
            id: UUID(),
            studentName: trimmedName.isEmpty ? "未命名学生" : trimmedName,
            parentPhoneNumber: trimmedPhone,
            completedTaskCount: tasks.filter { $0.status == .completed }.count,
            totalTaskCount: tasks.count
        )

        teacherWorkspace.classrooms[index].studentBindings.append(binding)
    }

    func playTeacherCourse(courseID: UUID, classroomID: UUID?) {
        guard let courseIndex = teacherWorkspace.courses.firstIndex(where: { $0.id == courseID }) else { return }
        let classroom = classroomID.flatMap { id in
            teacherWorkspace.classrooms.first { $0.id == id }
        }

        teacherWorkspace.courses[courseIndex].progress = min(1, teacherWorkspace.courses[courseIndex].progress + 0.25)
        let course = teacherWorkspace.courses[courseIndex]
        let record = CoursePlaybackRecord(
            id: UUID(),
            courseTitle: course.title,
            classroomName: classroom?.name ?? "未选择班级",
            playedAt: .now,
            playedMinutes: min(10, course.durationMinutes),
            progress: course.progress
        )
        teacherWorkspace.playbackRecords.insert(record, at: 0)
    }

    func approveProjectForPlaza(projectID: UUID) {
        publishProject(id: projectID)
    }

    func rejectProject(projectID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].isPublished = false
        projects[index].status = .rejected
        projects[index].updatedAt = .now
    }

    func generateTeacherComment(for projectID: UUID) -> String {
        guard let project = project(id: projectID) else { return "" }
        let style = teacherWorkspace.commentStylePhrases.joined(separator: "，")
        let comment = "\(project.title)有清楚的想法和表达亮点。建议下一步补充一个更具体的细节，让作品更完整。点评风格：\(style)。"
        teacherWorkspace.latestGeneratedComment = comment
        return comment
    }

    func applyBackendConfiguration(_ configuration: AppBackendConfiguration) {
        if !configuration.friends.isEmpty {
            friends = configuration.friends
        }

        if !configuration.creationTypes.isEmpty {
            creationTypes = configuration.creationTypes
        }

        parentSettings = configuration.parentSettings
    }

    private func mergeRemotePlazaProjects(_ remoteProjects: [CreationProject]) {
        for remoteProject in remoteProjects {
            if let index = projects.firstIndex(where: { $0.id == remoteProject.id }) {
                projects[index] = remoteProject
            } else {
                projects.insert(remoteProject, at: 0)
            }
        }
    }
}

private extension AppState {
    static var recentFriendIDsKey: String {
        "AIClassroom.recentFriendIDs"
    }

    static var favoriteFriendIDsKey: String {
        "AIClassroom.favoriteFriendIDs"
    }

    static func loadUUIDArray(forKey key: String) -> [UUID] {
        UserDefaults.standard.stringArray(forKey: key)?.compactMap(UUID.init(uuidString:)) ?? []
    }

    func persistLocalMemoryIfNeeded() {
        guard persistsLocalMemory else { return }

        UserDefaults.standard.set(recentFriendIDs.map(\.uuidString), forKey: Self.recentFriendIDsKey)
        UserDefaults.standard.set(favoriteFriendIDs.map(\.uuidString), forKey: Self.favoriteFriendIDsKey)
    }
}
