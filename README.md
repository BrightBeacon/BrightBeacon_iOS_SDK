iOS-SDK
=======

##BrightSDK
### 概述

智石开发包（BrightSDK）符合苹果的iBeacon技术，提供了扫描或管理Beacon设备或模拟iBeacon设备的API。你可以访问[智石官网（http://www.brtbeacon.com）](http://www.brtbeacon.com)了解更多信息，也可以查阅SDK文档或前往我们的[开发者社区（http://bbs.brtbeacon.com）](http://bbs.brtbeacon.com)交流和找到我们软硬件相关问题。

智石开发包需要手持设备支持蓝牙4.0及其以上，并IOS6.0及其以上系统。


##如何集成（任选其一）
###一、使用CocoaPods集成
添加以下代码到您Pod项目的Podfile文件：

```
	pod 'BrightSDK'
```
在Podfile文件目录运行命令：
(PS：请事先更新你本地的CocoaPods库：pod repo update)

```
	pod update
```

###二、使用常规集成
使用如下步骤手动集成：

1、复制BrightSDK目录（包含 libBrightSDK.a 和 Headers）到你的项目目录

2、打开你的project setting->build phase,在Link library with binaries点击+，在弹出框里边选择libBrightSDK.a

3、注意BrightSDK需要以下本地IOS库：

```
	CoreBluetooth.framework
	CoreLocation.framework
	SystemConfiguration.framework
```
4、前往 project settings 的 build settings，搜索Header Search Paths. 添加"$(SRCROOT)/../BrightSDK/Headers".

恭喜，集成完毕.

##如何调用
`1、注册APPKEY`<br/>

- 登录BrightSDK的官方网站添加应用并获取 APPKEY。如果尚未注册，[请点击这里注册并创建应用 APPKEY](http://developer.brtbeacon.com)
- 初始化BrightSDK

打开*AppDelegate.m(*代表你的工程名字)  导入文件头BRTBeaconManager.h

```
#import "BRTBeaconManager.h"
```
在- (BOOL)application: didFinishLaunchingWithOptions:方法中调用registerApp方法来初始化SDK

```
[BRTBeaconManager registerApp:YOUR_APPKEY];
```
`2、常见的API调用`<br/>

 - 扫描范围内所有BrightBeacon设备
 
 ```
//支持IOS6以上
 扫描BrightBeacon设备，uuids为NSUUID数组:IOS6.x该参数无效；IOS7.x该参数用于构造区域BRTBeaconRegion来实现扫描、广播融合模式，提高RSSI精度(注：留空则只开启蓝牙扫描)
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
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    region.notifyEntryStateOnDisplay = YES;
    [BRTBeaconSDK startMonitoringForRegions:@[region]];
 ```
 
 - 请求指定区域状态
 
 ```
     [BRTBeaconSDK requestStateForRegions:@[region]];
 ```
 - 连接Bright Beacon
 
 ```
 	//连接前务必已经使用对应的APPKEY，否则会连接失败
 	//连接设备
     [beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
        if(connected){
        	//连接成功
        }
    }];
    //写入数据
        NSDictionary *values = @{B_UUID: <VALUE>,
                             B_MAJOR:<VALUE>,
                             B_MINOR:<VALUE>,
                             B_NAME:<VALUE>,
                             B_MEASURED:<VALUE>,
                             B_TX:<VALUE>,
                             B_MODE:<VALUE>,
                             B_INTERVAL:<VALUE>};
    [beacon writeBeaconValues:values withCompletion:^(NSError *error) {
    	if(!error){
    		//写人成功
    	}
    }];
 ```

## 相关文档或网站
* [集成文档](http://www.brtbeacon.com/home/document_ios.shtml)
* [API文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)
* [开发者社区](http://bbs.brtbeacon.com)