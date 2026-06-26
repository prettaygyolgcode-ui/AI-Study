import XCTest

final class PrototypeSmokeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLoginCreatePublishAndBrowsePlaza() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["loginRoot"].waitForExistence(timeout: 4))

        app.textFields["phoneField"].tap()
        app.textFields["phoneField"].typeText("13800138000")
        app.buttons["requestCodeButton"].tap()
        app.textFields["codeField"].tap()
        app.textFields["codeField"].typeText("123456")
        app.buttons["enterClassroomButton"].tap()

        XCTAssertTrue(app.otherElements["friendsScreen"].waitForExistence(timeout: 3))

        tapTab(named: "AI创作", in: app)
        XCTAssertTrue(app.otherElements["createHubScreen"].waitForExistence(timeout: 2))
        let storyCard = app.buttons["creationCard-story"]
        XCTAssertTrue(storyCard.waitForExistence(timeout: 2))
        storyCard.tap()

        XCTAssertTrue(app.textFields["creationTitleField"].waitForExistence(timeout: 3))
        app.textFields["creationTitleField"].tap()
        app.textFields["creationTitleField"].typeText("太空冒险")
        app.textFields["creationSubjectField"].tap()
        app.textFields["creationSubjectField"].typeText("月球猫")
        app.textFields["creationStyleField"].tap()
        app.textFields["creationStyleField"].typeText("科幻")
        app.textFields["creationMoodField"].tap()
        app.textFields["creationMoodField"].typeText("勇敢")
        app.buttons["startCreationButton"].tap()

        XCTAssertTrue(app.staticTexts["创作完成"].waitForExistence(timeout: 3))
        app.buttons["publishToPlazaButton"].tap()
        tapTab(named: "广场", in: app)

        XCTAssertTrue(app.staticTexts["作品广场"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["太空冒险"].waitForExistence(timeout: 2))
    }

    private func tapTab(named name: String, in app: XCUIApplication) {
        let tabBarButton = app.tabBars.buttons[name].firstMatch
        if tabBarButton.waitForExistence(timeout: 1) {
            tabBarButton.tap()
            return
        }

        let button = app.buttons[name].firstMatch
        if button.waitForExistence(timeout: 1) {
            button.tap()
            return
        }

        let cell = app.cells[name].firstMatch
        if cell.waitForExistence(timeout: 1) {
            cell.tap()
            return
        }

        XCTFail("Could not find tab named \(name)")
    }
}
