//
//  BRTBeaconUpdateInfo.h
//  BrightSDK
//
//  Version : 1.0.0
//  Created by Bright Beacon on 20/04/14.
//  Copyright (c) 2013 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRTBeaconUpdateInfo : NSObject

@property (nonatomic, strong) NSString* currentFirmwareVersion;
@property (nonatomic, strong) NSArray*  supportedHardware;

@end
