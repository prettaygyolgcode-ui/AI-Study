import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    profileHeader

                    VStack(spacing: AppSpacing.sm) {
                        profileLink(title: "课堂任务", subtitle: "查看老师布置的创作任务", systemImage: "checklist") {
                            ClassroomTasksView()
                        }
                        profileLink(title: "我的创作", subtitle: "回看保存和发布过的作品", systemImage: "folder") {
                            MyCreationsView()
                                .padding(AppSpacing.md)
                                .background(AppColors.background.ignoresSafeArea())
                                .navigationTitle("我的创作")
                        }
                        profileLink(title: "我的 AI 朋友", subtitle: "最近聊过的伙伴", systemImage: "person.2") {
                            RecentFriendsView()
                        }
                        profileLink(title: "语音设置", subtitle: "设置播报、语速和语气", systemImage: "speaker.wave.2") {
                            VoiceSettingsView()
                        }
                        profileLink(title: "家长设置", subtitle: "使用时长和内容偏好占位", systemImage: "figure.2.and.child.holdinghands") {
                            PlaceholderInfoView(title: "家长设置", message: "后续将支持使用时长、创作记录、内容偏好等家长管理功能。")
                        }
                        profileLink(title: "老师入口", subtitle: "课堂任务和数据面板占位", systemImage: "graduationcap") {
                            PlaceholderInfoView(title: "老师入口", message: "后续将支持课堂任务布置、作品查看、课堂数据面板等教师功能。")
                        }
                        profileLink(title: "账号设置", subtitle: "查看账号并退出登录", systemImage: "gearshape") {
                            AccountSettingsView()
                        }
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("我的")
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("你好，\(appState.user.nickname)")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(appState.user.classroomName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: AppSpacing.sm) {
                TagChip(title: "\(appState.projects.count) 个作品")
                TagChip(title: "\(appState.tasks.count) 个任务")
                TagChip(title: "\(appState.recentFriends.count) 位朋友")
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppColors.mintAccent.opacity(0.32), AppColors.surface],
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

    private func profileLink<Destination: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColors.primaryAction)
                    .frame(width: 42, height: 42)
                    .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(AppSpacing.md)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(AppColors.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
