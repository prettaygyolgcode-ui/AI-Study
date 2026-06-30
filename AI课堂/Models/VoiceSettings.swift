import Foundation

struct VoiceSettings: Equatable {
    enum Speed: String, CaseIterable, Identifiable {
        case slow
        case normal
        case fast

        var id: String { rawValue }
    }

    enum Tone: String, CaseIterable, Identifiable {
        case bright
        case calm
        case lively

        var id: String { rawValue }
    }

    var isNarrationEnabled: Bool
    var isVoiceInputEnabled = true
    var speed: Speed
    var tone: Tone
}
