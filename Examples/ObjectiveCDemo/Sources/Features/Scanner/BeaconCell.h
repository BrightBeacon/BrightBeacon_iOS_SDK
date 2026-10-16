#import <UIKit/UIKit.h>
@import BrightSDK;

@interface BeaconCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *signalLabel;
@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, copy) void (^onConnect)(void);
- (void)render:(BRTBeacon *)row ble:(BOOL)ble enabled:(BOOL)enabled;
@end
