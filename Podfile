platform :ios, '9.0'
use_frameworks!

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

def shared_pods
    pod 'RxSwift', '3.0.0'
    pod 'RxCocoa', '3.0.0'
    pod 'RxAlamofire', '3.0.0'
    pod 'ObjectMapper', '~> 2.1'
    pod 'MagicalRecord', '~> 2.3'
    pod 'AlamofireImage', '~> 3.1'
end

target 'SomaKit' do
    shared_pods
end

target 'SomaKitExample' do
    shared_pods
end
