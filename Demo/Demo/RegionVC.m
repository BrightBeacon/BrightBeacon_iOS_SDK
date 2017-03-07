//
//  RegionVC.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "RegionVC.h"
#import "BRTBeaconSDK.h"

@interface RegionVC ()

@property (nonatomic,strong) NSSet *regions;

@end

@implementation RegionVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.regions = [[BRTBeaconSDK BRTBeaconManager] monitoredRegions];
	[self.tableView reloadData];

	//IOS8.0 推送必须询求用户同意，来触发通知（按你程序所需）
	if ([[[UIDevice currentDevice] systemVersion] intValue]>=8) {
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
		[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.regions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
	BRTBeaconRegion *region = self.regions.allObjects[indexPath.row];
	cell.textLabel.text = region.proximityUUID.UUIDString;
	NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithObject:region.proximityUUID.UUIDString forKey:@"uuid"];
	NSString *detail = @"";
	if (region.major) {
		detail = [NSString stringWithFormat:@"major:%@",region.major];
		[mdict setObject:region.major forKey:@"major"];
		if (region.minor){
			detail = [NSString stringWithFormat:@"major:%@,minor:%@",region.major,region.minor];
			[mdict setObject:region.minor forKey:@"minor"];
		}
	}
	NSDictionary *dict = [BRTBeaconSDK isMonitoring:mdict];
	detail = [NSString stringWithFormat:@"%@ 进入:%@ 离开:%@ 锁屏点亮:%@",detail,dict[@"in"]?:@"0",dict[@"out"]?:@"0",dict[@"display"]?:@"0"];
	cell.detailTextLabel.text = detail;
	[((UISwitch *)cell.accessoryView) setOn:!!dict];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BRTBeaconRegion *region = self.regions.allObjects[indexPath.row];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	UISwitch *sw = (UISwitch *)cell.accessoryView;
	if (sw.isOn) {
		[BRTBeaconSDK stopMonitoringForRegions:@[region]];
	}else{
		[BRTBeaconSDK startMonitoringForRegions:@[region]];
	}
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
