//
//  BRTBeaconRegion.h
//  BrightSDK
//
//  Version : 1.0.0
//  Created by Bright Beacon on 20/04/14.
//  Copyright (c) 2014 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



/**
 
 BRTBeaconRegion定义了一类区域，是基于蓝牙设备,而不是一个地理位置。beacon区域寻找设备的识别信息匹配您提供的信息，当一个设备范围,该区域触发一个适当的通知
 
 您可以监视信标区域在两个方面。设备进入或退出时接收通知附近的beacon,使用startMonitoringForRegion:你的位置管理器对象的方法。当beacon在范围内,你也可以调用startRangingBeaconsInRegion:方法开始时接收通知的相对的距离变化.
 
 BRTBeaconRegion 扩展了基本的CLBeaconRegion类(IOS13及以上已使用了initWithUUID:)。
 
 */
@interface BRTBeaconRegion : CLBeaconRegion

/*
*  initWithProximityUUID:identifier:
*
*  Discussion:
*    Initialize a beacon region with a UUID. Major and minor values will be wildcarded.
*
*/
- (instancetype)initWithProximityUUID:(NSUUID *)uuid identifier:(NSString *)identifier API_AVAILABLE(ios(7.0));

/*
*  initWithProximityUUID:major:identifier:
*
*  Discussion:
*    Initialize a beacon region with a UUID and major value. Minor value will be wildcarded.
*
*/
- (instancetype)initWithProximityUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major identifier:(NSString *)identifier API_AVAILABLE(ios(7.0));

/*
*  initWithProximityUUID:major:minor:identifier:
*
*  Discussion:
*    Initialize a beacon region identified by a UUID, major and minor values.
*
*/
- (instancetype)initWithProximityUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier API_AVAILABLE(ios(7.0));
@end
