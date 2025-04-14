Pod::Spec.new do |s|
  s.name             = 'BitmovinYospaceModule'
  s.version          = '2.1.0'
  s.summary          = 'A short description of BitmovinYoSpaceModule.' 
  s.description      = 'A short description of BitmovinYoSpaceModule.'

  s.homepage         = 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Bitmovin, Inc.'
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace.git', :tag => s.version.to_s }

  s.swift_version = '5.7'
  s.ios.deployment_target = '14.0'
  s.tvos.deployment_target = '14.0'

  s.ios.source_files = 'BitmovinYospaceModule/Classes/**/*'
  s.tvos.source_files = 'BitmovinYospaceModule/Classes/**/*'
  s.tvos.exclude_files = 'BitmovinYospaceModule/Classes/BitmovinTruexRenderer.swift'

  s.ios.dependency 'BitmovinPlayerCore', '~>3.86'
  s.ios.dependency 'YOAdManagement-Release', '~>3.8'
  s.ios.dependency 'TruexAdRenderer-iOS', '3.2.1'
  s.tvos.dependency 'BitmovinPlayerCore', '~>3.86'
  s.tvos.dependency 'YOAdManagement-Release', '~>3.8'
end
