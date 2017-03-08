//
//  VirtualViewController.m
//  BRTExample
//
//  Created by thomasho on 14-12-31.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "VirtualVC.h"
#import "BRTBeaconSDK.h"

@interface VirtualVC ()

@property (weak, nonatomic) IBOutlet UITextField *Uuid;
@property (weak, nonatomic) IBOutlet UITextField *Major;
@property (weak, nonatomic) IBOutlet UITextField *Minor;
@property (weak, nonatomic) IBOutlet UIButton    *Button;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@end

@implementation VirtualVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *uuidmm = [[NSUserDefaults standardUserDefaults] valueForKey:@"virtualBeacon"];
    self.Button.selected = !!uuidmm;
    if (uuidmm) {
        NSArray *array = [uuidmm componentsSeparatedByString:@":"];
        self.Uuid.text = array[0];
        self.Major.text = array[1];
        self.Minor.text  = array[2];
    }else{
        self.Uuid.text = DEFAULT_UUID;
    }
}

- (IBAction)virtualButtonClicked:(UIButton*)sender {
    if (sender.selected) {
        [[BRTBeaconSDK BRTBeaconManager] stopAdvertising];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"virtualBeacon"];
        [self.ImageView.layer removeAllAnimations];
        self.ImageView.transform = CGAffineTransformIdentity;
    } else {
        [[BRTBeaconSDK BRTBeaconManager] startAdvertisingWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.Uuid.text] major:self.Major.text.integerValue minor:self.Minor.text.integerValue identifier:@"virtualBeacon" power:@-65];

        NSString *UUIDMAJORMINOR = [NSString stringWithFormat:@"%@:%@:%@",self.Uuid.text,self.Major.text,self.Minor.text];
        [[NSUserDefaults standardUserDefaults] setValue:UUIDMAJORMINOR forKey:@"virtualBeacon"];

        [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionRepeat animations:^{
            self.ImageView.transform = CGAffineTransformMakeScale(5, 5);
        } completion:^(BOOL finished) {
        }];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    sender.selected = !sender.selected;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
