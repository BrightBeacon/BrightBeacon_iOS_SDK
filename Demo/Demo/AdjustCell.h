//
//  AdjustCell.h
//  Demo
//
//  Created by thomasho on 17/3/8.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdjustCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblMac;
@property (nonatomic,weak) IBOutlet UILabel *lblRSSI;
@property (nonatomic,weak) IBOutlet UILabel *lblTimes;

- (void)startAnimating;
- (void)stopAnimating;

@end
