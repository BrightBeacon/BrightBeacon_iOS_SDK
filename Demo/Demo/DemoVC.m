//
//  DemoVC.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "DemoVC.h"
#import "BRTBeaconSDK.h"

@interface DemoVC ()


@end

@implementation DemoVC

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [NSString stringWithFormat:@"演示（%@）",SDK_VERSION];
}

@end
