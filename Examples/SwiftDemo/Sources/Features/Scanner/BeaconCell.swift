import UIKit
import BrightSDK

final class BeaconCell: UITableViewCell {
    let name = UILabel()
    let detail = UILabel()
    let signal = UILabel()
    let action = UIButton(type: .system)
    var onConnect: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        name.font = .preferredFont(forTextStyle: .headline)
        name.numberOfLines = 0
        detail.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        detail.textColor = .secondaryLabel
        detail.numberOfLines = 0
        signal.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        signal.textColor = .systemBlue
        action.setTitle("连接", for: .normal)
        action.addTarget(self, action: #selector(connect), for: .touchUpInside)
        let top = UIStackView(arrangedSubviews: [name, signal])
        top.spacing = 8
        top.alignment = .center
        signal.setContentCompressionResistancePriority(.required, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: [top, detail, action])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
    @objc private func connect() { onConnect?() }
    func render(_ row: BRTBeacon, mode: ScanMode, enabled: Bool) {
        name.text =
            mode == .iBeacon
            ? "Major \(row.major?.stringValue ?? "未知") · Minor \(row.minor?.stringValue ?? "未知")"
            : (row.name?.isEmpty == false ? row.name : "未命名设备")
        detail.text =
            mode == .iBeacon
            ? "UUID：\(row.proximityUUID?.uuidString ?? "未知")"
            : "MAC：\(row.macAddress ?? "广播未提供")\n本机标识：\(row.peripheral?.identifier.uuidString ?? "不可用")"
        signal.text = row.rssi == 0 ? "RSSI 未知" : "\(row.rssi) dBm"
        action.isHidden = mode == .iBeacon
        action.isEnabled = (row.isBrightBeacon && row.peripheral != nil) && enabled
        action.setTitle(
            (row.isBrightBeacon && row.peripheral != nil) ? "连接" : "该广播不支持 BrightSDK 连接",
            for: .normal)
        action.accessibilityIdentifier = "connect-\(row.peripheral?.identifier.uuidString ?? "")"
    }
}
