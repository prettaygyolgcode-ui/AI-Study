import SwiftUI

struct ParentSettingsGateView: View {
    @EnvironmentObject private var appState: AppState
    @State private var password = ""
    @State private var isUnlocked = false
    @State private var showsError = false

    var body: some View {
        Group {
            if isUnlocked {
                ParentSettingsView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        gateHeader

                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("输入管理密码")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)

                            SecureField("默认演示密码：0000", text: $password)
                                .keyboardType(.numberPad)
                                .textContentType(.password)
                                .padding(AppSpacing.md)
                                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(showsError ? Color.red.opacity(0.75) : AppColors.stroke, lineWidth: 1)
                                )
                                .foregroundStyle(AppColors.textPrimary)
                                .tint(AppColors.primaryAction)

                            if showsError {
                                Text("管理密码不正确，请重新输入。")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.red.opacity(0.85))
                            }

                            PrimaryButton(title: "进入家长设置") {
                                if appState.verifyParentManagementPassword(password) {
                                    isUnlocked = true
                                    showsError = false
                                } else {
                                    showsError = true
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 26))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(AppColors.stroke, lineWidth: 1)
                        )
                    }
                    .padding(AppSpacing.md)
                }
                .background(AppColors.background.ignoresSafeArea())
                .navigationTitle("家长设置")
            }
        }
    }

    private var gateHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: "lock.shield.fill")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppColors.primaryAction)

            Text("家长管理")
                .font(.title.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text("这里可以管理使用额度、AI 功能权限和作品公开设置。")
                .font(.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppColors.mintAccent.opacity(0.35), AppColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}

struct ParentSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                limitSection
                aiFeatureSection
                safetySection
                recordSection
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("家长设置")
    }

    private var limitSection: some View {
        settingsCard(title: "使用额度", icon: "timer") {
            Stepper(value: $appState.parentSettings.computeBudgetLimit, in: 0...500, step: 10) {
                settingLine(title: "算力额度", value: "\(appState.parentSettings.computeBudgetLimit) 点/天")
            }

            Divider()

            Stepper(value: $appState.parentSettings.dailyMinutesLimit, in: 0...240, step: 5) {
                settingLine(title: "每日使用时长", value: "\(appState.parentSettings.dailyMinutesLimit) 分钟")
            }
        }
    }

    private var aiFeatureSection: some View {
        settingsCard(title: "允许使用的 AI 功能", icon: "sparkles") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: AppSpacing.sm)], spacing: AppSpacing.sm) {
                ForEach(AIFeaturePermission.allCases) { feature in
                    Button {
                        toggleFeature(feature)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: feature.icon)
                            Text(feature.title)
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(appState.parentSettings.enabledAIFeatures.contains(feature) ? .white : AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            appState.parentSettings.enabledAIFeatures.contains(feature) ? AppColors.primaryAction : AppColors.chipFill,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var safetySection: some View {
        settingsCard(title: "安全开关", icon: "checkmark.shield.fill") {
            Toggle("允许公开发布作品", isOn: $appState.parentSettings.allowPublicPublishing)
            Toggle("开启自动朗读", isOn: parentNarrationBinding)
            Toggle("开启语音输入", isOn: parentVoiceInputBinding)
            Toggle("作品可公开展示", isOn: $appState.parentSettings.isPublicWorksEnabled)
        }
        .tint(AppColors.primaryAction)
    }

    private var recordSection: some View {
        settingsCard(title: "孩子使用记录", icon: "list.bullet.clipboard") {
            recordLine(title: "课堂任务", value: "\(appState.tasks.count) 个")
            recordLine(title: "创作记录", value: "\(appState.projects.count) 个")
            recordLine(title: "广场发布", value: "\(appState.plazaProjects.count) 个")

            if appState.tasks.isEmpty && appState.projects.isEmpty {
                Text("目前还没有本机使用记录。开始完成任务或创作后，这里会自动更新。")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.top, 4)
            }
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Label(title, systemImage: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)

            content()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    private func settingLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryAction)
        }
    }

    private func recordLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Text(value)
                .foregroundStyle(AppColors.textSecondary)
        }
        .font(.subheadline.weight(.semibold))
    }

    private func toggleFeature(_ feature: AIFeaturePermission) {
        if appState.parentSettings.enabledAIFeatures.contains(feature) {
            appState.parentSettings.enabledAIFeatures.remove(feature)
        } else {
            appState.parentSettings.enabledAIFeatures.insert(feature)
        }
    }

    private var parentNarrationBinding: Binding<Bool> {
        Binding(
            get: { appState.parentSettings.isAutoNarrationEnabled },
            set: { isEnabled in
                appState.parentSettings.isAutoNarrationEnabled = isEnabled
                appState.voiceSettings.isNarrationEnabled = isEnabled
            }
        )
    }

    private var parentVoiceInputBinding: Binding<Bool> {
        Binding(
            get: { appState.parentSettings.isVoiceInputEnabled },
            set: { isEnabled in
                appState.parentSettings.isVoiceInputEnabled = isEnabled
                appState.voiceSettings.isVoiceInputEnabled = isEnabled
            }
        )
    }
}
