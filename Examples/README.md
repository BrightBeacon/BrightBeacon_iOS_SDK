# 独立 Swift / Objective-C Demo

打开 `BrightSDKDemo.xcworkspace`，选择 `BrightSDKSwiftDemo` 或 `BrightSDKOCDemo`。SDK 统一引用 `../BrightSDK.xcframework`，不需要 CocoaPods 或桥接头。

两套工程目录一致：

```
Sources/
  App/                   # AppDelegate；OC 另有 main.m
  Features/
    Home/                # 两种扫描入口
    Scanner/             # ScannerController、BeaconCell
    Integration/         # 集成说明页
  SDK/                   # BrightSDKClient：主要接入代码
Tests/                   # SDK 类型契约与可选 AppKey
UITests/                 # 首页、集成说明和模拟器能力提示
```

- [Swift 接入](SwiftDemo/INTEGRATION.md)
- [OC 接入](ObjectiveCDemo/INTEGRATION.md)
- [SDK 总说明](../README.md)

示例最低 iOS 13。真机在 Signing & Capabilities 中选择自己的 Team。模拟器可以查看页面，不伪造蓝牙设备。

iBeacon 页按指定 UUID 扫描，显示 Major/Minor/RSSI；BLE 页发现 SDK 可识别的广播，点击连接时可选填 AppKey。留空使用默认凭据。BLE “本机标识”不是设备全局 ID。
