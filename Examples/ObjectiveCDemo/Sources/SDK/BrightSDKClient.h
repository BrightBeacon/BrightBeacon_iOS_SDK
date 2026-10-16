#import <Foundation/Foundation.h>
@import BrightSDK;
NS_ASSUME_NONNULL_BEGIN
typedef void (^DemoUpdate)(NSArray<BRTBeacon *> *devices, NSError *_Nullable error);
typedef void (^DemoConnection)(BOOL success, NSString *message);
/// Minimal SDK integration: scan, connect with optional key, and stop.
@interface BrightSDKClient : NSObject
@property (nonatomic, copy, nullable) void (^onDisconnect)(NSString *message);
- (void)startBLEWithOutput:(DemoUpdate)output;
- (void)startIBeaconWithUUID:(NSString *)uuid output:(DemoUpdate)output;
- (void)connectBeacon:(BRTBeacon *)beacon
               appKey:(NSString *)appKey
           completion:(DemoConnection)completion;
/// Empty / whitespace uses DEFAULT_KEY, and clears any previously configured key.
+ (void)configureConnectionKey:(NSString *)appKey;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
