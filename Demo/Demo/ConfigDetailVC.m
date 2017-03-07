//
//  ConfigDetailVC.m
//  Demo
//
//  Created by thomasho on 17/2/24.
//  Copyright © 2017年 brightbeacon. All rights reserved.
//

#import "ConfigDetailVC.h"

typedef NS_ENUM(NSUInteger, SettingType) {
	SettingTypeTX,
	SettingTypeTXINTERVAL,
	SettingTypeMPOWER,
};

@interface ConfigDetailVC ()<UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) UIPickerView* valuePicker;
@property (nonatomic,strong) UIToolbar* toolBar;

@end

@implementation ConfigDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self refreshButtonClicked];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.beacon disconnectBeacon];
}
- (void)dealloc {
	NSLog(@"dealloc");
}
#pragma mark - **************** 刷新读取按钮

- (IBAction)refreshButtonClicked {
	[self.beacon readBeaconValuesCompletion:^(BRTBeacon *beacon, NSError *error) {
		[self.tableView reloadData];
	}];
}
#pragma mark - **************** Getter
- (UIPickerView *)valuePicker {
	if (!_valuePicker) {
		_valuePicker = [[UIPickerView alloc]init];
		_valuePicker.delegate = self;
		_valuePicker.dataSource = self;
		_valuePicker.showsSelectionIndicator = YES;
		_valuePicker.backgroundColor = [UIColor whiteColor];
	}
	return _valuePicker;
}

- (UIToolbar *)toolBar {
	if (!_toolBar) {
		UIToolbar *foodToolBar=[[UIToolbar alloc]init];
		foodToolBar.barTintColor=[UIColor grayColor];
		foodToolBar.frame=CGRectMake(0, 0, 320, 38);
		UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked:)];
		[doneBtn setTintColor:[UIColor whiteColor]];
		UIBarButtonItem *spaceBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		foodToolBar.items=@[spaceBtn,doneBtn];
		_toolBar = foodToolBar;
	}
	return _toolBar;
}

#pragma mark - **************** PickerView

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (pickerView.tag) {
		case SettingTypeTX:return 8;
		case SettingTypeTXINTERVAL:return 12;
		case SettingTypeMPOWER:return 80;
	}
	return 0;
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	switch (pickerView.tag) {
		case SettingTypeTX:
			return @[@"-30dBm",@"-20dBm",@"-16dBm",@"-12dBm",@"-8dBm",@"-4dBm",@"0dBm",@"+4dBm"][row];//@"发射功率越大，信号越强";
		case SettingTypeTXINTERVAL:
			return @[@"100ms",@"152.5ms()",@"211.25ms()",@"318.75ms()",@"417.5ms()",@"546.25ms()",@"760ms()",@"852.5ms()",@"1022.5ms()",@"2000ms(2s)",@"4000ms(4s)",@"10000ms(10s)"][row];//@"发射间隔越小，信号越稳定";
		case SettingTypeMPOWER:
			return [NSString stringWithFormat:@"%ld",-90+row];//@"测量功率是iBeacon距离标尺(1米处RSSI)";
	}
	return @"";
}

#pragma mark - **************** TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	self.valuePicker.tag = textField.tag;
	[self.valuePicker reloadAllComponents];
	return YES;
}

#pragma mark - **************** TextField Done

- (IBAction)doneButtonClicked:(id)sender {
	[self.view endEditing:YES];
	NSInteger row = [self.valuePicker selectedRowInComponent:0];
	NSDictionary *dicForWrite = nil;
	switch (self.valuePicker.tag) {
		case SettingTypeTX:{
			NSString *value = @[@"-30dBm",@"-20dBm",@"-16dBm",@"-12dBm",@"-8dBm",@"-4dBm",@"0dBm",@"+4dBm"][row];
			dicForWrite = @{B_TX:@(value.integerValue) };
		}
			break;
		case SettingTypeTXINTERVAL:{
			NSString *value = @[@"100ms",@"152.5ms()",@"211.25ms()",@"318.75ms()",@"417.5ms()",@"546.25ms()",@"760ms()",@"852.5ms()",@"1022.5ms()",@"2000ms(2s)",@"4000ms(4s)",@"10000ms(10s)"][row];
			dicForWrite = @{B_INTERVAL:@(value.integerValue)};
		}
			break;
		case SettingTypeMPOWER:{
			dicForWrite = @{B_MEASURED:@(-90+row)};
		}
			break;
	}
	[self.beacon writeBeaconValues:dicForWrite withCompletion:^(BOOL complete, NSError *error) {
		if (complete) {
			[SVProgressHUD showSuccessWithStatus:@"修改成功"];
		}else{
			[SVProgressHUD showErrorWithStatus:error.description];
		}
	}];
}
#pragma mark - **************** TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (indexPath.row == 4||indexPath.row == 5 || indexPath.row == 6) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"cellwithtext" forIndexPath:indexPath];
	}else{
		cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	}
	UITextField *tf = (UITextField *)cell.accessoryView;
	if (tf) {
		tf.delegate = self;
		tf.inputAccessoryView = self.toolBar;
		tf.inputView = self.valuePicker;
	}
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"UUID";
			cell.detailTextLabel.text = self.beacon.proximityUUID.UUIDString;
			break;
		case 1:
			cell.textLabel.text = @"Major";
			cell.detailTextLabel.text = self.beacon.major.stringValue;
			break;
		case 2:
			cell.textLabel.text = @"Minor";
			cell.detailTextLabel.text = self.beacon.minor.stringValue;
			break;
		case 3:
			cell.textLabel.text = @"名称";
			cell.detailTextLabel.text = self.beacon.name;
			break;
		case 4:
			cell.textLabel.text = @"发射功率";
			tf.text = @(self.beacon.power).stringValue;
			tf.tag = SettingTypeTX;
			break;
		case 5:
			cell.textLabel.text = @"发射间隔";
			tf.text = self.beacon.advInterval.stringValue;
			tf.tag = SettingTypeTXINTERVAL;
			break;
		case 6:
			cell.textLabel.text = @"测量功率";
			tf.text = self.beacon.measuredPower.stringValue;
			tf.tag = SettingTypeMPOWER;
			break;
		case 7:
			cell.textLabel.text = @"电量";
			cell.detailTextLabel.text = self.beacon.battery.stringValue;
			break;
		case 8:
			cell.textLabel.text = @"温度";
			cell.detailTextLabel.text = self.beacon.temperature.stringValue;
			break;
		case 9:
			cell.textLabel.text = @"加密部署";
			cell.detailTextLabel.text = @(self.beacon.mode).stringValue;
			break;

		default:
			break;
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0:
		case 1:
		case 2:
		case 3:
		case 9:
		{
			BOOL isMode = indexPath.row == 9;
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:cell.textLabel.text message:isMode?@"必须设置您的appKey，才能修改加密部署。":nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
			alert.tag = indexPath.row;
			if (!isMode) {
				alert.alertViewStyle = UIAlertViewStylePlainTextInput;
				[[alert textFieldAtIndex:0] setText:cell.detailTextLabel.text];
			}
			[alert show];
		}
			break;
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (velocity.y<0) {
		[self.view endEditing:YES];
	}
}

#pragma mark - **************** AlertView

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
		return;
	}
	[SVProgressHUD showWithStatus:@"正在写入..."];
	NSString *value = [alertView textFieldAtIndex:0].text;
	NSDictionary *dicForWrite = nil;
	switch (alertView.tag) {
		case 0:dicForWrite = @{B_UUID:value};break;
		case 1:dicForWrite = @{B_MAJOR:value};break;
		case 2:dicForWrite = @{B_MINOR:value};break;
		case 3:dicForWrite = @{B_NAME:value};break;
		case 4:dicForWrite = @{B_TX:value}; break;
		case 5:dicForWrite = @{B_INTERVAL:value}; break;
		case 6:dicForWrite = @{B_MEASURED:value}; break;
		case 9:dicForWrite = @{B_MODE:@(1-self.beacon.mode)}; break;
		default:break;
	}
	[self.beacon writeBeaconValues:dicForWrite withCompletion:^(BOOL complete, NSError *error) {
		if (complete) {
			[SVProgressHUD showSuccessWithStatus:@"修改成功"];
		}else{
			[SVProgressHUD showErrorWithStatus:error.description];
		}
	}];
}

@end
