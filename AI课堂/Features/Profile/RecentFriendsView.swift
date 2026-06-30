import SwiftUI

struct RecentFriendsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                ForEach(appState.profileFriendGroups) { group in
                    friendGroupSection(group)
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("我的 AI 朋友")
    }

    private func friendGroupSection(_ group: ProfileFriendGroup) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(group.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(group.friends.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.primaryAction)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.chipFill, in: Capsule())
            }

            if group.friends.isEmpty {
                Text(group.emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.stroke, lineWidth: 1)
                    )
            } else {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(group.friends) { friend in
                        NavigationLink {
                            FriendChatView(friend: friend)
                        } label: {
                            friendCard(friend)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func friendCard(_ friend: AIFriend) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text(friend.emoji)
                .font(.system(size: 36))
                .frame(width: 58, height: 58)
                .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(friend.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    if appState.isFavorite(friend) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppColors.warmAccent)
                    }
                }
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
