import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.canvas, AppColors.surfaceAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                logo

                VStack(spacing: AppSpacing.xs) {
                    Text("AI课堂")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("学习、想象、创作")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.xl)
        }
        .accessibilityIdentifier("splashRoot")
    }

    private var logo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryAction, AppColors.mintAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 104, height: 104)
                .shadow(color: AppColors.shadow, radius: 18, y: 10)

            Image(systemName: "sparkles")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.white)
        }
        .accessibilityLabel("AI课堂 Logo")
    }
}
