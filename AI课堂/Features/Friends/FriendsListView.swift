import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedSection: FriendSection = .classroom

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: AppSpacing.md)
    ]

    private var visibleFriends: [AIFriend] {
        switch selectedSection {
        case .classroom:
            return appState.classroomFriends
        case .favorites:
            return appState.favoriteFriends
        case .recent:
            return appState.recentFriends
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Picker("AI朋友分类", selection: $selectedSection) {
                        ForEach(FriendSection.allCases) { section in
                            Text(section.title).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("friendsSectionPicker")

                    if visibleFriends.isEmpty {
                        EmptyStateView(title: selectedSection.emptyTitle, message: selectedSection.emptyMessage)
                            .padding(.vertical, AppSpacing.xl)
                    } else {
                        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                            ForEach(visibleFriends) { friend in
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
                .padding(AppSpacing.lg)
                .accessibilityIdentifier("friendsScreen")
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("AI朋友")
        }
    }

    private func friendCard(_ friend: AIFriend) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top) {
                Text(friend.emoji)
                    .font(.system(size: 38))
                    .frame(width: 62, height: 62)
                    .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 20))

                Spacer()

                if appState.isFavorite(friend) {
                    Label("已收藏", systemImage: "star.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.warmAccent)
                }
            }

            Text(friend.name)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(friend.subtitle)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)

            if selectedSection == .classroom, let assignmentNote = friend.assignmentNote {
                Text(assignmentNote)
                    .font(.caption)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(AppSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surfaceAccent, in: RoundedRectangle(cornerRadius: 16))
            }

            FlowTagRow(tags: friend.tags)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
        .shadow(color: AppColors.shadow, radius: 10, y: 6)
    }
}

private enum FriendSection: String, CaseIterable, Identifiable {
    case classroom
    case favorites
    case recent

    var id: Self { self }

    var title: String {
        switch self {
        case .classroom:
            return "课堂指定"
        case .favorites:
            return "已收藏"
        case .recent:
            return "最近使用"
        }
    }

    var emptyTitle: String {
        switch self {
        case .classroom:
            return "还没有课堂指定"
        case .favorites:
            return "还没有收藏的 AI 朋友"
        case .recent:
            return "还没有最近使用"
        }
    }

    var emptyMessage: String {
        switch self {
        case .classroom:
            return "老师指定的 AI 朋友会显示在这里。"
        case .favorites:
            return "进入伙伴对话页，点击右上角星星即可收藏。"
        case .recent:
            return "点击任意 AI 朋友开始对话后，会显示在这里。"
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
