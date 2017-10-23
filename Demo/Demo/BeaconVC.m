//
//  BeaconVC.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "BeaconVC.h"
#import "BRTBeaconSDK.h"

@interface BeaconVC ()

@property (nonatomic,strong) NSMutableDictionary *dataDict;

@end

@implementation BeaconVC

- (void)viewDidLoad {
	[super viewDidLoad];

	//IOS8.0以后，需在plist配置获得定位权限描述<key>NSLocationAlwaysUsageDescription</key><string>定位用途提示</string>
	if ([CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied) {
		if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请打开您的定位" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
			[alert show];
		}else{
			UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请打开您的定位" message:nil preferredStyle:UIAlertControllerStyleAlert];
			[alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				[alertVC dismissViewControllerAnimated:YES completion:nil];
			}]];
			[self presentViewController:alertVC animated:YES completion:nil];
		}
	}

	self.dataDict = [NSMutableDictionary dictionary];

    //智石默认UUID
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:DEFAULT_UUID];
    BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"test1ID"];
    //测试UUID
    NSUUID *uuid3 = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E1"];
    BRTBeaconRegion *region3 = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid3 identifier:@"testxID"];

    //微信常用UUID
	uuid = [[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];
	BRTBeaconRegion *region2 = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"test2ID"];

	NSArray *regions = @[region,region2,region3];
	if ([CLLocationManager isRangingAvailable]) {
		[BRTBeaconSDK startRangingBeaconsInRegions:regions onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
			if (beacons.count) {
				[self.dataDict setObject:beacons.copy forKey:region.proximityUUID.UUIDString];
			}else{
				[self.dataDict removeObjectForKey:region.proximityUUID.UUIDString];
			}
			[self.tableView reloadData];
		}];
    }else{
        NSLog(@"设备不支持");
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BRTBeaconSDK stopRangingBeacons];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.dataDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataDict[self.dataDict.allKeys[section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = self.dataDict.allKeys[section];
    NSArray *arr = [self.dataDict valueForKey:key];
	return [NSString stringWithFormat:@"(%ld)%@-...-%@",arr.count,[key substringToIndex:8],[key substringFromIndex:24]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

	NSString *key = self.dataDict.allKeys[indexPath.section];
	BRTBeacon *beacon = [self.dataDict valueForKey:key][indexPath.row];

	cell.textLabel.text = [NSString stringWithFormat:@"Major:%@ Minor:%@",beacon.major,beacon.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld，%.1fm",(long)beacon.rssi,beacon.accuracy?:-1];

	return cell;
}

@end
