//
//  RangeBeaconViewController.m
//  BRTExample
//
//  Created by JackRay on 14-5-27.
//  Copyright (c) 2014年 thomasho. All rights reserved.
//

#import "RangeBeaconViewController.h"
#import "BRTBeacon.h"
#import "BRTBeaconSDK.h"

@interface RangeBeaconViewController ()<BRTBeaconManagerDelegate>
@property (nonatomic, strong) IBOutlet UITableView     *tableview;
@property (nonatomic, strong) NSArray                  *beaconsArray;
@end

@implementation RangeBeaconViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [BRTBeaconSDK startRangingOption:RangingOptionOnRanged onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        self.beaconsArray = [beacons sortedArrayUsingComparator:^NSComparisonResult(BRTBeacon* obj1, BRTBeacon* obj2){
                return obj1.distance.floatValue>obj2.distance.floatValue?NSOrderedDescending:NSOrderedAscending;
        }];
        [self.tableview reloadData];
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [BRTBeaconSDK stopRangingBrightBeacons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beaconsArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@", beacon.name];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major:%@,Minor:%@,MAC:%@\nDis:%.2f,RSSI:%ld,mpower:%@", beacon.major, beacon.minor ,beacon.macAddress,[beacon.distance floatValue],beacon.rssi,beacon.measuredPower];
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:11]];
    
    /*switch (beacon.proximity) {
        case CLProximityUnknown: {
            cell.contentView.backgroundColor = [UIColor blueColor];
        }
            break;
            
        case CLProximityFar: {
            cell.contentView.backgroundColor = [UIColor blueColor];
        }
            break;
            
        case CLProximityImmediate: {
            cell.contentView.backgroundColor = [UIColor purpleColor];
        }
            break;
            
        case CLProximityNear: {
            cell.contentView.backgroundColor = [UIColor redColor];
        }
            break;
            
        default:
            break;
    }*/
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.beaconManager startBrightBeaconsDiscovery];
}
- (void)dealloc
{
    
}
@end
