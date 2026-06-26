import SwiftUI

struct MyCreationsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.projects.isEmpty {
            EmptyStateView(title: "还没有作品", message: "先从上面的创作卡片开始，做出第一份作品。")
        } else {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(appState.projects) { project in
                    NavigationLink {
                        ProjectDetailView(projectID: project.id)
                    } label: {
                        ProjectCardView(project: project)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
