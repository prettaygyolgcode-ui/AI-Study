import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case friends
    case create
    case plaza
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .friends:
            "AI朋友"
        case .create:
            "AI创作"
        case .plaza:
            "广场"
        case .profile:
            "我的"
        }
    }

    var systemImage: String {
        switch self {
        case .friends:
            "person.3.fill"
        case .create:
            "sparkles.rectangle.stack.fill"
        case .plaza:
            "square.grid.2x2.fill"
        case .profile:
            "person.crop.circle.fill"
        }
    }
}
