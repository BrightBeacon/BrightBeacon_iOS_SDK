Pod::Spec.new do |s|
  s.name         = "BrightSDK"
  s.version      = "3.4.7"
  s.summary      = "iOS library for BrightBeacon devices"
  s.homepage     = "http://www.brtbeacon.com"
  s.author       = { "BrightBeacon" => "o2owlkj@163.com" }
  s.platform     = :ios 
  s.source       = { :git => "https://github.com/BrightBeacon/BrightBeacon_iOS_SDK.git", :tag => "3.4.7"}
  s.source_files =  'BrightSDK/**/*.h'
  s.preserve_paths = 'BrightSDK/libBrightSDK.a'
  s.vendored_libraries = 'BrightSDK/libBrightSDK.a'
  s.ios.deployment_target = '6.0'
  s.frameworks = 'UIKit', 'Foundation', 'SystemConfiguration', 'MobileCoreServices', 'CoreLocation', 'CoreBluetooth'
  s.requires_arc = true
  s.xcconfig  =  { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/BrightSDK"',
                   'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/BrightSDK/include"' }
  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2017 BrightBeacon All rights reserved.
      LICENSE
  }
end