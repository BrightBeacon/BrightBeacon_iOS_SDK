//
//  BRTBeaconManager.h
//  BrightSDK
//
//  Version : 1.3.0
//  Created by Marcin Klimek on 9/18/13.
//  Copyright (c) 2013 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BRTBeaconRegion.h"
#import "BRTBeacon.h"
#import "BRTRegion.h"

//#define kUUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
//#define kUUID   @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
//#define kUUID   @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
//#define BRT_PROXIMITY_UUID             [[NSUUID alloc] initWithUUIDString:kUUID]
//#define BRT_MACBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"08D4A950-80F0-4D42-A14B-D53E063516E6"]
//#define BRT_IOSBEACON_PROXIMITY_UUID   [[NSUUID alloc] initWithUUIDString:@"8492E75F-4FD6-469D-B132-043FE94921D8"]

CBCentralManager *centralManager;

@class BRTBeaconManager;

/**
 
 The BRTBeaconManagerDelegate protocol defines the delegate methods to respond for related events.
 */

@protocol BRTBeaconManagerDelegate <NSObject>

@optional

/**
 * Delegate method invoked during ranging.
 * Allows to retrieve NSArray of all discoverd beacons
 * represented with BRTBeacon objects.
 *
 * @param manager Bright beacon manager
 * @param beacons all beacons as BRTBeacon objects
 * @param region Bright beacon region
 *
 * @return void
 */
- (void)beaconManager:(BRTBeaconManager *)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(BRTBeaconRegion *)region;

/**
 * Delegate method invoked wehen ranging fails
 * for particular region. Related NSError object passed.
 *
 * @param manager Bright beacon manager
 * @param region Bright beacon region
 * @param error object containing error info
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
rangingBeaconsDidFailForRegion:(BRTBeaconRegion *)region
           withError:(NSError *)error;


/**
 * Delegate method invoked wehen monitoring fails
 * for particular region. Related NSError object passed.
 *
 * @param manager Bright beacon manager
 * @param region Bright beacon region
 * @param error object containing error info
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
monitoringDidFailForRegion:(BRTBeaconRegion *)region
           withError:(NSError *)error;
/**
 * Method triggered when iOS device enters Bright 
 * beacon region during monitoring.
 *
 * @param manager Bright beacon manager
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
      didEnterRegion:(BRTBeaconRegion *)region;


/**
 * Method triggered when iOS device leaves Bright
 * beacon region during monitoring.
 *
 * @param manager Bright beacon manager
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
       didExitRegion:(BRTBeaconRegion *)region;

/**
 * Method triggered when Bright beacon region state
 * was determined using requBRTStateForRegion:
 *
 * @param manager Bright beacon manager
 * @param state Bright beacon region state
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)beaconManager:(BRTBeaconManager *)manager
     didDetermineState:(CLRegionState)state
             forRegion:(BRTRegion *)region;

/**
 * Method triggered when device starts advertising
 * as iBeacon.
 *
 * @param manager Bright beacon manager
 * @param error info about any error
 *
 * @return void
 */
-(void)beaconManagerDidStartAdvertising:(BRTBeaconManager *)manager
                                  error:(NSError *)error;

/**
 * Delegate method invoked to handle discovered
 * BRTBeacon objects using CoreBluetooth framework
 * in particular region.
 *
 * @param manager Bright beacon manager
 * @param beacon BRTBeacon object
 *
 * @return void
 */
- (void)beaconManager:(BRTBeaconManager *)manager
          didDiscoverBeacon:(BRTBeacon *)beacon;

/**
 * Delegate method invoked when CoreBluetooth based
 * discovery process fails.
 *
 * @param manager Bright beacon manager
 * @param region Bright beacon region
 *
 * @return void
 */
- (void)beaconManagerDidFailDiscovery:(BRTBeaconManager *)manager;

@end



/**
 
 The BRTBeaconManager class defines the interface for handling and configuring the Bright beacons and get related events to your application. You use an instance of this class to BRTablish the parameters that describes each beacon behavior. You can also use a beacon manager object to retrieve all beacons in range.
 
 A beacon manager object provides support for the following location-related activities:
 
 * Monitoring distinct regions of interBRT and generating location events when the user enters or leaves those regions (works in background mode).
 * Reporting the range to nearby beacons and ther distance for the device.
 
 */

@interface BRTBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id <BRTBeaconManagerDelegate> delegate;

/**
 Allows to avoid beacons with unknown state (proximity == 0), when ranging. Default value is NO.
 */
@property (nonatomic) BOOL avoidUnknownStateBeacons;

@property (nonatomic, strong) BRTBeaconRegion*         virtualBeaconRegion;


/**
 * Delegate method register developer key
 *
 * @param appKey Bright beacon developer key
 *
 * @return void
 */
+ (void)registerApp:(NSString *)appKey;

/// @name CoreLocation based iBeacon monitoring and ranging methods

/**
 * Range all Bright beacons that are visible in range.
 * Delegate method beaconManager:didRangeBeacons:inRegion: 
 * is used to retrieve found beacons. Returned NSArray contains 
 * BRTBeacon objects.
 *
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)startRangingBeaconsInRegion:(BRTBeaconRegion*)region;

/**
 * Start monitoring for particular region.
 * Functionality works in the background mode as well.
 * Every time you enter or leave region appropriet
 * delegate method inovked: beaconManager:didEnterRegtion:
 * and beaconManager:didExitRegion:
 *
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)startMonitoringForRegion:(BRTBeaconRegion*)region;

/**
 * Stops ranging Bright beacons.
 *
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)stopRangingBeaconsInRegion:(BRTBeaconRegion*)region;

/**
 * Unsubscribe application from iOS monitoring of
 * Bright beacon region.
 *
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)stopMonitoringForRegion:(BRTBeaconRegion *)region;

/**
 * Allows to validate current state for particular region
 *
 * @param region Bright beacon region
 *
 * @return void
 */
-(void)requestStateForRegion:(BRTBeaconRegion *)region;

/// @name Turning device into iBeacon

/**
 * Allows to turn device into virtual Bright beacon.
 *
 * @param proximityUUID proximity UUID beacon value
 * @param major minor beacon value
 * @param minor major beacon value
 * @param identifier unique identifier for you region
 *
 * @return void
 */
-(void)startAdvertisingWithProximityUUID:(NSUUID *)proximityUUID
                                   major:(CLBeaconMajorValue)major
                                   minor:(CLBeaconMinorValue)minor
                              identifier:(NSString*)identifier
                                   power:(NSNumber *)power;

/**
 * Stop beacon advertising
 *
 * @return void
 */
-(void)stopAdvertising;


/// @name CoreBluetooth based utility methods


/**
 * Start beacon discovery process based on CoreBluetooth 
 * framework. Method is useful for older beacons discovery 
 * that are not advertising as iBeacons.
 *
 *
 * @return void
 */
-(void)startBrightBeaconsDiscovery;


/**
 * Stops CoreBluetooth based beacon discovery process.
 *
 * @return void
 */
-(void)stopBrightBeaconDiscovery;

@end

