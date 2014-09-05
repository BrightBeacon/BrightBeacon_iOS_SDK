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
@property (strong, nonatomic) BRTBeacon *brtbeacon;
@property (strong, nonatomic) NSMutableDictionary *rssis;

@end

@implementation AdjustViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

 - (void)beaconAdjust:(BRTBeacon*)beacon
{
    if (!self.brtbeacon) {
        self.brtbeacon =  beacon;
        self.rssis = [NSMutableDictionary dictionary];
    }
    if (isStarting) {
        NSString *rssi = [NSString stringWithFormat:@"%ld",beacon.rssi];
        NSString *count = [self.rssis valueForKey:rssi];
        if (count) {
            [self.rssis setObject:[NSString stringWithFormat:@"%d",count.intValue+1] forKey:rssi];
        }else{
            [self.rssis setObject:@"1" forKey:rssi];
        }
        [self adjustButtonClicked:nil];
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@",beacon.name];
    self.distanceLabel.text = [NSString stringWithFormat:@"当前距离:%.2f米\nRSSI:%ld\nMajor:%@,Minor:%@\nMAC:%@\nmeasurePower:%@",[beacon.distance floatValue], beacon.rssi, beacon.major, beacon.minor ,beacon.macAddress,beacon.measuredPower];
}
- (IBAction)adjustButtonClicked:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected||!sender) {
        //adjust
        isStarting = YES;
//            NSArray *array = [self.rssis.allValues sortedArrayUsingSelector:@selector(compare:)];
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
            NSLog(@"%f",avgrssi);
            if ([[NSNumber numberWithFloat:avgrssi] integerValue]!=self.brtbeacon.measuredPower.integerValue) {
                __unsafe_unretained typeof(self) weakself = self;
                [self.brtbeacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
                    if (connected) {
                        [weakself.brtbeacon writeBeaconValues:@{B_MEASURED: [NSNumber numberWithFloat:avgrssi]} withCompletion:^(NSError *error) {
                            [weakself.brtbeacon disconnectBeacon];
                        }];
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
- (IBAction)closeButtonClicked:(id)sender
{
    NSLog(@"%@",self.presentingViewController.description);
    [[(UINavigationController*)self.presentingViewController topViewController] performSelector:@selector(setAdjustController:) withObject:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
