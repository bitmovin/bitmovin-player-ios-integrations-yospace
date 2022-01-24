Pod::Spec.new do |s|
  s.name             = 'BitmovinYospaceModule'
  s.version          = '1.22.4'
  s.summary          = 'A short description of BitmovinYoSpaceModule.' 
  s.description      = 'A short description of BitmovinYoSpaceModule.'

  s.homepage         = 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cory Zachman' => 'cory.zachman@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace.git', :tag => s.version.to_s }

  s.swift_version = '5'
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.2'

  s.ios.source_files = 'BitmovinYospaceModule/Classes/**/*'
  s.tvos.source_files = 'BitmovinYospaceModule/Classes/**/*'
  s.tvos.exclude_files = 'BitmovinYospaceModule/Classes/BitmovinTruexRenderer.swift'

  # >= 2.64.2 && < 2.66.1 are not supported but there is no good way to encode that in cocoapods
  s.ios.dependency 'BitmovinPlayer', '~>2.60'
  s.ios.dependency 'TruexAdRenderer-iOS', '3.2.1'
  s.tvos.dependency 'BitmovinPlayer', '~>2.60'

  s.ios.vendored_framework = 'lib/ios/Yospace.framework'
  s.tvos.vendored_framework = 'lib/tvOS/Yospace.framework'
  
end
