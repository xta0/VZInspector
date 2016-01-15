

Pod::Spec.new do |s|

  s.name          = "VZInspector"
  s.version       = "0.1.0"
  s.summary       = "an iOS app runtime debugger"
  s.homepage      = "http://vizlabxt.github.io/blog/2014/11/06/VZInspector/"
  s.license       = "MIT"
  s.author        = { "vizlabxt" => "jayson.xu@foxmail.com" }
  s.platform      = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source        = { :git => "https://github.com/vizlabxt/VZInspector.git", :tag => "#{s.version}" }
  s.requires_arc  = true
  s.framework     = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore'
  s.source_files  = 'VZInspector/**/*'
  s.libraries     = "z", "c++"

end
