

Pod::Spec.new do |s|

  s.name         = "VZInspector"
  s.version      = "0.0.4"
  s.summary      = "an iOS app runtime debugger"
  s.homepage     = "http://akadealloc.github.io/blog/2014/11/06/VZInspector.html"
  s.license      = "MIT"
 
  s.author       = { "akadealloc" => "jayson.xu@foxmail.com" }

  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"

  s.source       = { :git => "https://github.com/akaDealloc/VZInspector.git", :tag => "0.0.4" }
  s.requires_arc = true
  s.source_files  = "VZInspector/*"

end
