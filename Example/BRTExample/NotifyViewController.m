//
//  NotifyViewController.m
//  BRTExample
//
//  Created by thomasho on 14-9-3.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "NotifyViewController.h"
@interface NotifyViewController ()
{
    IBOutlet UISwitch *sw_in,*sw_out,*sw_on_display;
}
@end

@implementation NotifyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *regionState = [BRTBeaconSDK isMonitoring:@{@"uuid":self.beacon.proximityUUID.UUIDString,@"major":self.beacon.major,@"minor":self.beacon.minor}];
    [sw_in setOn:[regionState valueForKey:@"in"]];
    [sw_out setOn:[regionState valueForKey:@"out"]];
    [sw_on_display setOn:[regionState valueForKey:@"display"]];
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您没有开启后台刷新，关闭程序后将无法推送，请在 设置->通用->应用程序后台刷新 中开启." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}


- (IBAction)swValueChanged:(id)sender
{
    //IOS8.0 推送必须询求用户同意
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    //重构当前Beacon所在Region,如果your_region_id一致会覆盖之前的Region
    BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID identifier:@"your_region_id"];
    region.notifyOnEntry = sw_in.isOn;
    region.notifyOnExit = sw_out.isOn;
    region.notifyEntryStateOnDisplay = sw_on_display.isOn;
    if (!sw_in.isOn&&!sw_out.isOn&&!sw_on_display.isOn) {
        [BRTBeaconSDK stopMonitoringForRegions:@[region]];
    }else{
        [BRTBeaconSDK startMonitoringForRegions:@[region]];
    }
}
//用于停止所有的r
- (IBAction)stopAllButtonClicked:(id)sender{
    //获取所有的区域
    NSSet *regions = [[BRTBeaconSDK BRTBeaconManager] monitoredRegions];

    //停掉所有Region
    [BRTBeaconSDK stopMonitoringForRegions:regions];
}
- (void)dealloc
{
    
}
@end
