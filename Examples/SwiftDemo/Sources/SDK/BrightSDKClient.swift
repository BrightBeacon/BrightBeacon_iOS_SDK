import Foundation
import BrightSDK

typealias DemoUpdate = ([BRTBeacon], Error?) -> Void
typealias DemoConnection = (Bool, String) -> Void

/// 扫描 → 选择回调中的 BRTBeacon → 可选 AppKey 连接 → stop。
final class BrightSDKClient: NSObject, BRTBeaconDelegate {
    var onDisconnect: ((String) -> Void)?
    private var connectionEstablished = false
    private var scanningStarted = false
    private var connectedBeacon: BRTBeacon?
    private var generation = UUID()
    func startBLE(output: @escaping DemoUpdate) {
        stop()
        scanningStarted = true
        let token = generation
        BRTBeaconSDK.setInvalidTime(3)
        BRTBeaconSDK.setScanResponseTime(1)
        BRTBeaconSDK.scanBleServices(nil) { [weak self] items, error in
            DispatchQueue.main.async {
                guard let self = self, self.generation == token else { return }
                output(Self.receivedBeacons(items as? [Any] ?? []), error)
            }
        }
    }

    func startIBeacon(uuid: String, output: @escaping DemoUpdate) {
        stop()
        scanningStarted = true
        let token = generation
        let region = BRTBeaconRegion(
            proximityUUID: UUID(uuidString: uuid)!, identifier: "BrightSDK.Demo")!
        BRTBeaconSDK.startRangingBeacons(in: [region]) { [weak self] items, _, error in
            DispatchQueue.main.async {
                guard let self = self, self.generation == token else { return }
                let rows = Self.receivedBeacons(items as? [Any] ?? [])
                output(rows, error)
            }
        }
    }
    /// SDK 回调的是 BRTBeacon，不是 Core Location 的 CLBeacon。
    static func receivedBeacons(_ items: [Any]) -> [BRTBeacon] {
        items.compactMap { $0 as? BRTBeacon }
    }

    func connect(_ beacon: BRTBeacon, appKey: String, completion: @escaping DemoConnection) {
        guard beacon.isBrightBeacon, beacon.peripheral != nil else {
            completion(false, "该广播不支持 BrightSDK 连接。")
            return
        }
        connectedBeacon?.delegate = nil
        connectedBeacon?.disconnectBeacon()
        connectedBeacon = beacon
        connectionEstablished = false
        beacon.delegate = self
        let token = generation
        // A blank key means the SDK default, not an authentication bypass.
        // Always set it, so a previous device's key cannot leak into this attempt.
        Self.configureConnectionKey(appKey)
        beacon.connectToBeacon { [weak self] connected, error in
            DispatchQueue.main.async {
                guard let self = self, self.generation == token else { return }
                self.connectionEstablished = connected && error == nil
                if self.connectionEstablished { BRTBeaconSDK.stopScan() }
                completion(
                    connected && error == nil,
                    error.map { "连接失败：\($0.localizedDescription)" }
                        ?? (connected ? "设备连接成功" : "设备未连接成功"))
            }
        }
    }

    /// Public SDK registration with a nil callback sets the key without server validation.
    /// Device authentication (if any) still happens through the SDK connection flow.
    static func configureConnectionKey(_ appKey: String) {
        let key = appKey.trimmingCharacters(in: .whitespacesAndNewlines)
        BRTBeaconSDK.registerApp(
            key.isEmpty ? String(repeating: "0", count: 32) : key, onCompletion: nil)
    }

    func beaconDidDisconnect(_ beacon: BRTBeacon!, withError error: Error!) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.connectedBeacon === beacon, self.connectionEstablished
            else { return }
            self.connectionEstablished = false
            self.onDisconnect?(error?.localizedDescription ?? "设备连接已断开")
        }
    }

    func stop() {
        generation = UUID()
        if scanningStarted {
            BRTBeaconSDK.stopScan()
            BRTBeaconSDK.stopRangingBeacons()
        }
        scanningStarted = false
        connectionEstablished = false
        connectedBeacon?.delegate = nil
        connectedBeacon?.disconnectBeacon()
        connectedBeacon = nil
    }
}
