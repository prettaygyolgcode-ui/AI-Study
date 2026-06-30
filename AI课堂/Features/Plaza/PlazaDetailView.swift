import SwiftUI

struct PlazaDetailView: View {
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

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        SectionHeader(title: "作品互动", subtitle: "可以点赞作品，分数为只读展示。")

                        HStack(spacing: AppSpacing.md) {
                            Button {
                                appState.toggleLike(projectID: project.id)
                            } label: {
                                Label(
                                    project.isLiked ? "已点赞 \(project.likeCount)" : "点赞 \(project.likeCount)",
                                    systemImage: project.isLiked ? "heart.fill" : "heart"
                                )
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(project.isLiked ? AppColors.warmAccent : AppColors.primaryAction)

                            scoreBadge(project.rating)
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.stroke, lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("作品信息")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        infoLine(title: "作者", value: project.authorName)
                        infoLine(title: "类型", value: project.type.outputName)
                        infoLine(title: "状态", value: project.status.displayTitle)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.stroke, lineWidth: 1)
                    )
                }
                .padding(AppSpacing.md)
            } else {
                EmptyStateView(title: "作品不存在", message: "这个作品可能已经被删除，请返回广场重新选择。")
                    .padding(AppSpacing.md)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("作品详情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func scoreBadge(_ score: Double) -> some View {
        Label("作品分数 \(String(format: "%.1f", score))", systemImage: "star.fill")
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppColors.surfaceSoft, in: RoundedRectangle(cornerRadius: 18))
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
