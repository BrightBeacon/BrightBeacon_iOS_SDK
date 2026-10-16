#import <UIKit/UIKit.h>

@interface ScannerController : UIViewController
+ (NSString *)titleForBLE:(BOOL)ble;
+ (NSString *)explanationForBLE:(BOOL)ble;
- (instancetype)initWithBLE:(BOOL)ble;
@end
