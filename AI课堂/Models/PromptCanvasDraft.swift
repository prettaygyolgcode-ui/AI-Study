import Foundation

struct PromptCanvasOption: Equatable, Hashable, Identifiable {
    var id: String { title }
    let title: String
    let icon: String
}

enum StoryProtagonist: String, CaseIterable, Identifiable, Hashable {
    case boy
    case girl
    case unspecified

    var id: String { rawValue }

    var title: String {
        switch self {
        case .boy:
            return "男孩"
        case .girl:
            return "女孩"
        case .unspecified:
            return "不限定"
        }
    }

    var icon: String {
        switch self {
        case .boy:
            return "figure.child"
        case .girl:
            return "figure.child.circle.fill"
        case .unspecified:
            return "sparkles"
        }
    }
}

enum StoryAgeRange: String, CaseIterable, Identifiable, Hashable {
    case twoToThree
    case fourToFive
    case sixToEight
    case nineToTwelve

    var id: String { rawValue }

    var title: String {
        switch self {
        case .twoToThree:
            return "2～3岁"
        case .fourToFive:
            return "4～5岁"
        case .sixToEight:
            return "6～8岁"
        case .nineToTwelve:
            return "9～12岁"
        }
    }
}

struct PromptSeedInput: Equatable, Hashable {
    var plot: String
    var protagonist: StoryProtagonist
    var ageRange: StoryAgeRange

    var trimmedPlot: String {
        plot.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedPlot.isEmpty
    }

    var cardText: String {
        "\(trimmedPlot)\n\(protagonist.title) · \(ageRange.title)"
    }
}

enum PromptCanvasField: String, CaseIterable, Identifiable, Hashable {
    case seed
    case theme
    case value
    case style

    var id: String { rawValue }

    var title: String {
        switch self {
        case .seed:
            return "种子"
        case .theme:
            return "主题"
        case .value:
            return "价值"
        case .style:
            return "风格"
        }
    }

    var helperText: String {
        switch self {
        case .seed:
            return "写下故事剧情，选择主角和年龄段。"
        case .theme:
            return "选择故事最主要的方向。"
        case .value:
            return "选择希望孩子感受到的品质。"
        case .style:
            return "选择生成结果的画面气质。"
        }
    }

    var icon: String {
        switch self {
        case .seed:
            return "leaf.fill"
        case .theme:
            return "map.fill"
        case .value:
            return "heart.fill"
        case .style:
            return "paintpalette.fill"
        }
    }

    var options: [PromptCanvasOption] {
        switch self {
        case .seed:
            return []
        case .theme:
            return [
                PromptCanvasOption(title: "冒险", icon: "safari.fill"),
                PromptCanvasOption(title: "友谊", icon: "person.2.fill"),
                PromptCanvasOption(title: "家庭", icon: "house.fill"),
                PromptCanvasOption(title: "自然", icon: "tree.fill"),
                PromptCanvasOption(title: "魔法", icon: "wand.and.stars"),
                PromptCanvasOption(title: "动物", icon: "pawprint.fill"),
                PromptCanvasOption(title: "太空", icon: "moon.stars.fill"),
                PromptCanvasOption(title: "海洋", icon: "water.waves")
            ]
        case .value:
            return [
                PromptCanvasOption(title: "勇气", icon: "shield.fill"),
                PromptCanvasOption(title: "善良", icon: "heart.circle.fill"),
                PromptCanvasOption(title: "诚实", icon: "checkmark.seal.fill"),
                PromptCanvasOption(title: "坚持", icon: "flag.fill"),
                PromptCanvasOption(title: "分享", icon: "gift.fill"),
                PromptCanvasOption(title: "尊重", icon: "hands.sparkles.fill"),
                PromptCanvasOption(title: "创造力", icon: "lightbulb.fill"),
                PromptCanvasOption(title: "感恩", icon: "sun.max.fill")
            ]
        case .style:
            return [
                PromptCanvasOption(title: "温馨卡通", icon: "face.smiling.fill"),
                PromptCanvasOption(title: "水彩童话", icon: "paintbrush.pointed.fill"),
                PromptCanvasOption(title: "国风绘本", icon: "book.pages.fill"),
                PromptCanvasOption(title: "3D皮克斯", icon: "cube.transparent.fill")
            ]
        }
    }
}

struct PromptCanvasDraft: Equatable {
    private(set) var seedInput: PromptSeedInput?
    private var values: [PromptCanvasField: String] = [:]

    var completedFields: [PromptCanvasField] {
        PromptCanvasField.allCases.filter { value(for: $0) != nil }
    }

    var isComplete: Bool {
        PromptCanvasField.allCases.allSatisfy { value(for: $0) != nil }
    }

    mutating func selectSeed(_ seed: PromptSeedInput) {
        seedInput = seed.isValid ? seed : nil
    }

    mutating func select(_ value: String, for field: PromptCanvasField) {
        guard field != .seed else { return }
        values[field] = value
    }

    func value(for field: PromptCanvasField) -> String? {
        if field == .seed {
            guard let seedInput, seedInput.isValid else { return nil }
            return seedInput.cardText
        }

        guard let value = values[field]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }

        return value
    }

    func canSelect(_ field: PromptCanvasField) -> Bool {
        guard let index = PromptCanvasField.allCases.firstIndex(of: field) else { return false }
        guard index > 0 else { return true }

        let previousField = PromptCanvasField.allCases[index - 1]
        return value(for: previousField) != nil
    }

    var prompt: CreationPrompt? {
        guard
            let seedInput,
            seedInput.isValid,
            let theme = value(for: .theme),
            let moralValue = value(for: .value),
            let style = value(for: .style)
        else {
            return nil
        }

        return CreationPrompt(
            title: seedInput.trimmedPlot,
            subject: "主题：\(theme)；种子：\(seedInput.trimmedPlot)；主角：\(seedInput.protagonist.title)；年龄：\(seedInput.ageRange.title)",
            style: style,
            mood: moralValue
        )
    }
}
