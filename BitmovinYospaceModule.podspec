Pod::Spec.new do |s|
  s.name             = 'BitmovinYospaceModule'
  s.version          = '1.22.5'
  s.summary          = 'A short description of BitmovinYoSpaceModule.' 
  s.description      = 'A short description of BitmovinYoSpaceModule.'

  s.homepage         = 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cory Zachman' => 'cory.zachman@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace.git', :tag => s.version.to_s }

  s.swift_version = '5.7'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'

  s.ios.source_files = 'BitmovinYospaceModule/Classes/**/*'
  s.tvos.source_files = 'BitmovinYospaceModule/Classes/**/*'
  s.tvos.exclude_files = 'BitmovinYospaceModule/Classes/BitmovinTruexRenderer.swift'

  s.ios.dependency 'BitmovinPlayer', '~>3.21.0'
  s.ios.dependency 'TruexAdRenderer-iOS', '3.2.1'
  s.tvos.dependency 'BitmovinPlayer', '~>3.21.0'

  s.ios.vendored_framework = 'lib/ios/YOAdManagement.framework'
  s.tvos.vendored_framework = 'lib/tvOS/YOAdManagement.framework'
  
end
