//
//  RegionHander.h
//  Demo
//
//  Created by thomasho on 17/3/6.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRTBeaconSDK.h"

@interface RegionHander : NSObject <BRTBeaconRegionDelegate>
//通知权限申请
+ (void)registerNotification;

@end
