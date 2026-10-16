import UIKit

final class HomeController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BrightSDK · Swift"
        navigationItem.backButtonTitle = "首页"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "集成说明", style: .plain, target: self, action: #selector(openGuide))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }

    @objc private func openGuide() {
        navigationController?.pushViewController(IntegrationGuide(style: .insetGrouped), animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {2}

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    { "选择扫描方式" }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        "如何选择？\n识别 UUID / Major / Minor → iBeacon 扫描\n查找并连接 BrightBeacon 设备 → BLE 扫描\n\n两种扫描均无需 AppKey。连接 BLE 设备时可选填，是否需要由设备配置决定。"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let mode = ScanMode(rawValue: indexPath.row)!
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = mode.title
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.text = mode.summary + "\n\n" + mode.explanation
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(
            systemName: mode == .iBeacon
                ? "dot.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right")
        cell.imageView?.tintColor = .systemBlue
        cell.accessibilityIdentifier = "scan-mode-\(mode.rawValue)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            ScannerController(mode: ScanMode(rawValue: indexPath.row)!), animated: true)
    }
}
