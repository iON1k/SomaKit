Pod::Spec.new do |s|
  s.name             = 'SomaKit'
  s.version          = '0.2.1'
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
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Popkov' => 'ion1k88@gmail.com' }
  s.source           = { :git => 'https://github.com/iON1k/SomaKit.git', :tag => s.version.to_s }
  s.requires_arc          = true

  s.ios.deployment_target = '9.0'

  s.source_files = ['SomaKit/Core/**/*', 'SomaKit/Components/**/*', 'SomaKit/SomaKit.h']

  s.public_header_files = 'SomaKit/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift', '~> 3.0.0'
  s.dependency 'RxCocoa', '~> 3.0.0'
  s.dependency 'RxAlamofire', '~> 3.0.0'
  s.dependency 'ObjectMapper', '~> 2.1'
  s.dependency 'MagicalRecord', '~> 2.3'
  s.dependency 'AlamofireImage', '~> 3.1'
end
