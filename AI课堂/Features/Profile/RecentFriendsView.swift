import SwiftUI

struct RecentFriendsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            if appState.recentFriends.isEmpty {
                EmptyStateView(title: "还没有最近朋友", message: "先去 AI朋友 页面选择一个伙伴聊聊。")
                    .padding(AppSpacing.md)
            } else {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(appState.recentFriends) { friend in
                        NavigationLink {
                            FriendChatView(friend: friend)
                        } label: {
                            friendCard(friend)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppSpacing.md)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("我的 AI 朋友")
    }

    private func friendCard(_ friend: AIFriend) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text(friend.emoji)
                .font(.system(size: 36))
                .frame(width: 58, height: 58)
                .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text(friend.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                HStack {
                    ForEach(friend.tags.prefix(2), id: \.self) { tag in
                        TagChip(title: tag)
                    }
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}
