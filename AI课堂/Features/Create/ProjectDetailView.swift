import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var appState: AppState

    let projectID: UUID

    private var project: CreationProject? {
        appState.project(id: projectID)
    }

    var body: some View {
        ScrollView {
            if let project {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    ProjectCardView(project: project)

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("作品信息")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        infoLine(title: "类型", value: project.type.outputName)
                        infoLine(title: "来源", value: project.origin.displayTitle(in: appState))
                        infoLine(title: "状态", value: project.status.displayTitle)
                        infoLine(title: "作者", value: project.authorName)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(AppColors.stroke, lineWidth: 1)
                    )

                    if let prompt = project.prompt {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("创作设定")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)
                            infoLine(title: "主题", value: prompt.subject)
                            infoLine(title: "风格", value: prompt.style)
                            infoLine(title: "价值", value: prompt.mood)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(AppColors.stroke, lineWidth: 1)
                        )
                    }

                    publicationAction(for: project)
                }
                .padding(AppSpacing.md)
            } else {
                EmptyStateView(title: "作品不存在", message: "请返回我的创作，重新选择一个作品。")
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("作品详情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoLine(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    @ViewBuilder
    private func publicationAction(for project: CreationProject) -> some View {
        if project.isPublished {
            EmptyView()
        } else if project.status == .pendingReview {
            statusMessage("作品已提交审核，老师通过后会出现在广场。")
        } else if appState.parentSettings.allowPublicPublishing && appState.parentSettings.isPublicWorksEnabled {
            PrimaryButton(title: "提交发布审核") {
                appState.requestProjectPublishing(id: project.id)
            }
        } else {
            statusMessage("家长设置当前不允许公开发布作品。")
        }
    }

    private func statusMessage(_ message: String) -> some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColors.textPrimary)
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))
    }
}
