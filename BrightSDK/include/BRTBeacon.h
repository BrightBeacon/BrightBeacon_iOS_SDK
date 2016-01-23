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
 
 BRTBeaconDelegate 定义了 beacon 连接相关的委托方法，beacon 的连接是一个异步操作，因此你只需要实现例如beaconDidDisconnect:相关方法，它们会被自动回调.
 
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
- (void)beaconConnection:(BRTBeacon*)beacon withError:(NSError*)error;

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
 * Discussion:
 * 注意该值在用于区域标识，0和nil不等价：0是监测区域中对应UUID的设备下Minor为0的设备，nil则表示不使用该值
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
 *    该值是1米处的rssi值，用于设备距离估算.
 */
@property (nonatomic, strong)   NSNumber*               measuredPower;

/**
 *  region
 *
 *    该值是设备所在区域region，仅IOS7+支持
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
 *    battery电量，范围 0~100，通过实时工作电压估算值，连接后读取值为工作电压估算值，较广播时略偏低
 */
@property (nonatomic, strong)    NSNumber*    battery;

/**
 *  temperature
 *
 *    温度，范围 -40~100℃ ，127为无效值
 */
@property (nonatomic, strong)    NSNumber*    temperature;
/////////////////////////////////////////////////////
// 通过蓝牙连接，读取的属性

/// @name 连接之后属性可用


/**
 *  power
 *
 *  以分贝计的发射功率，连接后可用
 *  TI芯片：0：-23dBm 1：-6dBm 2：0dBm 3：+4dBm
 *  Nordic芯片：0：-40dBm 1：-30dBm 2：-20dBm 3：-16dBm 4：-12dBm 5：-8dBm 6：-4dBm 7：0dBm 8：+4dBm
 */
@property (nonatomic, unsafe_unretained)   NSInteger           power;

/**
 *  advInterval
 *
 *    广播发射间隔，值范围100ms~10000ms,连接后可用
 */
@property (nonatomic, strong)   NSNumber*               advInterval;

/**
 *  light
 *
 *    光感强度
 */
@property (nonatomic, unsafe_unretained)   NSInteger          light;

/**
 *  mode
 *
 *    Beacon模式，开发模式，部署模式，连接后可用
 */
@property (nonatomic, unsafe_unretained)    DevelopPublishMode    mode;

/**
 *  batteryCheckInteval
 *
 *    广播状态下Beacon的电量检测间隔，单位为：秒；范围：1800秒~43200秒（12小时），即每隔指定秒自动检测电量并更新广播的数据
 */
@property (nonatomic, unsafe_unretained)    NSInteger    batteryCheckInteval;

/**
 *  temperatureCheckInteval
 *
 *    广播状态下Beacon周边温度检测间隔，单位为：秒；范围：10秒~43200秒（12小时），即每隔指定秒自动检测电量并更新广播的数据
 */
@property (nonatomic, unsafe_unretained)    NSInteger    temperatureCheckInteval;

/**
 *  lightCheckInteval
 *
 *    广播状态下Beacon周边光强检测间隔，单位为：毫秒；范围：1000毫秒~10,000毫秒，即每隔指定毫秒自动检测光强并更新广播的数据
 */
@property (nonatomic, unsafe_unretained)    NSInteger    lightCheckInteval;

/**
 * lightSleep
 *
 *  开启光感休眠，当环境变得完全黑暗，Beacon设备会自动降低发射频率，来提高使用寿命
 */
@property (nonatomic, unsafe_unretained)    BOOL    lightSleep;

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
 *    固件最新版本信息，{@link checkFirmwareUpdateWithCompletion:}后可用
 */
@property (readonly, nonatomic)   NSString*               firmwareVersionInfo;

/**
 *  Eddystone的Uid
 */
@property (nonatomic,strong)  NSString *eddystone_Uid;

/**
 *  Eddystone的Url
 */
@property (nonatomic,strong)  NSString *eddystone_Url;

/**
 *  转换Url为eddystone模式NSData
 *  参考：https://github.com/google/eddystone/tree/master/eddystone-url
 *
 *  @param url 例(http://www.brtbeacon.com)->()
 *
 *  @return NSData
 */
- (NSData*)eddystone_Url_From:(NSString*)url;

/**
 *  将eddystone模式下的Url字符串转换为普通url
 *
 *  @param eddystoneUrl eddystone-URL字符串
 *
 *  @return NSString
 */
- (NSString*)eddystone_Url_To:(NSString*)eddystoneUrl;

/// @name 连接beacon相关的方法

/**
 * 当前版本支持状态（位标示）
 *
 * TI芯片 Nordic 光感支持 自动检测 防丢支持 加密模式
 * -----+------+-------+-------+------+-------
 *   1      1      1       1       1      1
 */
@property (nonatomic,assign) NSInteger supportOption;

/**
* 检测beacon设备是否支持某些属性
*/
- (BOOL)isSupport:(BrtSupports)option;

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

/// @name 写人beacon配置信息相关的方法

/**
 *  写入ControlBeacon数据
 *
 *  @param values     B_RWData
 *  @param completion 硬件返回数据
 */
- (void)writeCBeacon:(NSDictionary *)values withCompletion:(BRTDataCompletionBlock)completion;

/**
 * 写入设备信息
 *
 * @param values 设备信息(参见)
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
 *  读取设备版本信息
 *
 *  @param completion 读取完成回调
 */
- (void)readBeaconFirmwareVersionWithCompletion:(BRTStringCompletionBlock)completion;

/**
 *  读取设备变动信息：温度、电量、光感(若有)
 *
 *  @param completion 读取完成回调
 */
- (void)readBeaconChangesWithCompletion:(BRTDataCompletionBlock)completion;

/**
 * 重置beacon设备默认值，该操作要求已经成功执行 {@link registerApp:};
 *
 * @return void
 */
-(void)resetBeaconToDefault;

/**
 * 重置beacon设备默认KEY，该操作可以解除设备开发者绑定，让beacon设备可以重新被连接设定新的APP_KEY，该操作要求已经成功执行[BRTBeaconManager registerApp:APP_KEY];
 *
 * @return void
 */
- (void)resetSDKKEY;

/**
 * 设置此Beacon处于开发者模式（DevelopMode）还是部署模式（PublishMode）
 *
 * 如果Beacon处于开发者模式，则可以用任意的APP KEY进行连接， 如果Beacon处于部署模式，则需要对应配置过Beacon的APP KEY 才能再一次进行连接，确保Beacon部署安全
 * @param mode 0、开发模式 1、部署模式
 * @param completion 写入完成回调
 * @return void
 */
- (void)writeBeaconMode:(DevelopPublishMode)mode withCompletion:(BRTCompletionBlock)completion;


/**
 *  广播模式选择（1、iBeacon 2、eddystone-Uid 3、eddystone-Url）
 *
 * 轮播Beacon专用
 * 0.只广播iBeacon,               bit[2]=0,bit[3]=0,
 * 1.仅广播Eddystone(UID),        bit[2]=0,bit[3]=1,bit[4]=0
 * 2.仅广播Eddystone(URL),        bit[2]=0,bit[3]=1,bit[4]=1
 * 3.轮播iBeacon和Eddystone(UID), bit[2]=1,bit[3]=0,bit[4]=0
 * 4.轮播iBeacon和Eddystone(URL), bit[2]=1,bit[3]=0,bit[4]=1
 * 5,轮播Eddystone(UID/URL),      bit[2]=1,bit[3]=1
 */
@property (nonatomic,assign) BroadcastMode broadcastMode;

/**
 *  040x串口数据收发
 *
 *  该值会在串口数据变化时，自动更新。
 */
@property (nonatomic,copy) NSString *serialData;

/**
  * 用户自定义广播数据 4byte范围（0x00000000~0xFFFFFFFF）
  */
@property (nonatomic,strong) NSString *userData;

/**
 * 广播跳频模式，默认3种切换：2402、2426、2480MHz
 */
@property (nonatomic,assign) BOOL isOff2402;
@property (nonatomic,assign) BOOL isOff2426;
@property (nonatomic,assign) BOOL isOff2480;


/**
 *  eddystone模式的url
 */
@property (strong, nonatomic)   NSString*   reserved;


@property (nonatomic, assign)    NSInteger    rssis;
@property (nonatomic, assign)    NSInteger    count;
@property (nonatomic, assign)    BOOL    rssiByLocation;


/**
 *  阿里模式，已废弃，不建议使用
 */
@property (nonatomic,assign) BOOL isAliMode;

/**
 *  开启阿里UUID，已废弃，不建议使用
 */
@property (nonatomic,assign) BOOL isAliUUID;


/**
 *  是否在范围内，已废弃，不建议使用
 */
@property (nonatomic,assign) BOOL isInRange;

/**
 * 自动报警（可以每隔N秒写入一次B_InRange来停止自动蜂鸣），已废弃，不建议使用
 */
@property (nonatomic,assign) BOOL isAutoAlarm;

/**
 * 自动报警超时（默认超时5秒），已废弃，不建议使用
 */
@property (nonatomic,assign) NSInteger autoAlarmTimeOut;

/**
 * 主动寻找，写人该值设备立即蜂鸣，已废弃，不建议使用
 */
@property (nonatomic,assign) BOOL isActiveFind;

/**
 * 按钮报警，按钮报警状态，已废弃，不建议使用
 */
@property (nonatomic,assign) BOOL isButtonAlarm;

@end
