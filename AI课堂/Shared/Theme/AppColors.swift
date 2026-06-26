import SwiftUI

enum AppColors {
    static let canvas = Color(red: 0.98, green: 0.97, blue: 0.93)
    static let surface = Color(red: 1.0, green: 0.99, blue: 0.97)
    static let surfaceSoft = Color(red: 0.95, green: 0.97, blue: 1.0)
    static let surfaceAccent = Color(red: 0.92, green: 0.96, blue: 1.0)
    static let textPrimary = Color(red: 0.16, green: 0.22, blue: 0.33)
    static let textSecondary = Color(red: 0.39, green: 0.46, blue: 0.58)
    static let stroke = Color(red: 0.84, green: 0.88, blue: 0.93)
    static let shadow = Color.black.opacity(0.05)

    static let primaryAction = Color(red: 0.28, green: 0.55, blue: 0.90)
    static let primaryActionDisabled = Color(red: 0.72, green: 0.81, blue: 0.92)
    static let warmAccent = Color(red: 0.95, green: 0.57, blue: 0.34)
    static let mintAccent = Color(red: 0.42, green: 0.77, blue: 0.68)
    static let chipFill = Color(red: 0.91, green: 0.96, blue: 1.0)
    static let chipText = Color(red: 0.22, green: 0.39, blue: 0.63)

    static let background = canvas
    static let card = surface
    static let loginHero = Color(red: 0.21, green: 0.36, blue: 0.63)
    static let loginHeroSecondary = Color(red: 0.38, green: 0.62, blue: 0.88)
    static let loginAccent = warmAccent
    static let loginFieldBackground = surfaceSoft
    static let loginOutline = stroke
}
