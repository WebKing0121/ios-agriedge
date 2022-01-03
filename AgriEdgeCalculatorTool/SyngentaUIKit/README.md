# SyngentaUIKit

## Requirements
- cocoapods
- Xcode 11
- macOS 10.14
- Syngenta VPN connection

## Installation

- [install cocoapods](http://guides.cocoapods.org/using/getting-started.html)
- connect to the Syngenta VPN
- add the SyngentaUIKit private cocopods repo to the cocoapods installation by running the command:
    - `pod repo add SyngentaUIKit https://git.syngentaaws.org/digital-product-engineering/ios/frameworks/Syngenta-Podspecs`
        - enter your GitLab user ID when prompted
        - obtain a Personal Access Token from GitLab and use that for the password
- intialize cocoapods in an Xcode project:
    - `pod init`
- add the private pod's source above the targets in the Podfile:
    - `source 'https://git.syngentaaws.org/digital-product-engineering/ios/frameworks/Syngenta-Podspecs'`
- add the pod to your target in the Podfile:
    - `pod 'SyngentaUIKit'`
- install the pod:
    - `pod install`
- open the new .xcworkspace file. import the pod in any class where you need to use it:
    - `import SyngentaUIKit`