# Objective-C 接入：只看这四步

1. 给 App Target 添加 `BrightSDK.xcframework`，选择 **Do Not Embed**，移除旧 `.a` 链接。
2. 使用 `@import BrightSDK;`，无需 Swift 文件、桥接头或 CocoaPods。
3. 在 Info.plist 添加蓝牙用途说明；使用 iBeacon 扫描时额外添加使用期间定位说明。界面申请权限的示例在 `Sources/Features/Scanner/ScannerController.m`。
4. 阅读 `Sources/SDK/BrightSDKClient.h/.m`：SDK 调用集中在这一组文件；列表直接使用 SDK 的 `BRTBeacon`，无中间设备模型。

## SDK API

BLE 扫描，可选AppKey，用于支持连接配置：

```objc
@import BrightSDK;

[BRTBeaconSDK scanBleServices:nil onCompletion:^(NSArray *devices, NSError *error) {
    // 从真实回调选择 BRTBeacon；更新 UI 要回到主线程。
}];
[BRTBeaconSDK stopScan];
```

iBeacon 扫描，匹配指定 UUID，不支持蓝牙连接：

```objc
NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
BRTBeaconRegion *region = [[BRTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"MyBeaconRegion"];
[BRTBeaconSDK startRangingBeaconsInRegions:@[region] onCompletion:^(NSArray *devices, BRTBeaconRegion *region, NSError *error) {
    // SDK 回调 devices 中为 BRTBeacon（不是原生 CLBeacon），可查看 Major / Minor / RSSI。
}];
[BRTBeaconSDK stopRangingBeacons];
```

连接用户从 BLE 列表选择的 `BRTBeacon`：

```objc
// appKey 是可选输入。空值由 SDK 还原为 DEFAULT_KEY（32 个 0）。
// nil 回调只设置凭据，不增加服务器验证前置条件。
[BRTBeaconSDK registerApp:appKey onCompletion:nil];
[beacon connectToBeaconWithCompletion:^(BOOL connected, NSError *error) {
    // 根据真实 SDK 回调展示连接成功或失败。
}];
[beacon disconnectBeacon];
```

## 默认设备和密钥设备如何共存

- 留空：使用 SDK 默认凭据，适合接受默认凭据的设备。
- 填写：使用设备对应 AppKey，适合已设置自定义密钥的设备。


BLE 列表“本机标识”是 `CBPeripheral.identifier`，由当前 iPhone 分配，不是全局设备 ID。请勿将它当成 iBeacon UUID 或服务/特征的 CBUUID，也不保证跨手机或重置后不变。连接时直接使用扫描回调中的 BRTBeacon 对象。