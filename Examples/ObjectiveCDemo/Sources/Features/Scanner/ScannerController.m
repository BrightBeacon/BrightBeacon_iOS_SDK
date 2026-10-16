#import "ScannerController.h"
#import "BrightSDKClient.h"
#import "BeaconCell.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <TargetConditionals.h>

@interface ScannerController () <UITableViewDataSource, UITableViewDelegate,
                                 CBCentralManagerDelegate, CLLocationManagerDelegate,
                                 UITextFieldDelegate>
@property (nonatomic, assign) BOOL ble;
@property (nonatomic, assign) BOOL scanning;
@property (nonatomic, assign) BOOL pending;
@property (nonatomic, assign) BOOL connecting;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, strong) BrightSDKClient *engine;
@property (nonatomic, strong) NSArray<BRTBeacon *> *rows;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITextField *uuid;
@property (nonatomic, strong) UILabel *status;
@property (nonatomic, strong) UILabel *permissions;
@property (nonatomic, strong) UILabel *count;
@property (nonatomic, strong) UILabel *empty;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) CBCentralManager *bluetooth;
@property (nonatomic, strong) CLLocationManager *location;
@property (nonatomic, strong) NSUUID *session;
@property (nonatomic, strong) NSUUID *connectionID;
@end

@implementation ScannerController

+ (NSString *)titleForBLE:(BOOL)ble {
    return ble ? @"BLE 扫描" : @"iBeacon 扫描";
}

+ (NSString *)explanationForBLE:(BOOL)ble {
    return ble ? @"发现 BrightSDK 可识别的蓝牙广播设备，查看名称与信号强度。扫描不需要 "
                 @"AppKey；连接时可选填 AppKey。"
               : @"按指定 UUID 识别 iBeacon 广播，查看 Major、Minor "
                 @"和信号强度。此扫描不建立蓝牙连接，不需要 AppKey。";
}

- (instancetype)initWithBLE:(BOOL)ble {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _ble = ble;
        _engine = [BrightSDKClient new];
        _rows = @[];
        _session = [NSUUID UUID];
        _visible = YES;
    }
    return self;
}

- (UILabel *)label:(UIFontTextStyle)style {
    UILabel *label = [UILabel new];
    label.font = [UIFont preferredFontForTextStyle:style];
    label.numberOfLines = 0;
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ScannerController titleForBLE:self.ble];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    UILabel *description = [self label:UIFontTextStyleSubheadline];
    description.text = [ScannerController explanationForBLE:self.ble];
    description.textColor = UIColor.secondaryLabelColor;
    self.uuid = [UITextField new];
    self.uuid.text = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
    self.uuid.borderStyle = UITextBorderStyleRoundedRect;
    self.uuid.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.uuid.autocorrectionType = UITextAutocorrectionTypeNo;
    self.uuid.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.uuid.delegate = self;
    self.uuid.accessibilityIdentifier = @"uuid-filter";
    UILabel *uuidLabel = [self label:UIFontTextStyleCaption1];
    uuidLabel.text = @"匹配 UUID · Major / Minor 不限";
    UIStackView *filter = [[UIStackView alloc] initWithArrangedSubviews:@[ uuidLabel, self.uuid ]];
    filter.axis = UILayoutConstraintAxisVertical;
    filter.spacing = 6;
    filter.hidden = self.ble;
    self.status = [self label:UIFontTextStyleHeadline];
    self.status.text = @"尚未扫描";
    self.status.accessibilityIdentifier = @"scan-status";
    self.count = [self label:UIFontTextStyleSubheadline];
    self.count.text = @"0 个设备";
    self.count.textColor = UIColor.secondaryLabelColor;
    UIStackView *state =
        [[UIStackView alloc] initWithArrangedSubviews:@[ self.status, self.count ]];
    state.distribution = UIStackViewDistributionEqualSpacing;
    self.permissions = [self label:UIFontTextStyleCaption1];
    self.permissions.textColor = UIColor.secondaryLabelColor;
    UILabel *identityHint = [self label:UIFontTextStyleCaption1];
    identityHint.text = @"本机标识由当前 iPhone 分配，不是设备的全局 ID，也不是 iBeacon UUID。";
    identityHint.textColor = UIColor.secondaryLabelColor;
    identityHint.hidden = !self.ble;
    UIStackView *header = [[UIStackView alloc]
        initWithArrangedSubviews:@[ description, filter, identityHint, state, self.permissions ]];
    header.axis = UILayoutConstraintAxisVertical;
    header.spacing = 12;
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:header];
    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.table.dataSource = self;
    self.table.delegate = self;
    [self.table registerClass:BeaconCell.class forCellReuseIdentifier:@"beacon"];
    self.table.rowHeight = UITableViewAutomaticDimension;
    self.table.estimatedRowHeight = 150;
    self.table.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.table];
    self.empty = [self label:UIFontTextStyleSubheadline];
    self.empty.textColor = UIColor.secondaryLabelColor;
    self.empty.textAlignment = NSTextAlignmentCenter;
    self.empty.accessibilityIdentifier = @"scan-empty";
    self.table.backgroundView = self.empty;
    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.scanButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    [self.scanButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.scanButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.scanButton.backgroundColor = UIColor.systemBlueColor;
    self.scanButton.layer.cornerRadius = 14;
    self.scanButton.accessibilityIdentifier = @"scan-toggle";
    self.scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scanButton addTarget:self
                        action:@selector(toggleScan)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.table.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:4],
        [self.table.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.table.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.table.bottomAnchor constraintEqualToAnchor:self.scanButton.topAnchor constant:-10],
        [self.scanButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.scanButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                       constant:-20],
        [self.scanButton.heightAnchor constraintEqualToConstant:50],
        [self.scanButton.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-12]
    ]];
    __weak typeof(self) weakSelf = self;
    self.engine.onDisconnect = ^(NSString *message) {
        typeof(self) self = weakSelf;
        if (!self || !self.visible)
            return;
        [self finish:@"设备已断开"];
        self.empty.text = message;
    };
    self.location = [CLLocationManager new];
    self.location.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(background)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [self refreshPermissions];
    [self refreshRows];
}

- (void)refreshPermissions {
#if TARGET_OS_SIMULATOR
    self.permissions.text = @"模拟器 · 可查看示例界面；真实扫描与连接请使用 iPhone。";
#else
    NSString *ble = @"待检查";
    if (self.bluetooth) {
        switch (self.bluetooth.state) {
        case CBManagerStatePoweredOn:
            ble = @"已开启";
            break;
        case CBManagerStatePoweredOff:
            ble = @"已关闭";
            break;
        case CBManagerStateUnauthorized:
            ble = @"未授权";
            break;
        case CBManagerStateUnsupported:
            ble = @"不支持";
            break;
        default:
            break;
        }
    }
    NSString *location = @"待授权";
    switch (CLLocationManager.authorizationStatus) {
    case kCLAuthorizationStatusAuthorizedAlways:
        location = @"始终允许";
        break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        location = @"使用期间允许";
        break;
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted:
        location = @"未允许";
        break;
    default:
        break;
    }
    self.permissions.text = self.ble
                                ? [NSString stringWithFormat:@"蓝牙：%@", ble]
                                : [NSString stringWithFormat:@"蓝牙：%@ · 定位：%@", ble, location];
#endif
}

- (void)refreshRows {
    self.count.text = [NSString stringWithFormat:@"%lu 个设备", (unsigned long)self.rows.count];
    self.empty.hidden = self.rows.count > 0;
    if (!self.scanning && !self.rows.count)
        self.empty.text = self.ble ? @"等待开始\n\n扫描无需 AppKey；连接时可选填。"
                                   : @"等待开始\n\n请确认 UUID 与 Beacon 配置一致。";
    [self.table reloadData];
}

- (void)toggleScan {
    if (self.scanning || self.pending || self.connecting) {
        [self finish:@"已停止"];
        return;
    }
    [self start];
}

- (void)start {
    [self.view endEditing:YES];
    if (!self.ble && ![[NSUUID alloc] initWithUUIDString:self.uuid.text]) {
        self.status.text = @"UUID 格式无效";
        return;
    }
#if TARGET_OS_SIMULATOR
    self.status.text = @"需要真机";
    self.empty.text = @"模拟器无法接收真实 Beacon 广播。\n\n请在 iPhone 上运行本示例。";
    return;
#else
    self.pending = YES;
    [self.scanButton setTitle:@"取消" forState:UIControlStateNormal];
    if (!self.bluetooth) {
        self.status.text = @"正在检查蓝牙…";
        self.bluetooth = [[CBCentralManager alloc] initWithDelegate:self
                                                              queue:dispatch_get_main_queue()];
        return;
    }
    if (self.bluetooth.state != CBManagerStatePoweredOn) {
        self.status.text = @"蓝牙未就绪";
        [self refreshPermissions];
        return;
    }
    if (!self.ble) {
        if (!CLLocationManager.locationServicesEnabled) {
            [self finish:@"请开启系统定位服务"];
            return;
        }
        CLAuthorizationStatus auth = CLLocationManager.authorizationStatus;
        if (auth == kCLAuthorizationStatusNotDetermined) {
            self.status.text = @"等待定位授权…";
            [self.location requestWhenInUseAuthorization];
            return;
        }
        if (auth != kCLAuthorizationStatusAuthorizedAlways &&
            auth != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self finish:@"请在设置中允许定位权限"];
            return;
        }
    }
    self.pending = NO;
    self.scanning = YES;
    self.session = [NSUUID UUID];
    NSUUID *token = self.session;
    self.rows = @[];
    self.uuid.enabled = NO;
    self.status.text = @"扫描中 · 等待回调";
    [self.scanButton setTitle:@"停止扫描" forState:UIControlStateNormal];
    [self refreshRows];
    self.empty.text = @"正在等待广播…";
    __weak typeof(self) weakSelf = self;
    DemoUpdate output = ^(NSArray<BRTBeacon *> *devices, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self || !self.visible || ![token isEqual:self.session] || !self.scanning ||
            self.connecting)
            return;
        if (error) {
            [self finish:@"扫描失败"];
            self.empty.text = error.localizedDescription;
            return;
        }
        self.rows =
            [devices sortedArrayUsingComparator:^NSComparisonResult(BRTBeacon *a, BRTBeacon *b) {
                if (a.rssi == b.rssi)
                    return [(a.peripheral.identifier.UUIDString?:a.proximityUUID.UUIDString?:@"") compare:(b.peripheral.identifier.UUIDString?:b.proximityUUID.UUIDString?:@"")];
                if (a.rssi == 0)
                    return NSOrderedDescending;
                if (b.rssi == 0)
                    return NSOrderedAscending;
                return a.rssi > b.rssi ? NSOrderedAscending : NSOrderedDescending;
            }];
        self.status.text = [@"扫描中 · "
            stringByAppendingString:[NSDateFormatter
                                        localizedStringFromDate:[NSDate date]
                                                      dateStyle:NSDateFormatterNoStyle
                                                      timeStyle:NSDateFormatterMediumStyle]];
        [self refreshRows];
        if (!self.rows.count)
            self.empty.text = self.ble ? @"暂未发现设备\n\n检查设备是否在附近并正在广播。"
                                       : @"暂未发现设备\n\n检查 UUID 是否匹配、Beacon 是否开启。";
    };
    if (self.ble)
        [self.engine startBLEWithOutput:output];
    else
        [self.engine startIBeaconWithUUID:self.uuid.text output:output];
#endif
}

- (void)finish:(NSString *)message {
    self.session = [NSUUID UUID];
    self.scanning = NO;
    self.pending = NO;
    self.connecting = NO;
    [self.engine stop];
    self.uuid.enabled = YES;
    self.status.text = message;
    [self.scanButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    [self.table reloadData];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self refreshPermissions];
    if (central.state == CBManagerStatePoweredOn && self.pending)
        [self start];
    else if (central.state != CBManagerStatePoweredOn) {
        [self finish:@"蓝牙不可用"];
        self.empty.text = @"请检查蓝牙开关和应用蓝牙权限。";
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self refreshPermissions];
    if (self.pending && status != kCLAuthorizationStatusNotDetermined)
        [self start];
    else if (self.scanning && !self.ble && status != kCLAuthorizationStatusAuthorizedAlways &&
             status != kCLAuthorizationStatusAuthorizedWhenInUse)
        [self finish:@"定位权限已关闭"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRTBeacon *row = self.rows[indexPath.row];
    BeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beacon"
                                                       forIndexPath:indexPath];
    [cell render:row ble:self.ble enabled:self.scanning && !self.connecting];
    __weak typeof(self) weakSelf = self;
    cell.onConnect = ^{
        [weakSelf promptForDevice:row];
    };
    return cell;
}

- (void)promptForDevice:(BRTBeacon *)row {
    if (!self.scanning || self.connecting || !(row.isBrightBeacon && row.peripheral != nil))
        return;
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:[@"连接 " stringByAppendingString:row.name.length
                                                                       ? row.name
                                                                       : @"BrightBeacon"]
                         message:@"AppKey 可选。未设置密钥的设备可留空，使用 SDK "
                                 @"默认凭据；已设置密钥的设备请填写对应 AppKey。"
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"AppKey（可选，留空使用默认凭据）";
        field.secureTextEntry = YES;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        field.accessibilityIdentifier = @"connection-appkey";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    __weak typeof(self) weakSelf = self;
    __weak UIAlertController *weakAlert = alert;
    [alert addAction:[UIAlertAction
                         actionWithTitle:@"连接"
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     NSString *key = [weakAlert.textFields.firstObject.text
                                         stringByTrimmingCharactersInSet:
                                             NSCharacterSet.whitespaceAndNewlineCharacterSet];
                                     [weakSelf connect:row key:key];
                                 }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)connect:(BRTBeacon *)row key:(NSString *)key {
    if (!self.scanning || self.connecting)
        return;
    self.connecting = YES;
    self.status.text = @"正在连接设备…";
    [self.scanButton setTitle:@"取消连接 / 停止扫描" forState:UIControlStateNormal];
    [self.table reloadData];
    NSUUID *token = self.session;
    NSUUID *attempt = [NSUUID UUID];
    self.connectionID = attempt;
    __weak typeof(self) weakSelf = self;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, 45 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (self && [token isEqual:self.session] && [attempt isEqual:self.connectionID] &&
                self.connecting) {
                [self finish:@"连接超时"];
                [self message:@"连接超时"
                       detail:@"45 秒内未完成连接，请检查设备状态、蓝牙及设备所需的 AppKey。"];
            }
        });
    [self.engine
        connectBeacon:row
               appKey:key
           completion:^(BOOL success, NSString *message) {
               typeof(self) self = weakSelf;
               if (!self || ![token isEqual:self.session] || ![attempt isEqual:self.connectionID] ||
                   !self.connecting)
                   return;
               // Invalidate this attempt timeout without interrupting scan updates.
               self.connectionID = [NSUUID UUID];
               self.connecting = success;
               self.scanning = !success;
               self.status.text = success ? @"设备已连接" : @"连接失败 · 可重试";
               [self.scanButton setTitle:success ? @"断开连接" : @"停止扫描"
                                forState:UIControlStateNormal];
               [self.table reloadData];
               [self message:success ? @"连接成功" : @"连接失败"
                      detail:success ? message
                                     : [message stringByAppendingString:
                                                    @"\n\n如设备已设置密钥，请重试并填写对应 "
                                                    @"AppKey；也请检查设备距离和蓝牙状态。"]];
           }];
}

- (void)message:(NSString *)title detail:(NSString *)detail {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:detail
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)background {
    [self finish:@"已暂停 · 应用进入后台"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController) {
        self.visible = NO;
        [self finish:@"已停止"];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
