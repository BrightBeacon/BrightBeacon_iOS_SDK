//
//  BRTBeaconManager.h
//  BrightSDK
//
//  Version : 1.0.0
//  Created by Bright Beacon on 19/04/14.
//  Copyright (c) 2014 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BRTBeaconRegion.h"
#import "BRTBeacon.h"

#define iszh [[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location==0
#define BLE_SHOWTIPS YES
#define BLE_TITLE iszh?@"需要打开蓝牙":@"Please Turn on Bluetooth"
#define BLE_TIPS iszh?@"使用低功耗蓝牙可以发现身边的更多信息":@"Using bluetooth to find beacon around"
#define BLE_BUTTON iszh?@"好的":@"OK"

CBCentralManager *centralManager;

@class BRTBeaconManager;

/**
 
 BRTBeaconManagerDelegate协议定义了回调方法来响应关联的事件.
 */

@protocol BRTBeaconManagerDelegate <NSObject>

@optional

/**
 * 范围扫描触发的回调方法
 * 检索出所有的beacon设备，每个设备都是一个BRTBeacon实例.
 *
 * @param manager Bright beacon 管理器
 * @param beacons 所有的beacon设备，即BRTBeacon实体
 * @param region Bright beacon 区域
 *
 * @return void
 */
- (void)beaconManager:(BRTBeaconManager *)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(BRTBeaconRegion *)region;

/**
 * 范围扫描失败触发的回调方法，已经关联的错误信息
 *
 * @param manager Bright beacon 管理器
 * @param region Bright beacon 区域
 * @param error 错误信息
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
rangingBeaconsDidFailForRegion:(BRTBeaconRegion *)region
           withError:(NSError *)error;


/**
 * 只能在 AppDelegate 实现
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
           withError:(NSError *)error;
/**
 * 只能在 AppDelegate 实现
 *
 * 在区域监听中，iOS设备进入beacon设备区域触发该方法
 *
 * @param manager Bright beacon 管理器
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
      didEnterRegion:(BRTBeaconRegion *)region;


/**
 * 只能在 AppDelegate 实现
 *
 * 在区域监听中，iOS设备离开beacon设备区域触发该方法
 *
 * @param manager Bright beacon 管理器
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
       didExitRegion:(BRTBeaconRegion *)region;

/**
 * 只能在 AppDelegate 实现
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
             forRegion:(BRTBeaconRegion *)region;

/**
 * 当设备模拟iBeacon广播信息，调用该方法.
 *
 * @param manager Bright beacon 管理器
 * @param error 错误描述信息
 *
 * @return void
 */
-(void)beaconManagerDidStartAdvertising:(BRTBeaconManager *)manager
                                  error:(NSError *)error;

/**
 * 在该区域使用CoreBluetooth framework发现BRTBeacon将回调该方法
 *
 * @param manager Bright beacon 管理器
 * @param beacon BRTBeacon 实体
 *
 * @return void
 */
- (void)beaconManager:(BRTBeaconManager *)manager
          didDiscoverBeacon:(BRTBeacon *)beacon;

/**
 * 当使用CoreBluetooth扫描产生错误回调该方法
 *
 * @param manager Bright beacon 管理器
 *
 * @return void
 */
- (void)beaconManagerDidFailDiscovery:(BRTBeaconManager *)manager;

@end



/**
 
 BRTBeaconManager 类定义了操作、配置Bright Beacon，以及获取相关事件通知应用程序的接口。使用本类的实例来建立参数描述每个beacon设备，你也可以检索范围内所有的beacon设备。
 
 一个管理器提供支持以下位置相关的活动:
 
 * 监测不同感兴趣的区域和生成定位事件当用户进入或离开这些区域(在后台模式)。
 * 提供范围附近的beacon设备和它的距离。
 
 */

@interface BRTBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <BRTBeaconManagerDelegate> delegate;

/**
 屏蔽范围扫描时，未知状态的设备(proximity == 0)，默认NO.
 */
@property (nonatomic) BOOL avoidUnknownStateBeacons;
@property (nonatomic, strong) BRTBeaconRegion*         virtualBeaconRegion;

/**
 * 注册开发者appkey，申请地址：http://www.brtbeacon.com/api
 *
 * @param appKey Bright beacon 开发者密钥
 *
 * @return void
 */
+ (void)registerApp:(NSString *)appKey;

/// @name CoreLocation based iBeacon monitoring and ranging methods

/**
 * 范围扫描所有的可见的Bright Beacon设备.
 * 检索Bright Beacon设备，通过回调函数beaconManager:didRangeBeacons:inRegion:
 * 返回一个NSArray包含的
 * BRTBeacon 对象。
 *
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)startRangingBeaconsInRegion:(BRTBeaconRegion*)region;

/**
 * 开始监测区域Start monitoring for particular region.
 * 改功能在后台也能够工作.
 * 只要你进入或者离开区域，都会回调: beaconManager:didEnterRegtion:
 * 或 beaconManager:didExitRegion:
 *
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)startMonitoringForRegion:(BRTBeaconRegion*)region;

/**
 * 停止范围扫描 Bright beacon设备.
 *
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)stopRangingBeaconsInRegion:(BRTBeaconRegion*)region;

/**
 * 注销程序iOS区域检测
 *
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)stopMonitoringForRegion:(BRTBeaconRegion *)region;

/**
 * 允许为特定区域验证当前状态
 *
 * @param region Bright beacon 区域
 *
 * @return void
 */
-(void)requestStateForRegion:(BRTBeaconRegion *)region;

/// @name 转换设备为 iBeacon

/**
 * 设备模拟成 Bright beacon.
 *
 * @param proximityUUID beacon设备UUID值
 * @param major beacon设备major值
 * @param minor beacon设备minor值
 * @param identifier 唯一的区域标识
 *
 * @return void
 */
-(void)startAdvertisingWithProximityUUID:(NSUUID *)proximityUUID
                                   major:(CLBeaconMajorValue)major
                                   minor:(CLBeaconMinorValue)minor
                              identifier:(NSString*)identifier
                                   power:(NSNumber *)power;

/**
 * 停止模拟beacon广播
 *
 * @return void
 */
-(void)stopAdvertising;


/// @name 基于蓝牙CoreBluetooth方法


/**
 * 开始beacon设备扫描，基于CoreBluetooth
 * framework. 该方法用于扫描不是iBeacons一样广播数据的蓝牙设备.
 *
 *
 * @return void
 */
-(void)startBrightBeaconsDiscovery;
- (void)startBrightBeaconsDiscoveryAllowDuplicatesKey;


/**
 * 停止基于 CoreBluetooth 的beacon扫描.
 *
 * @return void
 */
-(void)stopBrightBeaconDiscovery;

@end

