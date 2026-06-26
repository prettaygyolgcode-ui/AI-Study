//
//  AI__UITestsLaunchTests.swift
//  AI课堂UITests
//
//  Created by LazyG on 2026/6/26.
//

import XCTest

final class AI__UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["loginRoot"].waitForExistence(timeout: 4))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Login Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
