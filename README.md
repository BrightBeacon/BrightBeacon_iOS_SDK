iOS-SDK
=======

##BrightSDK
### 概述

智石开发包（BrightSDK）符合苹果的iBeacon协议、Google的eddystone协议，提供了扫描或管理iBeacon、eddystone设备、模拟iBeacon设备的API。你可以访问[智石官网（http://www.brtbeacon.com）](http://www.brtbeacon.com)了解更多信息，也可以查阅[SDK文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)或前往我们的[开发者社区（http://bbs.brtbeacon.com）](http://bbs.brtbeacon.com)交流和找到我们软硬件相关问题。

智石开发包需要手持设备硬件支持蓝牙4.0及其以上，并要求系统版本IOS6.0及其以上。
附：支持的IOS设备列表
iphone4s以上、
itouch5以上、
iPad3以上、
iPad mini均可以
详情见：[http://en.wikipedia.org/wiki/List_of_iOS_devices](http://en.wikipedia.org/wiki/List_of_iOS_devices)

##更新日志
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

##如何集成（任选其一）
###一、使用CocoaPods集成
添加以下代码到您Pod项目的Podfile文件：

```
	pod 'BrightSDK'
```
在Podfile文件目录运行命令：
(PS：请事先更新你本地的CocoaPods库：pod repo update，并pod install)

```
	pod update
```

###二、使用常规集成

使用如下步骤手动集成：
- 登录BrightSDK的[开发者网站](http://developer.brtbeacon.com)下载并解压最新版本的SDK。如果您还尚未下载SDK，请 [点击这里下载](http://developer.brtbeacon.com/index/documents.shtml) 或者前往 [http://developer.brtbeacon.com/index/documents.shtml](http://developer.brtbeacon.com/index/documents.shtml) 。解压后如下图<br/>
![Resize icon][1]<br/>
[1]: https://i.nfil.es/mz5ZGG.png "下载"
- 将BrightSDK的框架目录导入到您的工程中
将下载的SDK文件解压，拖动里面的BrightSDK文件夹到工程中，而不是下载的整个文件，这点请注意，如下图<br/>
![Resize icon][2]<br/>
[2]: http://i.nfil.es/53nveH.png "导入"

<br/>拖到工程中后，弹出以下对话框，勾选"Copy items into destination group's folder(if needed)"，并点击“Finish“按钮, 如图<br/>
![Resize icon][3]<br/>
[3]: http://i.nfil.es/RlqsnP.png "复制"

<br/>注意：请务必在上述步骤中选择“Create groups for any added folders”单选按钮组。如果你选择“Create folder references for any added folders”，一个蓝色的文件夹引用将被添加到项目并且将无法找到它的资源。
最终效果图：<br/>
![Resize icon][4]<br/>
[4]: http://i.nfil.es/y78Mqm.png "效果图"



- 注意：

1、BrightSDK可能需要以下本地IOS库：

```
	CoreBluetooth.framework
	CoreLocation.framework
```

2、如果出现头文件无法找到，前往 project settings 的 build settings，搜索Header Search Paths. 添加"$(SRCROOT)/../BrightSDK/Headers".


##如何调用
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

 - 扫描范围内所有BrightBeacon设备
 
 ```
//支持IOS6以上
 扫描BrightBeacon设备，uuids为NSUUID数组:IOS6.x该参数无效；IOS7.x该参数用于构造区域BRTBeaconRegion来实现扫描、广播融合模式，提高RSSI精度(注：留空则只开启蓝牙扫描，且无法扫描获取到设备UUID，可以通过连接读取)
 uuids:
	NSUUID数组，筛选需要的uuid设备
[BRTBeaconSDK startRangingWithUuids:uuids onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error){
}];
//
//仅支持IOS7以上，感知区域中BrightBeacon设备,regions为BRTBeaconRegion数组(留空则启用默认的UUID)
[BRTBeaconSDK startRangingBeaconsInRegions:regions onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error){
}];
 ```
 
 - 监听区域方法
 
 ```
 * 以下是在后台运行、完全退出程序监听区域的回调函数，请拷贝需要的回调到AppDelegate
监听失败回调
-(void)beaconManager:(BRTBeaconManager *)manager monitoringDidFailForRegion:(BRTBeaconRegion *)region withError:(NSError *)error{}
进入区域回调
-(void)beaconManager:(BRTBeaconManager *)manager didEnterRegion:(BRTBeaconRegion *)region{
	if(region.notifyOnEntry){
		//to do
	}
}
离开区域回调
-(void)beaconManager:(BRTBeaconManager *)manager didExitRegion:(BRTBeaconRegion *)region{
	if(region.notifyOnExit){
		//to do
	}
}
屏幕点亮区域检测、requestStateForRegions回调
-(void)beaconManager:(BRTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(BRTBeaconRegion *)region{
	if(region.notifyEntryStateOnDisplay){
		//to do
	}else if(region.notifyOnEntry){
		//to do
	}else if(region.notifyOnExit){
		//to do
	}
}
```
- 启动监听区域

```
 region：需要监听的区域，支持后台监听（<=20）
 　
     BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:BRT_PROXIMITY_UUID identifier:kUUID];
    region.notifyOnEntry = YES;//监听进入区域
    region.notifyOnExit = YES;//监听离开区域
    region.notifyEntryStateOnDisplay = YES;//锁屏唤醒时监听
    [BRTBeaconSDK startMonitoringForRegions:@[region]];
 ```
 
 - 请求指定区域状态
 
 ```
     [BRTBeaconSDK requestStateForRegions:@[region]];
 ```

## 相关文档或网站
* [集成文档](http://www.brtbeacon.com/home/document_ios.shtml)
* [API文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)
* [开发者社区](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)