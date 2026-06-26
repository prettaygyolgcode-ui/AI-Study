import SwiftUI

struct ThemedTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textInputAutocapitalization: TextInputAutocapitalization? = nil

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(textInputAutocapitalization)
            .foregroundStyle(AppColors.textPrimary)
            .tint(AppColors.primaryAction)
            .preferredColorScheme(AppTheme.preferredColorScheme)
    }
}
