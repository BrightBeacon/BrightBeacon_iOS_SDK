# BrightBeacon iOS SDK

智石开发包（BrightSDK）符合苹果的iBeacon协议、Google的eddystone协议，提供了扫描iBeacon、eddystone协议设备、配置BrightBeacon设备参数、模拟iBeacon等API。你可以访问[智石官网（http://www.brtbeacon.com）](http://www.brtbeacon.com)了解更多设备信息。

当前SDK用于  iBeacon 扫描与区域监听、以及BrightBeacon BLE 扫描、设备连接配置。

当前SDK版本：**3.5.3**。本次改为 XCFramework 分平台分发

## 更新日志

- 3.5.3 本次改为 XCFramework 分平台分发
- 3.5.2 默认使用 `CLBeaconIdentityConstraint` 扫描 iBeacon
- 3.5.1 修复默认值设置
- 3.5.0 修复 iOS 13 读取、功率设定
- 3.4.9 修复 `brtBeacons` 等 API
- 3.4.8 分离蓝牙、iBeacon 扫描、区域监听回调 API
- 3.4.7 优化区域监听，请使用 `regionHander:`

## 先运行示例

打开 [`Examples/BrightSDKDemo.xcworkspace`](Examples/BrightSDKDemo.xcworkspace)：

- **BrightSDKSwiftDemo**：独立纯 Swift 工程，无桥接头。
- **BrightSDKOCDemo**：独立纯 Objective-C 工程，无 Swift 依赖。

选择模拟器即可查看界面；真实扫描、连接使用 iPhone，真机签名选择自己的 Team。SDK 最低 iOS 12。

详情见：[http://en.wikipedia.org/wiki/List_of_iOS_devices](http://en.wikipedia.org/wiki/List_of_iOS_devices)

代码按 `App / Features / SDK` 组织。所有 SDK 调用集中在各自的 `Sources/SDK/BrightSDKClient` 中，`AppDelegate` 只负责窗口与首页。两个工程引用同一份 SDK

[Swift 四步接入](Examples/SwiftDemo/INTEGRATION.md) · [OC 四步接入](Examples/ObjectiveCDemo/INTEGRATION.md)

## 如何集成（任选其一）

产物：[`BrightSDK.xcframework`](BrightSDK.xcframework)。包含真机 arm64，以及模拟器 arm64 / x86_64。

### 一、使用手动集成

1. 将整个 `BrightSDK.xcframework` 加入 App Target。
2. 选择 **Do Not Embed**，因为它包含静态库。
3. 删除旧 `libBrightSDK.a` 的链接引用和旧目录搜索配置，避免重复链接。
4. 配置蓝牙权限；使用 iBeacon 时额外配置定位权限。

Swift：

```swift
import BrightSDK
```

Objective-C：

```objc
@import BrightSDK;
```

头文件和模块配置已在 XCFramework 中，不需要 Swift 桥接头。不要单独把真机 `.a` 用到 arm64 模拟器；架构相同不代表平台相同。

### 二、使用CocoaPods集成

当前仓库的 podspec 是 **3.5.3 配置**。直接引用集成本地文件夹：

```ruby
pod 'BrightSDK', :path => '../BrightBeacon_iOS_SDK'
```

或者通过远端 tag 来 CocoaPods 集成：

```ruby
pod 'BrightSDK', '~> 3.5.3'
```

执行 `pod install`，随后打开宿主 App 的 `.xcworkspace`。不要同时手动链接 XCFramework 和通过 Pod 引入同一 SDK。

## 三、配置定位权限

扫描 iBeacon 需要定位权限；扫描和连接 BrightBeacon 蓝牙设备需要蓝牙权限。根据你的功能范围，在 `Info.plist` 中配置：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>用于扫描和连接 BrightBeacon 蓝牙设备</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>用于前台扫描 iBeacon 和展示附近设备</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>用于后台监听 iBeacon 区域并触发进入/离开提醒</string>
```

如需后台区域监听或后台蓝牙扫描，可按需开启：

```xml
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
  <string>bluetooth-central</string>
</array>
```

区域监听最多建议不超过系统限制的 20 个区域。后台唤醒后系统只给应用很短的处理时间，请在 `AppDelegate` 启动阶段完成 `regionHander:` 注册接收通知消息回调类。

## 两种扫描有什么区别

| | iBeacon 扫描 | BLE 扫描 |
| --- | --- | --- |
| 用途 | 扫描已知UUID的任意iBeacon设备 | 扫描BrightBeacon设备蓝牙广播 |
| 结果 | UUID、Major、Minor、RSSI、Accuracy | Major、Minor、RSSI、蓝牙的 MAC地址 |
| 权限 | 蓝牙、定位 | 蓝牙 |
| AppKey | 不需要 | 扫描不需要；连接时可选填 |
| 连接 | 无法建立连接 | 选择支持连接的设备后建立连接 |

**iBeacon 回调对象是 `BRTBeacon`，不是原生 `CLBeacon`。** Swift 应按 `[BRTBeacon]` 解析，错误转换会导致列表为空。

BLE 的“本机标识”是 `CBPeripheral.identifier`，由当前 iPhone 分配，不是设备的全局硬件 ID，也不是 iBeacon UUID。`CBUUID` 则用于服务、特征等标识。[Apple 说明](https://developer.apple.com/documentation/corebluetooth/cbpeer/identifier)

## Objective-C 示例

注册 AppKey：

```objc
#import "BRTBeaconSDK.h"
[BRTBeaconSDK registerApp:DEFAULT_KEY onCompletion:^(BOOL complete, NSError *error) {
    NSLog(@"register: %@ error: %@", complete ? @"YES" : @"NO", error);
}];
```

扫描 iBeacon：

```objc
NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:DEFAULT_UUID];
BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"default"];

[BRTBeaconSDK startRangingBeaconsInRegions:@[region] onCompletion:^(NSArray *beacons, BRTBeaconRegion *region, NSError *error) {
    NSLog(@"beacons: %@", beacons);
}];

[BRTBeaconSDK stopRangingBeacons];
```

扫描 BrightBeacon 蓝牙设备：

```objc
CBUUID *service = [CBUUID UUIDWithString:@"180A"];
[BRTBeaconSDK scanBleServices:@[service] onCompletion:^(NSArray<BRTBeacon *> *beacons, NSError *error) {
    NSLog(@"ble beacons: %@", beacons);
}];

[BRTBeaconSDK stopScan];
```

后台区域监听：

```objc
// AppDelegate didFinishLaunchingWithOptions 中尽早注册 handler
self.handler = [RegionHander new];
[BRTBeaconSDK regionHander:self.handler];

NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:DEFAULT_UUID];
BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"default"];
region.notifyOnEntry = YES;
region.notifyOnExit = YES;
region.notifyEntryStateOnDisplay = YES;

[BRTBeaconSDK startMonitoringForRegions:@[region]];
```



## Swift BLE 扫描：

```swift
BRTBeaconSDK.scanBleServices(nil) { devices, error in
    let beacons = devices as? [BRTBeacon] ?? []
    // 回到主线程更新界面，保存用户选择的 BRTBeacon。
}
BRTBeaconSDK.stopScan()
```

iBeacon 扫描：

```swift
let region = BRTBeaconRegion(
    proximityUUID: UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!,
    identifier: "my.beacon"
)!
BRTBeaconSDK.startRangingBeacons(in: [region]) { devices, region, error in
    let beacons = devices as? [BRTBeacon] ?? []
}
BRTBeaconSDK.stopRangingBeacons()
```

UUID 要与实际 Beacon 配置一致。

连接扫描列表中的 `BRTBeacon`：

```swift
// appKey 为用户输入；空字符串使用 SDK 默认凭据。
BRTBeaconSDK.registerApp(appKey, onCompletion: nil)
beacon.connectToBeacon { connected, error in
    // 根据真实回调显示连接结果。
}
beacon.disconnectBeacon()
```

- 未设置自定义密钥的设备可留空；有密钥的设备填写对应 AppKey。
- 每次连接都设置本次凭据，防止沿用上一台设备的密钥。
- `onCompletion:nil` 表示设置凭据，不增加联网验证前置条件；不是跳过设备鉴权。
- SDK 没有公开广播字段可可靠判断设备是否必须自定义 AppKey，不按名称或型号猜测。

OC 对应调用与完整权限、停止和断开处理见独立示例。用户应在退出扫描页或进入后台时停止前台扫描。

## 相关文档或网站

* [关于后台区域监听（必读）](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/LocationAwarenessPG/RegionMonitoring/RegionMonitoring.html#//apple_ref/doc/uid/TP40009497-CH9-SW1)
* [区域监听回调相关描述](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423570-locationmanager)
* [集成文档](https://github.com/BrightBeacon/BrightBeacon_iOS_SDK)
* [API文档](http://brightbeacon.github.io/BrightBeacon_iOS_SDK)
* [开发者社区](http://bbs.brtbeacon.com)
* [智石官网](http://www.brtbeacon.com)
