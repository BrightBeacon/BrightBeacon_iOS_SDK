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
#import "BRTTools.h"

////////////////////////////////////////////////////////////////////
// Type and class definitions

typedef void(^RangingBrightBeaconsCompletionBlock)(NSArray* beacons, BRTBeaconRegion* region, NSError* error);

////////////////////////////////////////////////////////////////////
// Interface definition

/**
 
 * BRTBeaconSDK类定义了快捷操作BrightBeacon方法.
 *
 *  IOS8以上新增获取定位权限、状态，请在Info.plist配置获取时提示用户内容Key：NSLocationAlwaysUsageDescription或NSLocationWhenInUseUsageDescription
 *
 *  1、Always:允许后台定位，可以支持后台区域推送等
 *  2、WhenInUse:只允许运行时定位，不支持后台区域感知
 *  使用[CLLocationManager authorizationStatus]获取定位状态
 */


@interface BRTBeaconSDK : NSObject

/**
 *  单例
 */
+ (BRTBeaconSDK*) Share;


/// @name beacon快捷扫描BrightBeacon相关的方法

/**
 * 注册并验证开发者appKey，申请地址：http://developer.brtbeacon.com
 *
 * @param appKey BrightBeacon AppKey
 * @param completion 验证appKey有效性状态
 *
 */
+ (void)registerApp:(NSString *)appKey onCompletion:(BRTCompletionBlock)completion;


/**
 设置超时移除Beacon时间，与硬件发射频率设置配合，默认3s未收到信号移除；
 未开启定位时，间隔会延迟，防止Beacon频繁误移。

 @param invalidTime beacon信号丢失移除间隔
 */
+ (void)setInvalidTime:(NSTimeInterval)invalidTime;


/**
 调节扫描返回调用频率，仅内部定时处理，蓝牙扫描本身无法设置间隔，默认1s

 @param scanResponseTime block回调间隔
 */
+ (void)setScanResponseTime:(NSTimeInterval)scanResponseTime;

/**
* BrightBeacon管理类，控制Beacon扫描、蓝牙扫描、区域检测、本地消息提醒
*
* @return BRTBeaconManager
*/
+ (BRTBeaconManager*) BRTBeaconManager;

/**
 * BrightBeacon设备数组，设备的距离会及时更新
 *
 * @return NSArray
 */
+ (NSArray*)BRTBeacons;

/**
 * BrightBeacon设备集合，设备的距离会及时更新，以mac为key，如无mac以（Major+Minor）为key
 *
 * @return NSDictionary
 */
+ (NSDictionary*)BRTBeaconsDictionary;

/**
 * 扫描BrightBeacon设备（支持蓝牙连接，扫描BrightBeacon额外参数），uuids为NSUUID数组:IOS6.x该参数无效；IOS7.x该参数用于构造区域BRTBeaconRegion来实现扫描、广播融合模式，提高RSSI精度(注：留空则只开启蓝牙扫描)
 * @param uuids uuid数组
 * @param completion 扫描Beacon回调（1秒/次）
 *
 */

+ (void) startRangingWithUuids:(NSArray*)uuids onCompletion:(RangingBrightBeaconsCompletionBlock)completion NS_AVAILABLE_IOS(6_0);

/**
 * 扫描iBeacon设备（不支持连接，能获取iBeacon协议参数），IOS7以上，感知区域中iBeacon设备,regions为BRTBeaconRegion数组(留空则启用默认的UUID)
 * @param regions 区域数组
 * @param completion 扫描Beacon回调（1秒/次）
 *
 */
+ (void) startRangingBeaconsInRegions:(NSArray*)regions onCompletion:(RangingBrightBeaconsCompletionBlock)completion NS_AVAILABLE_IOS(7_0);

/**
 * 停止扫描BrightBeacon设备
 *
 */
+ (void) stopRangingBrightBeacons;

/** 
 *
 *用于初始化接收后台区域监听回调类，此函数以及handler实体类都必须是与AppDelegate随同启动，否则无法接收到后台beacon推送
 *
 * 以下是在后台监听区域的回调函数，请拷贝需要的回调到AppDelegate或对应的handler类
 *<br/>监听失败回调
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager monitoringDidFailForRegion:(BRTBeaconRegion *)region withError:(NSError *)error;
 *<br/>进入区域回调
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager didEnterRegion:(BRTBeaconRegion *)region;
 *<br/>离开区域回调
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager didExitRegion:(BRTBeaconRegion *)region;
 *<br/>锁屏区域检测、requestStateForRegions回调
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region;
 *<br/>模拟iBeacon回调
 *<br/>- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error;
 *
 * @param handler 用于接收后台区域监听回调函数的类。传入的handler类用作接收回调（该类务必随程序的启动即初始化，否则无法接收到回调）；若传人值为nil会返回当前使用的handler（默认为AppDelegate）
 *
 * @return handler 返回当前使用的handler
 */
+ (id)regionHander:(id)handler;

/**
 *  请求监听状态，仅支持IOS7以上，IOS6始终返回nil
 *
 *  @param dict 需要请求的区域标识，uuid必须传人，major或minor按实际情况选传 示例：{uuid:...,major:@0}
 *
 *  @return 区域监听状态 nil为无监听 示例：{in:@YES,out:@NO,display:@YES}
 */
+ (NSDictionary*)isMonitoring:(NSDictionary*)dict NS_AVAILABLE_IOS(6_0);

/**
 * 开启区域监听要求IOS7以上系统；
 * 如果需要程序退出后持续监听，需要提醒用户打开位置权限->始终；并需在AppDelegate启动时调用{@link regionHandler:}
 * IOS8另需请求允许后台定位，requestAlwaysAuthorization
 * 检查状态：CLLocationManager.authorizationStatus==kCLAuthorizationStatusAuthorizedAlways.
 * 注：SDK默认只请求一直定位，可以通过BRTBeaconDefinitions.h中isLocationAlways来配置
 *
 * 状态会默认回调到appDelegate中(或自定义的handler中{@link regionHandler:})：
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager didEnterRegion:(BRTBeaconRegion *)region;
 *
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager didExitRegion:(BRTBeaconRegion *)region;
 *
 *<br/>-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region;
 *
 * @param regions @[region1,region2]
 *
 */
+ (void) startMonitoringForRegions:(NSArray *)regions  NS_AVAILABLE_IOS(7_0);

/**
 * 立即查询是否位于指定区域；状态会回调到appDelegate中：
 *
 *-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region;
 *
 * @param regions @[region1,region2]
 *
 */
+ (void) requestStateForRegions:(NSArray *)regions  NS_AVAILABLE_IOS(7_0);

/**
 * 停止扫描、监测,if(regions==nil)停止所有当前监听区域
 *
 * @param regions @[region1,region2]
 *
 */
+ (void) stopMonitoringForRegions:(NSArray *)regions;

/**
 * rssi 转换成 距离（米）
 *
 * @param beacon beacon设备，需要使用measured power值
 *
 * @return float 距离（米）
 */
+ (float)rssiToDistance:(BRTBeacon*)beacon;

@end
