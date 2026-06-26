import SwiftUI

struct CreateHubView: View {
    enum HubSection: String, CaseIterable, Identifiable {
        case cards
        case mine

        var id: String { rawValue }

        var title: String {
            switch self {
            case .cards:
                return "创作卡片"
            case .mine:
                return "我的创作"
            }
        }
    }

    @State private var selectedSection: HubSection = .cards

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    heroCard

                    Picker("AI创作视图", selection: $selectedSection) {
                        ForEach(HubSection.allCases) { section in
                            Text(section.title).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch selectedSection {
                    case .cards:
                        SectionHeader(title: "挑一张开始创作", subtitle: "故事、图画、音乐、动画、游戏和报告都可以从这里进入。")
                        CreateCardGridView()
                    case .mine:
                        SectionHeader(title: "我的创作", subtitle: "查看最近保存和发布的作品，继续完善它们。")
                        MyCreationsView()
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("AI创作")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("今天想创作什么？")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text("用低门槛的创作卡片，先把灵感变成一个能看的作品，再决定要不要发布到广场。")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppColors.warmAccent.opacity(0.55),
                    AppColors.mintAccent.opacity(0.35),
                    AppColors.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}
