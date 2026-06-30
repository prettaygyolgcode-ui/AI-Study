import SwiftUI

struct MyCreationsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedStatus: CreationProject.Status = .draft

    var showsStandaloneChrome = true

    private var filteredProjects: [CreationProject] {
        appState.projects(for: selectedStatus)
    }

    var body: some View {
        Group {
            if showsStandaloneChrome {
                ScrollView {
                    content
                        .padding(AppSpacing.md)
                }
                .background(AppColors.background.ignoresSafeArea())
                .navigationTitle("我的创作")
            } else {
                content
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            statusPicker

            if filteredProjects.isEmpty {
                EmptyStateView(
                    title: "\(selectedStatus.displayTitle)里还没有作品",
                    message: emptyMessage(for: selectedStatus)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.lg)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(filteredProjects) { project in
                        NavigationLink {
                            ProjectDetailView(projectID: project.id)
                        } label: {
                            ProjectCardView(project: project)
                                .overlay(alignment: .topTrailing) {
                                    Text(project.status.displayTitle)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(project.status.tintColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(project.status.tintColor.opacity(0.14), in: Capsule())
                                        .padding(AppSpacing.md)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var statusPicker: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(CreationProject.Status.allCases) { status in
                Button {
                    selectedStatus = status
                } label: {
                    VStack(spacing: 6) {
                        Text(status.displayTitle)
                            .font(.subheadline.weight(.bold))
                        Text("\(appState.projects(for: status).count)")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(selectedStatus == status ? .white : AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedStatus == status ? AppColors.primaryAction : AppColors.surface,
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(selectedStatus == status ? AppColors.primaryAction : AppColors.stroke, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func emptyMessage(for status: CreationProject.Status) -> String {
        switch status {
        case .draft:
            return "从 AI 创作或 AI 朋友开始，新作品会先保存在这里。"
        case .pendingReview:
            return "提交后等待老师或平台审核的作品会出现在这里。"
        case .published:
            return "发布到广场的作品会出现在这里。"
        case .rejected:
            return "没有被驳回的作品。需要修改时会在这里看到原因。"
        }
    }
}
