import AVFoundation
import SwiftUI

struct FriendChatView: View {
    @EnvironmentObject private var appState: AppState
    let friend: AIFriend
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isRecording = false
    @State private var isAutoReadEnabled = true
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(AppSpacing.lg)
                .accessibilityIdentifier("chatMessageList")
            }

            composer
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appState.toggleFavorite(friend)
                } label: {
                    Image(systemName: appState.isFavorite(friend) ? "star.fill" : "star")
                        .foregroundStyle(appState.isFavorite(friend) ? AppColors.warmAccent : AppColors.textSecondary)
                }
                .accessibilityLabel(appState.isFavorite(friend) ? "取消收藏" : "收藏")
                .accessibilityIdentifier("favoriteFriendButton")
            }
        }
        .onAppear {
            appState.openFriend(friend)
            seedWelcomeMessageIfNeeded()
        }
        .onDisappear {
            stopSpeaking()
        }
    }

    private var composer: some View {
        VStack(spacing: AppSpacing.sm) {
            if isRecording {
                Label("正在听你说话，真实语音识别接入后会自动填入文字。", systemImage: "waveform")
                    .font(.caption)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: AppSpacing.sm) {
                ThemedTextField(placeholder: "输入想和 \(friend.name) 说的话", text: $inputText)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 12)
                    .background(AppColors.loginFieldBackground, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.stroke, lineWidth: 1)
                    )
                    .submitLabel(.send)
                    .onSubmit(sendMessage)
                    .accessibilityIdentifier("chatInputField")

                Button {
                    handleVoiceInput()
                } label: {
                    Label(isRecording ? "停止并填入" : "语音输入", systemImage: isRecording ? "waveform.circle.fill" : "mic.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
                .tint(isRecording ? AppColors.warmAccent : AppColors.primaryAction)
                .accessibilityIdentifier("voiceInputButton")

                Button {
                    sendMessage()
                } label: {
                    Label("发送", systemImage: "paperplane.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderedProminent)
                .tint(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColors.primaryActionDisabled : AppColors.primaryAction)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("sendMessageButton")
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColors.stroke)
                .frame(height: 1)
        }
    }

    private func seedWelcomeMessageIfNeeded() {
        guard messages.isEmpty else { return }

        isAutoReadEnabled = appState.voiceSettings.isNarrationEnabled
        messages.append(ChatMessage(role: .friend, text: friend.welcomeMessage))

        if isAutoReadEnabled {
            startSpeaking(friend.welcomeMessage)
        }
    }

    private func sendMessage() {
        let prompt = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        inputText = ""
        messages.append(ChatMessage(role: .student, text: prompt))

        let reply = makeLocalReply(for: prompt)
        messages.append(ChatMessage(role: .friend, text: reply))

        if isAutoReadEnabled {
            startSpeaking(reply)
        }
    }

    private func handleVoiceInput() {
        if isRecording {
            isRecording = false
            messages.append(ChatMessage(role: .system, text: "语音输入已停止。"))
        } else {
            isRecording = true
            messages.append(ChatMessage(role: .system, text: "语音输入入口已开启。"))
        }
    }

    private func startSpeaking(_ text: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = speechRate
        utterance.pitchMultiplier = speechPitch
        speechSynthesizer.speak(utterance)
    }

    private func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    private var speechRate: Float {
        switch appState.voiceSettings.speed {
        case .slow:
            return 0.42
        case .normal:
            return AVSpeechUtteranceDefaultSpeechRate
        case .fast:
            return 0.58
        }
    }

    private var speechPitch: Float {
        switch appState.voiceSettings.tone {
        case .bright:
            return 1.12
        case .calm:
            return 0.95
        case .lively:
            return 1.2
        }
    }

    private func makeLocalReply(for prompt: String) -> String {
        let shortPrompt = String(prompt.prefix(24))

        return "\(friend.name)收到啦。我先记住你的想法：“\(shortPrompt)”。你可以继续告诉我角色、地点或想完成的作品。"
    }
}

private struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: ChatRole
    let text: String

    init(id: UUID = UUID(), role: ChatRole, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

private enum ChatRole: Equatable {
    case student
    case friend
    case system
}

private struct ChatBubble: View {
    let message: ChatMessage

    private var isStudent: Bool {
        message.role == .student
    }

    private var bubbleFill: Color {
        switch message.role {
        case .student:
            return AppColors.primaryAction
        case .friend:
            return AppColors.chipFill
        case .system:
            return AppColors.surfaceAccent
        }
    }

    private var textColor: Color {
        isStudent ? .white : AppColors.textPrimary
    }

    var body: some View {
        HStack {
            if isStudent {
                Spacer(minLength: 44)
            }

            Text(message.text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(AppSpacing.sm)
                .background(bubbleFill, in: RoundedRectangle(cornerRadius: 18))

            if !isStudent {
                Spacer(minLength: 44)
            }
        }
    }
}
