//
//  RegionAddVC.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "RegionAddVC.h"
#import "BRTBeaconSDK.h"

@interface RegionAddVC ()

@property (weak, nonatomic) IBOutlet UITextField *TFUUID;
@property (weak, nonatomic) IBOutlet UITextField *TFMAJOR;
@property (weak, nonatomic) IBOutlet UITextField *TFMINOR;
@property (weak, nonatomic) IBOutlet UISwitch *SWIN;
@property (weak, nonatomic) IBOutlet UISwitch *SWOUT;
@property (weak, nonatomic) IBOutlet UISwitch *SWDISPLAY;


@end

@implementation RegionAddVC

- (void)viewDidLoad {
    [super viewDidLoad];

	self.TFUUID.text = DEFAULT_UUID;
}

- (IBAction)saveButtonClicked:(id)sender {
	BRTBeaconRegion *region = nil;
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.TFUUID.text];
	NSString *regionID = uuid.UUIDString;
	if (self.TFMAJOR.text.length) {
		NSNumber *major = @(self.TFMAJOR.text.integerValue);
		if (self.TFMINOR.text.length) {
			regionID = [regionID stringByAppendingFormat:@"%@,%@",self.TFMAJOR.text,self.TFMINOR.text];
			NSNumber *minor = @(self.TFMINOR.text.integerValue);
			region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid major:major.integerValue minor:minor.integerValue identifier:regionID];
		}else{
			regionID = [regionID stringByAppendingFormat:@"%@",self.TFMAJOR.text];
			region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid major:major.integerValue identifier:regionID];
		}
	}else{
		region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:regionID];
	}
	region.notifyOnEntry = self.SWIN.isOn;
	region.notifyOnExit = self.SWOUT.isOn;
	region.notifyEntryStateOnDisplay = self.SWDISPLAY.isOn;
	[BRTBeaconSDK startMonitoringForRegions:@[region]];
	[self.navigationController popViewControllerAnimated:YES];
}
@end
