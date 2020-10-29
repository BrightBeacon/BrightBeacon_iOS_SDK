//
//  RegionHander.m
//  Demo
//
//  Created by thomasho on 17/3/6.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "RegionHander.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
@interface RegionHander ()<UNUserNotificationCenterDelegate>
#else
@interface RegionHander ()
#endif
@end

@implementation RegionHander

//如需测试完全关闭app：可以通过XCode->Windows->Devices->选中调试的iPhone查看NSLog信息
//也可以先获取本地通知权限，直接发本地通知
-(void)beaconManager:(BRTBeaconManager *)manager didEnterRegion:(BRTBeaconRegion *)region {
    NSLog(@"进入区域：%@",region);
    [self sendLocalNotification:NSLocalizedString(@"您已经进入了Beacon体验区",nil)];
}
-(void)beaconManager:(BRTBeaconManager *)manager didExitRegion:(BRTBeaconRegion *)region {
    NSLog(@"离开区域：%@",region);
    [self sendLocalNotification:NSLocalizedString(@"您已经离开",nil)];
}

-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region {
    NSLog(@"触发：1、锁屏点亮 2、requestState: 3、伴随didEnterRegion:/didExitRegion：%@->%ld",region,(long)state);
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"你监听的Beacon区域状态：%@,锁屏点亮屏幕会收到此推送",nil),(state==CLRegionStateUnknown)?@"未知":(state=CLRegionStateInside)?@"区域内":@"区域外"];
    [self sendLocalNotification:msg];
//    [BRTBeaconSDK startRangingBeaconsInRegions:@[region] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
//        NSLog(@"进入区域启动iBeacon扫描：%ld",beacons.count);
//    }];
//    [BRTBeaconSDK scanBleServices:@[[CBUUID UUIDWithString:@"180a"]] onCompletion:^(NSArray<BRTBeacon *> *beacons, NSError *error) {
//        NSLog(@"进入区域启动蓝牙扫描(需要与iBeacon扫描同时启动)：%@",beacons.firstObject.macAddress);
//    }];
}

- (void)beaconManager:(BRTBeaconManager *)manager monitoringDidFailForRegion:(BRTBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"区域监听失败：%@  error:%@",region,error);
}

- (void)beaconManagerDidStartAdvertising:(BRTBeaconManager *)manager error:(NSError *)error {
    //广播iBeacon回调
}

//通知权限申请
+ (void)registerNotification {
    //IOS8.0以后 推送必须询求用户同意，来触发通知（按你程序所需）
    UIApplication *application = [UIApplication sharedApplication];
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"推送权限：succeeded!");
            }
        }];
    } else if (@available(iOS 8.0, *)){//iOS8-iOS10
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {//iOS8以下
        [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
}

//发送本地通知
- (void)sendLocalNotification:(NSString*)msg
{
    static NSTimeInterval time = 0;
    if(CFAbsoluteTimeGetCurrent() - time < 1){
        NSLog(@"%@ 本地通知太频繁，可能导致部分推送看不到",msg);
        return;
    }else{
        time = CFAbsoluteTimeGetCurrent();
    }
    if (@available(iOS 10.0, *)) {
        [self addlocalNotificationForNewVersion:msg sub:NSLocalizedString(@"查看更多",nil) info:nil];
    }else{
        [self addLocalNotificationForOldVersion:msg sub:NSLocalizedString(@"查看更多",nil) info:nil];
    }
}

/**
 iOS 10以前版本添加本地通知
 */
- (void)addLocalNotificationForOldVersion:(NSString *)msg sub:(NSString *)subtitle info:(NSDictionary *) info __IOS_AVAILABLE(4.0){
    
    //定义本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置调用时间
//    notification.timeZone = [NSTimeZone localTimeZone];
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3.0];//通知触发的时间，1s以后
//    notification.repeatInterval = 1;//通知重复次数
//    notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
    
    //设置通知属性
    notification.alertBody = msg;//[NSString stringWithFormat:@"Agent-%d",arc4random()%100]; //通知主体
    notification.applicationIconBadgeNumber += 1;//应用程序图标右上角显示的消息数
    notification.alertAction = subtitle; //待机界面的滑动动作提示
    notification.alertLaunchImage = @"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
    notification.soundName = UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
    //    notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
    
    //设置用户信息
    notification.userInfo = info;//绑定到通知上的其他附加信息
    
    //调用通知，按fireDate
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //直接立即触发
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

/**
 iOS 10以后的本地通知
 */
- (void)addlocalNotificationForNewVersion:(NSString *)msg sub:(NSString *)subtitle info:(NSDictionary *)info __IOS_AVAILABLE(10.0){
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:msg arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:subtitle arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = info;
    
    //UNTimeIntervalNotificationTrigger （本地通知） 一定时间之后，重复或者不重复推送通知。我们可以设置timeInterval（时间间隔>0）和repeats（是否重复）。
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.001 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"OXNotification" content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"成功添加推送");
    }];
}

#pragma mark - UNUserNotificationCenterDelegate
// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
// iOS 10收到前台通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __IOS_AVAILABLE(10.0) {
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", body);
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
        [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] didReceiveLocalNotification:(id)notification];
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
// iOS 10后台点击通知后调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler __IOS_AVAILABLE(10.0) {
    [[UIApplication sharedApplication].delegate application:[UIApplication sharedApplication] didReceiveLocalNotification:(id)response.notification];
    completionHandler();
}
@end
