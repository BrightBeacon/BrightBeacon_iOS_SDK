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

#define BRT_SDK_KEY @"E71E63CE42A40F3D43B3E47C64344075"

@interface ViewController ()<BRTBeaconManagerDelegate>



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [BRTBeaconManager registerApp:BRT_SDK_KEY];
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (IBAction)back:(UIStoryboardSegue *)segue
{
    //back here
}
@end
