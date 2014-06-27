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

#import "BRTBeaconManager.h"

@interface ConfigBeaconViewController () <UITableViewDelegate,BRTBeaconDelegate , UITableViewDataSource,BRTBeaconManagerDelegate>
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

@property (strong, nonatomic) NSMutableArray *beaconArray;
@property (strong, nonatomic) UITableView *beaconsTableView;

@property (strong, nonatomic) BRTBeaconManager *beaconManager;
@property (strong, nonatomic) BRTBeacon *brtBeacon;

- (IBAction)intervalStepPressed:(id)sender;

@end

@implementation ConfigBeaconViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.beaconArray = [[NSMutableArray alloc] init];
    self.beaconsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.beaconsTableView.delegate = self;
    self.beaconsTableView.dataSource = self;
    
    [self.view addSubview:self.beaconsTableView];
    
    self.beaconManager = [[BRTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    [self showDeviceDetails:false];
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    
    [super viewWillDisappear:animated];
    [self.beaconManager stopBrightBeaconDiscovery];
    [self.brtBeacon disconnectBeacon];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)isAllWrite:(NSInteger)count{
    NSLog(@"%ld",(long)count);
    if (count == 7) {
        [self.brtBeacon disconnectBeacon];
        [self showDeviceDetails:NO];
    }
}

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
        
        [self.beaconManager startBrightBeaconsDiscovery];
    }
}

#pragma mark - IBAction Methods

- (IBAction)intervalChanged:(id)sender {
    int ms = [self.intervalSlider value];
    advertisingInterval = ms * 50;
    self.intervalSlider.value = ms;
    self.intervalStepper.value = ms * 10;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
}

- (IBAction)intervalStepPressed:(id)sender {
    int ms = [self.intervalStepper value];
    advertisingInterval = ms * 5;
    self.intervalSlider.value = ms / 10;
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
    self.intervalSlider.value = advertisingInterval/50;
    self.intervalStepper.value = advertisingInterval/5;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
    [self.TXSegment setSelectedSegmentIndex:DEFAULT_TX];
}

- (IBAction)saveClick:(id)sender {
    
    [self.view endEditing:YES];
    
    __block NSInteger writeCount = 0;
    
    [self.brtBeacon writeBeaconProximityUUID:[self.UUIDText text] withCompletion:^(NSString *value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
    
    int major = [[self.majorText text] intValue];
    [self.brtBeacon writeBeaconMajor:major withCompletion:^(unsigned short value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
    
    int minor = [[self.minorText text] intValue];
    [self.brtBeacon writeBeaconMinor:minor withCompletion:^(unsigned short value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
    
    int measured = [[self.measuredPowerText text] intValue];
    [self.brtBeacon writeBeaconMeasuredPower:measured withCompletion:^(short value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
    
    [self.brtBeacon writeBeaconName:[self.nameText text] withCompletion:^(NSString *value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
    
    [self.brtBeacon writeBeaconAdvInterval:advertisingInterval withCompletion:^(unsigned short value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
    
    [self.brtBeacon writeBeaconPower:self.TXSegment.selectedSegmentIndex withCompletion:^(BRTBeaconPower value, NSError *error) {
        [self isAllWrite:++writeCount];
    }];
}

#pragma mark --BRTBeaconManagerDelegate
- (void)beaconManager:(BRTBeaconManager *)manager didDiscoverBeacon:(BRTBeacon *)beacon{
    BOOL add = YES;
    //NSLog(@"%@",beacon.macAddress);
    for (BRTBeacon *item in self.beaconArray) {
        if ([item.macAddress isEqual:beacon.macAddress]) {
            add = NO;
            break;
        }
    }
    if (add) {
        [self.beaconArray addObject:beacon];
        
        [self.beaconsTableView reloadData];
    }
    
}

#pragma mark -- BRTBeaconDelegate

- (void)beaconConnectionDidSucceeded:(BRTBeacon *)beacon{
    [self showDeviceDetails:YES];
    
    self.brtBeacon = beacon;
    
    self.UUIDText.text = beacon.proximityUUID.UUIDString;
    self.majorText.text = beacon.major.stringValue;
    self.minorText.text = beacon.minor.stringValue;
    self.measuredPowerText.text = beacon.measuredPower.stringValue;
    self.nameText.text = beacon.name;
    [self.TXSegment setSelectedSegmentIndex:beacon.power];
    
    advertisingInterval = beacon.advInterval.shortValue;
    [self.intervalLabel setText:[NSString stringWithFormat:@" %dms", (unsigned int)advertisingInterval]];
    self.intervalSlider.value = advertisingInterval/50;
    self.intervalStepper.value = advertisingInterval/5;
}

- (void)beaconDidDisconnect:(BRTBeacon *)beacon withError:(NSError *)error{
    
}

- (void)beaconConnectionDidFail:(BRTBeacon *)beacon withError:(NSError *)error{
    
}

#pragma UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.beaconArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BRTBeacon *beacon = [self.beaconArray objectAtIndex:indexPath.row];
    
    NSString *identifier = beacon.macAddress;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    
    cell.textLabel.text = beacon.name;
    cell.detailTextLabel.text = beacon.macAddress;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BRTBeacon *beacon = [self.beaconArray objectAtIndex:indexPath.row];
    beacon.delegate = self;
    [self.beaconManager stopBrightBeaconDiscovery];
    [beacon connectToBeacon];
    // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
    
}

@end
