import SwiftUI

struct PlaceholderInfoView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(AppColors.primaryAction)
                .frame(width: 96, height: 96)
                .background(AppColors.chipFill, in: RoundedRectangle(cornerRadius: 28))

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(message)
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(title)
    }
}
