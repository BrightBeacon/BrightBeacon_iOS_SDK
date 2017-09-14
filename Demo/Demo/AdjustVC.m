//
//  AdjustViewController.m
//  BRTExample
//
//  Created by thomasho on 14-7-31.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "AdjustVC.h"
#import "BRTBeaconSDK.h"
#import "AdjustCell.h"

@interface AdjustVC (){

    BOOL isStarting;

}

@property (nonatomic,weak) IBOutlet UISegmentedControl *sgCtlSort;

@property (nonatomic, strong) NSMutableSet   *beaconSet;
@property (nonatomic, strong) NSArray        *beaconSorted;
@property (nonatomic,strong)  BRTBeacon *brtbeacon;

@property (assign, nonatomic) NSInteger totalRssi;
@property (assign, nonatomic) NSInteger totalCount;

@end

@implementation AdjustVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"AdjustCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(scanBeacon) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BRTBeaconSDK stopRangingBrightBeacons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.beaconSet = [NSMutableSet set];
    [self scanBeacon];
}

- (void)scanBeacon
{
    [self.refreshControl endRefreshing];
    [BRTBeaconSDK setInvalidTime:1];
    [BRTBeaconSDK setScanResponseTime:1];
    [BRTBeaconSDK scanBleServices:nil onCompletion:^(NSArray *beacons, NSError *error){
        [self.beaconSet addObjectsFromArray:beacons];
        if (isStarting) {
            [self beaconAdjust:beacons];
        }
        [self sgValueChanged:self.sgCtlSort];
    }];
}

- (IBAction)sgValueChanged:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex) {
        NSSortDescriptor *sortMajor = [NSSortDescriptor sortDescriptorWithKey:@"major" ascending:NO];
        NSSortDescriptor *sortMinor = [NSSortDescriptor sortDescriptorWithKey:@"minor" ascending:NO];
        self.beaconSorted = [self.beaconSet sortedArrayUsingDescriptors:@[sortMajor,sortMinor]];
    }else{
        NSSortDescriptor *sortRSSI = [NSSortDescriptor sortDescriptorWithKey:@"rssi" ascending:NO];
        self.beaconSorted = [self.beaconSet sortedArrayUsingDescriptors:@[sortRSSI]];
    }
    [self.tableView reloadData];
}
- (void)beaconAdjust:(NSArray *)beacons
{
    BRTBeacon *beacon = nil;
    for (beacon in beacons) {
        if ([beacon.macAddress isEqualToString:self.brtbeacon.macAddress]) {
            break;
        }
    }
    NSLog(@"%lf,%ld",beacon.invalidTime,beacon.rssi);
    //仅使用最新扫描到的有效rssi
    if (beacon.rssi>=0) {
        return;
    }
    self.totalRssi += beacon.rssi;
    self.totalCount += 1;
    //20次校准一次
    if (self.totalCount%20==0) {
        isStarting = NO;
        CGFloat avgrssi = self.totalRssi/self.totalCount;
        NSLog(@"校准测量功率（1米处rssi）：%f",avgrssi);
        [[BRTBeaconSDK BRTBeaconManager] stopScan];
        if (self.brtbeacon.measuredPower.integerValue != (NSInteger)avgrssi) {
            __unsafe_unretained typeof(self) weakself = self;
            [self.brtbeacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
                if (connected) {
                    [weakself writeMpower:avgrssi];
                }else{
                    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"校准失败，连接设备不成功。Er:%ld",nil),(long)error.code] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"重试",nil), nil] show];
                    [beacon disconnectBeacon];
                }
            }];
        }else{
            //如果计算结果一致，无需写入。
            [self disconnect];
        }
    }
}
- (void)writeMpower:(NSInteger)mpower
{
    __unsafe_unretained typeof(self) weakself = self;
    [self.brtbeacon writeBeaconValues:@{B_MEASURED: [NSNumber numberWithInteger:mpower]} withCompletion:^(BOOL complete,NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:error.domain message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"重试",nil), nil] show];
        }else{
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"距离校准完成",nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil] show];
            [weakself disconnect];
        }
    }];
}
- (void)disconnect
{
    [self.brtbeacon disconnectBeacon];
    [self scanBeacon];
}
- (void)dealloc
{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beaconSorted.count;
}
//fix iPad Cell BackGroundColor
- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    AdjustCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    BRTBeacon *beacon = [self.beaconSorted objectAtIndex:indexPath.row];
    cell.lblName.text = beacon.name;
    cell.lblMac.text = [NSString stringWithFormat:@"%@,%@ MAC%@", beacon.major, beacon.minor, beacon.macAddress];
    cell.lblRSSI.text = [NSString stringWithFormat:@"%.2f米", beacon.distance.floatValue];
    if (isStarting&&[beacon isEqual:self.brtbeacon]) {
        [cell startAnimating];
        NSInteger remaining = 19 - self.totalCount;
        cell.lblTimes.text = remaining==0?@"":[NSString stringWithFormat:@"%ld",19-self.totalCount];
    }else{
        [cell stopAnimating];
        cell.lblTimes.text = @"";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isStarting) {
        [self.brtbeacon disconnectBeacon];
        self.brtbeacon = nil;
        isStarting = NO;
    }else{
        self.brtbeacon = self.beaconSorted[indexPath.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"距离校准说明", nil) message:[NSString stringWithFormat:NSLocalizedString(@"请将您的手机静置离'%@'在期望距离1米处，然后点击->开始校准",nil),self.brtbeacon.name] delegate:self cancelButtonTitle:NSLocalizedString(@"取消",nil) otherButtonTitles:NSLocalizedString(@"开始校准",nil), nil];
        alert.tag = indexPath.row+1;
        [alert show];

    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!= alertView.cancelButtonIndex) {
        isStarting = YES;
        self.totalCount = 0;
        self.totalRssi = 0;
        //兼容重试，需要重新开启扫描
        [self scanBeacon];
    }
}

@end
