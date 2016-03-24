//
//  AdjustViewController.m
//  BRTExample
//
//  Created by thomasho on 14-7-31.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "AdjustViewController.h"
@interface AdjustViewController (){
    BOOL isStarting;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) NSMutableDictionary *rssis;

@end

@implementation AdjustViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self beaconAdjust:self.beacon];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scanBeacon];
}
- (void)scanBeacon
{
    NSString *mac = self.beacon.macAddress;
    __unsafe_unretained typeof(self) weakself = self;
    [BRTBeaconSDK startRangingWithUuids:@[self.beacon.proximityUUID] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        [beacons enumerateObjectsUsingBlock:^(BRTBeacon *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.macAddress isEqualToString:mac]) {
                [weakself beaconAdjust:obj];
                *stop = YES;
            }
        }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.beacon disconnectBeacon];
    [BRTBeaconSDK stopRangingBrightBeacons];
}
 - (void)beaconAdjust:(BRTBeacon*)beacon
{
    if (!self.rssis) {
        self.rssis = [NSMutableDictionary dictionary];
    }
    if (isStarting) {
        NSString *rssi = [NSString stringWithFormat:@"%d",beacon.rssi];
        NSString *count = [self.rssis valueForKey:rssi];
        if (count) {
            [self.rssis setObject:[NSString stringWithFormat:@"%d",count.intValue+1] forKey:rssi];
        }else{
            [self.rssis setObject:@"1" forKey:rssi];
        }
        [self adjustButtonClicked:nil];
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@",beacon.name];
    self.distanceLabel.text = [NSString stringWithFormat:@"RSSI:%d\n当前计算距离:%.2f米\n", beacon.rssi,[beacon.distance floatValue]];
}
- (IBAction)adjustButtonClicked:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected||!sender) {
        //adjust
        isStarting = YES;
            NSInteger all = 0;
            for (NSString *count in self.rssis.allValues) {
                all += count.integerValue;
            }
        if (all>0&&!(all%20)) {
            CGFloat avgrssi = 0.0;
            for (NSString *rssi in self.rssis.allKeys) {
                CGFloat delta = [[self.rssis valueForKey:rssi] floatValue]/all;
                avgrssi += delta*rssi.floatValue;
            }
            if ([[NSNumber numberWithFloat:avgrssi] integerValue]!=self.beacon.measuredPower.integerValue) {
                __unsafe_unretained typeof(self) weakself = self;
                [self.beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
                    if (connected) {
                        [weakself writeMpower:avgrssi];
                    }else{
                        isStarting = NO;
                        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:Lang(@"Er:%d", @"校准失败，连接设备不成功。Er:%d"),error.code] message:nil delegate:self cancelButtonTitle:Lang(@"Cancel", @"取消") otherButtonTitles: nil] show];
                    }
                }];
            }
        }
    }else{
        //stop
        self.rssis = [NSMutableDictionary dictionary];
        isStarting = NO;
    }
}
- (void)writeMpower:(NSInteger)mpower
{
    __unsafe_unretained typeof(self) weakself = self;
    [self.beacon writeBeaconValues:@{B_MEASURED: [NSNumber numberWithInteger:mpower]} withCompletion:^(BOOL complete,NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:error.domain message:nil delegate:self cancelButtonTitle:Lang(@"Cancel", @"取消") otherButtonTitles:Lang(@"Retry", @"重试"), nil] show];
        }else{
            [weakself disconnect];
        }
    }];
}
- (void)disconnect
{
    [self.beacon disconnectBeacon];
    [self scanBeacon];
}
- (IBAction)closeButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
