//
//  BRTBeaconSDK.h
//  BrightSDK
//
//  Created by thomasho on 14-6-19.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//
#import "BRTBeaconManager.h"
#import "BRTBeaconRegion.h"
#import "BRTBeacon.h"

//超时移除BrightBeacon时间，与硬件发射频率设置配合
#define InvalidTime 5

////////////////////////////////////////////////////////////////////
// Type and class definitions

typedef enum : int
{
    RangingOptionOnBeaconChange,
    RangingOptionOnRanged,
} RangingOptions;

typedef void(^RangingBrightBeaconsCompletionBlock)(NSArray* beacons, BRTBeaconRegion* region, NSError* error);
typedef void(^MonitoringForRegionsCompletionBlock)(BRTBeaconRegion* region, CLRegionState state, NSError* error);
typedef void(^RequestStateForRegionsCompletionBlock)(BRTBeaconRegion* region, CLRegionState state, NSError* error);

////////////////////////////////////////////////////////////////////
// Interface definition

/**
 
 BRTBeaconSDK类定义了快捷操作BrightBeacon方法.
 
 */

@interface BRTBeaconSDK : NSObject

/// @name beacon快捷扫描BrightBeacon相关的方法

/**
* 注册开发者appkey，申请地址：http://www.brtbeacon.com/api
*
* @param appKey Bright beacon 开发者密钥
*
* @return void
*/
+ (void)registerApp:(NSString *)appKey;

/**
* BrightBeacon管理类，控制Beacon扫描、蓝牙扫描、区域检测、本地消息提醒
*
* @return BRTBeaconManager
*/
+ (BRTBeaconManager*) BRTBeaconManager;

/**
 * BrightBeacon设备列表，设备的距离会及时更新
 *
 * @return NSArray
 */
+ (NSArray*)BRTBeacons;

/**
 * 扫描BrightBeacon设备、区域(<20)监测（支持后台模式）
 *
 * @param completion 扫描、监测回调
 *
 * @return void
 */
+ (void) startRangingOption:(RangingOptions)option onCompletion:(RangingBrightBeaconsCompletionBlock)completion;
+ (void) startMonitoringForRegions:(NSArray *)regions onCompletion:(MonitoringForRegionsCompletionBlock)completion;
+ (void) requestStateForRegions:(NSArray *)regions onCompletion:(RequestStateForRegionsCompletionBlock)completion;

/**
 * 停止扫描、监测
 *
 * @return void
 */
+ (void) stopRangingBrightBeacons;
+ (void) stopMonitoringForRegions:(NSArray *)regions;
@end
