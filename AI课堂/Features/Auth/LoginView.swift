import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    formCard
                }
                .padding(AppSpacing.md)
            }
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(loginBackground.ignoresSafeArea())
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("手机号登录")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)

            Text("验证码固定为 `123456`，用于当前前端原型联调。")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

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

                    Button(viewModel.countdown > 0 ? "\(viewModel.countdown)s 后重试" : "获取验证码") {
                        viewModel.requestCode()
                    }
                    .accessibilityIdentifier("requestCodeButton")
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryAction)
                    .disabled(!viewModel.canRequestCode || viewModel.countdown > 0)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button("进入课堂") {
                _ = viewModel.submit()
            }
            .accessibilityIdentifier("enterClassroomButton")
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primaryAction)
            .frame(maxWidth: .infinity, alignment: .leading)
            .disabled(!viewModel.canSubmit)

            Button("跳过登录，直接进入") {
                viewModel.skipLogin()
            }
            .font(.subheadline.weight(.semibold))
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
