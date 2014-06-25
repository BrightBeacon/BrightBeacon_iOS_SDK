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


typedef enum : char
{
    BRTBeaconPowerLevelMinus23 = 0,
    BRTBeaconPowerLevelMinus6 = 1,
    BRTBeaconPowerLevelDefault = 2,
    BRTBeaconPowerLevelPlus4 = 3,
} BRTBeaconPower;

typedef void(^BRTCompletionBlock)(NSError* error);
//typedef void(^BRTFirmwareUpdateCompletionBlock)(BOOL updateAvailable, BRTBeaconUpdateInfo* updateInfo, NSError* error);
typedef void(^BRTUnsignedShortCompletionBlock)(unsigned short value, NSError* error);
typedef void(^BRTShortCompletionBlock)(short value, NSError* error);
typedef void(^BRTPowerCompletionBlock)(BRTBeaconPower value, NSError* error);
typedef void(^BRTBoolCompletionBlock)(BOOL value, NSError* error);
typedef void(^BRTStringCompletionBlock)(NSString* value, NSError* error);

////////////////////////////////////////////////////////////////////
// Interface definition

@interface BRTBeaconDefinitions : NSObject

@end
