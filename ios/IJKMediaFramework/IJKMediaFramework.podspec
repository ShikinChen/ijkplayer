Pod::Spec.new do |s|
  s.name = 'IJKMediaFramework'
  s.version = '0.8.8'
  s.summary = 'Local ijkplayer iOS framework with FFmpeg and optional OpenSSL.'
  s.homepage = 'https://github.com/ShikinChen/ijkplayer-android'
  s.license = { :type => 'LGPL-2.1-or-later', :file => 'LICENSE.txt' }
  s.author = 'ijkplayer contributors'
  s.source = { :git => 'https://github.com/ShikinChen/ijkplayer-android.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.vendored_frameworks = 'IJKMediaFramework.framework'
  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'AudioToolbox', 'CoreGraphics',
                 'CoreMedia', 'CoreVideo', 'MediaPlayer', 'MobileCoreServices',
                 'OpenGLES', 'QuartzCore', 'VideoToolbox'
  s.libraries = 'c++', 'z', 'bz2'
end
