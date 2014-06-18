iOS-SDK
=======

##BrightSDK
### Introduction

Bright SDK plays with Apple iBeacon technology, using Bright hardware beacons as well as Bright Virtual Beacon iOS Application. To find out more about it read API section on our website, please. You can review SDK documentation and check our Community Portal to get answers for most common questions related to our Hardware and Software.

## How to install
### From CocoaPods
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
## Docs
* [Current Documentation](//github.com/BrightBeacon/BrightBeacon_iOS_SDK/Documents/index.html)
* [Community for BrightBeacon](http://brtbeacon.com)