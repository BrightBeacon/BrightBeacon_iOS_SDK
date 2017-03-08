//
//  AdjustCell.m
//  Demo
//
//  Created by thomasho on 17/3/8.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "AdjustCell.h"

@interface AdjustCell ()

@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *ActivityIndicator;

@end

@implementation AdjustCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)startAnimating {
    self.ActivityIndicator.hidden = NO;
    [self.ActivityIndicator startAnimating];
}

- (void)stopAnimating {
    self.ActivityIndicator.hidden = YES;
    [self.ActivityIndicator stopAnimating];
}
@end
