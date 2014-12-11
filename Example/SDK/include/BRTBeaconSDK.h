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

//超时移除BrightBeacon时间，与硬件发射频率设置配合，默认2s未收到信号移除
#define InvalidTime 4

////////////////////////////////////////////////////////////////////
// Type and class definitions

typedef void(^RangingBrightBeaconsCompletionBlock)(NSArray* beacons, BRTBeaconRegion* region, NSError* error);

////////////////////////////////////////////////////////////////////
// Interface definition

/**
 
 BRTBeaconSDK类定义了快捷操作BrightBeacon方法.
 
 */

@interface BRTBeaconSDK : NSObject

/// @name beacon快捷扫描BrightBeacon相关的方法

/**
* 注册开发者appkey，申请地址：http://www.brtbeacon.com/developers.shtml
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
 * 扫描BrightBeacon设备，uuids为NSUUID数组(留空则启用默认的UUID):IOS6.x该参数无效，IOS7以上该参数用于构造BRTBeaconRegion来实现range beacon，提高RSSI精度
 *
 * @param completion 蓝牙扫描、区域扫描/监测回调
 *
 * @return void
 */

+ (void) startRangingWithUuids:(NSArray*)uuids onCompletion:(RangingBrightBeaconsCompletionBlock)completion NS_AVAILABLE_IOS(6_0);

/**
 * 仅支持IOS7以上，扫描BrightBeacon设备、区域(<20)监测（支持后台模式）,regions为BRTBeaconRegion数组(留空则启用默认的UUID)
 *
 * @param completion 蓝牙扫描、区域扫描/监测回调
 *
 * @return void
 */
+ (void) startRangingBeaconsInRegions:(NSArray*)regions onCompletion:(RangingBrightBeaconsCompletionBlock)completion NS_AVAILABLE_IOS(7_0);

/**
 * 在后台监听beacon regions
 * 结果将自动回调到AppDelegate中
 
-(void)beaconManager:(BRTBeaconManager *)manager
monitoringDidFailForRegion:(BRTBeaconRegion *)region
           withError:(NSError *)error;

-(void)beaconManager:(BRTBeaconManager *)manager
      didEnterRegion:(BRTBeaconRegion *)region;

-(void)beaconManager:(BRTBeaconManager *)manager
       didExitRegion:(BRTBeaconRegion *)region;

-(void)beaconManager:(BRTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(BRTBeaconRegion *)region;

 * @param @[region1,region2]
 *
 * @return void
 */
+ (void) startMonitoringForRegions:(NSArray *)regions  NS_AVAILABLE_IOS(7_0);

+ (void) requestStateForRegions:(NSArray *)regions  NS_AVAILABLE_IOS(7_0);

/**
 * 停止扫描、监测,if(regions==nil)停止所有当前监听区域
 *
 * @return void
 */
+ (void) stopRangingBrightBeacons;
+ (void) stopMonitoringForRegions:(NSArray *)regions;

/**
 * rssi 转换成 距离（米）
 *
 * @return float 距离（米）
 */
+ (float)rssiToDistance:(BRTBeacon*)beacon;
@end
