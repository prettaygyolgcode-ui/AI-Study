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
                            infoLine(title: "感觉", value: prompt.mood)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(AppColors.stroke, lineWidth: 1)
                        )
                    }

                    if !project.isPublished {
                        PrimaryButton(title: "发布到广场") {
                            appState.publishProject(id: project.id)
                        }
                    }
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
}
