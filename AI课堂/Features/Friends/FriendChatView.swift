import SwiftUI

struct FriendChatView: View {
    @EnvironmentObject private var appState: AppState
    let friend: AIFriend
    @State private var draftProject: CreationProject?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(friend.emoji)
                        .font(.system(size: 44))
                    Text(friend.name)
                        .font(.largeTitle.bold())
                    Text(friend.welcomeMessage)
                        .foregroundStyle(AppColors.textSecondary)
                }

                SectionHeader(title: "试试这些创作", subtitle: "先从一个简单动作开始。")

                ForEach(friend.quickActions) { action in
                    Button(action.title) {
                        draftProject = appState.makeDraftFromFriend(friend, type: action.kind)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryAction)
                }

                if let draftProject {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("已生成草稿")
                            .font(.headline)
                        ProjectCardView(project: draftProject)
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(friend.name)
        .onAppear {
            appState.openFriend(friend)
        }
    }
}
