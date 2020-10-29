//
//  ConfigVC.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "ConfigVC.h"
#import "BRTBeaconSDK.h"
#import "ConfigDetailVC.h"

@interface ConfigVC () {
	UIRefreshControl *rf;
}

@property (nonatomic,strong) NSMutableSet *dataSet;
@property (nonatomic,strong) NSArray *beaconSortByRSSI;
@property (nonatomic,strong) BRTBeacon *beaconHold;

@end

@implementation ConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];

	self.dataSet = [NSMutableSet set];

	[self refesh];

	rf = [[UIRefreshControl alloc] init];
	[rf addTarget:self action:@selector(refesh) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:rf];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BRTBeaconSDK stopScan];
}

- (void)refesh{
	[rf endRefreshing];
	//这里的UUID用于开启GPS扫描iBeacon融合所需。
	//蓝牙扫描能获取智石设备的mac地址等额外设备数据，并支持连接配置。
    CBUUID *uuid = [CBUUID UUIDWithString:@"180a"];
	[BRTBeaconSDK scanBleServices:@[uuid] onCompletion:^(NSArray<BRTBeacon *> *beacons, NSError *error) {
        NSLog(@"ble:%@",beacons.firstObject.macAddress);
		[self.dataSet addObjectsFromArray:beacons];
		static NSInteger count = 0;
		if (count%5) {
			self.beaconSortByRSSI = [self.dataSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(BRTBeacon *obj1, BRTBeacon *obj2) {
				return obj1.rssi<obj2.rssi;
			}];
			[self.tableView reloadData];
            self.title = [NSString stringWithFormat:@"蓝牙设备(%ld)",self.beaconSortByRSSI.count];
		}
		count ++;
	}];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.beaconSortByRSSI.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

	BRTBeacon *beacon = self.beaconSortByRSSI[indexPath.row];
	cell.textLabel.text = [NSString stringWithFormat:@"%@  MAC:%@",beacon.name,beacon.macAddress];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Major:%@,Minor:%@",beacon.major,beacon.minor];
	((UILabel*)cell.accessoryView).text = [NSString stringWithFormat:@"%ld",(long)beacon.rssi];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.beaconHold = self.beaconSortByRSSI[indexPath.row];
	[SVProgressHUD showWithStatus:@"正在连接..."];
	[self.beaconHold connectToBeaconWithCompletion:^(BOOL complete, NSError *error) {
		if (complete) {
			[SVProgressHUD dismiss];
			[self performSegueWithIdentifier:@"detail" sender:nil];
		}else{
			NSLog(@"%@",error);
			[SVProgressHUD showErrorWithStatus:error.description];
		}
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[ConfigDetailVC class]]) {
		[segue.destinationViewController setValue:self.beaconHold forKey:@"beacon"];
	}
}
@end
