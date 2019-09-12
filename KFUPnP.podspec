#
# Be sure to run `pod lib lint KFUPnP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KFUPnP'
  s.version          = '0.1.1'
  s.summary          = 'A short description of KFUPnP.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/AlbertBoy/KFUPnP'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AlbertBoy' => 'fengsc@328ym.com' }
  s.source           = { :git => 'https://github.com/AlbertBoy/KFUPnP.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KFUPnP/Classes/ARC/**/*'
  
  # s.resource_bundles = {
  #   'KFUPnP' => ['KFUPnP/Assets/*.png']
  # }
  
  s.libraries = 'icucore', 'c++', 'z', 'xml2'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'CocoaAsyncSocket'
  
  s.xcconfig = {'ENABLE_BITCODE' => 'NO',
      'HEADER_SEARCH_PATHS' => '${SDKROOT}/usr/include/libxml2',
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  
  s.subspec 'MRC' do |sp|
      sp.source_files = 'KFUPnP/Classes/MRC/GData/*'
      sp.requires_arc = false
  end
end
