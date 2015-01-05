//
//  VirtualViewController.m
//  BRTExample
//
//  Created by thomasho on 14-12-31.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "VirtualViewController.h"
#import "BRTBeaconSDK.h"
@interface VirtualViewController ()
@property (weak, nonatomic) IBOutlet UITextField *Uuid;
@property (weak, nonatomic) IBOutlet UITextField *Major;
@property (weak, nonatomic) IBOutlet UITextField *Minor;
@property (weak, nonatomic) IBOutlet UIButton    *Button;

@end

@implementation VirtualViewController

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
    } else {
        [[BRTBeaconSDK BRTBeaconManager] startAdvertisingWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.Uuid.text] major:self.Major.text.integerValue minor:self.Minor.text.integerValue identifier:@"virtualBeacon" power:@-65];

        NSString *UUIDMAJORMINOR = [NSString stringWithFormat:@"%@:%@:%@",self.Uuid.text,self.Major.text,self.Minor.text];
        [[NSUserDefaults standardUserDefaults] setValue:UUIDMAJORMINOR forKey:@"virtualBeacon"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    sender.selected = !sender.selected;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
