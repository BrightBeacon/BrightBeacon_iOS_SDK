#import "IntegrationGuide.h"

@implementation IntegrationGuide

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OC 集成说明";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 180;
}

- (NSArray *)steps {
    return @[
        @[
            @"1 · 添加 SDK",
            @"将 BrightSDK.xcframework 添加到 App Target。\nLink Binary With Libraries 中保留一份，选择 Do Not Embed。\n移除旧 libBrightSDK.a 链接。"
        ],
        @[
            @"2 · 导入与权限",
            @"@import BrightSDK;\n\nBLE：配置蓝牙用途说明。\niBeacon：额外配置使用期间定位说明。\n本工程 Sources/App/Info.plist 已提供示例。"
        ],
        @[
            @"3 · 扫描与停止",
            @"// BLE：无需 AppKey\n[BRTBeaconSDK scanBleServices:nil onCompletion:^(NSArray *devices, NSError *error) {\n    // 更新设备列表\n}];\n[BRTBeaconSDK stopScan];\n\n// iBeacon：按 UUID 扫描，不建立连接\n[BRTBeaconSDK startRangingBeaconsInRegions:@[region] onCompletion:^(NSArray *devices, BRTBeaconRegion *region, NSError *error) {\n    // 查看 Major / Minor / RSSI\n}];\n[BRTBeaconSDK stopRangingBeacons];"
        ],
        @[
            @"4 · 连接：AppKey 可选",
            @"// 空值会使用 SDK 默认凭据；覆盖之前设置的密钥\n[BRTBeaconSDK registerApp:appKey onCompletion:nil];\n[beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {\n    // 以真实连接回调显示结果\n}];\n[beacon disconnectBeacon];\n\n未设置密钥的设备可留空；设置过密钥的设备需对应 AppKey。默认凭据不等于跳过设备鉴权。"
        ]
    ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.steps.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.steps[section][0];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return section == 3 ? @"SDK 调用集中在 Sources/SDK/BrightSDKClient.m；ScannerController.m "
                          @"负责界面和权限，无 Swift 依赖。"
                        : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    cell.textLabel.text = self.steps[indexPath.section][1];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
