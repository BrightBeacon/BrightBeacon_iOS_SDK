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

#define SDK_VERSION @"3.0.0"

#define B_NAME @"name"
#define B_UUID @"uuid"
#define B_MAJOR @"major"
#define B_MINOR @"minor"
#define B_MEASURED @"mPower"
#define B_INTERVAL @"txInterval"
#define B_TX @"txPower"
#define B_LED @"ledState"
#define B_MODE @"pMode"
#define B_BATTERY_INTERVAL @"batteryInterval"
#define B_TEMPERATURE_INTERVAL @"temperatureInterval"


#define DEFAULT_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
#define DEFAULT_MAJOR 0
#define DEFAULT_MINOR 0
#define DEFAULT_MEASURED -65
#define DEFAULT_LED 1
#define DEFAULT_INTERVAL 400
#define DEFAULT_TX 2
#define DEFAULT_NAME  @"BrightBeacon"
#define DEFAULT_MODE 0

#define kNotifyConnect @"kNotifyConnect"
#define kNotifyDisconnect @"kNotifyDisconnect"

typedef enum : int
{
    DevelopMode=0,  //开发模式
    PublishMode,    //部署模式
} DevelopPublishMode;

typedef enum : int
{
    regionMonitorStateIn=0,
    regionMonitorStateInAndOut,
    regionMonitorStateInAndOutAndDisplay
} regionMonitorState;
/*
 kCLErrorLocationUnknown  = 0,         // location is currently unknown, but CL will keep trying
 kCLErrorDenied,                       // Access to location or ranging has been denied by the user
 kCLErrorNetwork,                      // general, network-related error
 kCLErrorHeadingFailure,               // heading could not be determined
 kCLErrorRegionMonitoringDenied,       // Location region monitoring has been denied by the user
 kCLErrorRegionMonitoringFailure,      // A registered region cannot be monitored
 kCLErrorRegionMonitoringSetupDelayed, // CL could not immediately initialize region monitoring
 kCLErrorRegionMonitoringResponseDelayed, // While events for this fence will be delivered, delivery will not occur immediately
 kCLErrorGeocodeFoundNoResult,         // A geocode request yielded no result
 kCLErrorGeocodeFoundPartialResult,    // A geocode request yielded a partial result
 kCLErrorGeocodeCanceled,              // A geocode request was cancelled
 kCLErrorDeferredFailed,               // Deferred mode failed
 kCLErrorDeferredNotUpdatingLocation,  // Deferred mode failed because location updates disabled or paused
 kCLErrorDeferredAccuracyTooLow,       // Deferred mode not supported for the requested accuracy
 kCLErrorDeferredDistanceFiltered,     // Deferred mode does not support distance filters
 kCLErrorDeferredCanceled,             // Deferred mode request canceled a previous request
	kCLErrorRangingUnavailable,           // Ranging cannot be performed
	kCLErrorRangingFailure,               // General ranging failure
 */
typedef enum : int
{
    ErrorCodeNone = 0,      //正常
    ErrorCodeUnKnown = 99,  //未知连接错误
    ErrorCode100 = 100,     //连接错误，APP KEY不正确
    ErrorCode101 = 101,     //未识别的设备，无法连入
    ErrorCode102 = 102,     //网络连接失败
    ErrorCode103 = 103,     //未检测到电量传感器(读取传感器特征失败)
    ErrorCode104 = 104,     //未检测到温度传感器、读取数据有误(读取传感器特征失败)
    ErrorCode105 = 105,     //当前版本固件不支持更新
    ErrorCode106 = 106,     //暂无版本更新，或未执行版本检测：checkFirmwareUpdateWithCompletion:
    ErrorCode107 = 107,     //固件下载失败，请重试
    ErrorCode108 = 108,     //固件数据有误
    ErrorCode109 = 109,     //固件更新中断
    ErrorCode110 = 110,     //unuse
} ErrorCode;

typedef enum : char
{
    BRTBeaconPowerLevelMinus23 = 0,
    BRTBeaconPowerLevelMinus6 = 1,
    BRTBeaconPowerLevelDefault = 2,
    BRTBeaconPowerLevelPlus4 = 3,
} BRTBeaconPower;

typedef void(^BRTCompletionBlock)(NSError* error);
typedef void(^BRTUnsignedShortCompletionBlock)(unsigned short value, NSError* error);
typedef void(^BRTShortCompletionBlock)(short value, NSError* error);
typedef void(^BRTPowerCompletionBlock)(BRTBeaconPower value, NSError* error);
typedef void(^BRTBoolCompletionBlock)(BOOL value, NSError* error);
typedef void(^BRTStringCompletionBlock)(NSString* value, NSError* error);
typedef void(^BRTIntegerCompletionBlock)(NSInteger value, NSError* error);
typedef void(^BRTConnectCompletionBlock)(BOOL connected, NSError* error);


////////////////////////////////////////////////////////////////////
// Interface definition

@interface BRTBeaconDefinitions : NSObject

@end
