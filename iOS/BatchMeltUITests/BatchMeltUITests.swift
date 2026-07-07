import XCTest

final class BatchMeltUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()
        return app
    }

    func testAddEntryFromMainList() throws {
        let app = launchApp()

        let addButton = app.buttons["addPourButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let firstField = app.textFields["pieceNameField"]
        XCTAssertTrue(firstField.waitForExistence(timeout: 5), "New entry sheet did not appear")
        firstField.tap()
        firstField.typeText("Test Entry")

        let saveButton = app.buttons["pourSaveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Test Entry"].waitForExistence(timeout: 5), "New entry did not appear on the list")
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = launchApp()
        for i in 0..<35 {
            let addButton = app.buttons["addPourButton"]
            if addButton.waitForExistence(timeout: 3) {
                addButton.tap()
                let firstField = app.textFields["pieceNameField"]
                if firstField.waitForExistence(timeout: 3) {
                    firstField.tap()
                    firstField.typeText("Entry \(i)")
                    app.buttons["pourSaveButton"].tap()
                }
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["paywallSubscribeButton"].waitForExistence(timeout: 5), "Paywall did not appear after hitting the free limit")
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = launchApp()
        let addButton = app.buttons["addPourButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let firstField = app.textFields["pieceNameField"]
        XCTAssertTrue(firstField.waitForExistence(timeout: 5))
        firstField.tap()
        firstField.typeText("Tap Away Test")
        XCTAssertTrue(app.keyboards.element.exists)

        app.navigationBars.firstMatch.tap()

        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.keyboards.element)
        _ = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should dismiss when tapping outside the text field")
    }

    func testSettingsUnlockProButtonOpensPaywall() throws {
        let app = launchApp()
        app.tabBars.buttons["Settings"].tap()
        let unlockButton = app.buttons["settingsUnlockProButton"]
        XCTAssertTrue(unlockButton.waitForExistence(timeout: 5))
        unlockButton.tap()
        XCTAssertTrue(app.buttons["paywallSubscribeButton"].waitForExistence(timeout: 5))
    }
}
