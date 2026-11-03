# iOS 依赖构建

与 Android 共用仓库根目录的 `extra/ffmpeg`、可选的 `extra/openssl` 和
`config/module.sh`。iOS 脚本会覆盖共享配置中的 JNI/MediaCodec 选项。
需要完整 Xcode 及 iOS SDK。

```bash
# 在仓库根目录执行；OpenSSL 源码存在时会自动编译并启用 HTTPS。
./ios/compile-ffmpeg.sh arm64
```

默认最低系统版本为 iOS 15.0，可通过环境变量调整：

```bash
IOS_DEPLOYMENT_TARGET=16.0 ./ios/compile-ffmpeg.sh arm64
```

- `arm64`：iOS 真机。
- `x86_64`：Intel 模拟器。
- `all`：依次构建上述两个目标，再执行原有的 universal 静态库合并。
- `lipo`：合并已有产物。
- `clean`：删除 iOS 构建输出，不清理共享源码。

单架构库位于 `ios/build/ffmpeg-<架构>/output` 和
`ios/build/openssl-<架构>/output`；原有 Xcode 工程使用的合并库和头文件位于
`ios/build/universal`。Apple Silicon 模拟器 arm64 和 XCFramework 打包尚未提供。

单独编译 OpenSSL 可执行 `./ios/compile-openssl.sh arm64`。
脚本会重新配置共享源码，因此 Android 与 iOS 构建应依次运行，不能同时执行。

## 通过 CocoaPods 运行 Demo

`ios/IJKMediaFramework/IJKMediaFramework.podspec` 提供本地二进制 Pod，Demo 的
`Podfile` 使用 `pod 'IJKMediaFramework', :path => '../IJKMediaFramework'` 引入它。
该配置面向 iPhone 真机；当前打包脚本不包含模拟器 Framework。

首次使用或修改播放器源码后，在仓库根目录执行：

```bash
./ios/compile-ffmpeg.sh arm64
./ios/build-framework.sh
cd ios/IJKMediaDemo
pod install
open IJKMediaDemo.xcworkspace
```

在 Xcode 中选择 `IJKMediaDemo` Scheme 和 iPhone，配置签名后运行。
后续使用 CocoaPods 时打开 `.xcworkspace`，不再直接打开 `.xcodeproj`。
`build-framework.sh` 生成 Release 静态 Framework，并包含当前 FFmpeg/OpenSSL
依赖；只修改 Demo 时无需重新打包播放器。更换依赖配置时需先重新构建 FFmpeg。

`build-framework.sh` 同时更新独立的 `ios/IJKMediaFramework` 分发目录，包含
podspec、Framework、许可证和接入说明。复制整个目录到其他工程后，将 Podfile 的
`:path` 指向复制后的目录，即可本地引入，无需原仓库或源码。
