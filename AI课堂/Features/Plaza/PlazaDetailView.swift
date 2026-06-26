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
                        SectionHeader(title: "作品互动", subtitle: "点赞和打分只保存在当前前端原型里。")

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

                            Text("均分 \(String(format: "%.1f", project.rating))")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.surfaceSoft, in: RoundedRectangle(cornerRadius: 18))
                        }

                        ratingRow(project: project)
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

    private func ratingRow(project: CreationProject) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(project.userRating == nil ? "给这个作品打分" : "你的评分：\(project.userRating ?? 0) 分")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        appState.rate(projectID: project.id, value: value)
                    } label: {
                        Image(systemName: (project.userRating ?? 0) >= value ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(AppColors.warmAccent)
                            .frame(width: 38, height: 38)
                            .background(AppColors.chipFill, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
