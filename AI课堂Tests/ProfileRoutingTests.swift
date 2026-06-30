import Foundation
import Testing
@testable import AI课堂

@MainActor
struct ProfileRoutingTests {
    @Test
    func allPrimaryTabsAreAvailable() {
        let tabs = AppTab.allCases.map(\.title)

        #expect(tabs == ["AI朋友", "AI创作", "广场", "我的"])
    }

    @Test
    func recentFriendsReturnsLatestOpenedFirst() {
        let state = AppState.preview
        let first = state.friends[0]
        let second = state.friends[1]

        state.openFriend(first)
        state.openFriend(second)

        #expect(state.recentFriends.map(\.id) == [second.id, first.id])
    }

    @Test
    func friendBucketsExposeClientSideGroups() {
        let state = AppState.preview

        #expect(state.favoriteFriends.isEmpty)
        #expect(state.recentFriends.isEmpty)
        #expect(state.classroomFriends.contains { $0.name == "科学伙伴" })
        #expect(state.classroomFriends.contains { $0.name == "音乐伙伴" })
        #expect(state.classroomFriends.contains { $0.name == "画画伙伴" })
        #expect(state.classroomFriends.contains { $0.name == "游戏伙伴" })

        let allClassroomFriendsAreAssigned = state.classroomFriends.reduce(true) { result, friend in
            result && friend.isClassroomAssigned
        }
        #expect(allClassroomFriendsAreAssigned)
    }

    @Test
    func togglingFriendFavoriteUpdatesFavoritesBucket() {
        let state = AppState.preview
        let friend = state.friends[0]

        state.toggleFavorite(friend)

        #expect(state.isFavorite(friend))
        #expect(state.favoriteFriends.map(\.id) == [friend.id])

        state.toggleFavorite(friend)

        #expect(!state.isFavorite(friend))
        #expect(state.favoriteFriends.isEmpty)
    }

    @Test
    func voiceSettingsUpdatePersistsInState() {
        let state = AppState.preview

        state.voiceSettings.isNarrationEnabled = false
        state.voiceSettings.isVoiceInputEnabled = false
        state.voiceSettings.speed = .fast
        state.voiceSettings.tone = .calm

        #expect(state.voiceSettings.isNarrationEnabled == false)
        #expect(state.voiceSettings.isVoiceInputEnabled == false)
        #expect(state.voiceSettings.speed == .fast)
        #expect(state.voiceSettings.tone == .calm)
    }

    @Test
    func parentSettingsRequireManagementPasswordAndStoreLocalControls() {
        let state = AppState.preview

        #expect(!state.verifyParentManagementPassword("123456"))
        #expect(state.verifyParentManagementPassword("0000"))

        state.parentSettings.dailyMinutesLimit = 45
        state.parentSettings.allowPublicPublishing = false
        state.parentSettings.enabledAIFeatures.remove(.video)

        #expect(state.parentSettings.dailyMinutesLimit == 45)
        #expect(state.parentSettings.allowPublicPublishing == false)
        #expect(!state.parentSettings.enabledAIFeatures.contains(.video))
    }

    @Test
    func teacherEntryIsUnavailableByDefault() {
        let state = AppState.preview

        #expect(!state.teacherAccess.isAuthorized)
        #expect(state.teacherAccess.statusText == "未开通")
    }

    @Test
    func teacherPreviewAuthorizationUnlocksClientWorkspace() {
        let state = AppState.preview

        state.authorizeTeacherPreview()

        #expect(state.teacherAccess.isAuthorized)
        #expect(state.teacherAccess.statusText == "已开通")
        #expect(!state.teacherCourses(for: .age6to8).isEmpty)
    }

    @Test
    func teacherCanCreateClassroomAndBindStudentByParentPhone() {
        let state = AppState.preview

        let classroom = state.createTeacherClassroom(name: "松果一班", ageBand: .age6to8)
        state.bindStudent(parentPhoneNumber: "13800138000", studentName: "小鹿", to: classroom.id)

        #expect(state.teacherWorkspace.classrooms.first?.name == "松果一班")
        #expect(state.teacherWorkspace.classrooms.first?.studentBindings.first?.parentPhoneNumber == "13800138000")
    }

    @Test
    func teacherCoursePlaybackCreatesLocalRecord() {
        let state = AppState.preview
        let classroom = state.createTeacherClassroom(name: "星星班", ageBand: .age6to8)
        let course = state.teacherCourses(for: .age6to8)[0]

        state.playTeacherCourse(courseID: course.id, classroomID: classroom.id)

        #expect(state.teacherWorkspace.playbackRecords.count == 1)
        #expect(state.teacherWorkspace.playbackRecords[0].courseTitle == course.title)
        #expect(state.teacherWorkspace.playbackRecords[0].classroomName == classroom.name)
    }

    @Test
    func teacherCanApproveRejectAndGenerateCommentForProjects() {
        let state = AppState.preview
        let project = sampleProject(status: .pendingReview, title: "海洋故事")
        state.projects = [project]

        let comment = state.generateTeacherComment(for: project.id)
        state.rejectProject(projectID: project.id)

        #expect(comment.contains("海洋故事"))
        #expect(state.project(id: project.id)?.status == .rejected)

        state.projects = [project]
        state.approveProjectForPlaza(projectID: project.id)

        #expect(state.project(id: project.id)?.status == .published)
        #expect(state.project(id: project.id)?.isPublished == true)
    }

    @Test
    func studentPublishRequestRequiresParentPermissionAndTeacherApproval() {
        let state = AppState.preview
        let project = sampleProject(status: .draft, title: "待发布故事")
        state.projects = [project]

        state.requestProjectPublishing(id: project.id)

        #expect(state.project(id: project.id)?.status == .pendingReview)
        #expect(state.project(id: project.id)?.isPublished == false)

        state.approveProjectForPlaza(projectID: project.id)

        #expect(state.project(id: project.id)?.status == .published)
        #expect(state.project(id: project.id)?.isPublished == true)

        state.projects = [project]
        state.parentSettings.allowPublicPublishing = false
        state.requestProjectPublishing(id: project.id)
        state.approveProjectForPlaza(projectID: project.id)

        #expect(state.project(id: project.id)?.status == .draft)
        #expect(state.project(id: project.id)?.isPublished == false)
    }

    @Test
    func myAIFriendGroupsMirrorMainFriendBuckets() {
        let state = AppState.preview
        let classroomFriend = state.classroomFriends[0]
        let favoriteFriend = state.friends[1]
        let recentFriend = state.friends[2]

        state.toggleFavorite(favoriteFriend)
        state.openFriend(recentFriend)

        #expect(state.profileFriendGroups.map(\.title) == ["课堂指定", "已收藏", "最近使用"])
        #expect(state.profileFriendGroups[0].friends.contains { $0.id == classroomFriend.id })
        #expect(state.profileFriendGroups[1].friends.map(\.id) == [favoriteFriend.id])
        #expect(state.profileFriendGroups[2].friends.map(\.id) == [recentFriend.id])
    }

    @Test
    func creationsCanBeBucketedForProfileDetail() {
        let state = AppState.preview
        state.projects = [
            sampleProject(status: .draft, title: "草稿"),
            sampleProject(status: .pendingReview, title: "待审核"),
            sampleProject(status: .published, title: "已发布", isPublished: true),
            sampleProject(status: .rejected, title: "被驳回")
        ]

        #expect(state.projects(for: .draft).map(\.title) == ["草稿"])
        #expect(state.projects(for: .pendingReview).map(\.title) == ["待审核"])
        #expect(state.projects(for: .published).map(\.title) == ["已发布"])
        #expect(state.projects(for: .rejected).map(\.title) == ["被驳回"])
    }

    private func sampleProject(status: CreationProject.Status, title: String, isPublished: Bool = false) -> CreationProject {
        CreationProject(
            id: UUID(),
            type: .story,
            title: title,
            previewText: "测试作品",
            authorName: "同学",
            coverSymbol: "📚",
            status: status,
            origin: .manual,
            isPublished: isPublished,
            likeCount: 0,
            rating: 0
        )
    }
}
