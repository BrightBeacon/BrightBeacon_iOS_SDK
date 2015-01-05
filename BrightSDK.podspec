Pod::Spec.new do |s|
  s.name         = "BrightSDK"
  s.version      = "2.0.1"
  s.summary      = "iOS library for Bright iBeacon devices"
  s.homepage     = "http://www.brtbeacon.com"
  s.author       = { "BrightBeacon" => "o2owlkj@163.com" }
  s.platform     = :ios 
  s.source       = { :git => "https://github.com/BrightBeacon/BrightBeacon_iOS_SDK.git", :tag => "2.0.1" }
  s.source_files =  'BrightSDK/**/*.h'
  s.preserve_paths = 'BrightSDK/libBrightSDK.a'
  s.vendored_libraries = 'BrightSDK/libBrightSDK.a'
  s.ios.deployment_target = '6.0'
  s.frameworks = 'UIKit', 'Foundation', 'SystemConfiguration', 'MobileCoreServices', 'CoreLocation', 'AdSupport'
  s.requires_arc = true
  s.xcconfig  =  { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/BrightSDK"',
                   'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/BrightSDK/Headers"' }
  s.license      = {
    :type => 'Copyright',
    :text => <<-LICENSE
      Copyright 2014 智石网络科技 All rights reserved.
      LICENSE
  }
end