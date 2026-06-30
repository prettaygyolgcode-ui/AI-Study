import SwiftUI

struct CreationFormView: View {
    @EnvironmentObject private var appState: AppState

    let type: CreationType

    @State private var draft = PromptCanvasDraft()
    @State private var nodePositions: [PromptCanvasField: CGPoint] = [:]
    @State private var dragStartPositions: [PromptCanvasField: CGPoint] = [:]
    @State private var canvasScale: CGFloat = 1
    @GestureState private var pinchScale: CGFloat = 1
    @State private var generatedProject: CreationProject?
    @State private var activeField: PromptCanvasField?
    @State private var viewport = CanvasViewportState()
    @State private var canvasPanStartOffset: CGFloat?

    private var effectiveScale: CGFloat {
        clampScale(canvasScale * pinchScale)
    }

    var body: some View {
        VStack(spacing: 0) {
            topToolbar

            GeometryReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    Color.white
                        .ignoresSafeArea()

                    canvasContent(size: proxy.size)

                    zoomControls
                        .padding(AppSpacing.lg)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle(type.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $generatedProject) { project in
            CreationResultView(projectID: project.id)
        }
        .sheet(item: $activeField) { field in
            if field == .seed {
                SeedInputSheet(
                    initialSeed: draft.seedInput,
                    tintColor: type.tintColor
                ) { seed in
                    draft.selectSeed(seed)
                    activeField = nil
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            } else {
                PromptOptionSheet(
                    field: field,
                    selectedValue: draft.value(for: field),
                    tintColor: type.tintColor
                ) { option in
                    select(option.title, for: field)
                    activeField = nil
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var topToolbar: some View {
        VStack(spacing: AppSpacing.sm) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppSpacing.sm) {
                    promptControls
                }
                .fixedSize(horizontal: true, vertical: false)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150), spacing: AppSpacing.sm)],
                    spacing: AppSpacing.sm
                ) {
                    promptControls
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .accessibilityIdentifier("promptToolbar")

            HStack(spacing: AppSpacing.sm) {
                Text("按顺序选择卡片，把想法连成一条提示词。")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                Text("\(draft.completedFields.count)/\(PromptCanvasField.allCases.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.primaryAction)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
        }
        .background(AppColors.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.stroke)
                .frame(height: 1)
        }
    }

    private var promptControls: some View {
        Group {
            ForEach(PromptCanvasField.allCases) { field in
                promptButton(for: field)
            }

            generateButton
        }
    }

    private var generateButton: some View {
        Button {
            generate()
        } label: {
            Label("生成", systemImage: "sparkles")
                .font(.headline.weight(.bold))
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, 13)
                .frame(minWidth: 110)
                .background(draft.isComplete ? AppColors.primaryAction : AppColors.primaryActionDisabled, in: Capsule())
                .foregroundStyle(.white)
        }
        .disabled(!draft.isComplete)
        .accessibilityIdentifier("generateFromCanvasButton")
    }

    @ViewBuilder
    private func promptButton(for field: PromptCanvasField) -> some View {
        if draft.canSelect(field) {
            Button {
                activeField = field
            } label: {
                PromptFieldButton(field: field, value: draft.value(for: field), isEnabled: true)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("promptField-\(field.rawValue)")
        } else {
            PromptFieldButton(field: field, value: nil, isEnabled: false)
                .accessibilityIdentifier("promptField-\(field.rawValue)")
        }
    }

    private func canvasContent(size: CGSize) -> some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 6)
                        .onChanged { value in
                            if canvasPanStartOffset == nil {
                                canvasPanStartOffset = viewport.horizontalOffset
                            }

                            viewport.updateHorizontalDrag(
                                startOffset: canvasPanStartOffset ?? viewport.horizontalOffset,
                                translationWidth: value.translation.width / effectiveScale
                            )
                        }
                        .onEnded { _ in
                            canvasPanStartOffset = nil
                        }
                )

            ZStack {
                connectionLines(size: size)

                ForEach(draft.completedFields) { field in
                    PromptNodeCard(
                        number: nodeNumber(for: field),
                        title: field.title,
                        value: draft.value(for: field) ?? "",
                        tintColor: type.tintColor
                    )
                    .position(position(for: field, in: size))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if dragStartPositions[field] == nil {
                                    dragStartPositions[field] = position(for: field, in: size)
                                }

                                guard let start = dragStartPositions[field] else { return }
                                nodePositions[field] = CGPoint(
                                    x: start.x + value.translation.width / effectiveScale,
                                    y: start.y + value.translation.height / effectiveScale
                                )
                            }
                            .onEnded { _ in
                                dragStartPositions[field] = nil
                            }
                    )
                    .accessibilityIdentifier("promptNode-\(field.rawValue)")
                }

                if draft.completedFields.isEmpty {
                    emptyCanvasHint
                }
            }
            .offset(x: viewport.horizontalOffset)
        }
        .frame(width: size.width, height: size.height)
        .scaleEffect(effectiveScale, anchor: .center)
        .gesture(
            MagnificationGesture()
                .updating($pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    canvasScale = clampScale(canvasScale * value)
                }
        )
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: draft.completedFields)
        .accessibilityIdentifier("promptCanvas")
    }

    private func connectionLines(size: CGSize) -> some View {
        Path { path in
            let fields = draft.completedFields
            guard fields.count > 1 else { return }

            for index in 0..<(fields.count - 1) {
                path.move(to: position(for: fields[index], in: size))
                path.addLine(to: position(for: fields[index + 1], in: size))
            }
        }
        .stroke(
            type.tintColor.opacity(0.72),
            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: type.tintColor.opacity(0.18), radius: 8, y: 4)
    }

    private var emptyCanvasHint: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(AppColors.primaryAction)

            Text("先点上方第一个按钮")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)

            Text("选好后，画布上会出现第一张提示词卡片。")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.surface.opacity(0.94), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    private var zoomControls: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                canvasScale = clampScale(canvasScale - 0.15)
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .accessibilityLabel("缩小画布")

            Text("\(Int(effectiveScale * 100))%")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 48)

            Button {
                canvasScale = clampScale(canvasScale + 0.15)
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
            .accessibilityLabel("放大画布")
        }
        .font(.headline)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface, in: Capsule())
        .overlay(
            Capsule()
                .stroke(AppColors.stroke, lineWidth: 1)
        )
        .shadow(color: AppColors.shadow, radius: 10, y: 6)
    }

    private func select(_ value: String, for field: PromptCanvasField) {
        draft.select(value, for: field)
    }

    private func generate() {
        guard let prompt = draft.prompt else { return }
        let project = appState.generateProject(type: type.kind, prompt: prompt)
        generatedProject = project

        Task {
            await appState.submitProjectToBackendIfPossible(project)
        }
    }

    private func position(for field: PromptCanvasField, in size: CGSize) -> CGPoint {
        nodePositions[field] ?? defaultPosition(for: field, in: size)
    }

    private func defaultPosition(for field: PromptCanvasField, in size: CGSize) -> CGPoint {
        let index = PromptCanvasField.allCases.firstIndex(of: field) ?? 0
        let columns = max(CGFloat(PromptCanvasField.allCases.count - 1), 1)
        let x = size.width * (0.18 + CGFloat(index) * (0.64 / columns))
        let y = size.height * (index.isMultiple(of: 2) ? 0.38 : 0.62)

        return CGPoint(x: x, y: y)
    }

    private func nodeNumber(for field: PromptCanvasField) -> Int {
        (PromptCanvasField.allCases.firstIndex(of: field) ?? 0) + 1
    }

    private func clampScale(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.65), 1.65)
    }
}

private struct PromptFieldButton: View {
    let field: PromptCanvasField
    let value: String?
    let isEnabled: Bool

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: value == nil ? field.icon : "checkmark.circle.fill")
                .font(.headline.weight(.bold))

            VStack(alignment: .leading, spacing: 2) {
                Text(field.title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)

                Text(value ?? "点我选择")
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
            }

            Image(systemName: isEnabled ? "chevron.up.chevron.down" : "lock.fill")
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 10)
        .frame(minWidth: field == .seed ? 230 : 150, alignment: .leading)
        .background(isEnabled ? AppColors.chipFill : AppColors.surfaceSoft, in: RoundedRectangle(cornerRadius: 18))
        .foregroundStyle(isEnabled ? AppColors.chipText : AppColors.textSecondary)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}

private struct PromptNodeCard: View {
    let number: Int
    let title: String
    let value: String
    let tintColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("\(number)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(tintColor, in: Circle())

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()
            }

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(4)
        }
        .padding(AppSpacing.md)
        .frame(width: title == "种子" ? 290 : 230, alignment: .topLeading)
        .frame(minHeight: title == "种子" ? 142 : 118, alignment: .topLeading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(tintColor.opacity(0.32), lineWidth: 2)
        )
        .shadow(color: AppColors.shadow, radius: 14, y: 8)
    }
}

private struct SeedInputSheet: View {
    @Environment(\.dismiss) private var dismiss

    let tintColor: Color
    let onSave: (PromptSeedInput) -> Void

    @State private var plot: String
    @State private var protagonist: StoryProtagonist
    @State private var ageRange: StoryAgeRange

    private var canSave: Bool {
        !plot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(initialSeed: PromptSeedInput?, tintColor: Color, onSave: @escaping (PromptSeedInput) -> Void) {
        self.tintColor = tintColor
        self.onSave = onSave
        _plot = State(initialValue: initialSeed?.plot ?? "")
        _protagonist = State(initialValue: initialSeed?.protagonist ?? .unspecified)
        _ageRange = State(initialValue: initialSeed?.ageRange ?? .sixToEight)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SheetHeader(
                        icon: PromptCanvasField.seed.icon,
                        title: "种下一个故事种子",
                        subtitle: "先告诉 AI 故事从哪里开始，再选择适合的小主角和年龄段。",
                        tintColor: tintColor
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Label("故事剧情", systemImage: "pencil.and.scribble")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColors.textPrimary)

                        TextEditor(text: $plot)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(minHeight: 150)
                            .padding(AppSpacing.sm)
                            .scrollContentBackground(.hidden)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(canSave ? tintColor.opacity(0.38) : AppColors.stroke, lineWidth: 2)
                            )
                            .accessibilityIdentifier("seedPlotEditor")

                        Text("例：一只小鹿在森林里发现会发光的地图。")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        SectionLabel(icon: "person.crop.circle.fill", title: "故事主角")
                        ChipGrid(items: StoryProtagonist.allCases, selected: protagonist, tintColor: tintColor) { item in
                            protagonist = item
                        }
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        SectionLabel(icon: "calendar.badge.clock", title: "年龄段")
                        ChipGrid(items: StoryAgeRange.allCases, selected: ageRange, tintColor: tintColor) { item in
                            ageRange = item
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("种子")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("放进画布") {
                        onSave(PromptSeedInput(plot: plot, protagonist: protagonist, ageRange: ageRange))
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                }
            }
        }
    }
}

private struct PromptOptionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let field: PromptCanvasField
    let selectedValue: String?
    let tintColor: Color
    let onSelect: (PromptCanvasOption) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: AppSpacing.md)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SheetHeader(
                        icon: field.icon,
                        title: "选择\(field.title)",
                        subtitle: field.helperText,
                        tintColor: tintColor
                    )

                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(field.options) { option in
                            Button {
                                onSelect(option)
                            } label: {
                                OptionTile(
                                    option: option,
                                    isSelected: selectedValue == option.title,
                                    tintColor: tintColor
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("promptOption-\(option.title)")
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(field.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct SheetHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    let tintColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(tintColor, in: RoundedRectangle(cornerRadius: 22))
                .shadow(color: tintColor.opacity(0.28), radius: 14, y: 8)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}

private struct SectionLabel: View {
    let icon: String
    let title: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline.weight(.bold))
            .foregroundStyle(AppColors.textPrimary)
    }
}

private struct ChipGrid<Item: StoryChoiceItem>: View {
    let items: [Item]
    let selected: Item
    let tintColor: Color
    let onSelect: (Item) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 130), spacing: AppSpacing.sm)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: item.choiceIcon)
                            .font(.headline.weight(.bold))

                        Text(item.choiceTitle)
                            .font(.headline.weight(.bold))
                            .lineLimit(1)

                        Spacer()

                        if selected.id == item.id {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .padding(AppSpacing.md)
                    .foregroundStyle(selected.id == item.id ? .white : AppColors.textPrimary)
                    .background(selected.id == item.id ? tintColor : AppColors.surface, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selected.id == item.id ? tintColor : AppColors.stroke, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private protocol StoryChoiceItem: Identifiable, Hashable {
    var choiceTitle: String { get }
    var choiceIcon: String { get }
}

extension StoryProtagonist: StoryChoiceItem {
    var choiceTitle: String { title }
    var choiceIcon: String { icon }
}

extension StoryAgeRange: StoryChoiceItem {
    var choiceTitle: String { title }
    var choiceIcon: String { "clock.fill" }
}

private struct OptionTile: View {
    let option: PromptCanvasOption
    let isSelected: Bool
    let tintColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: option.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(isSelected ? .white : tintColor)
                    .frame(width: 54, height: 54)
                    .background(isSelected ? tintColor.opacity(0.28) : tintColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
            }

            Text(option.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
        .background(isSelected ? tintColor : AppColors.surface, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isSelected ? tintColor : AppColors.stroke, lineWidth: 1.5)
        )
        .shadow(color: isSelected ? tintColor.opacity(0.18) : AppColors.shadow, radius: 12, y: 7)
    }
}
