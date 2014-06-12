//
//  RangeBeaconViewController.m
//  BRTExample
//
//  Created by JackRay on 14-5-27.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "RangeBeaconViewController.h"
#import "BRTBeaconManager.h"
#import "BRTBeacon.h"

#define defaultUUID   @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"

@interface RangeBeaconViewController ()<BRTBeaconManagerDelegate>
@property (nonatomic, strong) IBOutlet UITableView     *tableview;
@property (nonatomic, strong) BRTBeaconManager         *beaconManager;
@property (nonatomic, strong) BRTBeaconRegion          *region;
@property (nonatomic, strong) NSArray                  *beaconsArray;
@end

@implementation RangeBeaconViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[BRTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[BRTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:defaultUUID]
                                                      identifier:@"BrtSampleRegion"];
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    [self.beaconManager startRangingBeaconsInRegion:self.region];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - BRTBeaconManager delegate

- (void)beaconManager:(BRTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(BRTBeaconRegion *)region
{
    NSLog(@"%@",beacons.description);
    self.beaconsArray = beacons;
    [self.tableview reloadData];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beaconsArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    /*
     * Fill the table with beacon data.
     */
    BRTBeacon *beacon = [self.beaconsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"UUID: %@", beacon.proximityUUID.UUIDString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@ ,Distance: %.2f", beacon.major, beacon.minor ,[beacon.distance floatValue]];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:11]];
    
    switch (beacon.proximity) {
        case CLProximityUnknown: {
            self.view.backgroundColor = [UIColor blueColor];
        }
            break;
            
        case CLProximityFar: {
            self.view.backgroundColor = [UIColor blueColor];
        }
            break;
            
        case CLProximityImmediate: {
            self.view.backgroundColor = [UIColor purpleColor];
        }
            break;
            
        case CLProximityNear: {
            self.view.backgroundColor = [UIColor redColor];
        }
            break;
            
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.beaconManager startBrightBeaconsDiscovery];
}

@end
