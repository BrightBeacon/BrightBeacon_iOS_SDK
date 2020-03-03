//
//  AppDelegate.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "AppDelegate.h"
#import "BRTBeaconSDK.h"
#import "RegionHander.h"

@interface AppDelegate ()
@property (nonatomic,strong) RegionHander *handler;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
    /* APP未启动，点击推送消息的情况下 iOS10遗弃UIApplicationLaunchOptionsLocalNotificationKey，
     使用代理UNUserNotificationCenterDelegate方法didReceiveNotificationResponse:withCompletionHandler:获取本地推送
     */
    UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        NSLog(@"localUserInfo:%@",notification);
        //APP未启动，点击推送消息
        [self application:application didReceiveLocalNotification:notification];
    }

    //设置appkey，连接、加密设备，后台管理所需
    [BRTBeaconSDK registerApp:DEFAULT_KEY onCompletion:^(BOOL complete, NSError *error) {
        NSLog(@"注册appKey：%@",error);
    }];

	//如需后台监听区域，必须在随App启动的类中调用regionHander：
    //并且hander也必须启动自行初始化，保证监听到区域自启动软件时，能成功回调该类的Region相关函数。
    self.handler = [RegionHander new];
	[BRTBeaconSDK  regionHander:self.handler];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //后台唤醒APP操作。
    }
	return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(id)notification {
    NSString *className = NSStringFromClass([notification class]);
    if ([notification isKindOfClass:[UILocalNotification class]]) {
        NSLog(@"IOS9软件运行中，滑动通知内容：%@",notification);
        //((UILocalNotification*)notification).userInfo
    }else if([className isEqualToString:@"UNNotification"]) {
        NSLog(@"IOS10软件运行中，滑动通知内容：%@",notification);
        //((UNNotification*)notification).request.content.userInfo
    }
}
@end
