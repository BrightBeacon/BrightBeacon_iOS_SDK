iOS-SDK
=======

## BrightSDK
###  概述

智石开发包（BrightSDK）符合苹果的iBeacon协议、Google的eddystone协议，提供了扫描或管理iBeacon、eddystone设备、模拟iBeacon设备的API。你可以访问[智石官网（http://www.brtbeacon.com）](http://www.brtbeacon.com)了解更多信息，也可以查阅[SDK文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)或前往我们的[开发者社区（http://bbs.brtbeacon.com）](http://bbs.brtbeacon.com)交流和找到我们软硬件相关问题。

智石开发包需要手持设备硬件支持蓝牙4.0及其以上，并要求系统版本IOS7及其以上。
附：支持的IOS设备列表
iphone4s以上、
itouch5以上、
iPad3以上、
iPad mini均可以
详情见：[http://en.wikipedia.org/wiki/List_of_iOS_devices](http://en.wikipedia.org/wiki/List_of_iOS_devices)

## 更新日志
 *  3.4.7 优化区域监听，请使用regionHander:(2017.3.7)
 *  3.4.5 优化扫描(2017.1.23)
 *  3.4.4 增加单独iBeacon扫描(2016.8.12)
 *  3.4.3 优化扫描
 *  3.4.2 修复部分连接问题 (2016.5.17)
 *  3.4.1 新增beacon.flag标识位
 *  3.4.0 优化扫描大量设备出现异常
 *  3.3.9 修正050x配置参数
 *  3.3.8 修复030x连接即配置参数异常，修复0401固件升级
 *  3.3.7 连接优化，支持固件050x
 *  3.3.6 修复部分设备名乱码
 *  3.3.5 新增位置反馈
 *  3.3.4 新增自定义广播数据段、定频固件0313、CB系列040x固件支持
 *  3.3.3 支持Google的eddystone,修复ios6.0.x
 *  3.3.2 IOS9适配：主要修复030x无法连接配置

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
- 登录BrightSDK的[开发者网站](http://developer.brtbeacon.com)下载并解压最新版本的SDK。如果您还尚未下载SDK，请 [点击这里下载](http://developer.brtbeacon.com/index/documents.shtml) 或者前往 [http://developer.brtbeacon.com/index/documents.shtml](http://developer.brtbeacon.com/index/documents.shtml) 。解压后如下图<br/>
- 将BrightSDK的框架目录导入到您的工程中
将下载的SDK文件解压，拖动里面的BrightSDK文件夹到工程中
<br/>拖到工程中后，弹出以下对话框，勾选"Copy items into destination group's folder(if needed)"，并点击“Finish“按钮,

<br/>注意：请务必在上述步骤中选择“Create groups for any added folders”单选按钮组。如果你选择“Create folder references for any added folders”，一个蓝色的文件夹引用将被添加到项目并且将无法找到它的资源。
最终效果图：<br/>



- 注意：

1、BrightSDK可能需要以下本地IOS库：

```
	CoreBluetooth.framework
	CoreLocation.framework
```

2、如果出现头文件无法找到，前往 project settings 的 build settings，搜索Header Search Paths. 添加"$(SRCROOT)/../BrightSDK/include".


## 如何调用
`1、注册APPKEY`<br/>

- 登录BrightSDK的官方网站添加应用并获取 APPKEY。如果尚未注册，[请点击这里注册并创建应用 APPKEY](http://developer.brtbeacon.com)
- 初始化BrightSDK

打开*AppDelegate.m(*代表你的工程名字)  导入文件头BRTBeaconSDK.h

```
#import "BRTBeaconSDK.h"
```
在- (BOOL)application: didFinishLaunchingWithOptions:方法中调用registerApp方法来初始化SDK

```
[BRTBeaconSDK registerApp:(NSString *)appKey onCompletion:(BRTCompletionBlock)completion];
```
`2、常见的API调用`<br/>

 - 扫描Regions内所有iBeacon设备。

IOS7以上，通过GPS扫描iBeacon设备，支持后台扫描（可以扫描到CLBeacon参数proximityUUID、Major、Minor、proximity、accuracy、rssi），效率更高，建议使用该方法。

```
regions为BRTBeaconRegion数组(留空则默认的E2C56DB5-DFFB-48D2-B060-D0F5A71096E0)
[BRTBeaconSDK startRangingBeaconsInRegions:regions onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error){
}];
```
 - 扫描BrightBeacon设备、uuids内的iBeacon设备。
IOS6以上，蓝牙设备扫描融合（在第1点基础上，增加了允许连接配置、获取额外的参数如mac地址等功能），建议需要用于设备连接配置或特殊参数要求者使用。
uuids用于1中构造BRTBeaconRegion，启用GPS扫描iBeacon设备(注：留空或iBeacon设备的UUID参数不在此数组，则仅能通过蓝牙扫描获取部分数据，无法获取到设备的UUID，也不支持后台扫描)

```
 uuids:
	NSUUID数组，（即设备配置的UUID）
[BRTBeaconSDK startRangingWithUuids:uuids onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error){
}];
 ```
 
 - 监听区域方法（IOS7以上）

//如需后台监听区域，必须在随App启动的类中调用regionHander：;并且hander也必须启动自行初始化，保证监听到区域自启动软件时，能成功回调该类的Region相关函数。简约使用时，可以直接利用appdelegate类。

```
	[BRTBeaconSDK  regionHander:[RegionHander new]];
```

 * 以下是在后台运行、完全退出程序监听区域的回调函数，请拷贝需要的回调到RegionHander类

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

 region：需要监听的区域，支持后台监听（<=20)，当进入区域时，APP会自启动，你有至少10s处理相关逻辑。在ios8以上startMonitoringForRegions内会调取系统获取GPS权限。你也可以自行控制调取时机或权限类型。
 
```
  //ios8以上自行获取权限方式
 [[[BRTBeaconSDK Share] brtmanager] requestAlwaysAuthorization];
```
//监听区域示例
 
```
     BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:@"这里传人需要监听的iBeacon设备的UUID" identifier:@"区域唯一标识符，会覆盖已有相同id的区域"];
    region.notifyOnEntry = YES;//监听进入区域
    region.notifyOnExit = YES;//离开区域时回调
    region.notifyEntryStateOnDisplay = YES;//处于区域内，锁屏唤醒时回调
    [BRTBeaconSDK startMonitoringForRegions:@[region]];
 ```
 
 - 立即请求指定区域状态
 
 ```
     [BRTBeaconSDK requestStateForRegions:@[region]];
 ```
- 监听的所有区域；当前活跃的区域

```
[[[BRTBeaconSDK Share] brtmanager] monitoredRegions];
[[[BRTBeaconSDK Share] brtmanager] rangedRegions];
```
## 相关文档或网站
* [集成文档](http://www.brtbeacon.com/home/document_ios.shtml)
* [API文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)
* [开发者社区](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)