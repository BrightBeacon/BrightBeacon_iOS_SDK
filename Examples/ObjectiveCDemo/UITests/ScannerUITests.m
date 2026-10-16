#import <XCTest/XCTest.h>
@interface ScannerUITests : XCTestCase
@end
@implementation ScannerUITests

- (void)testModesAndSimulatorState {
    XCUIApplication *app = [XCUIApplication new];
    [app launch];
    XCTAssertEqual(app.cells.count, 2);
    [app.navigationBars.buttons[@"集成说明"] tap];
    NSPredicate *hasImport =
        [NSPredicate predicateWithFormat:@"label CONTAINS %@", @"@import BrightSDK;"];
    XCTAssertTrue([app.staticTexts matchingPredicate:hasImport].firstMatch.exists);
    [[app.navigationBars.buttons elementBoundByIndex:0] tap];
    XCTAssertFalse(app.staticTexts[@"AppKey 注册验证"].exists);
    for (NSInteger mode = 0; mode < 2; mode++) {
        [app.cells[[NSString stringWithFormat:@"scan-mode-%ld", (long)mode]] tap];
        XCTAssertEqual(app.textFields[@"uuid-filter"].exists, mode == 0);
        XCTAssertFalse(app.textFields[@"connection-appkey"].exists);
        [app.buttons[@"scan-toggle"] tap];
        XCTAssertEqualObjects(app.staticTexts[@"scan-status"].label, @"需要真机");
        XCTAssertTrue(
            [app.staticTexts[@"scan-empty"].label containsString:@"模拟器无法接收真实 Beacon"]);
        [[app.navigationBars.buttons elementBoundByIndex:0] tap];
    }
}

@end
