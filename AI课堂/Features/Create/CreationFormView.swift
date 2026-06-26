import SwiftUI

struct CreationFormView: View {
    @EnvironmentObject private var appState: AppState

    let type: CreationType

    @State private var title = ""
    @State private var subject = ""
    @State private var style = ""
    @State private var mood = ""
    @State private var generatedProject: CreationProject?

    private var prompt: CreationPrompt {
        CreationPrompt(title: title, subject: subject, style: style, mood: mood)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                promptTip

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    textField("给作品起个名字", text: $title, accessibilityIdentifier: "creationTitleField")
                    textField("这次想围绕什么主题", text: $subject, accessibilityIdentifier: "creationSubjectField")
                    textField("想要什么风格", text: $style, accessibilityIdentifier: "creationStyleField")
                    textField("希望它带来什么感觉", text: $mood, accessibilityIdentifier: "creationMoodField")
                }

                suggestionRow

                PrimaryButton(title: "开始创作", isEnabled: prompt.isValid) {
                    generatedProject = appState.generateProject(type: type.kind, prompt: prompt)
                }
                .accessibilityIdentifier("startCreationButton")
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(type.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $generatedProject) { project in
            CreationResultView(projectID: project.id)
        }
    }

    private var promptTip: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(type.kind.formTitle)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(type.kind.formHint)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(type.tintColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 24))
    }

    private var suggestionRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(type.kind.sampleSuggestions, id: \.self) { item in
                    Button(item) {
                        applySuggestion(item)
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 10)
                    .background(AppColors.surface, in: Capsule())
                    .foregroundStyle(type.tintColor)
                    .overlay(
                        Capsule()
                            .stroke(type.tintColor.opacity(0.24), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func textField(_ placeholder: String, text: Binding<String>, accessibilityIdentifier: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(placeholder)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            ThemedTextField(
                placeholder: "请输入",
                text: text,
                textInputAutocapitalization: .never
            )
                .accessibilityIdentifier(accessibilityIdentifier)
                .padding(AppSpacing.md)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.stroke, lineWidth: 1)
                )
        }
    }

    private func applySuggestion(_ suggestion: String) {
        if subject.isEmpty {
            subject = suggestion
        } else if title.isEmpty {
            title = suggestion
        } else if style.isEmpty {
            style = suggestion
        } else {
            mood = suggestion
        }
    }
}
