# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'AgriEdgeCalculatorTool' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  # Pods for AgriEdgeCalculatorTool
  pod 'Moya'
  pod 'ReachabilitySwift'
  pod 'RealmSwift'
  pod 'Pulley'
  pod 'SwiftLint'
  pod 'TPPDF'
  pod 'OktaOidc', '3.5.1'
  pod 'NewRelicAgent', '6.11.0'
  pod 'RMPickerViewController', '2.3.1'
  
  target 'AgriEdgeCalculatorToolTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

