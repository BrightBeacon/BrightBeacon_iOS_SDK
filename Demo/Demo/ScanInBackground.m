//
//  ScanInBackground.m
//  Demo
//
//  Created by thomasho on 2020/3/27.
//  Copyright © 2020 brightbeacon. All rights reserved.
//

#import "ScanInBackground.h"
#import "BRTBeaconSDK.h"

@implementation ScanInBackground

- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    if (@available(iOS 9.0, *))
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager startUpdatingLocation];
    
    //扫描iBeacon参数：（UUID major minor accuracy rssi等参见CLBeacon参数列表）
    [BRTBeaconSDK startRangingBeaconsInRegions:@[DEFAULT_UUID] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        NSLog(@"后台扫描到iBeacon:%@",beacons);
    }];
    //扫描BrightBeacon（后台扫描需指定服务特征180a)参数，（major minor rssi macAddress measurePower等参见不需要连接参数列表）
    [BRTBeaconSDK scanBleServices:@[[CBUUID UUIDWithString:@"180a"]] onCompletion:^(NSArray<BRTBeacon *> *beacons, NSError *error) {
        NSLog(@"后台蓝牙扫描(需要与iBeacon扫描同启)：%@",beacons.firstObject.macAddress);
    }];
}

#pragma mark 定位成功
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    double lat = newLocation.coordinate.latitude;
    double lon = newLocation.coordinate.longitude;
    NSLog(@"后台定位，用于常驻后台：lat:%f,lon:%f",lat,lon);
}
 
#pragma mark 定位失败
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"error:%@",error);
}
@end
