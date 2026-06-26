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

        XCTAssertTrue(app.otherElements["splashRoot"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["loginRoot"].waitForExistence(timeout: 4))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
