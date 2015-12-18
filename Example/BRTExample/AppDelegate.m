//
//  AppDelegate.m
//  BRTExample
//
//  Created by thomasho on 14-4-3.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "AppDelegate.h"
#import "BRTBeaconSDK.h"

//#define BRT_SDK_KEY 全0仅用于测试，请填写你申请的APP KEY
#define BRT_SDK_KEY @"00000000000000000000000000000000"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%@",[[BRTBeaconSDK BRTBeaconManager] monitoredRegions]);
    // Override point for customization after application launch.
    [BRTBeaconSDK registerApp:BRT_SDK_KEY onCompletion:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //此处用于获取本地消息通知
//    [[[UIAlertView alloc] initWithTitle:notification.alertTitle message:notification.alertBody delegate:nil cancelButtonTitle:notification.alertAction otherButtonTitles: nil] show];
}
#pragma monitor
- (void)sendLocalNotification:(NSString*)msg
{
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    notice.alertBody = msg;
    notice.alertAction = Lang(@"Open", @"打开软件");
    notice.soundName = UILocalNotificationDefaultSoundName;
    notice.userInfo = @{@"msg":@"whatever you want"};
    [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
}
/**
 * 只能在AppDelegate实现
 *
 * 区域监听失败触发的回调方法，以及关联的错误信息
 *
 * @param manager Bright beacon 管理器
 * @param region Bright beacon 区域
 * @param error 错误信息
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
monitoringDidFailForRegion:(BRTBeaconRegion *)region
           withError:(NSError *)error{
    
}

/**
 * 只能在AppDelegate实现
 *
 * 在区域监听中，iOS设备进入beacon设备区域触发该方法
 *
 * @param manager Bright beacon 管理器
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
      didEnterRegion:(BRTBeaconRegion *)region{
    if(region.notifyOnEntry)[self sendLocalNotification:Lang(@"Hello!", @"您已经进入了Beacon体验区")];
}


/**
 * 只能在AppDelegate实现
 *
 * 在区域监听中，iOS设备离开beacon设备区域触发该方法
 *
 * @param manager Bright beacon 管理器
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
       didExitRegion:(BRTBeaconRegion *)region{
    if(region.notifyOnExit)[self sendLocalNotification:Lang(@"Goodbye.", @"您已经离开")];
}

/**
 * 只能在AppDelegate实现
 *
 * 在调用startMonitoringForRegion:方法，当beacon区域状态变化会触发该方法
 *
 * @param manager Bright beacon 管理器
 * @param state Bright beacon 区域状态
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(BRTBeaconRegion *)region{
    if(region.notifyEntryStateOnDisplay)[self sendLocalNotification:Lang(@"Hello!", @"你处于监听Beacon区域,点亮屏幕收到此推送")];
}
@end
