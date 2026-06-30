import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        brandHeader
                        formCard
                    }
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .center)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.xl)
                }
                .scrollIndicators(.hidden)
                .background(loginBackground.ignoresSafeArea())
            }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.surface)
                    .frame(width: 72, height: 72)
                    .shadow(color: AppColors.shadow, radius: 14, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(AppColors.warmAccent)
            }

            VStack(spacing: AppSpacing.xs) {
                Text("AI课堂")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("登录后继续你的 AI 创作学习")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("家长手机号登录")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("本地 Docker 后台验证码固定为 123456。")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            labeledField(title: "家长手机号") {
                ThemedTextField(
                    placeholder: "请输入 11 位手机号",
                    text: $viewModel.phoneNumber,
                    keyboardType: .numberPad
                )
                .accessibilityIdentifier("phoneField")
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("验证码")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)

                HStack(spacing: AppSpacing.sm) {
                    ThemedTextField(
                        placeholder: "请输入验证码",
                        text: $viewModel.verificationCode,
                        keyboardType: .numberPad
                    )
                        .accessibilityIdentifier("codeField")
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.loginFieldBackground, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(AppColors.loginOutline, lineWidth: 1)
                        )

                    Button {
                        viewModel.requestCode()
                    } label: {
                        Text(viewModel.countdown > 0 ? "\(viewModel.countdown)s 后重试" : "获取验证码")
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .frame(minWidth: 104)
                    }
                    .padding(.horizontal, AppSpacing.sm)
                    .frame(height: 52)
                    .background(
                        requestCodeButtonFill,
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .foregroundStyle(requestCodeButtonText)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.loginOutline, lineWidth: viewModel.canRequestCode ? 0 : 1)
                    }
                    .accessibilityIdentifier("requestCodeButton")
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canRequestCode || viewModel.countdown > 0)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    await viewModel.submitWithBackend()
                }
            } label: {
                Label(viewModel.isSubmitting ? "正在连接后台" : "进入课堂", systemImage: "arrow.right.circle.fill")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .foregroundStyle(.white)
            .background(
                viewModel.canSubmit ? AppColors.primaryAction : AppColors.primaryActionDisabled,
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(color: viewModel.canSubmit ? AppColors.primaryAction.opacity(0.22) : .clear, radius: 12, y: 6)
            .buttonStyle(.plain)
            .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
            .accessibilityIdentifier("enterClassroomButton")

            Button {
                viewModel.skipLogin()
            } label: {
                Text("跳过登录，直接进入")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(AppColors.primaryAction)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
        .shadow(color: AppColors.shadow, radius: 20, y: 10)
    }

    private var requestCodeButtonFill: Color {
        guard viewModel.canRequestCode, viewModel.countdown == 0 else {
            return AppColors.surface
        }
        return AppColors.primaryAction
    }

    private var requestCodeButtonText: Color {
        guard viewModel.canRequestCode, viewModel.countdown == 0 else {
            return AppColors.textSecondary
        }
        return .white
    }

    private var loginBackground: some View {
        LinearGradient(
            colors: [
                AppColors.canvas,
                AppColors.surfaceAccent
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func labeledField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            content()
                .padding(AppSpacing.md)
                .background(AppColors.loginFieldBackground, in: RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.loginOutline, lineWidth: 1)
                )
        }
    }
}
