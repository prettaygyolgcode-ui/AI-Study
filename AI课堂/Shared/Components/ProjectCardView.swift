import SwiftUI

struct ProjectCardView: View {
    let project: CreationProject

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(project.coverSymbol)
                .font(.system(size: 28))
            Text(project.title)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text(project.previewText)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
        .shadow(color: AppColors.shadow, radius: 10, y: 6)
    }
}
