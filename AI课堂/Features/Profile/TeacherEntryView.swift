import SwiftUI

struct TeacherEntryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                if appState.teacherAccess.isAuthorized {
                    TeacherWorkspaceView()
                } else {
                    unavailableContent
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("老师入口")
    }

    private var unavailableContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(systemName: "graduationcap.fill")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppColors.primaryAction)

            Text("老师入口未开通")
                .font(.title.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text("正式环境需要后台授权。当前是客户端原型，可以跳过验证查看老师工作台。")
                .font(.body)
                .foregroundStyle(AppColors.textSecondary)

            PrimaryButton(title: "跳过验证，查看老师功能") {
                appState.authorizeTeacherPreview()
            }
            .accessibilityIdentifier("skipTeacherAuthorizationButton")

            Text("授权后将支持课程播放、班级管理、作品审批和 AI 批量点评。")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(AppSpacing.md)
                .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}

private struct TeacherWorkspaceView: View {
    @EnvironmentObject private var appState: AppState
    @State private var newClassroomName = ""
    @State private var studentName = ""
    @State private var parentPhone = ""
    @State private var selectedClassroomID: UUID?
    @State private var selectedProjectID: UUID?

    private var selectedAgeBand: Binding<TeacherAgeBand> {
        Binding(
            get: { appState.teacherWorkspace.selectedAgeBand },
            set: { appState.teacherWorkspace.selectedAgeBand = $0 }
        )
    }

    private var currentCourses: [TeacherCourse] {
        appState.teacherCourses(for: appState.teacherWorkspace.selectedAgeBand)
    }

    private var pendingProjects: [CreationProject] {
        appState.projects(for: .pendingReview)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            dashboardHeader
            courseSection
            classroomSection
            approvalSection
            commentSection
        }
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("老师工作台")
                .font(.title.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text("课程、班级、审批和点评都先在客户端模拟，后续接入后台授权与 Web 上传数据。")
                .font(.body)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: AppSpacing.sm) {
                TagChip(title: "\(appState.teacherWorkspace.classrooms.count) 个班级")
                TagChip(title: "\(appState.teacherWorkspace.playbackRecords.count) 条播放记录")
                TagChip(title: "\(pendingProjects.count) 个待审核")
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppColors.mintAccent.opacity(0.35), AppColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    private var courseSection: some View {
        teacherCard(title: "我的课程", icon: "play.rectangle.fill") {
            Picker("年龄段", selection: selectedAgeBand) {
                ForEach(TeacherAgeBand.allCases) { ageBand in
                    Text(ageBand.title).tag(ageBand)
                }
            }
            .pickerStyle(.segmented)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: AppSpacing.md)], spacing: AppSpacing.md) {
                ForEach(currentCourses) { course in
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(course.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("\(course.durationMinutes) 分钟 · \(course.uploadSource)上传")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)

                        ProgressView(value: course.progress)
                            .tint(AppColors.primaryAction)

                        Button {
                            appState.playTeacherCourse(courseID: course.id, classroomID: selectedClassroomID)
                        } label: {
                            Label("播放课件", systemImage: "play.fill")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .foregroundStyle(.white)
                                .background(AppColors.primaryAction, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 20))
                }
            }

            if !appState.teacherWorkspace.playbackRecords.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("播放记录")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    ForEach(appState.teacherWorkspace.playbackRecords.prefix(3)) { record in
                        recordRow(title: record.courseTitle, value: "\(record.classroomName) · \(Int(record.progress * 100))%")
                    }
                }
            }
        }
    }

    private var classroomSection: some View {
        teacherCard(title: "班级管理", icon: "person.3.fill") {
            HStack(spacing: AppSpacing.sm) {
                TextField("创建班级，例如：松果一班", text: $newClassroomName)
                    .textFieldStyle(.plain)
                    .padding(AppSpacing.md)
                    .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(AppColors.textPrimary)

                Button("创建") {
                    let classroom = appState.createTeacherClassroom(
                        name: newClassroomName,
                        ageBand: appState.teacherWorkspace.selectedAgeBand
                    )
                    selectedClassroomID = classroom.id
                    newClassroomName = ""
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 14)
                .background(AppColors.primaryAction, in: RoundedRectangle(cornerRadius: 16))
            }

            if appState.teacherWorkspace.classrooms.isEmpty {
                Text("还没有班级。创建班级后，可以用家长手机号绑定学生。")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Picker("班级", selection: selectedClassroomBinding) {
                    ForEach(appState.teacherWorkspace.classrooms) { classroom in
                        Text(classroom.name).tag(Optional(classroom.id))
                    }
                }
                .pickerStyle(.menu)
                .tint(AppColors.primaryAction)

                HStack(spacing: AppSpacing.sm) {
                    TextField("学生昵称", text: $studentName)
                    TextField("家长手机号", text: $parentPhone)
                        .keyboardType(.phonePad)
                    Button("绑定") {
                        guard let classroomID = selectedClassroomID ?? appState.teacherWorkspace.classrooms.first?.id else { return }
                        appState.bindStudent(parentPhoneNumber: parentPhone, studentName: studentName, to: classroomID)
                        studentName = ""
                        parentPhone = ""
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryAction, in: RoundedRectangle(cornerRadius: 14))
                }
                .textFieldStyle(.plain)
                .padding(AppSpacing.md)
                .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))

                ForEach(appState.teacherWorkspace.classrooms) { classroom in
                    classroomSummary(classroom)
                }
            }
        }
    }

    private var approvalSection: some View {
        teacherCard(title: "作品审批", icon: "checkmark.seal.fill") {
            if pendingProjects.isEmpty {
                Text("当前没有待审核作品。学生提交作品后会出现在这里。")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                ForEach(pendingProjects) { project in
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(project.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(project.previewText)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)

                        HStack {
                            Button("允许发布") {
                                appState.approveProjectForPlaza(projectID: project.id)
                            }
                            .accessibilityIdentifier("approveProjectButton")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, 10)
                            .background(AppColors.primaryAction, in: Capsule())

                            Button("驳回修改") {
                                appState.rejectProject(projectID: project.id)
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, 10)
                            .background(AppColors.chipFill, in: Capsule())

                            Spacer()
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surfaceSoft, in: RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }

    private var commentSection: some View {
        teacherCard(title: "AI点评与批量点评", icon: "text.bubble.fill") {
            Text("系统会按老师常用点评语组织语气：\(appState.teacherWorkspace.commentStylePhrases.joined(separator: "、"))。")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            Picker("点评作品", selection: selectedProjectBinding) {
                Text("选择作品").tag(Optional<UUID>.none)
                ForEach(appState.projects) { project in
                    Text(project.title).tag(Optional(project.id))
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.primaryAction)

            Button {
                guard let selectedProjectID else { return }
                _ = appState.generateTeacherComment(for: selectedProjectID)
            } label: {
                Label("生成 AI 点评", systemImage: "sparkles")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(AppColors.primaryAction, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .disabled(selectedProjectID == nil)
            .opacity(selectedProjectID == nil ? 0.45 : 1)

            if !appState.teacherWorkspace.latestGeneratedComment.isEmpty {
                Text(appState.teacherWorkspace.latestGeneratedComment)
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(AppSpacing.md)
                    .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private var selectedClassroomBinding: Binding<UUID?> {
        Binding(
            get: {
                selectedClassroomID ?? appState.teacherWorkspace.classrooms.first?.id
            },
            set: { selectedClassroomID = $0 }
        )
    }

    private var selectedProjectBinding: Binding<UUID?> {
        Binding(
            get: { selectedProjectID },
            set: { selectedProjectID = $0 }
        )
    }

    private func teacherCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Label(title, systemImage: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)

            content()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    private func classroomSummary(_ classroom: TeacherClassroom) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(classroom.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text(classroom.ageBand.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.primaryAction)
            }

            if classroom.studentBindings.isEmpty {
                Text("还没有绑定学生")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                ForEach(classroom.studentBindings) { binding in
                    recordRow(
                        title: "\(binding.studentName) · \(binding.parentPhoneNumber)",
                        value: "\(binding.completedTaskCount)/\(binding.totalTaskCount) 任务"
                    )
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfaceSoft, in: RoundedRectangle(cornerRadius: 18))
    }

    private func recordRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
