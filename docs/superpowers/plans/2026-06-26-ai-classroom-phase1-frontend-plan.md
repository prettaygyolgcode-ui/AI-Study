# AI课堂一期前端原型版 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the phase-one student-facing SwiftUI prototype for AI课堂 with working navigation, mock data, creation flows, plaza browsing, and personal-center pages.

**Architecture:** Keep the app as a single-target SwiftUI prototype with `NavigationStack` + `TabView`, a shared in-memory `AppState`, and feature folders for Auth, Friends, Create, Plaza, and Profile. Use mock repositories and lightweight view models only where state mutation or screen flow becomes non-trivial, so the first iteration stays easy to ship and easy to refactor into real services later.

**Tech Stack:** SwiftUI, Observation / `ObservableObject`, XCTest, XCUITest, Xcode default asset pipeline

---

## Priority Order

### P0

1. App shell, routing, shared models, mock data
2. Login flow
3. AI朋友 list and chat-to-create flow
4. AI创作 hub, form screens, result screens, my-creations flow

### P1

5. 广场 list, filters, sort, detail interactions
6. 我的 page, classroom tasks, recent friends, settings, placeholders
7. Cross-screen state sync, loading/empty/error states, polish

### P2

8. UI tests, responsive cleanup for iPad/phone, copy pass

## Proposed File Structure

### Modify

- `AI课堂/AI__App.swift`
- `AI课堂.xcodeproj/project.pbxproj`

### Create

- `AI课堂/App/AppView.swift`
- `AI课堂/App/AppTab.swift`
- `AI课堂/App/AppState.swift`
- `AI课堂/Models/UserProfile.swift`
- `AI课堂/Models/AIFriend.swift`
- `AI课堂/Models/CreationType.swift`
- `AI课堂/Models/CreationProject.swift`
- `AI课堂/Models/CreationPrompt.swift`
- `AI课堂/Models/PlazaSort.swift`
- `AI课堂/Models/ClassroomTask.swift`
- `AI课堂/Models/VoiceSettings.swift`
- `AI课堂/Mock/MockSeed.swift`
- `AI课堂/Shared/Theme/AppColors.swift`
- `AI课堂/Shared/Theme/AppSpacing.swift`
- `AI课堂/Shared/Components/PrimaryButton.swift`
- `AI课堂/Shared/Components/SectionHeader.swift`
- `AI课堂/Shared/Components/EmptyStateView.swift`
- `AI课堂/Shared/Components/TagChip.swift`
- `AI课堂/Shared/Components/ProjectCardView.swift`
- `AI课堂/Features/Auth/LoginView.swift`
- `AI课堂/Features/Auth/LoginViewModel.swift`
- `AI课堂/Features/Friends/FriendsListView.swift`
- `AI课堂/Features/Friends/FriendChatView.swift`
- `AI课堂/Features/Friends/FriendQuickAction.swift`
- `AI课堂/Features/Create/CreateHubView.swift`
- `AI课堂/Features/Create/CreateCardGridView.swift`
- `AI课堂/Features/Create/MyCreationsView.swift`
- `AI课堂/Features/Create/CreationFormView.swift`
- `AI课堂/Features/Create/CreationResultView.swift`
- `AI课堂/Features/Create/ProjectDetailView.swift`
- `AI课堂/Features/Plaza/PlazaView.swift`
- `AI课堂/Features/Plaza/PlazaDetailView.swift`
- `AI课堂/Features/Profile/ProfileView.swift`
- `AI课堂/Features/Profile/ClassroomTasksView.swift`
- `AI课堂/Features/Profile/RecentFriendsView.swift`
- `AI课堂/Features/Profile/VoiceSettingsView.swift`
- `AI课堂/Features/Profile/PlaceholderInfoView.swift`
- `AI课堂/Features/Profile/AccountSettingsView.swift`
- `AI课堂Tests/AppStateTests.swift`
- `AI课堂Tests/LoginViewModelTests.swift`
- `AI课堂Tests/CreationFlowTests.swift`
- `AI课堂Tests/PlazaInteractionTests.swift`
- `AI课堂Tests/ProfileRoutingTests.swift`
- `AI课堂UITests/PrototypeSmokeUITests.swift`

## Screen Ownership

- `AppState.swift`: single source of truth for login state, selected user, projects, plaza list, likes, ratings, recent friends, and settings.
- `MockSeed.swift`: preloads one student account, six friends, six creation types, sample tasks, and creation/plaza items from the PRD.
- `CreationProject.swift`: canonical object reused by AI创作, 我的创作, and 广场.
- `CreationFormView.swift`: one generic form renderer driven by `CreationType`, not six separate form screens.
- `CreationResultView.swift`: one reusable result screen with type-specific preview sections.
- `PlaceholderInfoView.swift`: reusable placeholder page for 家长设置, 老师入口, and task detail stubs.

### Task 1: App Shell and Prototype State Foundation

**Priority:** P0

**Files:**
- Modify: `AI课堂/AI__App.swift`
- Modify: `AI课堂/ContentView.swift`
- Modify: `AI课堂.xcodeproj/project.pbxproj`
- Create: `AI课堂/App/AppView.swift`
- Create: `AI课堂/App/AppTab.swift`
- Create: `AI课堂/App/AppState.swift`
- Create: `AI课堂/Models/UserProfile.swift`
- Create: `AI课堂/Models/AIFriend.swift`
- Create: `AI课堂/Models/CreationType.swift`
- Create: `AI课堂/Models/CreationProject.swift`
- Create: `AI课堂/Models/PlazaSort.swift`
- Create: `AI课堂/Models/ClassroomTask.swift`
- Create: `AI课堂/Models/VoiceSettings.swift`
- Create: `AI课堂/Mock/MockSeed.swift`
- Create: `AI课堂/Shared/Theme/AppColors.swift`
- Create: `AI课堂/Shared/Theme/AppSpacing.swift`
- Test: `AI课堂Tests/AppStateTests.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import AI__

final class AppStateTests: XCTestCase {
    func test_bootstrap_loads_phase_one_mock_data() {
        let state = AppState.preview

        XCTAssertEqual(state.friends.count, 6)
        XCTAssertEqual(state.creationTypes.count, 6)
        XCTAssertGreaterThanOrEqual(state.projects.count, 8)
        XCTAssertGreaterThanOrEqual(state.plazaProjects.count, 10)
        XCTAssertEqual(state.tasks.count, 3)
        XCTAssertFalse(state.isLoggedIn)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/AppStateTests
```

Expected: FAIL because `AppState` and the model types do not exist yet.

- [ ] **Step 3: Write the minimal implementation**

```swift
// AI课堂/App/AppState.swift
import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: UserProfile
    @Published var friends: [AIFriend]
    @Published var creationTypes: [CreationType]
    @Published var projects: [CreationProject]
    @Published var tasks: [ClassroomTask]
    @Published var voiceSettings: VoiceSettings

    init(
        user: UserProfile,
        friends: [AIFriend],
        creationTypes: [CreationType],
        projects: [CreationProject],
        tasks: [ClassroomTask],
        voiceSettings: VoiceSettings
    ) {
        self.user = user
        self.friends = friends
        self.creationTypes = creationTypes
        self.projects = projects
        self.tasks = tasks
        self.voiceSettings = voiceSettings
    }

    static let preview: AppState = {
        let seed = MockSeed.make()
        return AppState(
            user: seed.user,
            friends: seed.friends,
            creationTypes: seed.creationTypes,
            projects: seed.projects,
            tasks: seed.tasks,
            voiceSettings: seed.voiceSettings
        )
    }()

    var plazaProjects: [CreationProject] {
        projects.filter(\.isPublished)
    }
}
```

```swift
// AI课堂/App/AppView.swift
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                Text("main-root")
                    .accessibilityIdentifier("mainRoot")
            } else {
                Text("login-root")
                    .accessibilityIdentifier("loginRoot")
            }
        }
    }
}
```

```swift
// AI课堂/AI__App.swift
import SwiftUI

@main
struct AI__App: App {
    @StateObject private var appState = AppState.preview

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appState)
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/AppStateTests
```

Expected: PASS with one executed test.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/AI__App.swift" "AI课堂/App" "AI课堂/Models" "AI课堂/Mock" "AI课堂/Shared/Theme" "AI课堂Tests/AppStateTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add prototype app shell and mock state"
```

### Task 2: Login Flow

**Priority:** P0

**Files:**
- Create: `AI课堂/Features/Auth/LoginView.swift`
- Create: `AI课堂/Features/Auth/LoginViewModel.swift`
- Modify: `AI课堂/App/AppView.swift`
- Modify: `AI课堂/App/AppState.swift`
- Create: `AI课堂Tests/LoginViewModelTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
@testable import AI__

@MainActor
final class LoginViewModelTests: XCTestCase {
    func test_phone_validation_rejects_short_numbers() {
        let vm = LoginViewModel(appState: .preview)
        vm.phoneNumber = "1380013"
        XCTAssertFalse(vm.canRequestCode)
    }

    func test_valid_code_logs_user_in() {
        let state = AppState.preview
        let vm = LoginViewModel(appState: state)
        vm.phoneNumber = "13800138000"
        vm.verificationCode = "123456"

        XCTAssertTrue(vm.submit())
        XCTAssertTrue(state.isLoggedIn)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/LoginViewModelTests
```

Expected: FAIL because `LoginViewModel` does not exist.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/Features/Auth/LoginViewModel.swift
import Foundation

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
        phoneNumber.count == 11
    }

    var canSubmit: Bool {
        canRequestCode && verificationCode.count == 6
    }

    func requestCode() {
        countdown = 59
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
        appState.isLoggedIn = true
        return true
    }
}
```

```swift
// AI课堂/Features/Auth/LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: LoginViewModel

    init(appState: AppState) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("AI课堂")
                    .font(.largeTitle.bold())
                TextField("家长手机号", text: $viewModel.phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Button(viewModel.countdown > 0 ? "\(viewModel.countdown)s 后重试" : "获取验证码") {
                    viewModel.requestCode()
                }
                .disabled(!viewModel.canRequestCode || viewModel.countdown > 0)
                TextField("验证码", text: $viewModel.verificationCode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Button("进入课堂") {
                    _ = viewModel.submit()
                }
                .disabled(!viewModel.canSubmit)
            }
            .padding(24)
        }
    }
}
```

```swift
// AI课堂/App/AppView.swift
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            Text("main-root")
                .accessibilityIdentifier("mainRoot")
        } else {
            LoginView(appState: appState)
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/LoginViewModelTests
```

Expected: PASS with two executed tests.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/Features/Auth" "AI课堂/App/AppView.swift" "AI课堂/App/AppState.swift" "AI课堂Tests/LoginViewModelTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add prototype login flow"
```

### Task 3: Main Tab Shell and Shared UI Components

**Priority:** P0

**Files:**
- Create: `AI课堂/App/AppTab.swift`
- Create: `AI课堂/Shared/Components/PrimaryButton.swift`
- Create: `AI课堂/Shared/Components/SectionHeader.swift`
- Create: `AI课堂/Shared/Components/EmptyStateView.swift`
- Create: `AI课堂/Shared/Components/TagChip.swift`
- Create: `AI课堂/Shared/Components/ProjectCardView.swift`
- Modify: `AI课堂/App/AppView.swift`

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import AI__

final class ProfileRoutingTests: XCTestCase {
    func test_all_primary_tabs_are_available() {
        let tabs = AppTab.allCases.map(\.title)
        XCTAssertEqual(tabs, ["AI朋友", "AI创作", "广场", "我的"])
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/ProfileRoutingTests/test_all_primary_tabs_are_available
```

Expected: FAIL because `AppTab` is missing.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/App/AppTab.swift
import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case friends
    case create
    case plaza
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .friends: "AI朋友"
        case .create: "AI创作"
        case .plaza: "广场"
        case .profile: "我的"
        }
    }
}
```

```swift
// AI课堂/App/AppView.swift
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: AppTab = .friends

    var body: some View {
        if appState.isLoggedIn {
            TabView(selection: $selectedTab) {
                Text("Friends").tabItem { Label("AI朋友", systemImage: "person.3") }.tag(AppTab.friends)
                Text("Create").tabItem { Label("AI创作", systemImage: "sparkles.rectangle.stack") }.tag(AppTab.create)
                Text("Plaza").tabItem { Label("广场", systemImage: "square.grid.2x2") }.tag(AppTab.plaza)
                Text("我的").tabItem { Label("我的", systemImage: "person.crop.circle") }.tag(AppTab.profile)
            }
        } else {
            LoginView(appState: appState)
        }
    }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/ProfileRoutingTests/test_all_primary_tabs_are_available
```

Expected: PASS with one executed test.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/App/AppTab.swift" "AI课堂/App/AppView.swift" "AI课堂/Shared/Components" "AI课堂Tests/ProfileRoutingTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add main tab shell and shared prototype components"
```

### Task 4: AI朋友 List and Chat Flow

**Priority:** P0

**Files:**
- Create: `AI课堂/Features/Friends/FriendsListView.swift`
- Create: `AI课堂/Features/Friends/FriendChatView.swift`
- Create: `AI课堂/Features/Friends/FriendQuickAction.swift`
- Modify: `AI课堂/App/AppView.swift`
- Modify: `AI课堂/App/AppState.swift`
- Test: `AI课堂Tests/CreationFlowTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
@testable import AI__

@MainActor
final class CreationFlowTests: XCTestCase {
    func test_selecting_friend_marks_it_recently_used() {
        let state = AppState.preview
        let friend = state.friends[0]

        state.openFriend(friend)

        XCTAssertEqual(state.recentFriendIDs.first, friend.id)
    }

    func test_friend_quick_action_creates_draft_project() {
        let state = AppState.preview
        let friend = state.friends[0]

        let project = state.makeDraftFromFriend(friend, type: .story)

        XCTAssertEqual(project.type, .story)
        XCTAssertEqual(project.origin, .friend(friend.id))
        XCTAssertEqual(state.projects.first?.id, project.id)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/CreationFlowTests
```

Expected: FAIL because `recentFriendIDs`, `openFriend`, and `makeDraftFromFriend` are undefined.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/App/AppState.swift
@Published var recentFriendIDs: [UUID] = []

func openFriend(_ friend: AIFriend) {
    recentFriendIDs.removeAll { $0 == friend.id }
    recentFriendIDs.insert(friend.id, at: 0)
}

func makeDraftFromFriend(_ friend: AIFriend, type: CreationType.Kind) -> CreationProject {
    openFriend(friend)
    let draft = CreationProject.draft(friend: friend, type: type)
    projects.insert(draft, at: 0)
    return draft
}
```

```swift
// AI课堂/Features/Friends/FriendsListView.swift
import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 180), spacing: 16)], spacing: 16) {
                    ForEach(appState.friends) { friend in
                        NavigationLink(value: friend) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(friend.emoji)
                                    .font(.system(size: 36))
                                Text(friend.name).font(.headline)
                                Text(friend.subtitle).font(.subheadline)
                                HStack {
                                    ForEach(friend.tags, id: \.self) { TagChip(title: $0) }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("AI朋友")
            .navigationDestination(for: AIFriend.self) { friend in
                FriendChatView(friend: friend)
                    .onAppear { appState.openFriend(friend) }
            }
        }
    }
}
```

```swift
// AI课堂/Features/Friends/FriendChatView.swift
import SwiftUI

struct FriendChatView: View {
    @EnvironmentObject private var appState: AppState
    let friend: AIFriend

    var body: some View {
        VStack(spacing: 16) {
            Text(friend.welcomeMessage)
            ForEach(friend.quickActions, id: \.id) { action in
                NavigationLink(action.title) {
                    CreationResultView(project: appState.makeDraftFromFriend(friend, type: action.kind))
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(friend.name)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/CreationFlowTests
```

Expected: PASS with two executed tests.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/Features/Friends" "AI课堂/App/AppState.swift" "AI课堂/App/AppView.swift" "AI课堂Tests/CreationFlowTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add ai friends list and chat prototype"
```

### Task 5: AI创作 Hub, Generic Form, Result, and My Creations

**Priority:** P0

**Files:**
- Create: `AI课堂/Models/CreationPrompt.swift`
- Create: `AI课堂/Features/Create/CreateHubView.swift`
- Create: `AI课堂/Features/Create/CreateCardGridView.swift`
- Create: `AI课堂/Features/Create/MyCreationsView.swift`
- Create: `AI课堂/Features/Create/CreationFormView.swift`
- Create: `AI课堂/Features/Create/CreationResultView.swift`
- Create: `AI课堂/Features/Create/ProjectDetailView.swift`
- Modify: `AI课堂/App/AppState.swift`
- Modify: `AI课堂/App/AppView.swift`
- Modify: `AI课堂/Models/CreationProject.swift`
- Test: `AI课堂Tests/CreationFlowTests.swift`

- [ ] **Step 1: Extend the failing tests**

```swift
func test_submitting_form_creates_saved_project() {
    let state = AppState.preview
    let prompt = CreationPrompt(
        title: "太空冒险",
        subject: "小宇航员和月球猫",
        style: "科幻",
        mood: "勇敢"
    )

    let project = state.generateProject(type: .story, prompt: prompt)

    XCTAssertEqual(project.status, .saved)
    XCTAssertEqual(project.title, "太空冒险")
    XCTAssertEqual(state.projects.first?.title, "太空冒险")
}

func test_publish_project_makes_it_visible_in_plaza() {
    let state = AppState.preview
    let projectID = state.projects[0].id

    state.publishProject(id: projectID)

    XCTAssertTrue(state.projects[0].isPublished)
    XCTAssertTrue(state.plazaProjects.contains { $0.id == projectID })
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/CreationFlowTests
```

Expected: FAIL because `CreationPrompt`, `generateProject`, and `publishProject` are undefined.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/App/AppState.swift
func generateProject(type: CreationType.Kind, prompt: CreationPrompt) -> CreationProject {
    let project = CreationProject.generated(type: type, prompt: prompt, author: user.nickname)
    projects.insert(project, at: 0)
    return project
}

func publishProject(id: UUID) {
    guard let index = projects.firstIndex(where: { $0.id == id }) else { return }
    projects[index].isPublished = true
    projects[index].status = .published
}
```

```swift
// AI课堂/Features/Create/CreateHubView.swift
import SwiftUI

struct CreateHubView: View {
    var body: some View {
        NavigationStack {
            CreateCardGridView()
                .navigationTitle("AI创作")
        }
    }
}
```

```swift
// AI课堂/Features/Create/CreateCardGridView.swift
import SwiftUI

struct CreateCardGridView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List(appState.creationTypes) { type in
            NavigationLink(type.name) {
                CreationFormView(type: type)
            }
        }
    }
}
```

```swift
// AI课堂/Features/Create/CreationFormView.swift
import SwiftUI

struct CreationFormView: View {
    @EnvironmentObject private var appState: AppState
    let type: CreationType
    @State private var title = ""
    @State private var subject = ""
    @State private var style = ""
    @State private var mood = ""
    @State private var generatedProject: CreationProject?

    var body: some View {
        Form {
            TextField("标题", text: $title)
            TextField("主题", text: $subject)
            TextField("风格", text: $style)
            TextField("情绪", text: $mood)
            Button("开始创作") {
                generatedProject = appState.generateProject(
                    type: type.kind,
                    prompt: CreationPrompt(title: title, subject: subject, style: style, mood: mood)
                )
            }
            .disabled(title.isEmpty || subject.isEmpty)
        }
        .navigationDestination(item: $generatedProject) { project in
            CreationResultView(project: project)
        }
        .navigationTitle(type.name)
    }
}
```

```swift
// AI课堂/Features/Create/MyCreationsView.swift
import SwiftUI

struct MyCreationsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.projects.isEmpty {
            EmptyStateView(title: "还没有作品", message: "去创作第一份作品吧")
        } else {
            List(appState.projects) { project in
                NavigationLink(project.title) {
                    ProjectDetailView(projectID: project.id)
                }
            }
        }
    }
}
```

```swift
// AI课堂/Features/Create/CreationResultView.swift
import SwiftUI

struct CreationResultView: View {
    @EnvironmentObject private var appState: AppState
    let project: CreationProject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(project.title).font(.title.bold())
                Text(project.previewText)
                Button("保存到我的创作") { }
                Button("发布到广场") { appState.publishProject(id: project.id) }
            }
            .padding()
        }
        .navigationTitle("创作结果")
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/CreationFlowTests
```

Expected: PASS with four executed tests.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/Features/Create" "AI课堂/App/AppState.swift" "AI课堂/App/AppView.swift" "AI课堂/Models/CreationProject.swift" "AI课堂/Models/CreationPrompt.swift" "AI课堂Tests/CreationFlowTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add creation hub and result flows"
```

### Task 6: 广场 Filters, Sort, Detail, Like, and Rating

**Priority:** P1

**Files:**
- Create: `AI课堂/Features/Plaza/PlazaView.swift`
- Create: `AI课堂/Features/Plaza/PlazaDetailView.swift`
- Modify: `AI课堂/App/AppState.swift`
- Modify: `AI课堂/App/AppView.swift`
- Test: `AI课堂Tests/PlazaInteractionTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
@testable import AI__

@MainActor
final class PlazaInteractionTests: XCTestCase {
    func test_filter_returns_only_selected_type() {
        let state = AppState.preview
        let stories = state.plazaProjectsFiltered(by: .story, sort: .recommended)
        XCTAssertTrue(stories.allSatisfy { $0.type == .story })
    }

    func test_like_toggle_updates_count() {
        let state = AppState.preview
        let project = state.plazaProjects[0]
        let original = project.likeCount

        state.toggleLike(projectID: project.id)

        XCTAssertEqual(state.project(id: project.id)?.likeCount, original + 1)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/PlazaInteractionTests
```

Expected: FAIL because plaza filtering and interaction APIs are missing.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/App/AppState.swift
func plazaProjectsFiltered(by kind: CreationType.Kind?, sort: PlazaSort) -> [CreationProject] {
    let filtered = plazaProjects.filter { kind == nil || $0.type == kind }
    switch sort {
    case .recommended: return filtered
    case .hot: return filtered.sorted { $0.likeCount > $1.likeCount }
    }
}

func toggleLike(projectID: UUID) {
    guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
    projects[index].isLiked.toggle()
    projects[index].likeCount += projects[index].isLiked ? 1 : -1
}

func rate(projectID: UUID, value: Int) {
    guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
    projects[index].userRating = value
}
```

```swift
// AI课堂/Features/Plaza/PlazaView.swift
import SwiftUI

struct PlazaView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedKind: CreationType.Kind?
    @State private var sort: PlazaSort = .recommended

    var body: some View {
        NavigationStack {
            List(appState.plazaProjectsFiltered(by: selectedKind, sort: sort)) { project in
                NavigationLink(project.title) {
                    PlazaDetailView(projectID: project.id)
                }
            }
            .navigationTitle("广场")
            .toolbar {
                Menu("排序") {
                    Button("默认推荐") { sort = .recommended }
                    Button("热度优先") { sort = .hot }
                }
            }
        }
    }
}
```

```swift
// AI课堂/Features/Plaza/PlazaDetailView.swift
import SwiftUI

struct PlazaDetailView: View {
    @EnvironmentObject private var appState: AppState
    let projectID: UUID

    var body: some View {
        if let project = appState.project(id: projectID) {
            VStack(alignment: .leading, spacing: 16) {
                Text(project.title).font(.title.bold())
                Button(project.isLiked ? "取消点赞" : "点赞") {
                    appState.toggleLike(projectID: projectID)
                }
                Stepper("评分 \(project.userRating ?? 0)", value: Binding(
                    get: { project.userRating ?? 0 },
                    set: { appState.rate(projectID: projectID, value: $0) }
                ), in: 0...5)
            }
            .padding()
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/PlazaInteractionTests
```

Expected: PASS with two executed tests.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/Features/Plaza" "AI课堂/App/AppState.swift" "AI课堂/App/AppView.swift" "AI课堂Tests/PlazaInteractionTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add plaza browsing interactions"
```

### Task 7: 我的 Page, Tasks, Recent Friends, Voice Settings, and Placeholder Pages

**Priority:** P1

**Files:**
- Create: `AI课堂/Features/Profile/ProfileView.swift`
- Create: `AI课堂/Features/Profile/ClassroomTasksView.swift`
- Create: `AI课堂/Features/Profile/RecentFriendsView.swift`
- Create: `AI课堂/Features/Profile/VoiceSettingsView.swift`
- Create: `AI课堂/Features/Profile/PlaceholderInfoView.swift`
- Create: `AI课堂/Features/Profile/AccountSettingsView.swift`
- Modify: `AI课堂/App/AppView.swift`
- Modify: `AI课堂/App/AppState.swift`
- Test: `AI课堂Tests/ProfileRoutingTests.swift`

- [ ] **Step 1: Extend the failing tests**

```swift
func test_recent_friends_returns_latest_opened_first() {
    let state = AppState.preview
    let first = state.friends[0]
    let second = state.friends[1]

    state.openFriend(first)
    state.openFriend(second)

    XCTAssertEqual(state.recentFriends.map(\.id), [second.id, first.id])
}

func test_voice_settings_update_persists_in_state() {
    let state = AppState.preview
    state.voiceSettings.isNarrationEnabled = false
    XCTAssertFalse(state.voiceSettings.isNarrationEnabled)
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/ProfileRoutingTests
```

Expected: FAIL because `recentFriends` or the view wiring is incomplete.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/App/AppState.swift
var recentFriends: [AIFriend] {
    recentFriendIDs.compactMap { id in
        friends.first(where: { $0.id == id })
    }
}
```

```swift
// AI课堂/Features/Profile/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("课堂任务") { ClassroomTasksView() }
                NavigationLink("我的创作") { MyCreationsView() }
                NavigationLink("我的 AI 朋友") { RecentFriendsView() }
                NavigationLink("语音设置") { VoiceSettingsView() }
                NavigationLink("家长设置") { PlaceholderInfoView(title: "家长设置", message: "后续将支持使用时长与创作记录管理") }
                NavigationLink("老师入口") { PlaceholderInfoView(title: "老师入口", message: "后续将支持任务布置与课堂面板") }
                NavigationLink("账号设置") { AccountSettingsView() }
            }
            .navigationTitle("我的")
        }
    }
}
```

```swift
// AI课堂/Features/Profile/VoiceSettingsView.swift
import SwiftUI

struct VoiceSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Toggle("播报开关", isOn: $appState.voiceSettings.isNarrationEnabled)
            Picker("语速", selection: $appState.voiceSettings.speed) {
                Text("慢").tag(VoiceSettings.Speed.slow)
                Text("中").tag(VoiceSettings.Speed.normal)
                Text("快").tag(VoiceSettings.Speed.fast)
            }
        }
        .navigationTitle("语音设置")
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/ProfileRoutingTests
```

Expected: PASS with all profile-related tests green.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/Features/Profile" "AI课堂/App/AppState.swift" "AI课堂/App/AppView.swift" "AI课堂Tests/ProfileRoutingTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: add profile and settings screens"
```

### Task 8: Cross-Screen State Sync, Empty States, Loading States, and Prototype Polish

**Priority:** P1

**Files:**
- Modify: `AI课堂/App/AppView.swift`
- Modify: `AI课堂/App/AppState.swift`
- Modify: `AI课堂/Features/Friends/FriendChatView.swift`
- Modify: `AI课堂/Features/Create/CreateHubView.swift`
- Modify: `AI课堂/Features/Create/MyCreationsView.swift`
- Modify: `AI课堂/Features/Create/CreationResultView.swift`
- Modify: `AI课堂/Features/Plaza/PlazaView.swift`
- Modify: `AI课堂/Features/Profile/ProfileView.swift`
- Test: `AI课堂Tests/CreationFlowTests.swift`
- Test: `AI课堂Tests/PlazaInteractionTests.swift`

- [ ] **Step 1: Extend the failing tests**

```swift
func test_deleting_project_removes_it_from_my_creations_and_plaza() {
    let state = AppState.preview
    let project = state.plazaProjects[0]

    state.deleteProject(id: project.id)

    XCTAssertNil(state.project(id: project.id))
    XCTAssertFalse(state.plazaProjects.contains { $0.id == project.id })
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests/CreationFlowTests/test_deleting_project_removes_it_from_my_creations_and_plaza
```

Expected: FAIL because delete behavior does not exist.

- [ ] **Step 3: Write minimal implementation**

```swift
// AI课堂/App/AppState.swift
func project(id: UUID) -> CreationProject? {
    projects.first { $0.id == id }
}

func deleteProject(id: UUID) {
    projects.removeAll { $0.id == id }
}
```

```swift
// AI课堂/Features/Create/MyCreationsView.swift
List {
    ForEach(appState.projects) { project in
        NavigationLink(project.title) {
            ProjectDetailView(projectID: project.id)
        }
    }
    .onDelete { offsets in
        for offset in offsets {
            appState.deleteProject(id: appState.projects[offset].id)
        }
    }
}
```

```swift
// AI课堂/Features/Create/CreationResultView.swift
@State private var isPublishing = false

Button(isPublishing ? "发布中..." : "发布到广场") {
    isPublishing = true
    appState.publishProject(id: project.id)
    isPublishing = false
}
```

- [ ] **Step 4: Run focused tests and a full unit suite**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂Tests
```

Expected: PASS with all unit tests green.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂/App/AppState.swift" "AI课堂/Features/Friends/FriendChatView.swift" "AI课堂/Features/Create" "AI课堂/Features/Plaza/PlazaView.swift" "AI课堂/Features/Profile/ProfileView.swift" "AI课堂Tests/CreationFlowTests.swift" "AI课堂Tests/PlazaInteractionTests.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "feat: sync prototype state across tabs"
```

### Task 9: Smoke UI Tests and Device-Level Verification

**Priority:** P2

**Files:**
- Create: `AI课堂UITests/PrototypeSmokeUITests.swift`
- Modify: `AI课堂UITests/AI__UITests.swift`
- Modify: `AI课堂UITests/AI__UITestsLaunchTests.swift`

- [ ] **Step 1: Write the failing UI test**

```swift
import XCTest

final class PrototypeSmokeUITests: XCTestCase {
    func test_login_create_publish_and_browse_plaza() {
        let app = XCUIApplication()
        app.launch()

        app.textFields["家长手机号"].tap()
        app.textFields["家长手机号"].typeText("13800138000")
        app.buttons["获取验证码"].tap()
        app.textFields["验证码"].tap()
        app.textFields["验证码"].typeText("123456")
        app.buttons["进入课堂"].tap()

        XCTAssertTrue(app.staticTexts["AI朋友"].waitForExistence(timeout: 2))
    }
}
```

- [ ] **Step 2: Run the UI test to verify it fails**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂UITests/PrototypeSmokeUITests
```

Expected: FAIL until accessibility labels and the tab shell are fully in place.

- [ ] **Step 3: Add accessibility labels and finish the smoke path**

```swift
// LoginView.swift
TextField("家长手机号", text: $viewModel.phoneNumber)
    .accessibilityIdentifier("phoneField")

TextField("验证码", text: $viewModel.verificationCode)
    .accessibilityIdentifier("codeField")
```

```swift
// FriendsListView.swift
.navigationTitle("AI朋友")
.accessibilityIdentifier("friendsScreen")
```

```swift
// PrototypeSmokeUITests.swift
XCTAssertTrue(app.otherElements["friendsScreen"].waitForExistence(timeout: 2))
app.tabBars.buttons["AI创作"].tap()
app.staticTexts["故事卡"].tap()
app.textFields["标题"].tap()
app.textFields["标题"].typeText("太空冒险")
app.textFields["主题"].tap()
app.textFields["主题"].typeText("月球猫")
app.buttons["开始创作"].tap()
app.buttons["发布到广场"].tap()
app.tabBars.buttons["广场"].tap()
XCTAssertTrue(app.staticTexts["太空冒险"].waitForExistence(timeout: 2))
```

- [ ] **Step 4: Run iPhone and iPad verification**

Run:

```bash
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AI课堂UITests/PrototypeSmokeUITests
xcodebuild test -scheme "AI课堂" -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' -only-testing:AI课堂UITests/PrototypeSmokeUITests
```

Expected: PASS on both simulator destinations.

- [ ] **Step 5: Commit**

```bash
git add "AI课堂UITests" "AI课堂/Features/Auth/LoginView.swift" "AI课堂/Features/Friends/FriendsListView.swift" "AI课堂/Features/Create/CreationFormView.swift" "AI课堂.xcodeproj/project.pbxproj"
git commit -m "test: add phase one prototype smoke tests"
```

## Spec Coverage Check

- Login: covered by Task 2 and Task 9.
- AI朋友 list, card entry, chat, recent use: covered by Task 4 and Task 7.
- AI创作 tabs, forms, result page, my creations: covered by Task 5 and Task 8.
- 广场 browse, filter, sort, like, rating, detail: covered by Task 6.
- 我的 page, classroom tasks, voice settings, placeholders, account: covered by Task 7.
- Shared states, empty/loading/publish/delete flows: covered by Task 8.
- iPad/phone smoke verification: covered by Task 9.

## Notes for Execution

1. Do not split the six creation types into six separate view files in phase one. Keep one generic form and one generic result screen.
2. Keep all data in memory for phase one. Do not add persistence, networking, or external dependencies.
3. Reuse `CreationProject` everywhere to avoid state drift between AI创作, 广场, and 我的.
4. If `@Observable` macros complicate deployment target or tests, use `ObservableObject` consistently and keep the prototype moving.

## Recommended Execution Rhythm

1. Finish all P0 tasks before polishing visuals.
2. After each task, manually run the app once in the simulator and verify the primary path before committing.
3. Do not start UI tests before the P0 shell is stable.
4. Keep commits small and aligned with the task list above.
