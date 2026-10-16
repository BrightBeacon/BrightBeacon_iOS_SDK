#import "HomeController.h"
#import "ScannerController.h"
#import "IntegrationGuide.h"

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BrightSDK · OC";
    self.navigationItem.backButtonTitle = @"首页";
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"集成说明"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(openGuide)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
}

- (void)openGuide {
    [self.navigationController
        pushViewController:[[IntegrationGuide alloc] initWithStyle:UITableViewStyleInsetGrouped]
                  animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"选择扫描方式";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"如何选择？\n识别 UUID / Major / Minor → iBeacon 扫描\n查找并连接 BrightBeacon 设备 → "
           @"BLE 扫描\n\n两种扫描均无需 AppKey。连接 BLE 设备时可选填，是否需要由设备配置决定。";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL ble = indexPath.row == 1;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    cell.textLabel.text = [ScannerController titleForBLE:ble];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    cell.detailTextLabel.text = [NSString
        stringWithFormat:@"%@\n\n%@", ble ? @"发现设备 · 按需连接" : @"识别信标 · 无需连接",
                         [ScannerController explanationForBLE:ble]];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    cell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
    cell.imageView.image = [UIImage systemImageNamed:ble ? @"antenna.radiowaves.left.and.right"
                                                         : @"dot.radiowaves.left.and.right"];
    cell.imageView.tintColor = UIColor.systemBlueColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessibilityIdentifier =
        [NSString stringWithFormat:@"scan-mode-%ld", (long)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController
        pushViewController:[[ScannerController alloc] initWithBLE:indexPath.row == 1]
                  animated:YES];
}

@end
