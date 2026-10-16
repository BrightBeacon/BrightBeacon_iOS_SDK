import UIKit

/// A short path from the sample UI to the actual SDK API calls.
final class IntegrationGuide: UITableViewController {
    private let steps: [(String, String)] = [
        (
            "1 · 添加 SDK",
            "将 BrightSDK.xcframework 添加到 App Target。\nLink Binary With Libraries 中保留一份，选择 Do Not Embed。\n移除旧 libBrightSDK.a 链接。"
        ),
        (
            "2 · 导入与权限",
            "import BrightSDK\n\nBLE：配置蓝牙用途说明。\niBeacon：额外配置使用期间定位说明。\n本工程 Sources/App/Info.plist 已提供示例。"
        ),
        (
            "3 · 扫描与停止",
            "// BLE：无需 AppKey\nBRTBeaconSDK.scanBleServices(nil) { devices, error in\n    // 更新设备列表\n}\nBRTBeaconSDK.stopScan()\n\n// iBeacon：按 UUID 扫描，不建立连接\nBRTBeaconSDK.startRangingBeacons(in: [region]) { devices, region, error in\n    // 查看 Major / Minor / RSSI\n}\nBRTBeaconSDK.stopRangingBeacons()"
        ),
        (
            "4 · 连接：AppKey 可选",
            "// 空值会使用 SDK 默认凭据；覆盖之前设置的密钥\nBRTBeaconSDK.registerApp(appKey, onCompletion: nil)\nbeacon.connectToBeacon { connected, error in\n    // 以真实连接回调显示结果\n}\nbeacon.disconnectBeacon()\n\n未设置密钥的设备可留空；设置过密钥的设备需对应 AppKey。默认凭据不等于跳过设备鉴权。"
        ),
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swift 集成说明"
        navigationItem.largeTitleDisplayMode = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
    }

    override func numberOfSections(in tableView: UITableView) -> Int { steps.count }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    { steps[section].0 }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
        -> String?
    {
        section == steps.count - 1
            ? "SDK 调用集中在 Sources/SDK/BrightSDKClient.swift；ScannerController.swift 负责界面和权限，无 OC 桥接。"
            : nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = steps[indexPath.section].1
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        cell.selectionStyle = .none
        return cell
    }
}
