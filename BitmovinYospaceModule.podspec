Pod::Spec.new do |s|
  s.name             = 'BitmovinYospaceModule'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BitmovinYoSpaceModule.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cory Zachman' => 'cory.zachman@bitmovin.com' }
  s.source           = { :git => 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'BitmovinYospaceModule/Classes/**/*'
  
  s.ios.dependency 'BitmovinPlayer', '~> 2.14.0'
  s.tvos.dependency 'BitmovinPlayer', '~> 2.14.0'

  s.ios.vendored_framework = 'lib/Yospace.framework'
  s.tvos.vendored_framework = 'lib/Yospace-tvOS.framework'
  s.static_framework = true;
  
end
