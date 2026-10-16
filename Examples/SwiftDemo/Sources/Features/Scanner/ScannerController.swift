import UIKit
import CoreBluetooth
import CoreLocation
import BrightSDK

enum ScanMode: Int {
    case iBeacon, ble
    var title: String { self == .iBeacon ? "iBeacon 扫描" : "BLE 扫描" }
    var summary: String { self == .iBeacon ? "识别信标 · 无法连接" : "发现设备 · 按需连接" }
    var explanation: String {
        self == .iBeacon
            ? "按指定 UUID 识别 iBeacon 广播，查看：Major、Minor、信号强度RSSI。此扫描不能蓝牙连接。"
            : "发现 BrightSDK 可识别的蓝牙广播设备，查看：Major、Minor、名称、MAC地址、信号强度RSSI。扫描不需要 AppKey；连接时可选填 AppKey。"
    }
}

final class ScannerController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    CBCentralManagerDelegate, CLLocationManagerDelegate, UITextFieldDelegate
{
    let mode: ScanMode
    private var engine = BrightSDKClient()
    private var rows: [BRTBeacon] = []
    private let uuid = UITextField()
    private let status = UILabel()
    private let permissions = UILabel()
    private let count = UILabel()
    private let empty = UILabel()
    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let scanButton = UIButton(type: .system)
    private var bluetooth: CBCentralManager?
    private let location = CLLocationManager()
    private var scanning = false
    private var pendingStart = false
    private var connecting = false
    private var visible = true
    private var session = UUID()
    private var connectionTimeout: DispatchWorkItem?
    init(mode: ScanMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode.title
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        let description = UILabel()
        description.numberOfLines = 0
        description.font = .preferredFont(forTextStyle: .subheadline)
        description.textColor = .secondaryLabel
        description.text = mode.explanation
        uuid.text = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        uuid.borderStyle = .roundedRect
        uuid.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        uuid.autocapitalizationType = .allCharacters
        uuid.autocorrectionType = .no
        uuid.clearButtonMode = .whileEditing
        uuid.delegate = self
        uuid.accessibilityIdentifier = "uuid-filter"
        let uuidLabel = UILabel()
        uuidLabel.text = "匹配 UUID · Major / Minor 不限"
        uuidLabel.font = .preferredFont(forTextStyle: .caption1)
        let filter = UIStackView(arrangedSubviews: [uuidLabel, uuid])
        filter.axis = .vertical
        filter.spacing = 6
        filter.isHidden = mode == .ble
        status.text = "尚未扫描"
        status.font = .preferredFont(forTextStyle: .headline)
        status.accessibilityIdentifier = "scan-status"
        count.text = "0 个设备"
        count.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        count.textColor = .secondaryLabel
        let stateRow = UIStackView(arrangedSubviews: [status, count])
        stateRow.distribution = .equalSpacing
        permissions.numberOfLines = 0
        permissions.font = .preferredFont(forTextStyle: .caption1)
        permissions.textColor = .secondaryLabel
        let identityHint = UILabel()
        identityHint.numberOfLines = 0
        identityHint.font = .preferredFont(forTextStyle: .caption1)
        identityHint.textColor = .secondaryLabel
        identityHint.text = "本机标识由当前 iPhone 分配，不是设备的全局 ID，也不是 iBeacon UUID。"
        identityHint.isHidden = mode == .iBeacon
        let header = UIStackView(arrangedSubviews: [
            description, filter, identityHint, stateRow, permissions,
        ])
        header.axis = .vertical
        header.spacing = 12
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        table.dataSource = self
        table.delegate = self
        table.register(BeaconCell.self, forCellReuseIdentifier: "beacon")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 150
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        empty.numberOfLines = 0
        empty.textAlignment = .center
        empty.font = .preferredFont(forTextStyle: .subheadline)
        empty.textColor = .secondaryLabel
        empty.accessibilityIdentifier = "scan-empty"
        table.backgroundView = empty
        scanButton.setTitle("开始扫描", for: .normal)
        scanButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.backgroundColor = .systemBlue
        scanButton.layer.cornerRadius = 14
        scanButton.addTarget(self, action: #selector(toggleScan), for: .touchUpInside)
        scanButton.accessibilityIdentifier = "scan-toggle"
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanButton)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            table.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: scanButton.topAnchor, constant: -10),
            scanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            scanButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
        engine.onDisconnect = { [weak self] message in
            guard let self = self, self.visible else { return }
            self.finishScan(message: "设备已断开")
            self.empty.text = message
        }
        location.delegate = self
        NotificationCenter.default.addObserver(
            self, selector: #selector(background),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        refreshPermissions()
        refreshRows()
    }

    private func refreshPermissions() {
        #if targetEnvironment(simulator)
            permissions.text = "模拟器 · 可查看示例界面；真实扫描与连接请使用 iPhone。"
        #else
            let ble: String
            switch bluetooth?.state {
            case .poweredOn?: ble = "已开启"
            case .poweredOff?: ble = "已关闭"
            case .unauthorized?: ble = "未授权"
            case .unsupported?: ble = "不支持"
            default: ble = "待检查"
            }
            var value = "蓝牙：\(ble)"
            if mode == .iBeacon {
                let auth: String
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways: auth = "始终允许"
                case .authorizedWhenInUse: auth = "使用期间允许"
                case .denied, .restricted: auth = "未允许"
                default: auth = "待授权"
                }
                value += " · 定位：\(auth)"
            }
            permissions.text = value
        #endif
    }

    private func refreshRows() {
        count.text = "\(rows.count) 个设备"
        empty.isHidden = !rows.isEmpty
        if !scanning && rows.isEmpty {
            empty.text =
                "等待开始\n\n" + (mode == .iBeacon ? "请确认 UUID 与 Beacon 配置一致。" : "扫描无需 AppKey；连接时可选填。")
        }
        table.reloadData()
    }

    @objc private func toggleScan() {
        if scanning || pendingStart || connecting {
            finishScan(message: "已停止")
            return
        }
        start()
    }

    private func start() {
        view.endEditing(true)
        if mode == .iBeacon && UUID(uuidString: uuid.text ?? "") == nil {
            status.text = "UUID 格式无效"
            return
        }
        #if targetEnvironment(simulator)
            status.text = "需要真机"
            empty.text = "模拟器无法接收真实 Beacon 广播。\n\n请在 iPhone 上运行本示例。"
            return
        #else
            pendingStart = true
            scanButton.setTitle("取消", for: .normal)
            if bluetooth == nil {
                bluetooth = CBCentralManager(delegate: self, queue: .main)
                status.text = "正在检查蓝牙…"
                return
            }
            guard bluetooth?.state == .poweredOn else {
                status.text = "蓝牙未就绪"
                refreshPermissions()
                return
            }
            if mode == .iBeacon {
                guard CLLocationManager.locationServicesEnabled() else {
                    finishScan(message: "请开启系统定位服务")
                    return
                }
                let authorization = CLLocationManager.authorizationStatus()
                if authorization == .notDetermined {
                    status.text = "等待定位授权…"
                    location.requestWhenInUseAuthorization()
                    return
                }
                guard authorization == .authorizedAlways || authorization == .authorizedWhenInUse
                else {
                    finishScan(message: "请在设置中允许定位权限")
                    return
                }
            }
            pendingStart = false
            scanning = true
            session = UUID()
            let token = session
            rows.removeAll()
            uuid.isEnabled = false
            scanButton.setTitle("停止扫描", for: .normal)
            status.text = "扫描中 · 等待回调"
            refreshRows()
            empty.text =
                "正在等待广播…\n\n"
                + (mode == .iBeacon ? "仅接收当前 UUID 的 iBeacon。" : "将附近 BrightBeacon 放到手机旁。")
            let update: DemoUpdate = { [weak self] devices, error in
                DispatchQueue.main.async {
                    guard let self = self, self.visible, self.session == token, self.scanning,
                        !self.connecting
                    else { return }
                    if let error = error {
                        self.finishScan(message: "扫描失败")
                        self.empty.text = error.localizedDescription
                        return
                    }
                    self.rows = devices.sorted {
                        $0.rssi == $1.rssi
                            ? ($0.peripheral?.identifier.uuidString ?? $0.proximityUUID?.uuidString
                                ?? "")
                                < ($1.peripheral?.identifier.uuidString ?? $1.proximityUUID?
                                    .uuidString ?? "")
                            : ($0.rssi == 0 ? false : $1.rssi == 0 ? true : $0.rssi > $1.rssi)
                    }
                    self.status.text =
                        "扫描中 · "
                        + DateFormatter.localizedString(
                            from: Date(), dateStyle: .none, timeStyle: .medium)
                    self.refreshRows()
                    if self.rows.isEmpty {
                        self.empty.text =
                            "暂未发现设备\n\n"
                            + (self.mode == .iBeacon
                                ? "检查 UUID 是否匹配、Beacon 是否开启。" : "检查设备是否在附近并正在广播。")
                    }
                }
            }
            if mode == .ble {
                engine.startBLE(output: update)
            } else {
                engine.startIBeacon(uuid: uuid.text!, output: update)
            }
        #endif
    }

    private func finishScan(message: String) {
        session = UUID()
        pendingStart = false
        scanning = false
        connecting = false
        connectionTimeout?.cancel()
        connectionTimeout = nil
        engine.stop()
        uuid.isEnabled = true
        scanButton.setTitle("开始扫描", for: .normal)
        status.text = message
        table.reloadData()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        refreshPermissions()
        if central.state == .poweredOn && pendingStart {
            start()
        } else if central.state != .poweredOn {
            finishScan(message: "蓝牙不可用")
            empty.text = "请检查蓝牙开关和应用蓝牙权限。"
        }
    }

    func locationManager(
        _ manager: CLLocationManager, didChangeAuthorization authorization: CLAuthorizationStatus
    ) {
        refreshPermissions()
        if pendingStart && authorization != .notDetermined {
            start()
        } else if scanning && mode == .iBeacon && authorization != .authorizedAlways
            && authorization != .authorizedWhenInUse
        {
            finishScan(message: "定位权限已关闭")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "beacon", for: indexPath) as! BeaconCell
        let row = rows[indexPath.row]
        cell.render(row, mode: mode, enabled: scanning && !connecting)
        cell.onConnect = { [weak self] in self?.promptForKey(row) }
        return cell
    }

    private func promptForKey(_ row: BRTBeacon) {
        guard mode == .ble, scanning, !connecting, row.isBrightBeacon && row.peripheral != nil
        else { return }
        let alert = UIAlertController(
            title: "连接 \(row.name?.isEmpty == false ? row.name! : "BrightBeacon")",
            message: "AppKey 可选。未设置密钥的设备可留空，使用 SDK 默认凭据；已设置密钥的设备请填写对应 AppKey。",
            preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "AppKey（可选，留空使用默认凭据）"
            field.isSecureTextEntry = true
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.accessibilityIdentifier = "connection-appkey"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "连接", style: .default) { [weak self, weak alert] _ in
                guard let self = self else { return }
                let key = (alert?.textFields?.first?.text ?? "").trimmingCharacters(
                    in: .whitespacesAndNewlines)
                self.connect(row, key: key)
            })
        present(alert, animated: true)
    }

    private func connect(_ row: BRTBeacon, key: String) {
        guard scanning && !connecting else { return }
        connecting = true
        status.text = "正在连接设备…"
        scanButton.setTitle("取消连接 / 停止扫描", for: .normal)
        table.reloadData()
        let token = session
        let timeout = DispatchWorkItem { [weak self] in
            guard let self = self, self.session == token, self.connecting else { return }
            self.finishScan(message: "连接超时")
            self.showMessage("连接超时", "45 秒内未完成连接，请检查设备状态、蓝牙及设备所需的 AppKey。")
        }
        connectionTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 45, execute: timeout)
        engine.connect(row, appKey: key) { [weak self] success, message in
            DispatchQueue.main.async {
                guard let self = self, self.session == token, self.connecting else { return }
                self.connectionTimeout?.cancel()
                self.connectionTimeout = nil
                self.connecting = false
                if success {
                    self.scanning = false
                    self.status.text = "设备已连接"
                    self.scanButton.setTitle("断开连接", for: .normal)
                    self.connecting = true
                } else {
                    self.status.text = "连接失败 · 可重试"
                    self.scanButton.setTitle("停止扫描", for: .normal)
                }
                self.table.reloadData()
                self.showMessage(
                    success ? "连接成功" : "连接失败",
                    success ? message : message + "\n\n如设备已设置密钥，请重试并填写对应 AppKey；也请检查设备距离和蓝牙状态。")
            }
        }
    }

    private func showMessage(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func background() { finishScan(message: "已暂停 · 应用进入后台") }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            visible = false
            finishScan(message: "已停止")
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}
