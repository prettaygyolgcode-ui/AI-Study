import SwiftUI

struct TagChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 6)
            .background(AppColors.chipFill, in: Capsule())
            .foregroundStyle(AppColors.chipText)
    }
}
