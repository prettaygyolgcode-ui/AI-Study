import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject private var appState: AppState

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: AppSpacing.md)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SectionHeader(
                        title: "AI朋友",
                        subtitle: "选择一个官方 AI 伙伴，马上开始你的创作。"
                    )

                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(appState.friends) { friend in
                            NavigationLink {
                                FriendChatView(friend: friend)
                            } label: {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    Text(friend.emoji)
                                        .font(.system(size: 36))
                                    Text(friend.name)
                                        .font(.headline)
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text(friend.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(AppColors.textSecondary)
                                    FlowTagRow(tags: friend.tags)
                                }
                                .padding(AppSpacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColors.card, in: RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(AppColors.stroke, lineWidth: 1)
                                )
                                .shadow(color: AppColors.shadow, radius: 10, y: 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("AI朋友")
        }
    }
}

private struct FlowTagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(tags, id: \.self) { tag in
                    TagChip(title: tag)
                }
            }
        }
    }
}
