#
#  Be sure to run `pod spec lint MediaComposition.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|



  s.name         = "MediaComposition"
  s.version      = "1.0.1"
  s.summary      = "图片合成视频特效 音视频合成"
  s.description  = <<-DESC 
                    MediaComposition 音视频合成
                   DESC
  

  s.homepage     = "https://github.com/TintGit/MediaComposition"
 
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "闫明" => "yanming_m@sina.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/TintGit/MediaComposition.git", :branch => 'master' }

  s.source_files  = 'MediaComposition/Source/*.swift'
  s.swift_version = "4.2"
  s.frameworks = 'AVFoundation'
  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  s.resources = "MediaComposition/Resource/black.mp4", "MediaComposition/Resource/*.png"
  s.static_framework = true
  

 s.requires_arc = true


end
