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

#import "BRTBeaconSDK.h"

@interface ConfigBeaconViewController () <UITableViewDelegate,UIAlertViewDelegate,BRTBeaconDelegate , UITableViewDataSource,BRTBeaconManagerDelegate>
{
    UInt16 advertisingInterval;
}

@property (weak, nonatomic) IBOutlet UIButton *defaultButton;
- (IBAction)defaultClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)saveClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *deviceView;

@property (weak, nonatomic) IBOutlet UITextField *UUIDText;
@property (weak, nonatomic) IBOutlet UITextField *majorText;
@property (weak, nonatomic) IBOutlet UITextField *minorText;
@property (weak, nonatomic) IBOutlet UITextField *measuredPowerText;
@property (weak, nonatomic) IBOutlet UISwitch *LEDSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *TXSegment;
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;
@property (weak, nonatomic) IBOutlet UISlider *intervalSlider;
- (IBAction)intervalChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *intervalStepper;

@property (strong, nonatomic) NSArray *beaconArray;
@property (strong, nonatomic) UITableView *beaconsTableView;

@property (strong, nonatomic) BRTBeacon *brtBeacon;

- (IBAction)intervalStepPressed:(id)sender;

@end

@implementation ConfigBeaconViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.beaconsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.beaconsTableView.delegate = self;
    self.beaconsTableView.dataSource = self;
    
    [self.view addSubview:self.beaconsTableView];
    __unsafe_unretained typeof(self) weakself = self;
    [BRTBeaconSDK startRangingOption:RangingOptionOnBeaconChange onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        [weakself reloadData:beacons];
    }];
    
    [self showDeviceDetails:false];
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (void)reloadData:(NSArray*)beacons
{
    self.beaconArray = [beacons sortedArrayUsingComparator:^NSComparisonResult(BRTBeacon* obj1, BRTBeacon* obj2){
        return obj1.distance.floatValue>obj2.distance.floatValue?NSOrderedDescending:NSOrderedAscending;
    }];
    [self.beaconsTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    
    [super viewWillDisappear:animated];
    [BRTBeaconSDK stopRangingBrightBeacons];
    [self.brtBeacon disconnectBeacon];
    self.brtBeacon.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)showDeviceDetails:(bool) show
{
    self.beaconsTableView.hidden = show;
    self.deviceView.hidden = !show;
    self.saveButton.hidden = !show;
    
    if (show) {
        [self.defaultButton setTitle:@"Default" forState:UIControlStateNormal];
    }
    else{
        [self.defaultButton setTitle:@"back" forState:UIControlStateNormal];
        
        [[BRTBeaconSDK BRTBeaconManager] startBrightBeaconsDiscovery];
    }
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
    if (self.saveButton.hidden) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self.deviceView endEditing:YES];
    [self.UUIDText setText:DEFAULT_UUID];
    [self.majorText setText:[NSString stringWithFormat:@"%d", DEFAULT_MAJOR]];
    [self.minorText setText:[NSString stringWithFormat:@"%d", DEFAULT_MINOR]];
    [self.measuredPowerText setText:[NSString stringWithFormat:@"%d", DEFAULT_MEASURED]];
    [self.LEDSwitch setOn:DEFAULT_LED];
    [self.nameText setText:DEFAULT_NAME];
    advertisingInterval = DEFAULT_INTERVAL;
    self.intervalSlider.value = advertisingInterval/50.0;
    self.intervalStepper.value = advertisingInterval;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
    [self.TXSegment setSelectedSegmentIndex:DEFAULT_TX];
}
- (IBAction)saveClick:(id)sender {
    NSDictionary *values = @{B_UUID: self.UUIDText.text,
                             B_MAJOR:self.majorText.text,
                             B_MIOR:self.minorText.text,
                             B_NAME:self.nameText.text,
                             B_MEASURED:self.measuredPowerText.text,
                             B_TX:[NSString stringWithFormat:@"%d",self.TXSegment.selectedSegmentIndex],
                             B_INTERVAL:[NSString stringWithFormat:@"%d",advertisingInterval]};
    [self.brtBeacon writeBeaconValues:values withCompletion:^(NSError *error) {
        [self.brtBeacon disconnectBeacon];
        [self showDeviceDetails:NO];
    }];
}

#pragma UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.beaconArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BRTBeacon *beacon = [self.beaconArray objectAtIndex:indexPath.row];
    
    NSString *identifier = beacon.macAddress;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",beacon.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"UDID:%@ MAC:%@ major:%@  minor:%@  mpower:%@ distance:%@ RSSI:%ld",beacon.proximityUUID.UUIDString,beacon.macAddress,beacon.major,beacon.minor,beacon.measuredPower,beacon.distance,beacon.rssi];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.brtBeacon = [self.beaconArray objectAtIndex:indexPath.row];
    self.brtBeacon.delegate = self;
    [BRTBeaconSDK stopRangingBrightBeacons];
    
    __unsafe_unretained typeof(self) weakself = self;
    [self.brtBeacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
        if(connected){
            [weakself refreshValues];
        }else{
            if (error.code == 7) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"连接APPKEY不正确，无法连入" delegate:weakself cancelButtonTitle:@"关闭" otherButtonTitles: nil] show];
            }else{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"连接已断开！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                [alert performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:1];
            }
            NSLog(@"error:%@",error.description);
        }
    }];
    // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)refreshValues
{
    [self showDeviceDetails:YES];
    self.UUIDText.text = self.brtBeacon.proximityUUID.UUIDString;
    self.majorText.text = self.brtBeacon.major.stringValue;
    self.minorText.text = self.brtBeacon.minor.stringValue;
    self.measuredPowerText.text = self.brtBeacon.measuredPower.stringValue;
    self.nameText.text = self.brtBeacon.name;
    [self.TXSegment setSelectedSegmentIndex:self.brtBeacon.power];
    
    advertisingInterval = self.brtBeacon.advInterval.shortValue;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
    self.intervalSlider.value = advertisingInterval/50;
    self.intervalStepper.value = advertisingInterval/5;
}
- (void)dealloc
{
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
