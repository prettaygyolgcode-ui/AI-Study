import SwiftUI

struct CreateCardGridView: View {
    @EnvironmentObject private var appState: AppState

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: AppSpacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(appState.creationTypes) { type in
                NavigationLink {
                    CreationFormView(type: type)
                } label: {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Image(systemName: type.icon)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(type.tintColor, in: RoundedRectangle(cornerRadius: 16))

                        Text(type.name)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)

                        Text(type.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                    .background(
                        LinearGradient(
                            colors: [AppColors.surface, type.tintColor.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(type.tintColor.opacity(0.24), lineWidth: 1)
                    )
                    .shadow(color: AppColors.shadow, radius: 10, y: 6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
