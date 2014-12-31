//
//  AdjustViewController.h
//  BRTExample
//
//  Created by thomasho on 14-7-31.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BRTBeacon.h"
#import <BrightSDK/BRTBeacon.h>
@interface AdjustViewController : UIViewController
- (void)beaconAdjust:(BRTBeacon*)beacon;
@end
