import Testing
@testable import AI课堂

@MainActor
struct LoginViewModelTests {
    @Test
    func phoneValidationRejectsShortNumbers() {
        let viewModel = LoginViewModel(appState: .preview)
        viewModel.phoneNumber = "1380013"

        #expect(viewModel.canRequestCode == false)
    }

    @Test
    func validCodeLogsUserIn() {
        let state = AppState.preview
        let viewModel = LoginViewModel(appState: state)
        viewModel.phoneNumber = "13800138000"
        viewModel.verificationCode = "123456"

        #expect(viewModel.submit() == true)
        #expect(state.isLoggedIn == true)
    }

    @Test
    func invalidCodeShowsError() {
        let viewModel = LoginViewModel(appState: .preview)
        viewModel.phoneNumber = "13800138000"
        viewModel.verificationCode = "000000"

        #expect(viewModel.submit() == false)
        #expect(viewModel.errorMessage == "验证码错误")
    }

    @Test
    func skipLoginEntersClassroom() {
        let state = AppState.preview
        let viewModel = LoginViewModel(appState: state)

        viewModel.skipLogin()

        #expect(state.isLoggedIn == true)
        #expect(viewModel.errorMessage == nil)
    }
}
