platform :ios, '15.0'

target 'Flip board -handwritten- (iOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Flip board -handwritten- (iOS)
  pod 'Google-Mobile-Ads-SDK'

end

target 'Flip board -handwritten- (macOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Flip board -handwritten- (macOS)

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'

      if target.name == 'nanopb'
        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
        config.build_settings['VALIDATE_MODULE'] = 'NO'
      end
    end
  end
end
