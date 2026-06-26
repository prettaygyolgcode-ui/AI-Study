import SwiftUI

struct PlazaView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedKind: CreationType.Kind?
    @State private var sort: PlazaSort = .recommended

    private var projects: [CreationProject] {
        appState.plazaProjectsFiltered(by: selectedKind, sort: sort)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SectionHeader(title: "作品广场", subtitle: "看看同学们公开发布的故事、图画、音乐和课堂报告。")
                    filterBar
                    sortBar

                    if projects.isEmpty {
                        EmptyStateView(title: "还没有公开作品", message: "换一个分类看看，或先发布自己的作品。")
                    } else {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(projects) { project in
                                NavigationLink {
                                    PlazaDetailView(projectID: project.id)
                                } label: {
                                    plazaCard(project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(AppSpacing.md)
                .accessibilityIdentifier("plazaScreen")
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("广场")
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                filterButton(title: "全部", kind: nil)

                ForEach(CreationType.Kind.allCases) { kind in
                    filterButton(title: kind.outputName, kind: kind)
                }
            }
        }
    }

    private var sortBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("排序")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)

            Picker("排序", selection: $sort) {
                Text("推荐").tag(PlazaSort.recommended)
                Text("热度").tag(PlazaSort.hot)
            }
            .pickerStyle(.segmented)
        }
    }

    private func filterButton(title: String, kind: CreationType.Kind?) -> some View {
        Button {
            selectedKind = kind
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 10)
                .background(filterFill(for: kind), in: Capsule())
                .foregroundStyle(filterText(for: kind))
        }
        .buttonStyle(.plain)
    }

    private func plazaCard(_ project: CreationProject) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ProjectCardView(project: project)

            HStack(spacing: AppSpacing.sm) {
                TagChip(title: project.type.outputName)
                Label("\(project.likeCount)", systemImage: project.isLiked ? "heart.fill" : "heart")
                Label(String(format: "%.1f", project.rating), systemImage: "star.fill")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func filterFill(for kind: CreationType.Kind?) -> Color {
        selectedKind == kind ? AppColors.primaryAction : AppColors.chipFill
    }

    private func filterText(for kind: CreationType.Kind?) -> Color {
        selectedKind == kind ? .white : AppColors.chipText
    }
}
