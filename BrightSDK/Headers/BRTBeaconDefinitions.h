//
//  BRTBeaconDefinitions.h
//  BrightSDK
//
//  Version : 1.0.0
//  Created by Bright Beacon on 19/04/14.
//  Copyright (c) 2014 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
////////////////////////////////////////////////////////////////////
// Type and class definitions
/**
 * 更新日志
 *
 *  3.2.6 替换使用CBUUID类别方法产生的undefined selector
 *
 *  3.2.5 修复ios7.0.x配置
 *
 *  3.2.4 解决部分无法编译
 *
 *  3.2.3 兼容新版本固件
 *
 *  3.2.2 修复17位key连接失败
 *
 *  3.2.1 防丢器新版
 *
 *  3.2.0 新增防丢器，扫描和Range合并，提高性能
 *
 *  3.1.0 修复光感休眠，批量部署错误，新增连接15s超时
 *
 *  3.0.9 光感休眠等
 *
 *  3.0.8 for Api Cloud支持
 *
 *  3.0.7 光感、间隔、最新固件大小端问题
 *
 *  3.0.6 修复Range的RSSI
 *
 *  3.0.5 修复records温度、电量为nil错误
 *
 *  3.0.4 修复第一次启动无法成功开启扫描
 * 
 *  3.0.3 提供IOS8定位权限选择、蓝牙一直扫描
 *
 *  3.0.2 新增Beacon属性
 *
 *  3.0.0 注释完善
 *
 */
#define SDK_VERSION @"3.2.6"

#define B_NAME @"name"
#define B_UUID @"uuid"
#define B_MAJOR @"major"
#define B_MINOR @"minor"
#define B_MEASURED @"mPower"
#define B_MPOWER @"mPower"
#define B_INTERVAL @"txInterval"
#define B_TX @"txPower"
#define B_MODE @"pMode"
#define B_BATTERY_INTERVAL @"batteryInterval"
#define B_TEMPERATURE_INTERVAL @"temperatureInterval"
#define B_LIGHT_INTERVAL @"lightInterval"
#define B_LIGHT_SLEEP @"lightSleep"
//Anti
#define B_Reserved @"Reserved"
#define B_InRange @"InRange"
#define B_AutoAlarm @"AutoAlarm"
#define B_ActiveFind @"ActiveFind"
#define B_ButtonAlarm @"ButtonAlarm"
#define B_AutoAlarmTimeOut @"autoalarmtimeout"
//Ali
#define B_Ali_Switch @"AliSw"
#define B_AliUUID_Switch @"useAliUUIDSw"
#define B_AliUUID @"Reserved"

#define DEFAULT_KEY @"00000000000000000000000000000000"   //32-0
#define DEFAULT_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
#define DEFAULT_MAJOR 0
#define DEFAULT_MINOR 0
#define DEFAULT_MEASURED -65
//#define DEFAULT_LED 1
#define DEFAULT_INTERVAL 800
#define DEFAULT_BCHECK_INTERVAL 3600
#define DEFAULT_TCHECK_INTERVAL 3600
#define DEFAULT_LCHECK_INTERVAL 5000
#define DEFAULT_TX 2
#define DEFAULT_TX_PLUS 7
#define DEFAULT_NAME  @"BrightBeacon"
#define DEFAULT_MODE 0
#define DEFAULT_LIGHT_SLEEP 0

#define kNotifyConnect @"kNotifyConnect"
#define kNotifyDisconnect @"kNotifyDisconnect"

#define I2N(x) [NSNumber numberWithInteger:x]
#define I2S(x) [NSString stringWithFormat:@"%ld",(long)x]
/**
 *  IOS8以上新增获取定位权限、状态，请在Info.plist配置获取时提示用户内容Key：NSLocationAlwaysUsageDescription和NSLocationWhenInUseUsageDescription
 *
 *  1、Always:允许后台定位，可以支持后台区域推送，网络数据传输等
 *  2、WhenInUse:只允许运行时定位，不支持后台区域感知
 *  使用[CLLocationManager authorizationStatus]获取定位状态
 */
#define isLocationAlways NO

typedef NS_OPTIONS(NSUInteger, BrtSupports) {
    BrtSupportsCC254x                   = 1 << 0,
    BrtSupportsNordic                   = 1 << 1,
    BrtSupportsLight                    = 1 << 2,
    BrtSupportsCombineCharacteristic    = 1 << 3,
    BrtSupportsAntiLose                 = 1 << 4,
    BrtSupports16Key                    = 1 << 5,
    BrtSupportsUpdateName               = 1 << 6,
    BrtSupportsAli                      = 1 << 7//新版本判断含CCx和Nordic：0100
};

typedef enum : int
{
    DevelopMode=0,  //开发模式
    PublishMode,    //部署模式
} DevelopPublishMode;

typedef enum : int
{
    ErrorCodeUnKnown = 0,  //未知错误（发起连接失败、蓝牙信道拥塞）
    CBErrorCode1 = 1,     //参数无效
    CBErrorCode2 = 2,     //指定属性无效
    CBErrorCode3 = 3,     //设备未连入
    CBErrorCode4 = 4,     //设备空间资源耗尽
    CBErrorCode5 = 5,     //操作被取消
    CBErrorCode6 = 6,     //连接超时
    CBErrorCode7 = 7,     //设备被断开（系统错误、AppKey不正确）
    CBErrorCode8 = 8,     //指定的UUID不允许
    CBErrorCode9 = 9,     //设备正在广播
    CBErrorCode10 = 10,     //设备连接失败(信号中断等)
    
    ErrorCode100 = 100,     //APP KEY不正确
    ErrorCode101 = 101,     //未识别的设备(未检测到peripheral或非BrightBeacon设备)
    ErrorCode102 = 102,     //网络连接失败
    ErrorCode103 = 103,     //未检测到传感器(读取传感器特征失败)
    ErrorCode104 = 104,     //未检测到传感器、读取数据有误(读取传感器特征失败)
    ErrorCode105 = 105,     //当前版本固件不支持更新
    ErrorCode106 = 106,     //暂无版本更新，或未执行版本检测：checkFirmwareUpdateWithCompletion:
    ErrorCode107 = 107,     //固件下载失败，请重试
    ErrorCode108 = 108,     //固件数据有误
    ErrorCode109 = 109,     //固件更新中断
    ErrorCode110 = 110,     //unuse
} ErrorCode;

typedef void(^BRTCompletionBlock)(NSError* error);
typedef void(^BRTUnsignedShortCompletionBlock)(unsigned short value, NSError* error);
typedef void(^BRTShortCompletionBlock)(short value, NSError* error);
typedef void(^BRTPowerCompletionBlock)(NSInteger value, NSError* error);
typedef void(^BRTBoolCompletionBlock)(BOOL value, NSError* error);
typedef void(^BRTStringCompletionBlock)(NSString* value, NSError* error);
typedef void(^BRTIntegerCompletionBlock)(NSInteger value, NSError* error);
typedef void(^BRTConnectCompletionBlock)(BOOL complete, NSError* error);

typedef void (^BRTDataCompletionBlock)(id data,NSError *error);


////////////////////////////////////////////////////////////////////
// Interface definition

@interface BRTBeaconDefinitions : NSObject

@end
