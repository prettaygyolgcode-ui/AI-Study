import SwiftUI

struct ClassroomTasksView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            if appState.tasks.isEmpty {
                EmptyStateView(title: "还没有课堂任务", message: "老师发布任务后会显示在这里。")
                    .padding(AppSpacing.md)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(appState.tasks) { task in
                        NavigationLink {
                            ClassroomTaskDetailView(task: task)
                        } label: {
                            taskCard(task)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppSpacing.md)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("课堂任务")
    }

    private func taskCard(_ task: ClassroomTask) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(task.detail)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                TagChip(title: task.status.displayTitle)
            }

            Label("推荐：\(task.recommendedType.outputName)", systemImage: "wand.and.stars")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.primaryAction)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}

private struct ClassroomTaskDetailView: View {
    @EnvironmentObject private var appState: AppState
    let task: ClassroomTask

    private var creationType: CreationType? {
        appState.creationTypes.first { $0.kind == task.recommendedType }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                SectionHeader(title: task.title, subtitle: task.detail)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    infoLine(title: "任务状态", value: task.status.displayTitle)
                    infoLine(title: "推荐创作", value: task.recommendedType.outputName)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppColors.stroke, lineWidth: 1)
                )

                if let creationType {
                    NavigationLink {
                        CreationFormView(type: creationType)
                    } label: {
                        Text("去完成任务")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primaryAction, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("任务详情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoLine(title: String, value: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

private extension ClassroomTask.Status {
    var displayTitle: String {
        switch self {
        case .notStarted:
            return "未开始"
        case .inProgress:
            return "进行中"
        case .completed:
            return "已完成"
        }
    }
}
