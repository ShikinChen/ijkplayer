# IJKMediaFramework 本地 Pod

复制整个 `IJKMediaFramework` 文件夹到应用工程，例如与 Podfile 同级：

```ruby
platform :ios, '15.0'
target 'YourApp' do
  pod 'IJKMediaFramework', :path => './IJKMediaFramework'
end
```

执行 `pod install`，使用生成的 `.xcworkspace` 打开工程。在 Objective-C 中引入：

```objc
#import <IJKMediaFramework/IJKMediaFramework.h>
```

此目录包含静态 Framework 及其所需的 FFmpeg/OpenSSL 库，不需要另行链接它们。
当前仅支持 iPhone 真机 arm64，最低 iOS 15.0，不包含模拟器切片。

维护者在原仓库运行 `./ios/build-framework.sh` 可更新此目录中的二进制及许可证。
