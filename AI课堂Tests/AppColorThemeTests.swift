import Testing
import SwiftUI
import UIKit
@testable import AI课堂

struct AppColorThemeTests {
    @Test
    func appUsesLightColorSchemeForCurrentPrototypeTheme() {
        #expect(AppTheme.preferredColorScheme == .light)
    }

    @Test
    func themeMaintainsReadableContrast() {
        let textContrast = contrastRatio(
            between: UIColor(AppColors.textPrimary),
            and: UIColor(AppColors.canvas)
        )
        let secondaryContrast = contrastRatio(
            between: UIColor(AppColors.textSecondary),
            and: UIColor(AppColors.surface)
        )
        let strokeSeparation = contrastRatio(
            between: UIColor(AppColors.stroke),
            and: UIColor(AppColors.surface)
        )

        #expect(textContrast >= 7.0)
        #expect(secondaryContrast >= 4.5)
        #expect(strokeSeparation >= 1.15)
    }

    @Test
    func actionColorStaysDistinctFromBackground() {
        let actionContrast = contrastRatio(
            between: UIColor(AppColors.primaryAction),
            and: UIColor(AppColors.canvas)
        )

        #expect(actionContrast >= 2.2)
    }

    private func contrastRatio(between lhs: UIColor, and rhs: UIColor) -> Double {
        let lhsLuminance = relativeLuminance(lhs)
        let rhsLuminance = relativeLuminance(rhs)
        let lighter = max(lhsLuminance, rhsLuminance)
        let darker = min(lhsLuminance, rhsLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func relativeLuminance(_ color: UIColor) -> Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        func transform(_ component: CGFloat) -> Double {
            let normalized = Double(component)
            if normalized <= 0.03928 {
                return normalized / 12.92
            }
            return pow((normalized + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * transform(red) + 0.7152 * transform(green) + 0.0722 * transform(blue)
    }
}
