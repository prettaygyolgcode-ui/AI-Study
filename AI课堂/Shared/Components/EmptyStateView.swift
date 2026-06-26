import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}
