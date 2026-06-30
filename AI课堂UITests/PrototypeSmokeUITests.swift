import XCTest

final class PrototypeSmokeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLoginCreateApproveAndBrowsePlaza() throws {
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

        fillSeed(plot: "小鹿在森林里找到发光地图", protagonist: "女孩", in: app)
        selectCanvasOption(field: "theme", option: "冒险", in: app)
        selectCanvasOption(field: "value", option: "勇气", in: app)
        selectCanvasOption(field: "style", option: "水彩童话", in: app)
        tapCanvasControl(identifier: "generateFromCanvasButton", in: app)

        XCTAssertTrue(app.staticTexts["创作完成"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["已提交审核，老师通过后会发布到广场。"].waitForExistence(timeout: 2))

        tapTab(named: "我的", in: app)
        XCTAssertTrue(app.scrollViews["profileScreen"].waitForExistence(timeout: 2))
        tapButton(identifier: "profileLink-老师入口", in: app)
        tapButton(identifier: "skipTeacherAuthorizationButton", in: app)
        tapButton(identifier: "approveProjectButton", in: app)

        tapTab(named: "广场", in: app)

        XCTAssertTrue(app.staticTexts["作品广场"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["小鹿在森林里找到发光地图"].waitForExistence(timeout: 2))
    }

    private func fillSeed(plot: String, protagonist: String, in app: XCUIApplication) {
        let button = app.buttons["promptField-seed"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()

        let editor = app.textViews["seedPlotEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 2))
        editor.tap()
        editor.typeText(plot)

        let protagonistButton = app.buttons[protagonist].firstMatch
        XCTAssertTrue(protagonistButton.waitForExistence(timeout: 2))
        protagonistButton.tap()

        app.buttons["放进画布"].tap()
    }

    private func selectCanvasOption(field: String, option: String, in app: XCUIApplication) {
        tapCanvasControl(identifier: "promptField-\(field)", in: app)

        let optionButton = app.buttons["promptOption-\(option)"].firstMatch
        XCTAssertTrue(optionButton.waitForExistence(timeout: 2))
        optionButton.tap()
        XCTAssertTrue(optionButton.waitForNonExistence(timeout: 2))
    }

    private func tapCanvasControl(identifier: String, in app: XCUIApplication) {
        let toolbar = app.otherElements["promptToolbar"].firstMatch

        for _ in 0..<5 {
            let button = app.buttons[identifier].firstMatch
            if button.waitForExistence(timeout: 1), app.frame.intersects(button.frame) {
                button.tap()
                return
            }

            if toolbar.waitForExistence(timeout: 1) {
                let start = toolbar.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5))
                let end = toolbar.coordinate(withNormalizedOffset: CGVector(dx: 0.12, dy: 0.5))
                start.press(forDuration: 0.05, thenDragTo: end)
            } else {
                app.swipeLeft()
            }
        }

        XCTFail("Could not tap canvas control \(identifier)")
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

    private func tapButton(identifier: String, in app: XCUIApplication) {
        for _ in 0..<6 {
            let button = app.buttons[identifier].firstMatch
            if button.waitForExistence(timeout: 1), button.isHittable {
                button.tap()
                return
            }
            app.swipeUp()
        }

        XCTFail("Could not find button with identifier \(identifier)")
    }

    private func tapButton(named name: String, in app: XCUIApplication) {
        for _ in 0..<6 {
            let button = app.buttons[name].firstMatch
            if button.waitForExistence(timeout: 1), button.isHittable {
                button.tap()
                return
            }
            app.swipeUp()
        }

        XCTFail("Could not find button named \(name)")
    }
}
