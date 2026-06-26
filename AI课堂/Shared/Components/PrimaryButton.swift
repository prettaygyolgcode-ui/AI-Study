import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 14)
                .background(
                    isEnabled ? AppColors.primaryAction : AppColors.primaryActionDisabled,
                    in: RoundedRectangle(cornerRadius: 18)
                )
        }
            .disabled(!isEnabled)
            .buttonStyle(.plain)
    }
}
