//
//  BRTBeaconDefinitions.h
//  BrightSDK
//
//  Version : 1.3.0
//  Created by Marcin Klimek on 9/26/13.
//  Copyright (c) 2013 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRTBeaconUpdateInfo.h"

////////////////////////////////////////////////////////////////////
// Type and class definitions


typedef enum : char
{
    BRTBeaconPowerLevelMinus23 = 0,
    BRTBeaconPowerLevelMinus6 = 1,
    BRTBeaconPowerLevelDefault = 2,
    BRTBeaconPowerLevelPlus4 = 3,
} BRTBeaconPower;

typedef enum : int
{
    BRTBeaconFirmwarestateBoot,
    BRTBeaconFirmwarestateApp
} BRTBeaconFirmwarestate;

typedef enum : int
{
    BRTBeaconFirmwareUpdateNone,
    BRTBeaconFirmwareUpdateAvailable,
    BRTBeaconFirmwareUpdateNotAvailable
} BRTBeaconFirmwareUpdate;

typedef void(^BRTCompletionBlock)(NSError* error);
typedef void(^BRTFirmwareUpdateCompletionBlock)(BOOL updateAvailable, BRTBeaconUpdateInfo* updateInfo, NSError* error);
typedef void(^BRTUnsignedShortCompletionBlock)(unsigned short value, NSError* error);
typedef void(^BRTShortCompletionBlock)(short value, NSError* error);
typedef void(^BRTPowerCompletionBlock)(BRTBeaconPower value, NSError* error);
typedef void(^BRTBoolCompletionBlock)(BOOL value, NSError* error);
typedef void(^BRTStringCompletionBlock)(NSString* value, NSError* error);




////////////////////////////////////////////////////////////////////
// Interface definition

@interface BRTBeaconDefinitions : NSObject

@end
