#
#  Be sure to run `pod spec lint MediaComposition.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|



  s.name         = "MediaComposition"
  s.version      = "0.0.1"
  s.summary      = "A short description of MediaComposition."
  

  s.homepage     = "https://github.com/TintGit/MediaComposition"
 
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "闫明" => "yanming_m@sina.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/TintGit/MediaComposition.git", :branch => 'master' }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "MediaComposition/Core/*.swift"
  s.swift_version = "4.2"
  # s.public_header_files = "Classes/**/*.h"



  # s.resource  = "icon.png"
  s.resources = "MediaComposition/Resource/*.mp4"

  

 s.requires_arc = true


end
