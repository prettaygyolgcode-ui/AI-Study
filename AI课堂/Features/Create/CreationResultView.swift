import SwiftUI

struct CreationResultView: View {
    @EnvironmentObject private var appState: AppState

    let projectID: UUID

    @State private var showProjectDetail = false

    private var project: CreationProject? {
        appState.project(id: projectID)
    }

    var body: some View {
        ScrollView {
            if let project {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("创作完成")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("作品已经放进“我的创作”，你可以继续修改，也可以直接发布到广场。")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    ProjectCardView(project: project)

                    if let prompt = project.prompt {
                        promptSummary(prompt)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("当前状态")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(project.status.displayTitle)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 10)
                            .background(project.status.tintColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(project.status.tintColor)
                    }

                    PrimaryButton(title: "查看我的作品") {
                        showProjectDetail = true
                    }

                    if !project.isPublished {
                        Button("发布到广场") {
                            appState.publishProject(id: project.id)
                        }
                        .accessibilityIdentifier("publishToPlazaButton")
                        .buttonStyle(.bordered)
                        .tint(AppColors.primaryAction)
                    }
                }
                .padding(AppSpacing.md)
            } else {
                EmptyStateView(title: "作品不存在", message: "这个作品可能已经被移除，请返回继续创作。")
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("创作结果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showProjectDetail) {
            ProjectDetailView(projectID: projectID)
        }
    }

    private func promptSummary(_ prompt: CreationPrompt) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("创作设定")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            promptLine(title: "主题", value: prompt.subject)
            promptLine(title: "风格", value: prompt.style)
            promptLine(title: "感觉", value: prompt.mood)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    private func promptLine(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            Text(value.isEmpty ? "未填写" : value)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
