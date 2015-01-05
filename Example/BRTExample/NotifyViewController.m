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
    //IOS8.0 推送必须询求用户同意
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    NSString *UUIDMAJORMINOR = [NSString stringWithFormat:@"%@%@%@",self.beacon.proximityUUID.UUIDString,self.beacon.major,self.beacon.minor];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [sw_in setOn:[[defaults valueForKey:@"in"] isEqualToString:UUIDMAJORMINOR]];
    [sw_out setOn:[[defaults valueForKey:@"out"] isEqualToString:UUIDMAJORMINOR]];
    [sw_on_display setOn:[[defaults valueForKey:@"notifyOnDisplay"] isEqualToString:UUIDMAJORMINOR]];
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您没有开启后台刷新，关闭程序后将无法推送，请在 设置->通用->应用程序后台刷新 中开启." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}


- (IBAction)swValueChanged:(id)sender
{
    NSString *UUIDMAJORMINOR = [NSString stringWithFormat:@"%@%@%@",self.beacon.proximityUUID.UUIDString,self.beacon.major,self.beacon.minor];
    if (sender == sw_in) {
        if (sw_in.isOn) {
            [[NSUserDefaults standardUserDefaults] setValue:UUIDMAJORMINOR forKey:@"in"];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"in"];
        }
    }else if(sender == sw_out){
        if (sw_out.isOn) {
            [[NSUserDefaults standardUserDefaults] setValue:UUIDMAJORMINOR forKey:@"out"];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"out"];
        }
    }else if(sender == sw_on_display){
        if (sw_on_display.isOn) {
            [[NSUserDefaults standardUserDefaults] setValue:UUIDMAJORMINOR forKey:@"notifyOnDisplay"];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notifyOnDisplay"];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    //停掉所有Region
    [BRTBeaconSDK stopMonitoringForRegions:nil];
    
    //重构当前Beacon所在Region
    BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID identifier:UUIDMAJORMINOR];
    region.notifyOnEntry = sw_in.isOn;
    region.notifyOnExit = sw_out.isOn;
    region.notifyEntryStateOnDisplay = sw_on_display.isOn;
    if (!sw_in.isOn&&!sw_out.isOn&&!sw_on_display.isOn) {
        [BRTBeaconSDK stopMonitoringForRegions:@[region]];
    }else{
        [BRTBeaconSDK startMonitoringForRegions:@[region]];
    }
}
- (void)dealloc
{
    
}
@end
