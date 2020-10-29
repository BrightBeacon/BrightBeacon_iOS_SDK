//
//  ScanInBackground.h
//  Demo
//
//  Created by thomasho on 2020/3/27.
//  Copyright © 2020 brightbeacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanInBackground : UIViewController <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;

@end

NS_ASSUME_NONNULL_END
