iOS-SDK
=======

## BrightSDK
###  概述

智石开发包（BrightSDK）符合苹果的iBeacon协议、Google的eddystone协议，提供了扫描iBeacon、eddystone协议设备、配置BrightBeacon设备参数、模拟iBeacon等API。你可以访问[智石官网（http://www.brtbeacon.com）](http://www.brtbeacon.com)了解更多设备信息，或前往我们的[开发者社区（http://bbs.brtbeacon.com）](http://bbs.brtbeacon.com)交流和找到我们软硬件相关问题。

智石开发包需要手持设备硬件支持蓝牙4.0及其以上，并要求系统版本IOS7及其以上。
附：支持的IOS设备列表
iphone4s及以上、
itouch5及以上、
iPad3及以上、
iPad mini均可以
详情见：[http://en.wikipedia.org/wiki/List_of_iOS_devices](http://en.wikipedia.org/wiki/List_of_iOS_devices)

## 更新日志
 *  3.4.9 修复brtBeacons等API(2017.10)
 *  3.4.8 分离蓝牙、iBeacon扫描、区域监听回调API(2017.9)
 *  3.4.7 优化区域监听，请使用regionHander:(2017.3)

## 如何集成（任选其一）
### 一、使用CocoaPods集成
添加以下代码到您Pod项目的Podfile文件：

```
	pod 'BrightSDK'
```
在Podfile文件目录运行命令：
(PS：请事先更新你本地的CocoaPods库：pod repo update，并pod install)

```
	pod update
```

### 二、使用常规集成

使用如下步骤手动集成：

- 如果您还尚未下载SDK，请 [点击这里下载](https://github.com/BrightBeacon/BrightBeacon_iOS_SDK)，或在GitHub搜索BrightBeacon。
- 将下载的SDK文件解压，拖动里面的BrightSDK文件夹（内含include文件夹和.a库文件）到工程中
- 拖到工程中后，弹出以下对话框，勾选"Copy items into destination group's folder(if needed)"，并点击“Finish“按钮,

注意：请务必在上述步骤中选择“Create groups for any added folders”单选按钮组。如果你选择“Create folder references for any added folders”，一个蓝色的文件夹引用将被添加到项目并且将无法找到它的资源。



- 注意：如果出现头文件无法找到，前往 project settings 的 build settings，搜索Header Search Paths. 添加"$(SRCROOT)/../BrightSDK/include"，并检查实际目录地址。


## 如何调用
`1、注册APPKEY`<br/>

- 登录BrightSDK的官方网站添加应用并获取 APPKEY。如果尚未注册，[请点击这里注册并创建应用 APPKEY](http://open.brtbeacon.com)

```
#import "BRTBeaconSDK.h"

//如需配置设备，请注册appKey.
	[BRTBeaconSDK registerApp:(NSString *)appKey onCompletion:(BRTCompletionBlock)completion];
```
`2、常见的API调用`<br/>

 - 扫描Regions内所有iBeacon设备（IOS7及以上，需要定位权限，并打开蓝牙，传入扫描UUID）。

通过BRTBeaconRegion扫描iBeacon设备（可扫描到参数proximityUUID、Major、Minor、proximity、accuracy、rssi），建议用于iBeacon定位、签到、区域推送等场景。

```
regions为BRTBeaconRegion数组(默认使用：E2C56DB5-DFFB-48D2-B060-D0F5A71096E0)
	[BRTBeaconSDK startRangingBeaconsInRegions:regions onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error){
	}];
	//停止扫描iBeacons
	[BRTBeaconSDK stopRangingBeacons];
```
 - 扫描BrightBeacon蓝牙设备（仅需打开蓝牙，支持配置BrightBeacon设备）。
IOS6及以上，蓝牙设备扫描（允许连接配置、获取蓝牙参数如mac地址、电量等功能，无法获取iBeacon的proximityUUID、proximity），建议需要用于设备连接配置、巡检等场景。
(如需后台扫描，必须限定扫描的服务，例如180a)

```
 uuid:
	CBUUID数组，（设备广播数据中的服务，例：[[CBUUID alloc] initWithString:@"180a"]；留空时能扫描所有服务，但不支持后台扫描。）
	[BRTBeaconSDK scanBleServices:(NSArray<CBUUID *> *)services onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error){
	}];
	//停止扫描BrightBeacon
	[BRTBeaconSDK stopScan];
```
 
 - 监听区域方法（IOS7及以上，需要定位权限，并打开蓝牙）

//如需后台监听区域，请在随App启动的类（如：appDelegate的didFinishLaunch方法）中调用regionHandler;并且handler也必须启动自行初始化，保证监听到区域自启动软件时，handler能成功回调区域相关函数。简约使用时，可以直接使用appDelegate类。

```
	[BRTBeaconSDK  regionHandler:handler];
```

 * 以下是在前台运行、后台或完全退出程序监听区域的回调函数，请拷贝需要的回调到handler类

```
	进入区域回调
	-(void)beaconManager:(BRTBeaconManager *)manager didEnterRegion:(BRTBeaconRegion *)region{
	}
	离开区域回调
	-(void)beaconManager:(BRTBeaconManager *)manager didExitRegion:(BRTBeaconRegion *)region{
	}
	屏幕点亮区域检测、requestStateForRegions回调
	-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region{
	}
```
- 启动监听区域

 region：需要监听的区域，支持后台监听（<=20)，当进入、离开区域时，APP会后台自启动，你有约10s处理相关逻辑。在IOS8以上startMonitoringForRegions内会调取系统获取定位权限。你也可以自行控制调取弹窗时机或权限类型。
 
```
 	//ios8以上自行获取权限方式
 	[[[BRTBeaconSDK Share] brtmanager] requestAlwaysAuthorization];
```

```
	//监听区域示例
     BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:@"这里传人需要监听的iBeacon设备的UUID" identifier:@"区域唯一标识符，会覆盖已有相同id的区域"];
    region.notifyOnEntry = YES;//监听进入区域
    region.notifyOnExit = YES;//离开区域时回调
    region.notifyEntryStateOnDisplay = YES;//是否锁屏唤醒时，监测区域状态
    [BRTBeaconSDK startMonitoringForRegions:@[region]];
```
 
 - 立即监测区域状态
 
```
    [BRTBeaconSDK requestStateForRegions:@[region]];
```
- 监听的所有区域；当前活跃的区域

```
	[[[BRTBeaconSDK Share] brtmanager] monitoredRegions];
	[[[BRTBeaconSDK Share] brtmanager] rangedRegions];
```
## 相关文档或网站
* [集成文档](https://github.com/BrightBeacon/BrightBeacon_iOS_SDK)
* [API文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)
* [开发者社区](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)