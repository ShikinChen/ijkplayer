# ijkplayer

## <mark>为了学习 aosp 已经替换 Ubuntu 主开发系统(主要 mac book pro 太贵),脚本适配 Ubuntu 为主,MacOS 尽量适配</mark>

### <mark>有升级到 FFmpeg 7.1 的分支,因为 7.1 的 api 变化有点大,对源码修改比较大,修改后不知道稳定如何,所以单独开一个分支,需要的请自行切换或者拉取</mark>

```shell
git clone https://github.com/ShikinChen/ijkplayer-android --recursive -b ijk0.8.8--ff7.1
```

### 构建环境

- Common
- Mac OS X 14.3/Ubuntu 22.04
- Android
- [NDK r27](https://github.com/android/ndk/wiki/Unsupported-Downloads)
- Android Studio 2023.1.1 Patch 2
- Gradle 7.2
- Xcode 12.5.1
- Python 3.9.x
- [HomeBrew](http://brew.sh)
- ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
- brew install git

### 构建前配置

#### MacOS

```shell
# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm
brew install pyenv
```

配置 pyenv

```shell
#编辑环境变量文件
vim ~/.bash_profile
#追加下面内容
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
eval "$(pyenv init --path)"
```

#### Ubuntu

```shell
# 将Shell的解释器改为dash,执行dpkg-reconfigure dash命令，然后选择no
sudo dpkg-reconfigure dash
sudo apt install -y ninja-build git
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
```

配置 pyenv

```shell
#编辑环境变量文件
vim ~/.bashrc
#追加下面内容
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

#### 安装 python 3.9.19

```shell
pyenv install 3.9.19
```

终端环境变量配置

```shell
# add these lines to your ~/.bash_profile or ~/.profile
# export ANDROID_SDK=<your sdk path>
# export ANDROID_NDK=<your ndk path>

```

### 拉取源码

```shell
git clone https://github.com/ShikinChen/ijkplayer-android --recursive
```

如果拉取部分模块出错,需要重新拉取项目模块

```shell
cd ijkplayer-android
git submodule update --init --remote --recursive --progress
```

#### 如果需要 openssl,执行下面脚本拉取 openssl,后面会自动进行链接到 FFmpeg(可选)

<mark>在 MacOS 的 ndk 27 以下没办法进行 ld 引入 ssl 和 crypto 库,导致在 FFmpeg 编译的检测时候出现错误,而 ndk 27 是没办法编译 armv7a 版本,如果需要编译 armv7a 版本需要在 Ubuntu 进行</mark>

```shell
cd ijkplayer-android
./init-android-openssl.sh
```

### 构建和导入

```shell
cd ijkplayer-android

#编译ffmpeg一定要使用ndk r27
export ANDROID_NDK=NDK r27的路径
#ndk r27已经不支持armeabi-v7a
cd android/contrib
./compile-ffmpeg.sh arm64
```

执行完 compile-ffmpeg.sh arm64 编译完 ffmpeg 的 arm64 静态库后,用 android studio 直接将
ijkplayer-android/android/ijkplayer 导入整个项目,并且在设置修改 Gradle JDK 为
java-17

### 打包

#### 基于 ndk r27 打包 arm64-v8a 版本(项目默认是 ndk r27)

执行之前一样要定义 ANDROID_NDK 环境变量,并且 ffmpeg 已经编译好

```shell
export ANDROID_NDK=NDK r27的路径
```

```shell
cd ijkplayer-android/android/ijkplayer
./gradlew :ijkplayer-java:assembleRelease
```

最后生成的 ijkplayer-java-release.aar 在
ijkplayer-android/android/ijkplayer/ijkplayer-java/build/outputs/aar/目录下

#### 基于 ndk r21 打包 armeabi-v7a 和 arm64-v8a 版本

```shell
export ANDROID_NDK=NDK r21的路径
```

然后修改 ijkplayer-android/android/ijkplayer/ijkplayer-java/build.gradle 的 ndk 和 ndkVersion,如果需要运行
ijkplayer-example 项目也一样修改它的 build.gradle 的 ndk 和 ndkVersion

```gradle
ndk {
    abiFilters 'armeabi-v7a', 'arm64-v8a'
}
```

```gradle
 ndkVersion '21.4.7075529'
```

重新进行 ffmpeg 编译的 armv7a 和 arm64

```shell
cd ijkplayer-android
cd android/contrib
./compile-ffmpeg.sh armv7a
./compile-ffmpeg.sh arm64
```

打包 aar

```shell
cd ../..
cd android/ijkplayer
./gradlew :ijkplayer-java:assembleRelease
```

## iOS 编译和使用

### 环境要求

- macOS、完整 Xcode 和 iOS SDK；先启动 Xcode 完成首次初始化。
- CocoaPods（`pod` 命令可用），可通过 `brew install cocoapods` 安装。
- 默认最低支持 iOS 15.0；当前 CocoaPods 分发包支持 iPhone 真机 arm64，不包含模拟器切片。

Android 与 iOS 共用 `extra/ffmpeg`、可选的 `extra/openssl` 和
`config/module.sh`，请依次构建，不要同时执行两个平台的依赖编译。

### 编译 FFmpeg 和打包 Framework

以下命令在仓库根目录执行：

```shell
# 首次拉取后，初始化 FFmpeg 等子模块
git submodule update --init --recursive

# 可选：需要 HTTPS 时初始化 OpenSSL；已有 extra/openssl 时可跳过
./init-android-openssl.sh

# 第一步：编译 iOS arm64 的 FFmpeg；检测到 OpenSSL 源码时会自动编译并链接
./ios/compile-ffmpeg.sh arm64

# 第二步：编译播放器并生成可直接复制的 CocoaPods 分发目录
./ios/build-framework.sh
```

`init-android-openssl.sh` 虽以 Android 命名，但初始化的 `extra/openssl`
也供 iOS 使用。iOS 构建不需要设置 `ANDROID_NDK`。

`compile-ffmpeg.sh arm64` 只生成依赖静态库，随后执行 `build-framework.sh`
才会生成或更新下面的独立目录：

```text
ios/IJKMediaFramework/
├── IJKMediaFramework.podspec
├── IJKMediaFramework.framework/
├── LICENSE.txt
├── Licenses/
└── README.md
```

FFmpeg 的单架构产物位于 `ios/build/ffmpeg-arm64/output`，合并后的依赖库及头文件
位于 `ios/build/universal`。`build-framework.sh` 将播放器打包为 Release 静态
Framework，并包含当前启用的 FFmpeg/OpenSSL 依赖。

只修改播放器源码时，重新执行 `./ios/build-framework.sh` 即可；修改 FFmpeg、
OpenSSL 或模块配置后，需要先重新执行 `./ios/compile-ffmpeg.sh arm64`。
只修改 Demo 时，无需重新打包播放器。

### 运行 iOS Demo

完成上述打包后，在仓库根目录执行：

```shell
cd ios/IJKMediaDemo
pod install
open IJKMediaDemo.xcworkspace
```

Demo 的 Podfile 已通过本地路径引入播放器：

```ruby
pod 'IJKMediaFramework', :path => '../IJKMediaFramework'
```

在 Xcode 中选择 `IJKMediaDemo` Scheme 和 iPhone 真机，在
Signing & Capabilities 中设置自己的 Team、Bundle Identifier 后运行。
使用 CocoaPods 后应打开 `IJKMediaDemo.xcworkspace`；不要同时单独打开
`IJKMediaPlayer.xcodeproj`，以免产生子工程重复加载冲突。

### 在其他项目中通过 CocoaPods 引入

复制整个 `ios/IJKMediaFramework` 文件夹到目标项目，例如与目标项目的 Podfile 同级。
该文件夹已包含 podspec、二进制和许可证，接入时无需原仓库源码。Podfile 示例：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'IJKMediaFramework', :path => './IJKMediaFramework'
end
```

执行 `pod install`，然后通过生成的 `.xcworkspace` 打开项目。在 Objective-C 中引入：

```objc
#import <IJKMediaFramework/IJKMediaFramework.h>
```

需要复制完整文件夹，单独复制 `.podspec` 不包含播放器二进制。
更多依赖构建选项见 [iOS 构建说明](ios/README.md)。
