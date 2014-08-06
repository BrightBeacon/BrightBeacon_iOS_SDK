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
#import "AdjustViewController.h"

@interface RangeBeaconViewController ()<BRTBeaconManagerDelegate>
@property (nonatomic, strong) IBOutlet UITableView     *tableview;
@property (nonatomic, strong) NSArray                  *beaconsArray;
@property (nonatomic ,strong) NSString *uniqueMacAddr;

@property (nonatomic,assign) AdjustViewController *adjustController;
@end

@implementation RangeBeaconViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [BRTBeaconSDK startRangingOption:RangingOptionOnRanged onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error)
     {
         if (!self.adjustController) {
             self.beaconsArray = [beacons sortedArrayUsingComparator:^NSComparisonResult(BRTBeacon* obj1, BRTBeacon* obj2){
                 return obj1.distance.floatValue>obj2.distance.floatValue?NSOrderedDescending:NSOrderedAscending;
             }];
             [self.tableview reloadData];

         }
         else{
             for (BRTBeacon *item in beacons) {
                 if ([item.macAddress isEqualToString:self.uniqueMacAddr]) {
                     [self.adjustController beaconAdjust:item];
                     break;
                 }
             }
         }
         
                  
     }];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    if(!self.adjustController){
        [BRTBeaconSDK stopRangingBrightBeacons];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.uniqueMacAddr = @"";
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beaconsArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major:%@,Minor:%@,MAC:%@\nDis:%.2f,RSSI:%d,mpower:%@", beacon.major, beacon.minor ,beacon.macAddress,[beacon.distance floatValue],beacon.rssi,beacon.measuredPower];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.uniqueMacAddr = [(BRTBeacon *)[self.beaconsArray objectAtIndex:indexPath.row] macAddress];
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    AdjustViewController *adjust = [st instantiateViewControllerWithIdentifier:@"AdjustViewController"];
        [self presentViewController:adjust animated:YES completion:nil];
    self.adjustController = adjust;
}
- (void)dealloc
{
    
}
@end
