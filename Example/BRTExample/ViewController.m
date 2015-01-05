//
//  ViewController.m
//  BRTExample
//
//  Created by thomasho on 14-4-3.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "ViewController.h"
#import "BRTBeaconManager.h"
#import "BRTBeacon.h"


@interface ViewController ()<BRTBeaconManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"virtual"]) {
        //nothing to do
    }else{
        [segue.destinationViewController setValue:[NSNumber numberWithInteger:[sender tag]] forKey:@"type"];
    }
}
@end
