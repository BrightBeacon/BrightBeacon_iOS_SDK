//
//  BRTBeacon.h
//  BrightSDK
//
//  Version : 1.3.0
//  Created by Marcin Klimek on 9/19/13.
//  Copyright (c) 2013 Bright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BRTBeaconDefinitions.h"

#define DEFAULT_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
#define DEFAULT_MAJOR 0
#define DEFAULT_MINOR 0
#define DEFAULT_MEASURED -55
#define DEFAULT_LED 1
#define DEFAULT_INTERVAL 250
#define DEFAULT_TX 2
#define DEFAULT_NAME  @"BrightBeacon"

@class BRTBeacon;

////////////////////////////////////////////////////////////////////
// Bright beacon delegate protocol


/**
 
 BRTBeaconDelegate defines beacon connection delegate mathods. Connection is asynchronous operation so you need to be prepared that eg. beaconDidDisconnectWith: method can be invoked without previous action.
 
 */

@protocol BRTBeaconDelegate <NSObject>

@optional

/**
 * Delegate method that indicates error in beacon connection.
 *
 * @param beacon reference to beacon object
 * @param error information about reason of error
 *
 * @return void
 */
- (void)beaconConnectionDidFail:(BRTBeacon*)beacon withError:(NSError*)error;

/**
 * Delegate method that indicates success in beacon connection.
 *
 * @param beacon reference to beacon object
 *
 * @return void
 */
- (void)beaconConnectionDidSucceeded:(BRTBeacon*)beacon;

/**
 * Delegate method that beacon did disconnect with device.
 *
 * @param beacon reference to beacon object
 * @param error information about reason of error
 *
 * @return void
 */
- (void)beaconDidDisconnect:(BRTBeacon*)beacon withError:(NSError*)error;

@end


////////////////////////////////////////////////////////////////////
// Interface definition

/**
 
 The BRTBeacon class represents a beacon that was encountered during region monitoring. You do not create instances of this class directly. The BRTBeaconManager object reports encountered beacons to its associated delegate object. You can use the information in a beacon object to identify which beacon was encountered.
 
 
BRTBeacon class contains basic Apple CLBeacon object reference as well as some additional functionality. It allows to  connect with Bright beacon to read / write its characteristics.
 
 */

@interface BRTBeacon : NSObject <CBPeripheralDelegate>

extern CBCentralManager *centralManager;

@property (nonatomic)           BRTBeaconFirmwarestate  firmwarestate;
@property (nonatomic, weak)     id <BRTBeaconDelegate>  delegate;

/////////////////////////////////////////////////////
// bluetooth beacon available when used with
// startBrightBeaconsDiscoveryForRegion:

@property (nonatomic, unsafe_unretained) NSInteger invalidTime;

/**
 *  macAddress
 *
 *  Discussion:
 *    Hardware MAC address of the beacon.
 */
@property (nonatomic, strong)   NSString*               macAddress;

/**
 *  name
 *
 *    name associated with the beacon.
 *
 */
@property (nonatomic, strong)   NSString*               name;

/**
 *  proximityUUID
 *
 *    Proximity identifier associated with the beacon.
 *
 */
@property (nonatomic, strong)   NSUUID*                 proximityUUID;

/**
 *  major
 *
 *    Most significant value associated with the region. If a major value wasn't specified, this will be nil.
 *
 */
@property (nonatomic, strong)   NSNumber*               major;

/**
 *  minor
 *
 *    Least significant value associated with the region. If a minor value wasn't specified, this will be nil.
 *
 */
@property (nonatomic, strong)   NSNumber*               minor;



/**
 *  rssi
 *
 *    Received signal strength in decibels of the specified beacon.
 *    This value is an average of the RSSI samples collected since this beacon was last reported.
 *
 */
@property (nonatomic)           NSInteger               rssi;

/**
 *  distance
 *
 *    Distance between phone and beacon calculated based on rssi and measured power.
 *
 */
@property (nonatomic, strong)   NSNumber*               distance;

/**
 *  proximity
 *
 *    The value in this property gives a general sense of the relative distance to the beacon. Use it to quickly identify beacons that are nearer to the user rather than farther away.
 */
@property (nonatomic)           CLProximity             proximity;

/**
 *  measuredPower
 *
 *    rssi value measured from 1m. This value is used for device calibration.
 */
@property (nonatomic, strong)   NSNumber*               measuredPower;

/**
 *  hardwareVersion
 *
 *    Reference of the device peripheral object.
 */
@property (nonatomic, strong)   CBPeripheral*           peripheral;

/////////////////////////////////////////////////////
// properties filled when read characteristic

/// @name Properties available after connection


/**
 *  firmwareUpdateInfo
 *
 *    Flag indicating connection status.
 */
@property (nonatomic, readonly)   BOOL                  isConnected;

/**
 *  power
 *
 *    Power of signal in dBm. Value available after connection with the beacon. It takes one of the values represented by BRTBeaconPower .
 */
@property (nonatomic, unsafe_unretained)   BRTBeaconPower           power;

/**
 *  advInterval
 *
 *    Advertising interval of the beacon. Value change from 50ms to 2000ms. Value available after connection with the beacon
 */
@property (nonatomic, strong)   NSNumber*               advInterval;

/**
 *  ledState
 *
 */
@property (nonatomic, unsafe_unretained)   BOOL          ledState;

/**
 *  hardwareVersion
 *
 *    Version of device hardware. Value available after connection with the beacon
 */
@property (nonatomic, strong)   NSString*               hardwareVersion;

/**
 *  firmwareVersion
 *
 *    Version of device firmware. Value available after connection with the beacon
 */
@property (nonatomic, strong)   NSString*               firmwareVersion;


/**
 *  firmwareUpdateInfo
 *
 *    Firmware update availability status. Value available after connection with the beacon and firmware version check.
 */
@property (readonly, nonatomic) BRTBeaconFirmwareUpdate firmwareUpdateInfo;


/// @name Connection handling methods


/**
 * Connect to particular beacon using bluetooth.
 * Connection is required to change values like
 * Major, Minor, Power and Advertising interval.
 *
 * @return void
 */
-(void)connectToBeacon;

/**
 * Disconnect device with particular beacon
 *
 * @return void
 */
-(void)disconnectBeacon;


/// @name Methods for reading beacon configuration


/**
 * Read name of connected beacon (Previous connection
 * required)
 *
 * @param completion block with name value as param
 *
 * @return void
 */
- (void)readBeaconNameWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * Read Proximity UUID of connected beacon (Previous connection
 * required)
 *
 * @param completion block with major value as param
 *
 * @return void
 */
- (void)readBeaconProximityUUIDWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * Read major of connected beacon (Previous connection
 * required)
 *
 * @param completion block with major value as param
 *
 * @return void
 */
- (void)readBeaconMajorWithCompletion:(BRTUnsignedShortCompletionBlock)completion;

/**
 * Read minor of connected beacon (Previous connection
 * required)
 *
 * @param completion block with minor value as param
 *
 * @return void
 */
- (void)readBeaconMinorWithCompletion:(BRTUnsignedShortCompletionBlock)completion;

/**
 * Read advertising interval of connected beacon (Previous connection
 * required)
 *
 * @param completion block with advertising interval value as param
 *
 * @return void
 */
- (void)readBeaconAdvIntervalWithCompletion:(BRTUnsignedShortCompletionBlock)completion;


/**
 * Read power of connected beacon (Previous connection
 * required)
 *
 * @param completion block with power value as param
 *
 * @return float value of beacon power
 */
- (void)readBeaconPowerWithCompletion:(BRTPowerCompletionBlock)completion;

/**
 * Read led state of connected beacon (Previous connection
 * required)
 *
 * @param completion block with led state value as param
 *
 * @return void
 */
- (void)readBeaconLedStateWithCompletion:(BRTBoolCompletionBlock)completion;

/**
 * Read MeasuredPower of connected beacon (Previous connection
 * required)
 *
 * @param completion block with MeasuredPower value as param
 *
 * @return void
 */
- (void)readBeaconMeasuredPowerWithCompletion:(BRTShortCompletionBlock)completion;

/**
 * Read firmware version of connected beacon (Previous connection
 * required)
 *
 * @param completion block with firmware version value as param
 *
 * @return void
 */
- (void)readBeaconFirmwareVersionWithCompletion:(BRTStringCompletionBlock)completion;

/**
 * Read hardware version of connected beacon (Previous connection
 * required)
 *
 * @param completion block with hardware version value as param
 *
 * @return void
 */
- (void)readBeaconHardwareVersionWithCompletion:(BRTStringCompletionBlock)completion;


/// @name Methods for writing beacon configuration

/**
 * Writes name param to bluetooth connected beacon.
 *
 * @param name beacon value
 * @param completion block handling operation completion
 *
 * @return void
 */
- (void)writeBeaconName:(NSString *)name withCompletion:(BRTStringCompletionBlock)completion;

/**
 * Writes Proximity UUID param to bluetooth connected beacon. Please  remember that If you change the UUID to your very own value anyone can read it, copy it and spoof your beacons. So if you are working on a mission critical application where security is an issue - be sure to implement it on your end. We are also working on a secure mode for our beacons and it will be included in one of the next firmware updates.
 *
 * @param pUUID new Proximity UUID value
 * @param completion block handling operation completion
 *
 * @return void
 */
- (void)writeBeaconProximityUUID:(NSString*)pUUID withCompletion:(BRTStringCompletionBlock)completion;

/**
 * Writes major param to bluetooth connected beacon.
 *
 * @param major major beacon value
 * @param completion block handling operation completion
 *
 * @return void
 */
- (void)writeBeaconMajor:(unsigned short)major withCompletion:(BRTUnsignedShortCompletionBlock)completion;

/**
 * Writes minor param to bluetooth connected beacon.
 *
 * @param minor minor beacon value
 * @param completion block handling operation completion
 *
 * @return void
 */
- (void)writeBeaconMinor:(unsigned short)minor withCompletion:(BRTUnsignedShortCompletionBlock)completion;

/**
 * Writes advertising interval (in milisec) of connected beacon.
 *
 * @param advertising interval of beacon (50 - 2000 ms)
 * @param completion block handling operation completion
 *
 * @return void
 */
- (void)writeBeaconAdvInterval:(unsigned short)interval withCompletion:(BRTUnsignedShortCompletionBlock)completion;


/**
 * Writes power of bluetooth connected beacon.
 *
 * @param power advertising beacon power (can take value from BRTBeaconPowerLevel1 / waak to BRTBeaconPowerLevel8 / strong)
 * @param completion block handling operation completion
 *
 * @return void
 */
- (void)writeBeaconPower:(BRTBeaconPower)power withCompletion:(BRTPowerCompletionBlock)completion;

/**
 * Writes led state of connected beacon (Previous connection
 * required)
 *
 * @param completion block with led state value as param
 *
 * @return void
 */
- (void)writeBeaconLedState:(BOOL)ledState withCompletion:(BRTBoolCompletionBlock)completion;

/**
 * Writes MeasuredPower of connected beacon (Previous connection
 * required)
 * @param MeasuredPower value as param
 * @param completion block with MeasuredPower value as param
 *
 * @return void
 */
- (void)writeBeaconMeasuredPower:(short)measurePower withCompletion:(BRTShortCompletionBlock)completion;

/// @name Firmware update handling methods

/**
 * Verifies if new firmware version is available for download
 * without any additional action. Internet connection
 * is required to pass this process.
 *
 * @param completion Block handling operation completion
 *
 * @return void
 */
-(void)checkFirmwareUpdateWithCompletion:(BRTFirmwareUpdateCompletionBlock)completion;

/**
 * Verifies if new firmware version is available for download
 * and updates firmware of connected beacon. Internet connection 
 * is required to pass this process.
 *
 * @param progress Block handling operation progress
 * @param completion Block handling operation completion
 *
 * @return void
 */
-(void)updateBeaconFirmwareWithProgress:(BRTStringCompletionBlock)progress
                          andCompletion:(BRTCompletionBlock)completion;

/**
 * resetBeaconToDefault
 *
 *
 * @return void
 */
-(void)resetBeaconToDefault;

/**
 * resetBeaconToDefault
 *
 * @return void
 */
- (void)resetSDKKEY;

@end
