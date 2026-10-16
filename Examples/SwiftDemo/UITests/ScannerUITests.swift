import XCTest
final class ScannerUITests: XCTestCase {
    func testModesAndSimulatorState() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.cells.count, 2)
        app.navigationBars.buttons["集成说明"].tap()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "import BrightSDK"))
                .firstMatch.exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertFalse(app.staticTexts["AppKey 注册验证"].exists)
        for mode in 0...1 {
            app.cells["scan-mode-\(mode)"].tap()
            XCTAssertEqual(app.textFields["uuid-filter"].exists, mode == 0)
            XCTAssertFalse(app.textFields["connection-appkey"].exists)
            app.buttons["scan-toggle"].tap()
            XCTAssertEqual(app.staticTexts["scan-status"].label, "需要真机")
            XCTAssertTrue(app.staticTexts["scan-empty"].label.contains("模拟器无法接收真实 Beacon"))
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

}
