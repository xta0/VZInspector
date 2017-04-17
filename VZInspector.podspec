

Pod::Spec.new do |s|

  s.name          = "VZInspector"
  s.version       = "0.1.3"
  s.summary       = "an iOS app runtime debugger"
  s.homepage      = "https://github.com/vizlabxt/VZInspector"
  s.license       = "MIT"
  s.author        = { "vizlabxt" => "jayson.xu@foxmail.com" }
  s.platform      = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source        = { :git => "https://github.com/vizlabxt/VZInspector.git", :tag => "#{s.version}" }
  s.requires_arc  = true
  s.framework     = 'Foundation', 'UIKit', 'CoreGraphics', 'QuartzCore'
  s.source_files  = 'VZInspector/**/*'
  s.libraries     = "z", "c++"
  mrr_files = [
    'VZInspector/toolbox/mermoryProfile/vendor/allocationTrack/NSObject+VZAllocationTracker.mm',
    'VZInspector/toolbox/mermoryProfile/vendor/allocationTrack/VZAllocationTrackerNSZombieSupport.mm',
    'VZInspector/toolbox/mermoryProfile/vendor/Associations/VZAssociationManager.mm',
    'VZInspector/toolbox/mermoryProfile/vendor/Layout/Blocks/VZBlockStrongLayout.m',
    'VZInspector/toolbox/mermoryProfile/vendor/Layout/Blocks/VZBlockStrongRelationDetector.m',
    'VZInspector/toolbox/mermoryProfile/vendor/Layout/Classes/VZClassStrongLayoutHelpers.m'
  ]
  files = Pathname.glob("VZInspector/**/*")
  files = files.map {|file| file.to_path}
  files = files.reject {|file| mrr_files.include?(file)}

  # 解决 cannot create __weak reference in file using manual reference counting
  s.xcconfig = {
    'CLANG_ENABLE_OBJC_WEAK' => 'YES'
  }
  s.requires_arc = files

end
