//
//  RangeBeaconViewController.m
//  BRTExample
//
//  Created by JackRay on 14-5-27.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "RangeBeaconViewController.h"
#import "BRTBeaconSDK.h"

#define showAlert(msg) [[[UIAlertView alloc] initWithTitle:Lang(@"Tips", @"提示") message:msg delegate:nil cancelButtonTitle:Lang(@"OK", @"确定") otherButtonTitles: nil] show];

@interface RangeBeaconViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView     *tableview;
@property (nonatomic, strong) NSArray                  *beacons;
@end

@implementation RangeBeaconViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [BRTBeaconSDK stopRangingBrightBeacons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startButtonClicked:)];
    [self startButtonClicked:nil];
    self.tableview.tableFooterView = [UIView new];
}

- (IBAction)startButtonClicked:(id)sender
{
    __unsafe_unretained typeof(self) weakSelf = self;
    [BRTBeaconSDK startRangingWithUuids:@[[[NSUUID alloc] initWithUUIDString:DEFAULT_UUID]] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        if (!error) {
            [weakSelf reloadData:beacons];
        }else{
            showAlert(error.description);
        }
     }];
}
- (void)reloadData:(NSArray*)beacons
{
    self.beacons = [beacons sortedArrayUsingComparator:^NSComparisonResult(BRTBeacon* obj1, BRTBeacon* obj2){
        return obj1.distance.floatValue>obj2.distance.floatValue?NSOrderedDescending:NSOrderedAscending;
    }];
    [self.tableview reloadData];
}
#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beacons.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"beaconCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    BRTBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
    UIImageView *iv = (UIImageView*)[cell viewWithTag:97];
    if(beacon.rssi>-45){
        iv.image = [UIImage imageNamed:@"rssi_5"];
    }else if(beacon.rssi>-55){
        iv.image = [UIImage imageNamed:@"rssi_4"];
    }else if(beacon.rssi>-65){
        iv.image = [UIImage imageNamed:@"rssi_3"];
    }else if(beacon.rssi>-75){
        iv.image = [UIImage imageNamed:@"rssi_2"];
    }else if(beacon.rssi>-95){
        iv.image = [UIImage imageNamed:@"rssi_1"];
    }else{
        iv.image = [UIImage imageNamed:@"rssi_0"];
    }
    
    [[cell viewWithTag:98] setHidden:!beacon.mode];
    [[cell viewWithTag:99] setHidden:!beacon.proximityUUID];
    UILabel *lbl = (UILabel*)[cell viewWithTag:100];
    lbl.text = [NSString stringWithFormat:@"%ld", (long)beacon.rssi];
    
    lbl = (UILabel*)[cell viewWithTag:101];
    lbl.text = [NSString stringWithFormat:@"%@", beacon.name];
    lbl = (UILabel*)[cell viewWithTag:102];
    lbl.text = [NSString stringWithFormat:@"%@", beacon.major];
    lbl = (UILabel*)[cell viewWithTag:103];
    lbl.text = [NSString stringWithFormat:@"%@", beacon.minor];
    lbl = (UILabel*)[cell viewWithTag:104];
    lbl.text = [NSString stringWithFormat:@"%@", beacon.macAddress];
    lbl = (UILabel*)[cell viewWithTag:105];
    lbl.text = [NSString stringWithFormat:@"%.2f", beacon.accuracy<0.00001?beacon.distance.floatValue:beacon.accuracy];
    lbl = (UILabel*)[cell viewWithTag:106];
    lbl.text = [NSString stringWithFormat:@"%@%%", beacon.battery];
    lbl = (UILabel*)[cell viewWithTag:107];
    lbl.text = [NSString stringWithFormat:@"%@℃", beacon.temperature];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __unsafe_unretained typeof(self) weakSelf = self;
    BRTBeacon *beacon = [self.beacons objectAtIndex:indexPath.row];
    
    switch (self.type.integerValue) {
        case 0:
        {
            [beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
                if (connected) {
                    [weakSelf performSegueWithIdentifier:@"config" sender:beacon];
                }else{
                    showAlert(@"设备连接中断");
                }
            }];
            
        }
            break;
        case 1:
        {
            if (beacon.proximityUUID) {
                [self performSegueWithIdentifier:@"notify" sender:beacon];
            }else{
                if (!([CLLocationManager locationServicesEnabled] &&
                      [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
                        showAlert(@"该功能需要打开 系统设置->隐私->定位服务->BrightBeacon");
                }else{
                    showAlert(@"无法支持该设备，请监听该设备的UUID，或前往配置->设置该设备为默认UUID");
                }
            }
        }
            break;
        case 2:
        {
            [beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
                if (connected) {
                    [beacon disconnectBeacon];
                    [weakSelf performSegueWithIdentifier:@"adjust" sender:beacon];
                }else{
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"设备连接中断" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setValue:sender forKey:@"beacon"];
}
@end
