/*
 
 Copyright (c) 2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

#import "ConfigBeaconViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ConfigBeaconViewController ()<UIScrollViewDelegate>
{
    UInt16 advertisingInterval;
}

- (IBAction)defaultClick:(id)sender;
- (IBAction)saveClick:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *UUIDText;
@property (weak, nonatomic) IBOutlet UITextField *majorText;
@property (weak, nonatomic) IBOutlet UITextField *minorText;
@property (weak, nonatomic) IBOutlet UITextField *measuredPowerText;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *TXSegment,*TXPlusSegment;
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;
@property (weak, nonatomic) IBOutlet UISlider *intervalSlider;
@property (weak, nonatomic) IBOutlet UIStepper *intervalStepper;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UITextField *tf_eddystone_url;
@property (nonatomic,strong) IBOutlet UIButton *btn_mode;

- (IBAction)intervalChanged:(id)sender;
- (IBAction)intervalStepPressed:(id)sender;
- (IBAction)readBatteryButtonPressed:(id)sender;

@end

@implementation ConfigBeaconViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

//    [self.tf_eddystone_url setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self refreshValues];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [super viewWillDisappear:animated];
    [self.beacon disconnectBeacon];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods

- (IBAction)intervalChanged:(id)sender {
    int ms = [self.intervalSlider value];
    advertisingInterval = ms*50;
    self.intervalStepper.value = advertisingInterval;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
}

- (IBAction)intervalStepPressed:(id)sender {
    int ms = [self.intervalStepper value];
    advertisingInterval = ms;
    self.intervalSlider.value = ms/50.0;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
}

- (IBAction)defaultClick:(id)sender {
    [self.UUIDText setText:DEFAULT_UUID];
    [self.majorText setText:[NSString stringWithFormat:@"%d", DEFAULT_MAJOR]];
    [self.minorText setText:[NSString stringWithFormat:@"%d", DEFAULT_MINOR]];
    [self.measuredPowerText setText:[NSString stringWithFormat:@"%d", DEFAULT_MEASURED]];
    [self.nameText setText:DEFAULT_NAME];
    advertisingInterval = DEFAULT_INTERVAL;
    self.intervalSlider.value = advertisingInterval/50.0;
    self.intervalStepper.value = advertisingInterval;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
    
    if ([self.beacon isSupport:BrtSupportsCC254x]) {
        [self.TXSegment setSelectedSegmentIndex:DEFAULT_TX];
    }else{
        [self.TXPlusSegment setSelectedSegmentIndex:DEFAULT_TX_PLUS];
    }
    self.btn_mode.tag = 0;
    [self.btn_mode setTitle:@"iBeacon" forState:UIControlStateNormal];
    [self.beacon resetSDKKEY]; //reset SDK key to default,allow another SDK key connect
}
- (IBAction)saveClick:(id)sender {
    NSMutableDictionary *values =[NSMutableDictionary dictionaryWithDictionary:@{B_UUID: self.UUIDText.text,
                             B_MAJOR:self.majorText.text,
                             B_MINOR:self.minorText.text,
                             B_NAME:self.nameText.text,
                             B_MEASURED:self.measuredPowerText.text,
                             B_TX:[NSString stringWithFormat:@"%d",[self.beacon isSupport:BrtSupportsCC254x]?self.TXSegment.selectedSegmentIndex:self.TXPlusSegment.selectedSegmentIndex+1],
                             B_INTERVAL:[NSString stringWithFormat:@"%d",advertisingInterval]}];
    if ([self.beacon isSupport:BrtSupportsAli]) {
        [values setValue:[NSString stringWithFormat:@"%d",self.btn_mode.tag] forKey:B_BroadcastMode];
        NSString *macRegex = @"[a-zA-z]+://[^\\s]*";
        NSPredicate *macTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", macRegex];
        if([macTest evaluateWithObject:self.tf_eddystone_url.text])[values setValue:self.tf_eddystone_url.text forKey:B_EddystoneURL];
    }
    BOOL flag = [self.nameText.text isEqualToString:self.beacon.name];
    [self.beacon writeBeaconValues:values withCompletion:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:error.domain message:nil delegate:nil cancelButtonTitle:Lang(@"OK", @"确定") otherButtonTitles: nil] show];
        }else{
            [self.beacon disconnectBeacon];
            if (flag||[self.beacon isSupport:BrtSupportsUpdateName]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [self performSelector:@selector(updatename) withObject:nil afterDelay:.3];
            }
        }
    }];
}
- (void)updatename
{
    [self.beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
        [self.beacon disconnectBeacon];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)refreshValues
{
    self.UUIDText.text = self.beacon.proximityUUID.UUIDString;
    self.majorText.text = self.beacon.major.stringValue;
    self.minorText.text = self.beacon.minor.stringValue;
    self.measuredPowerText.text = self.beacon.measuredPower.stringValue;
    self.nameText.text = self.beacon.name;
    if ([self.beacon isSupport:BrtSupportsCC254x]) {
        [self.TXSegment setSelectedSegmentIndex:self.beacon.power];
    }else{
        [self.TXPlusSegment setSelectedSegmentIndex:self.beacon.power];
    }
    
    advertisingInterval = self.beacon.advInterval.shortValue;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
    self.intervalSlider.value = advertisingInterval/50.0;
    self.intervalStepper.value = advertisingInterval;
    self.batteryLabel.text = [NSString stringWithFormat:@"%d%%",self.beacon.battery.unsignedShortValue];
    self.tempLabel.text = [NSString stringWithFormat:@"%d℃",self.beacon.temperature.unsignedShortValue];
    [self.beacon readBeaconFirmwareVersionWithCompletion:^(NSString *value, NSError *error) {
        self.versionLabel.text = value;
    }];

    if ([self.beacon isSupport:BrtSupportsEddystone]) {
        //        [self.sw_Ali setOn:self.brtBeacon.isAliMode];
        //        [self.sw_AliUUID setOn:self.brtBeacon.isAliUUID];
        switch (self.beacon.broadcastMode) {
            case Broadcast_iBeacon_Only:
                [self.btn_mode setTitle:@"iBeacon" forState:UIControlStateNormal];
                break;
            case Broadcast_iBeacon_eddystone_Url:
                [self.btn_mode setTitle:@"iBeacon+eddystoneURL" forState:UIControlStateNormal];
                break;
            case Broadcast_iBeacon_eddystone_Uid:
                [self.btn_mode setTitle:@"iBeacon+eddystoneUID" forState:UIControlStateNormal];
                break;
            case Broadcast_eddystone_Url_Only:
                [self.btn_mode setTitle:@"eddystoneURL" forState:UIControlStateNormal];
                break;
            case Broadcast_eddystone_Url_Uid:
                [self.btn_mode setTitle:@"eddystoneUID+URL" forState:UIControlStateNormal];
                break;
            case Broadcast_eddystone_Uid_Only:
                [self.btn_mode setTitle:@"eddystoneUID" forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        self.tf_eddystone_url.text = self.beacon.eddystone_Url;
    }
}
- (void)dealloc
{
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
- (IBAction)eddy2ibeaconButtonClicked:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:Lang(@"Select", @"选择广播模式") delegate:self cancelButtonTitle:Lang(@"Cancel", @"取消") destructiveButtonTitle:nil otherButtonTitles:@"iBeacon",@"iBeacon+EddystoneUrl",@"iBeacon+EddystoneUid", @"EddystoneUrl",@"EddystoneUid",Lang(@"EddystoneUid+Url", @"EddystoneUid+Url"), nil] showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
        if (actionSheet.cancelButtonIndex!=buttonIndex) {
            [self.btn_mode setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
            self.btn_mode.tag = [@[@"0",@"5",@"4",@"3",@"2",@"6"][buttonIndex] integerValue];
        }
}
@end
