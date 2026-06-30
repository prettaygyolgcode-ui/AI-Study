//
//  AI__UITests.swift
//  AI课堂UITests
//
//  Created by LazyG on 2026/6/26.
//

import XCTest

final class AI__UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsSplashThenLogin() throws {
        let app = XCUIApplication()
        app.launch()

        _ = app.otherElements["splashRoot"].waitForExistence(timeout: 2)
        XCTAssertTrue(app.otherElements["loginRoot"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testLoginFormIsVisuallyCentered() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["loginRoot"].waitForExistence(timeout: 4))
        let primaryAction = app.buttons["enterClassroomButton"]
        XCTAssertTrue(primaryAction.waitForExistence(timeout: 2))

        XCTAssertGreaterThan(primaryAction.frame.midY, app.frame.midY)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
