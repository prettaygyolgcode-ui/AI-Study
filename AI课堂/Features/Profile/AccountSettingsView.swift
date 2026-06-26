import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                SectionHeader(title: "账号信息", subtitle: "当前为前端原型账号，不连接真实用户系统。")

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    infoLine(title: "昵称", value: appState.user.nickname)
                    infoLine(title: "家长手机号", value: appState.user.parentPhoneNumber)
                    infoLine(title: "课堂", value: appState.user.classroomName)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppColors.stroke, lineWidth: 1)
                )

                PrimaryButton(title: "退出登录") {
                    appState.isLoggedIn = false
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("账号设置")
    }

    private func infoLine(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
