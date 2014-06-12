//
//  BRTBeaconUpdateInfo.h
//  BrightSDK
//
//  Version : 1.3.0
//  Created by Marcin Klimek on 27/11/13.
//  Copyright (c) 2013 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRTBeaconUpdateInfo : NSObject

@property (nonatomic, strong) NSString* currentFirmwareVersion;
@property (nonatomic, strong) NSArray*  supportedHardware;

@end
