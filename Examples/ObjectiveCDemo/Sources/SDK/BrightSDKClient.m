#import "BrightSDKClient.h"
@import BrightSDK;
@interface BrightSDKClient () <BRTBeaconDelegate>
@property (nonatomic, strong, nullable) BRTBeacon *connectedBeacon;
@property (nonatomic, strong) NSUUID *generation;
@property (nonatomic, assign) BOOL scanningStarted;
@property (nonatomic, assign) BOOL connectionEstablished;
@end
@implementation BrightSDKClient

- (instancetype)init {
    if (self = [super init]) {
        _generation = [NSUUID UUID];
    }
    return self;
}

- (void)startBLEWithOutput:(DemoUpdate)output {
    [self stop];
    self.scanningStarted = YES;
    NSUUID *generation = self.generation;
    [BRTBeaconSDK setInvalidTime:3];
    [BRTBeaconSDK setScanResponseTime:1];
    __weak typeof(self) weakSelf = self;
    [BRTBeaconSDK scanBleServices:nil
                     onCompletion:^(NSArray *beacons, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             typeof(self) self = weakSelf;
                             if (!self || ![generation isEqual:self.generation])
                                 return;
                             output(beacons ?: @[], error);
                         });
                     }];
}

- (void)startIBeaconWithUUID:(NSString *)uuid output:(DemoUpdate)output {
    [self stop];
    self.scanningStarted = YES;
    NSUUID *generation = self.generation;
    BRTBeaconRegion *region =
        [[BRTBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                            identifier:@"BrightSDK.Demo"];
    __weak typeof(self) weakSelf = self;
    [BRTBeaconSDK
        startRangingBeaconsInRegions:@[ region ]
                        onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                typeof(self) self = weakSelf;
                                if (!self || ![generation isEqual:self.generation])
                                    return;
                                // SDK 回调为 BRTBeacon，直接交给列表使用。
                                output(beacons ?: @[], error);
                            });
                        }];
}

- (void)connectBeacon:(BRTBeacon *)beacon
               appKey:(NSString *)appKey
           completion:(DemoConnection)completion {
    if (!beacon.isBrightBeacon || !beacon.peripheral) {
        completion(NO, @"该广播不支持 BrightSDK 连接。");
        return;
    }
    self.connectedBeacon.delegate = nil;
    [self.connectedBeacon disconnectBeacon];
    self.connectedBeacon = beacon;
    self.connectionEstablished = NO;
    beacon.delegate = self;
    NSUUID *generation = self.generation;
    __weak typeof(self) weakSelf = self;
    // No server prerequisite: the SDK uses the configured key during connection.
    [BrightSDKClient configureConnectionKey:appKey];
    [beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) self = weakSelf;
            if (!self || ![generation isEqual:self.generation])
                return;
            self.connectionEstablished = connected && !error;
            if (self.connectionEstablished)
                [BRTBeaconSDK stopScan];
            completion(connected && !error,
                       error
                           ? [NSString stringWithFormat:@"连接失败：%@", error.localizedDescription]
                       : connected ? @"设备连接成功"
                                   : @"设备未连接成功");
        });
    }];
}

+ (void)configureConnectionKey:(NSString *)appKey {
    NSString *key =
        [appKey stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [BRTBeaconSDK registerApp:key.length ? key : DEFAULT_KEY onCompletion:nil];
}

- (void)beaconDidDisconnect:(BRTBeacon *)beacon withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectedBeacon != beacon || !self.connectionEstablished)
            return;
        self.connectionEstablished = NO;
        if (self.onDisconnect)
            self.onDisconnect(error.localizedDescription ?: @"设备连接已断开");
    });
}

- (void)stop {
    self.generation = [NSUUID UUID];
    if (self.scanningStarted) {
        [BRTBeaconSDK stopScan];
        [BRTBeaconSDK stopRangingBeacons];
    }
    self.scanningStarted = NO;
    self.connectionEstablished = NO;
    self.connectedBeacon.delegate = nil;
    [self.connectedBeacon disconnectBeacon];
    self.connectedBeacon = nil;
}

@end
