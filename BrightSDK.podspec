Pod::Spec.new do |s|
  s.name = 'BrightSDK'
  s.version = '3.5.3'
  s.summary = 'iOS xcframework for BrightBeacon devices'
  s.homepage = 'https://www.brtbeacon.com'
  s.author = { 'BrightBeacon' => 'developer@brtbeacon.com' }
  s.source = {
    :git => 'https://github.com/BrightBeacon/BrightBeacon_iOS_SDK.git',
    :tag => s.version.to_s
  }
  s.ios.deployment_target = '12.0'
  s.cocoapods_version = '>= 1.9'
  s.module_name = 'BrightSDK'
  s.vendored_frameworks = 'BrightSDK.xcframework'
  s.frameworks = 'UIKit', 'Foundation', 'CoreLocation', 'CoreBluetooth', 'Security'
  s.requires_arc = true
  s.license = {
    :type => 'Copyright',
    :text => 'Copyright BrightBeacon. All rights reserved.'
  }
end
