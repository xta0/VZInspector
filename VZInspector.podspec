

Pod::Spec.new do |s|

  s.name         = "VZInspector"
  s.version      = "0.0.1"
  s.summary      = "an iOS app runtime debugger"
  s.homepage     = "http://akadealloc.github.io/blog/2014/11/06/VZInspector.html"
  s.license      = "MIT"

  
  s.author             = { "akadealloc" => "http://akadealloc.github.io/blog/" }

  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"

  s.source       = { :git => "https://github.com/akaDealloc/VZInspector.git", :tag => "0.1.0" }
  s.requires_arc = true
  s.source_files  = "VZInspector/*"
  #s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.



  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
