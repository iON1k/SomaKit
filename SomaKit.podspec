Pod::Spec.new do |s|
  s.name             = 'SomaKit'
  s.version          = '0.1.0'
  s.summary          = 'SomaKit is a architectural framework for iOS app development'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/iON1k/SomaKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Popkov' => 'ion1k88@gmail.com' }
  s.source           = { :git => 'https://github.com/iON1k/SomaKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = ['SomaKit/Core/**/*', 'SomaKit/Components/**/*']

  # s.resource_bundles = {
  #   'SomaKit' => ['SomaKit/Assets/*.png']
  # }

  s.public_header_files = 'SomaKit/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift', '~> 2.6'
  s.dependency 'RxCocoa', '~> 2.6'
  s.dependency 'RxAlamofire', '~> 2.5'
  s.dependency 'ObjectMapper', '~> 1.4'
  s.dependency 'MagicalRecord', '~> 2.3'
  s.dependency 'AlamofireImage', '~> 2.4'
end
