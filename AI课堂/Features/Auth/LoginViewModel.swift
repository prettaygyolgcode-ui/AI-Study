import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var countdown = 0
    @Published var errorMessage: String?

    private unowned let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var canRequestCode: Bool {
        phoneNumber.count == 11 && phoneNumber.allSatisfy(\.isNumber)
    }

    var canSubmit: Bool {
        canRequestCode && verificationCode.count == 6
    }

    func requestCode() {
        guard canRequestCode else { return }
        countdown = 59
        errorMessage = nil
    }

    func skipLogin() {
        errorMessage = nil
        appState.isLoggedIn = true
    }

    @discardableResult
    func submit() -> Bool {
        guard canSubmit else {
            errorMessage = "请输入正确的手机号和验证码"
            return false
        }

        guard verificationCode == "123456" else {
            errorMessage = "验证码错误"
            return false
        }

        errorMessage = nil
        appState.isLoggedIn = true
        return true
    }
}
