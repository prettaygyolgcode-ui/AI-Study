import Foundation

enum PlazaSort: String, CaseIterable, Identifiable {
    case recommended
    case hot

    var id: String { rawValue }
}
