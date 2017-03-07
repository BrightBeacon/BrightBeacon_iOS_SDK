//
//  ConfigDetailVC.h
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTBeaconSDK.h"

@interface ConfigDetailVC : UITableViewController

@property (nonatomic,strong) BRTBeacon *beacon;

@end
