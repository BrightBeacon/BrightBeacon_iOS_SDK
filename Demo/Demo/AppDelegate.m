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

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	if(launchOptions)NSLog(@"软件被通知启动，滑动通知内容：%@",launchOptions);

    //设置appkey，连接、加密设备，后台管理所需
    [BRTBeaconSDK registerApp:DEFAULT_KEY onCompletion:^(BOOL complete, NSError *error) {
        NSLog(@"注册appKey：%@",error);
    }];

	//如需后台监听区域，必须在随App启动的类中调用regionHander：
    //并且hander也必须启动自行初始化，保证监听到区域自启动软件时，能成功回调该类的Region相关函数。
	[BRTBeaconSDK  regionHander:[RegionHander new]];
	return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	NSLog(@"软件运行中，滑动通知内容：%@",notification);
}
@end
