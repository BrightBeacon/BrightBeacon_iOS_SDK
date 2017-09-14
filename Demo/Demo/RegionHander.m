//
//  RegionHander.m
//  Demo
//
//  Created by thomasho on 17/3/6.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "RegionHander.h"

@implementation RegionHander

//如需测试完全关闭app：可以通过XCode->Windows->Devices->选中调试的iPhone查看NSLog信息
//也可以先获取本地通知权限，直接发本地通知
-(void)beaconManager:(BRTBeaconManager *)manager didEnterRegion:(BRTBeaconRegion *)region {
    NSLog(@"进入区域：%@",region);
    [self sendLocalNotification:NSLocalizedString(@"您已经进入了Beacon体验区",nil)];
//    [BRTBeaconSDK startRangingBeaconsInRegions:@[region] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
//        NSLog(@"进入区域启动扫描：%ld",beacons.count);
//    }];
}
-(void)beaconManager:(BRTBeaconManager *)manager didExitRegion:(BRTBeaconRegion *)region {
    NSLog(@"离开区域：%@",region);
    [self sendLocalNotification:NSLocalizedString(@"您已经离开",nil)];
}

-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region {
    NSLog(@"锁屏点亮、检测区域状态：%@->%ld",region,(long)state);
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"你监听的Beacon区域状态：%@,锁屏点亮屏幕会收到此推送",nil),(state==CLRegionStateUnknown)?@"未知":(state=CLRegionStateInside)?@"区域内":@"区域外"];
    [self sendLocalNotification:msg];
}

- (void)beaconManager:(BRTBeaconManager *)manager monitoringDidFailForRegion:(BRTBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"区域监听失败：%@  error:%@",region,error);
}

- (void)beaconManagerDidStartAdvertising:(BRTBeaconManager *)manager error:(NSError *)error {
    //广播iBeacon回调
}

- (void)sendLocalNotification:(NSString*)msg
{
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    notice.alertBody = msg;
    notice.alertAction =  NSLocalizedString(@"查看更多",nil);
    notice.soundName = UILocalNotificationDefaultSoundName;
    notice.userInfo = @{@"msg":@"提示到通知中心，ios8请提前获取通知授权"};
    [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
}
@end
