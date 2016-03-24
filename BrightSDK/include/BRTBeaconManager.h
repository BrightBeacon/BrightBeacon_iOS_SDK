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
#import <CoreBluetooth/CoreBluetooth.h>

@class BRTBeaconRegion;
@class BRTBeacon;

#define iszh [[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location==0
#define LOC_SHOWTIPS YES
#define LOC_TITLE iszh?@"需要定位":@"Location Need"
#define LOC_TIPS iszh?@"感知iBeacon设备，获取区域推送，需要定位权限“使用期间”或“始终”":@"In order to be notified about ibeacons near you, please open this app's settings and set location access to 'Always' Or 'WhenInUse'."

@class BRTBeaconManager;

/**
 
 BRTBeaconManagerDelegate协议定义了回调方法来响应关联的事件.
 */

@protocol BRTBeaconManagerDelegate <NSObject>

@optional

/**
 * 范围扫描触发的回调方法
 * 检索出所有的beacon设备，每个设备都是一个CLBeacon实例.
 *
 * @param manager Beacon 管理器
 * @param beacons 所有的beacon设备，即CLBeacon实体
 * @param region Beacon 区域
 *
 * @return void
 */
- (void)beaconManager:(BRTBeaconManager *)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(BRTBeaconRegion *)region;

/**
 * 范围扫描失败触发的回调方法，已经关联的错误信息
 *
 * @param manager Beacon 管理器
 * @param region Beacon 区域
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
 * @param manager Beacon 管理器
 * @param region Beacon 区域
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
 * @param manager Beacon 管理器
 * @param region Beacon 区域
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
 * @param manager Beacon 管理器
 * @param region Beacon 区域
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
 * @param manager Beacon 管理器
 * @param state Beacon 区域状态
 * @param region Beacon 区域
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
     didDetermineState:(CLRegionState)state
             forRegion:(BRTBeaconRegion *)region;

/**
 * 当设备模拟iBeacon广播信息，调用该方法.
 *
 * @param manager Beacon 管理器
 * @param error 错误描述信息
 *
 * @return void
 */
-(void)beaconManagerDidStartAdvertising:(BRTBeaconManager *)manager
                                  error:(NSError *)error;

/**
 * 在该区域使用CoreBluetooth framework发现BRTBeacon将回调该方法
 *
 * @param manager Beacon 管理器
 * @param beacon BRTBeacon 实体
 *
 * @return void
 */
- (void)beaconManager:(BRTBeaconManager *)manager
          didDiscoverBeacon:(BRTBeacon *)beacon;

/**
 * 当使用CoreBluetooth扫描产生错误回调该方法
 *
 * @param manager Beacon 管理器
 *
 * @return void
 */
- (void)beaconManagerDidFailDiscovery:(BRTBeaconManager *)manager;

@end

/**
 
 BRTBeaconManager 类定义了操作Beacon、配置Bright Beacon，以及获取相关事件通知应用程序的接口。使用本类的实例来建立参数描述每个Beacon设备，你也可以检索范围内所有的beacon设备。
 
 一个管理器提供支持以下位置相关的活动:
 
 * 监测不同感兴趣的区域和生成定位事件当用户进入或离开这些区域(在后台模式)。
 * 提供范围附近的Beacon设备和它的距离。
 
 */

@interface BRTBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <BRTBeaconManagerDelegate> delegate;

@property (nonatomic,strong) CBCentralManager *centralManager;


@property (nonatomic,assign) CLLocationCoordinate2D userCoordinate;
@property (nonatomic,strong) CLPlacemark *userPlacemark;
/*
 *  monitoredRegions
 *
 *  目前监测的所有区域。
 */
- (NSSet*)monitoredRegions;

/**
 *  rangedRegions
 *
 *  目前检测到正活跃的区域
 * @return NSSet
 */
- (NSSet*)rangedRegions;

/// @name CoreLocation based iBeacon monitoring and ranging methods

/**
 * 范围扫描所有的可见的Bright Beacon设备.
 * 检索Bright Beacon设备，通过回调函数beaconManager:didRangeBeacons:inRegion:
 * 返回一个NSArray包含的
 * BRTBeacon 对象。
 *
 * @param region bright beacon 区域
 *
 * @return void
 */
-(void)startRangingBeaconsInRegion:(BRTBeaconRegion*)region;

/**
 * 开始监测区域Start monitoring for particular region.
 * 该功能在后台也能够工作.
 * 只要你进入或者离开区域，都会回调: beaconManager:didEnterRegtion:
 * 或 beaconManager:didExitRegion:
 *
 * @param region bright beacon 区域
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
 * 设备模拟成 iBeacon.可以使用检测状态[[BRTBeaconSDK BRTBeaconManager] isAdvertising]
 *
 * @param proximityUUID beacon设备UUID值
 * @param major beacon设备major值
 * @param minor beacon设备minor值
 * @param identifier 唯一的区域标识
 * @param power 测量功率（1米处的RSSI值）
 *
 * @return void
 */
-(void)startAdvertisingWithProximityUUID:(NSUUID *)proximityUUID
                                   major:(CLBeaconMajorValue)major
                                   minor:(CLBeaconMinorValue)minor
                              identifier:(NSString*)identifier
                                   power:(NSNumber *)power;
/**
 * 是否正在模拟beacon广播
 *
 * @return void
 */
-(BOOL)isAdvertising;

/**
 * 停止模拟beacon广播
 *
 * @return void
 */
-(void)stopAdvertising;


/// @name 基于蓝牙CoreBluetooth方法


/**
 * 开始蓝牙扫描，基于CoreBluetooth
 * framework. 该方法用于扫描所有蓝牙设备.
 *
 *
 * @return void
 */
-(void)startBrightBeaconsDiscovery;


/**
 * 停止蓝牙扫描.
 *
 * @return void
 */
-(void)stopBrightBeaconDiscovery;

/**
 *  获取定位权限：允许后台定位，可以支持后台区域推送，网络数据传输等
 */
- (void)requestAlwaysAuthorization;

/**
 *  获取定位权限：只允许APP运行期间定位，不支持后台区域感知
 */
- (void)requestWhenInUseAuthorization;

/**
 *  获取用户位置信息
 *
 *  @param location  当前位置信息
 *  @param placemark 反转之后的地址信息
 *  @param error     错误信息
 */
typedef void(^locBlock)(CLLocation *location, CLPlacemark *placemark, NSError *error);
/**
 *  开始获取用户GPS
 *
 *  @param block GPS
 */
- (void)startUpdateLocations:(locBlock)block;
/**
 *  停止获取定位
 */
- (void)stopUpdatingLocation;

@end

