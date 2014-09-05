iOS-SDK
=======

##BrightSDK
### Introduction

Bright SDK plays with Apple iBeacon technology, using Bright hardware beacons as well as Bright Virtual Beacon iOS Application. To find out more about it read API section on our website, please. You can review SDK documentation and check our Community Portal to get answers for most common questions related to our Hardware and Software.

Support Bluetooth4.0 (above iOS 6.0).

## How to install
### From CocoaPods
Remember to update your local repo
```
pod repo update
```
Add the following line to your Podfile:

	pod 'BrightSDK'


Then run the following command in the same directory as your Podfile:

	pod update
	
### Normal way
Alternatively, you can install manually. Follow steps described below:

1. Copy BrightSDK directory (containing libBrightSDK.a and Headers) into your project directory.

2. Open your project settings and go to Build Phase tab. In the Link library with binaries section click +. In the popup window click add another at the bottom and select libBrightSDK.a library file.

3. In addition BrightSDK requires following native iOS frameworks:

    ```
	CoreBluetooth.framework
	CoreLocation.framework
	SystemConfiguration.framework
    ```

4. Go to Build Settings section of project settings and search for Header Search Paths. Add line containing "$(SRCROOT)/../BrightSDK/Headers".

Congratulations! You are done.
## How to use
###Scan BrightBeacons
```
    [BRTBeaconSDK startRangingOption:RangingOptionOnRanged uuids:nil onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        if (!error) {
        	//beacons: all brigthbeacons in all regions
        	//region: current region
        	//error: error info
        }
    }];
    //uuid limit
    [BRTBeaconSDK startRangingOption:RangingOptionOnRanged uuids:[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"]] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
        if (!error) {
        	//beacons: all brigthbeacons in all regions
        	//region: current region
        	//error: error info
        }
    }];
    
```
## Docs
* [Current Documentation](http://brtbeacon.com/developers_ios.html)
* [API Documentation](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)
* [BBS for BrightBeacon](http://bbs.brtbeacon.com)