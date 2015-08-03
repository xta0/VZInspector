

Pod::Spec.new do |s|

  s.name         = "VZInspector"
  s.version      = "0.0.7"
  s.summary      = "an iOS app runtime debugger"
  s.homepage     = "http://akadealloc.github.io/blog/%E9%9A%8F%E7%AC%94/2014/11/06/VZInspector.html"
  s.license      = "MIT"
  s.author       = { "akadealloc" => "jayson.xu@foxmail.com" }
  s.platform     = :ios, "6.0"
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/akaDealloc/VZInspector.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.framework    = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore'
  s.source_files  = 'VZInspector/**/*'
  s.libraries = "z", "c++"
end
