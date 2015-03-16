//
//  BRTBeacon.h
//  BrightSDK
//
//  Version : 1.0.0
//  Created by Bright Beacon on 21/04/14.
//  Copyright (c) 2014 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BRTBeaconDefinitions.h"

@class BRTBeacon;

////////////////////////////////////////////////////////////////////
// Bright Beacon delegate protocol


/**
 
 BRTBeaconDelegate 定义了 beacon 连接相关的委托方法，beacon 的连接是一个异步操作，因此你只需要实现例如beaconDidDisconnectWith:相关方法，它们会被自动回调.
 
 */

@protocol BRTBeaconDelegate <NSObject>

@optional

/**
 * beacon连接产生错误回调该方法.
 *
 * @param beacon 关联的beacon实体
 * @param error 错误的描述信息
 *
 * @return void
 */
- (void)beaconConnectionDidFail:(BRTBeacon*)beacon withError:(NSError*)error;

/**
 * beacon连接成功回调该方法
 *
 * @param beacon 关联的beacon实体
 *
 * @return void
 */
- (void)beaconConnectionDidSucceeded:(BRTBeacon*)beacon;

/**
 * beacon与设备已经断开连接回调该方法
 *
 * @param beacon 关联的beacon实体
 * @param error 错误的描述信息
 *
 * @return void
 */
- (void)beaconDidDisconnect:(BRTBeacon*)beacon withError:(NSError*)error;

@end


////////////////////////////////////////////////////////////////////
// Interface definition

/**
 
 BRTBeacon类代表了一个在该区域监听中遇到的beacon设备. 你不需要直接实例化这个类. BRTBeaconManager在扫描到beacon设备时会回调相应delegate的方法传人BRTBeacon.你可以通过BRTBeacon里的信息来识别不同的设备.
 
 
 BRTBeacon类既包含了苹果CLBeacon类的基本方法，同时也新增了一些扩展方法，它能连接到beacon设备读取和写人一些特征（characteristics）.
 
 */

@interface BRTBeacon : NSObject <CBPeripheralDelegate>

extern CBCentralManager *centralManager;

@property (nonatomic, unsafe_unretained)     id <BRTBeaconDelegate>  delegate;

/////////////////////////////////////////////////////
//
//

/**
 *  invalidTime
 *
 *  Discussion:
 *    beacon设备上一次出现的时间戳，一般用于维护是设备生存周期，例如5s内未再次收到该设备信号，就移除该beacon设备.
 */
@property (nonatomic, unsafe_unretained) NSInteger invalidTime;

/**
 *  macAddress
 *
 *  Discussion:
 *    beacon设备的物理地址.可以唯一标识Bright Beacon设备，非BrightBeacon设备该值可能为空
 */
@property (nonatomic, strong)   NSString*               macAddress;

/**
 *  name
 *
 *    beacon设备名.
 *
 */
@property (nonatomic, strong)   NSString*               name;

/**
 *  proximityUUID
 *
 *    beacon设备的UUID，可以用作区域标识
 *
 */
@property (nonatomic, strong)   NSUUID*                 proximityUUID;

/**
 *  major
 *
 *    设备的主要属性值，默认值是0。可以用作区域标识
 *
 * Discussion:
 * 注意该值在用于区域标识，0和nil不等价：0是监测区域中对应UUID的设备下Major为0的设备，nil则表示不使用该值
 */
@property (nonatomic, strong)   NSNumber*               major;

/**
 *  minor
 *
 *    设备的次要属性值，默认值是0。可以用作区域标识，类同Major
 *
 */
@property (nonatomic, strong)   NSNumber*               minor;



/**
 *  rssi
 *
 *    beacon的接收信号强度指示（Received Signal Strength Indicator）以分贝为单位.
 *    该值是根据本次beacon发射的信号所收集到样本的平均值.
 *
 */
@property (nonatomic)           NSInteger               rssi;

/*
 *  accuracy
 *
 *   该值单位‘米’，值越小表明位置越近，负值无效，仅作参考距离
 *
 */
@property (nonatomic) CLLocationAccuracy accuracy;

/**
 *  distance
 *
 *    根据接收信号强度指示（rssi）和测量功率（measured power：距离一米的rssi值）估算出的beacon设备到手机的距离.
 *
 */
@property (nonatomic, strong)   NSNumber*               distance;

/**
 *  proximity
 *
 *    该值代表相对距离远近，可以通过它快速确定beacon设备距离用户是在附近或是很远.
 */
@property (nonatomic)           CLProximity             proximity;

/**
 *  measuredPower
 *
 *    该值是1米处的rssi值，用于设备校准.
 */
@property (nonatomic, strong)   NSNumber*               measuredPower;

/**
 *  region
 *
 *    该值是设备所在region，仅IOS7+支持
 */
@property (nonatomic, strong)   CLBeaconRegion*               region;

/**
 *  peripheral
 *
 *    代表一个周边设备，用于蓝牙连接.
 */
@property (nonatomic, strong)   CBPeripheral*           peripheral;

/**
 *  isBrightBeacon
 *
 *    是否是BrightBeacon
 */
@property (nonatomic, unsafe_unretained)    BOOL    isBrightBeacon;

/**
 *  isConnected
 *
 *    标示连接状态.
 */
@property (nonatomic, readonly)   BOOL                  isConnected;
/**
 *  battery
 *
 *    battery电量，范围 0~100，通过工作电压估算值，连接后读取值为工作电压
 */
@property (nonatomic, strong)    NSNumber*    battery;

/**
 *  temperature
 *
 *    温度，范围 -40~100℃ ，127为保留值
 */
@property (nonatomic, strong)    NSNumber*    temperature;
/////////////////////////////////////////////////////
// 通过蓝牙连接，读取的属性

/// @name 连接之后属性可用


/**
 *  power
 *
 *    以分贝计的发射功率，连接后可用
 */
@property (nonatomic, unsafe_unretained)   BRTBeaconPower           power;

/**
 *  advInterval
 *
 *    广播发射间隔，值范围100ms~10000ms,连接后可用
 */
@property (nonatomic, strong)   NSNumber*               advInterval;

/**
 *  ledState
 *
 *    led灯状态，连接后可用
 */
@property (nonatomic, unsafe_unretained)   BOOL          ledState;



/**
 *  mode
 *
 *    Beacon模式，开发模式，部署模式，连接后可用
 */
@property (nonatomic, unsafe_unretained)    DevelopPublishMode    mode;

/**
 *  batteryCheckInteval
 *
 *    广播状态下Beacon的电量检测间隔，单位为:秒；最小值为1800秒，即每半小时自动检测电量并更新广播的数据
 */
@property (nonatomic, unsafe_unretained)    NSInteger    batteryCheckInteval;

/**
 *  temperatureCheckInteval
 *
 *    广播状态下Beacon周边温度检测间隔，单位为 秒；最小值为30秒，即每30秒自动检测电量并更新广播的数据
 */
@property (nonatomic, unsafe_unretained)    NSInteger    temperatureCheckInteval;

/**
 *  硬件版本
 *
 *    设备硬件版本，连接后可用
 */
@property (strong, nonatomic)   NSString*               hardwareVersion;

/**
 *  固件版本
 *
 *    设备固件版本，连接后可用
 */
@property (strong, nonatomic)   NSString*               firmwareVersion;

/**
 *  固件最新版本信息，
 *
 *    固件最新版本信息，checkFirmwareUpdateWithCompletion后可用
 */
@property (readonly, nonatomic)   NSString*               firmwareVersionInfo;

/// @name 连接beacon相关的方法


/**
 * 蓝牙连接到beacon设备
 * 只能连接之后才可以修改
 * Major, Minor, Power and Advertising interval.
 *
 * @return void
 */
-(void)connectToBeacon;
-(void)connectToBeaconWithCompletion:(BRTConnectCompletionBlock)completion;

/**
 * 断开蓝牙连接
 *
 * @return void
 */
-(void)disconnectBeacon;


/// @name 读取beacon配置信息相关的方法


/**
 * 读取连接中的beacon设备名 (要求已经连接成功)
 *
 * @param completion 读取设备名完成回调
 *
 * @return void
 */
- (void)readBeaconNameWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * 读取连接中的beacon设备临近的UUID值 (要求已经连接成功)
 *
 * @param completion 读取ProximityUUID值回调
 *
 * @return void
 */
- (void)readBeaconProximityUUIDWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的major值 (要求已经连接成功)
 *
 * @param completion 读取major值完成回调
 *
 * @return void
 */
- (void)readBeaconMajorWithCompletion:(BRTUnsignedShortCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的minor值 (要求已经连接成功)
 *
 * @param completion 读取minor值完成回调
 *
 * @return void
 */
- (void)readBeaconMinorWithCompletion:(BRTUnsignedShortCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的发射间隔 (要求已经连接成功)
 *
 * @param completion 读取发射间隔值完成回调
 *
 * @return void
 */
- (void)readBeaconAdvIntervalWithCompletion:(BRTUnsignedShortCompletionBlock)completion;


/**
 * 读取连接中的beacon设备的发射功率 (要求已经连接成功)
 *
 * @param completion 读取发射功率值完成回调
 *
 * @return beacon功率的float值
 */
- (void)readBeaconPowerWithCompletion:(BRTPowerCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的led灯状态 (要求已经连接成功)
 *
 * @param completion 读取led灯状态完成回调
 *
 * @return void
 */
- (void)readBeaconLedStateWithCompletion:(BRTBoolCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的测量功率 (要求已经连接成功)
 *
 * @param completion 读取测量功率值完成回调
 *
 * @return void
 */
- (void)readBeaconMeasuredPowerWithCompletion:(BRTShortCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的电量 (要求已经连接成功)
 *
 * @param completion 读取当前电量完成回调
 *
 * @return void
 */
- (void)readBeaconBatteryWithCompletion:(BRTShortCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的固件版本 (要求已经连接成功)
 *
 * @param completion 读取固件版本信息完成回调
 *
 * @return void
 */
- (void)readBeaconFirmwareVersionWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的硬件版本 (要求已经连接成功)
 *
 * @param completion 读取硬件版本信息完成回调
 *
 * @return void
 */
- (void)readBeaconHardwareVersionWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * 读取连接中的beacon设备的温度信息 (要求已经连接成功)
 *
 * @param completion 读取温度信息完成回调
 *
 * @return void
 */
- (void)readBeaconTemperatureWithCompletion:(BRTShortCompletionBlock)completion;

/**
 * 读取连接中的beacon设备在广播状态下自动检测 电量 的间隔时间 (要求已经连接成功)
 *
 * @param completion 读取间隔时间完成回调
 *
 * @return void
 */
- (void)readBatteryCheckIntevalWithCompletion:(BRTIntegerCompletionBlock)completion;

/**
 * 读取连接中的beacon设备在广播状态下自动检测 温度 的间隔时间 (要求已经连接成功)
 *
 * @param completion 读取间隔时间完成回调
 *
 * @return void
 */
- (void)readTemperatureCheckIntevalWithCompletion:(BRTIntegerCompletionBlock)completion;

/// @name 写人beacon配置信息相关的方法

/**
 * 写入设备信息
 *
 * @param values 设备信息
 * @param completion 写入完成回调
 *
 * @return void
 */
- (void)writeBeaconValues:(NSDictionary*)values withCompletion:(BRTCompletionBlock)completion;

/**
 *  检查固件更新
 *
 *  @param completion 写入完成回调
 */
-(void)checkFirmwareUpdateWithCompletion:(BRTStringCompletionBlock)completion;

/**
 *  云端更新固件
 *
 *  @param progress 更新进度0~100
 *  @param completion 写入完成回调
 */
-(void)updateBeaconFirmwareWithProgress:(BRTShortCompletionBlock)progress andCompletion:(BRTCompletionBlock)completion;

/**
 * 重置beacon设备默认值，该操作要求已经成功执行 {@link registerApp:};
 *
 *
 * @return void
 */
-(void)resetBeaconToDefault;

/**
 * 重置beacon设备默认KEY，该操作可以解除设备开发者绑定，让beacon设备可以重新被连接设定新的YOUR_KEY，该操作要求已经成功执行[BRTBeaconManager registerApp:YOUR_KEY];
 *
 * @return void
 */
- (void)resetSDKKEY;

/**
 * 设置此Beacon处于开发者模式（DevelopMode）还是发布模式（PublishMode）
 * 如果Beacon处于开发者模式，则可以用32个0的APP KEY进行任意链接， 如果Beacon处于发布模式，则需要对应配置过Beacon的APP KEY 才能再一次进行连接，确保Beacon部署安全
 * @param mode 0、开发模式 1、部署模式
 * @param completion 写入完成回调
 * @return void
 */
- (void)writeBeaconMode:(DevelopPublishMode)mode withCompletion:(BRTCompletionBlock)completion;




@property (nonatomic,assign) NSInteger rssis;
@property (nonatomic,assign) NSInteger count;
@end
