import XCTest
import BrightSDK
@testable import BrightSDKSwiftDemo
final class ConnectionKeyTests: XCTestCase {
    func testOptionalKeyResetsPreviouslyConfiguredSDKCredential() {
        let defaults = UserDefaults.standard
        let previous = defaults.object(forKey: "BRIGHTSDK_APPKEY")
        defer { defaults.set(previous, forKey: "BRIGHTSDK_APPKEY") }
        let key = String(repeating: "a", count: 32)
        BrightSDKClient.configureConnectionKey("  \(key)\n")
        XCTAssertEqual(defaults.string(forKey: "BRIGHTSDK_APPKEY"), key)
        BrightSDKClient.configureConnectionKey(" \n")
        XCTAssertEqual(
            defaults.string(forKey: "BRIGHTSDK_APPKEY"), String(repeating: "0", count: 32))
        BrightSDKClient.configureConnectionKey(String(repeating: "b", count: 32))
        BrightSDKClient.configureConnectionKey("")
        XCTAssertEqual(
            defaults.string(forKey: "BRIGHTSDK_APPKEY"), String(repeating: "0", count: 32))
    }

    func testIBeaconCallbackPreservesSDKBeaconObjects() {
        let uuid = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        let beacon = BRTBeacon()
        beacon.proximityUUID = UUID(uuidString: uuid)
        beacon.major = 12
        beacon.minor = 34
        beacon.rssi = -61
        let rows = BrightSDKClient.receivedBeacons([beacon])
        XCTAssertEqual(rows.count, 1, "SDK returns BRTBeacon, not CLBeacon")
        XCTAssertEqual(rows.first?.rssi, -61)
        XCTAssertTrue(rows.first === beacon)
        XCTAssertEqual(rows.first?.major, 12)
        XCTAssertEqual(rows.first?.minor, 34)
    }

}
