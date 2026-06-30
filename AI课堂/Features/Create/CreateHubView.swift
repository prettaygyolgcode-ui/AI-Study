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
                    Picker("AI创作视图", selection: $selectedSection) {
                        ForEach(HubSection.allCases) { section in
                            Text(section.title).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch selectedSection {
                    case .cards:
                        SectionHeader(title: "挑一张开始创作", subtitle: "故事、图画、音乐、动画和游戏都可以从这里进入。")
                        CreateCardGridView()
                    case .mine:
                        SectionHeader(title: "我的创作", subtitle: "查看最近保存和发布的作品，继续完善它们。")
                        MyCreationsView(showsStandaloneChrome: false)
                    }
                }
                .padding(AppSpacing.md)
                .accessibilityIdentifier("createHubScreen")
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("AI创作")
            .navigationDestination(for: CreationType.self) { type in
                CreationFormView(type: type)
            }
        }
    }
}
