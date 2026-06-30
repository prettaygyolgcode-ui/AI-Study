import SwiftUI

struct VoiceSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section("播报") {
                Toggle("开启作品朗读", isOn: narrationBinding)
                Toggle("开启语音输入", isOn: voiceInputBinding)
            }

            Section("声音") {
                Picker("语速", selection: speedBinding) {
                    ForEach(VoiceSettings.Speed.allCases) { speed in
                        Text(speed.displayTitle).tag(speed)
                    }
                }

                Picker("语气", selection: toneBinding) {
                    ForEach(VoiceSettings.Tone.allCases) { tone in
                        Text(tone.displayTitle).tag(tone)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("语音设置")
    }

    private var narrationBinding: Binding<Bool> {
        Binding(
            get: { appState.voiceSettings.isNarrationEnabled },
            set: { appState.voiceSettings.isNarrationEnabled = $0 }
        )
    }

    private var voiceInputBinding: Binding<Bool> {
        Binding(
            get: { appState.voiceSettings.isVoiceInputEnabled },
            set: { appState.voiceSettings.isVoiceInputEnabled = $0 }
        )
    }

    private var speedBinding: Binding<VoiceSettings.Speed> {
        Binding(
            get: { appState.voiceSettings.speed },
            set: { appState.voiceSettings.speed = $0 }
        )
    }

    private var toneBinding: Binding<VoiceSettings.Tone> {
        Binding(
            get: { appState.voiceSettings.tone },
            set: { appState.voiceSettings.tone = $0 }
        )
    }
}

private extension VoiceSettings.Speed {
    var displayTitle: String {
        switch self {
        case .slow:
            return "慢一点"
        case .normal:
            return "正常"
        case .fast:
            return "快一点"
        }
    }
}

private extension VoiceSettings.Tone {
    var displayTitle: String {
        switch self {
        case .bright:
            return "明亮"
        case .calm:
            return "安静"
        case .lively:
            return "活泼"
        }
    }
}
