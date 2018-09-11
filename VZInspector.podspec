

Pod::Spec.new do |s|

  s.name          = "VZInspector"
  s.version       = "0.1.7"
  s.summary       = "an iOS app runtime debugger"
  s.homepage      = "https://github.com/xta0/VZInspector"
  s.license       = "MIT"
  s.author        = { "xta0" => "xta0.me@gmail.com" }
  s.platform      = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source        = { :git => "https://github.com/xta0/VZInspector", :tag => "#{s.version}" }
  s.requires_arc  = true
  s.framework     = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore'
  s.source_files  = 'VZInspector/**/*.{h,c,m,mm}'
  s.libraries     = "z", "c++"
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
